import XCTest
@testable import NoctisDomain

final class ProgressionTests: XCTestCase {
    private var calendar: Calendar {
        var value = Calendar(identifier: .gregorian)
        value.timeZone = TimeZone(secondsFromGMT: 0)!
        return value
    }
    private func date(_ text: String) -> Date { ISO8601DateFormatter().date(from: text)! }
    private func entry(_ day: String, ritual: UUID = UUID(), reward: Int = 20, skill: Skill = .wisdom) -> Completion {
        Completion(ritualID: ritual, title: "Read", skill: skill, reward: reward, day: day, date: date(day + "T12:00:00Z"))
    }
    func testCompletionAwardsExperienceAndUndoRemovesIt() {
        var realm = Realm.initial
        let ritual = realm.rituals[0]
        let now = date("2026-10-03T12:00:00Z")
        XCTAssertTrue(Progression.toggle(ritual, in: &realm, now: now))
        XCTAssertEqual(Progression.xp(realm), ritual.reward)
        XCTAssertFalse(Progression.toggle(ritual, in: &realm, now: now))
        XCTAssertEqual(Progression.xp(realm), 0)
        XCTAssertTrue(realm.completions.isEmpty)
    }
    func testNextDayAwardsAnotherCompletion() {
        var realm = Realm.initial
        let ritual = realm.rituals[0]
        _ = Progression.toggle(ritual, in: &realm, now: date("2026-10-02T12:00:00Z"))
        _ = Progression.toggle(ritual, in: &realm, now: date("2026-10-03T12:00:00Z"))
        XCTAssertEqual(realm.completions.count, 2)
        XCTAssertEqual(Progression.xp(realm), ritual.reward * 2)
    }
    func testStreakAllowsUnfinishedToday() {
        let entries = [entry("2026-10-01"), entry("2026-10-02")]
        XCTAssertEqual(Progression.streak(entries, now: date("2026-10-03T12:00:00Z"), calendar: calendar), 2)
    }
    func testStreakResetsAfterMissedDay() {
        XCTAssertEqual(Progression.streak([entry("2026-10-01")], now: date("2026-10-03T12:00:00Z"), calendar: calendar), 0)
    }
    func testMultipleCompletionsOnOneDayCountOnce() {
        let entries = [entry("2026-10-02"), entry("2026-10-03"), entry("2026-10-03")]
        XCTAssertEqual(Progression.streak(entries, now: date("2026-10-03T12:00:00Z"), calendar: calendar), 2)
    }
    func testRitualStreakDoesNotBorrowAnotherRitual() {
        let id = UUID()
        let entries = [entry("2026-10-01", ritual: id), entry("2026-10-02"), entry("2026-10-03", ritual: id)]
        XCTAssertEqual(Progression.streak(entries, ritualID: id, now: date("2026-10-03T12:00:00Z"), calendar: calendar), 1)
    }
    func testStreakCrossesYearBoundary() {
        XCTAssertEqual(Progression.streak([entry("2025-12-31"), entry("2026-01-01")], now: date("2026-01-01T12:00:00Z"), calendar: calendar), 2)
    }
    func testDayUsesLocalCalendarAcrossDaylightSaving() {
        var local = calendar; local.timeZone = TimeZone(identifier: "America/New_York")!
        let entries = [entry("2026-03-07"), entry("2026-03-08"), entry("2026-03-09")]
        XCTAssertEqual(Progression.streak(entries, now: date("2026-03-09T12:00:00Z"), calendar: local), 3)
        XCTAssertEqual(Progression.day(date("2026-03-09T02:00:00Z"), calendar: local), "2026-03-08")
    }
    func testLevelBoundariesAndSkillIsolation() {
        XCTAssertEqual(Progression.level(199), 1)
        XCTAssertEqual(Progression.level(200), 2)
        XCTAssertEqual(Progression.level(1250), 5)
        var realm = Realm()
        realm.completions = [entry("2026-10-03", reward: 30, skill: .vitality), entry("2026-10-03", reward: 20, skill: .wisdom)]
        XCTAssertEqual(Progression.xp(realm), 50)
        XCTAssertEqual(Progression.xp(realm, skill: .wisdom), 20)
    }
    func testArchivingAndEditingDoNotRewriteEarnedRewards() {
        var realm = Realm.initial
        let ritual = realm.rituals[0]
        _ = Progression.toggle(ritual, in: &realm)
        realm.rituals[0].archived = true
        realm.rituals[0].reward = 50
        realm.rituals[0].skill = .wisdom
        XCTAssertEqual(Progression.xp(realm), ritual.reward)
        XCTAssertEqual(Progression.xp(realm, skill: ritual.skill), ritual.reward)
    }
    func testSnapshotHas28DaysAndNoFabricatedProgress() {
        let snapshot = RealmSnapshot(realm: .initial, now: date("2026-10-03T12:00:00Z"), calendar: calendar)
        XCTAssertEqual(snapshot.calendarDays.count, 28)
        XCTAssertEqual(snapshot.calendarDays.last?.key, "2026-10-03")
        XCTAssertEqual(snapshot.xp, 0)
        XCTAssertEqual(snapshot.level, 1)
        XCTAssertEqual(snapshot.achievements.count, 24)
        XCTAssertFalse(snapshot.achievements.contains { $0.unlocked })
    }
}

final class RepositoryTests: XCTestCase {
    @MainActor func testPersistenceRoundTrip() throws {
        let dir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        defer { try? FileManager.default.removeItem(at: dir) }
        let url = dir.appendingPathComponent("realm.json")
        let first = RealmRepository(url: url)
        try first.update { realm in
            realm.name = "Хранитель"
            let ritual = realm.rituals[0]
            _ = Progression.toggle(ritual, in: &realm)
        }
        let second = RealmRepository(url: url)
        XCTAssertEqual(second.realm.name, "Хранитель")
        XCTAssertEqual(second.realm.completions.count, 1)
        XCTAssertEqual(second.realm.rituals.count, 3)
    }
    @MainActor func testCorruptDataIsNeverOverwritten() throws {
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        defer { try? FileManager.default.removeItem(at: url) }
        let data = Data("invalid json".utf8)
        try data.write(to: url)
        let repository = RealmRepository(url: url)
        XCTAssertNotNil(repository.loadError)
        XCTAssertThrowsError(try repository.update { $0.name = "Overwrite" })
        XCTAssertEqual(try Data(contentsOf: url), data)
    }
    @MainActor func testFailedWriteDoesNotMutateMemory() throws {
        let file = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        defer { try? FileManager.default.removeItem(at: file) }
        try Data("not a directory".utf8).write(to: file)
        let repository = RealmRepository(url: file.appendingPathComponent("realm.json"))
        XCTAssertThrowsError(try repository.update { $0.name = "Changed" })
        XCTAssertEqual(repository.realm.name, "Мой профиль")
    }
}
