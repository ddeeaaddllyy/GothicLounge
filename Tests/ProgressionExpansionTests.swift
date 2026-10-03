import XCTest
@testable import NoctisDomain

final class ProgressionExpansionTests: XCTestCase {
    private func completion(_ day: String = "2026-10-01", xp: Int = 20, skill: Skill = .wisdom) -> Completion {
        Completion(ritualID: UUID(), title: "Привычка", skill: skill, reward: xp, day: day, date: Date())
    }

    func testEveryLevelRequiresMoreExperience() {
        for level in 1...100 {
            XCTAssertEqual(Progression.requirement(for: level + 1) - Progression.requirement(for: level), 75)
            let threshold = Progression.threshold(for: level)
            XCTAssertEqual(Progression.progress(threshold).level, level)
            XCTAssertEqual(Progression.progress(threshold).earned, 0)
            XCTAssertEqual(Progression.progress(threshold).required, Progression.requirement(for: level))
            if threshold > 0 { XCTAssertEqual(Progression.level(threshold - 1), level - 1) }
        }
        XCTAssertEqual(Progression.progress(200), LevelProgress(level: 2, earned: 0, required: 275))
        XCTAssertEqual(Progression.progress(474), LevelProgress(level: 2, earned: 274, required: 275))
        XCTAssertEqual(Progression.level(475), 3)
        XCTAssertEqual(Progression.threshold(for: 5), 1250)
    }

    func testNegativeExperienceIsClamped() {
        XCTAssertEqual(Progression.progress(-20), LevelProgress(level: 1, earned: 0, required: 200))
    }

    func testMilestoneIsCelebratedOnlyOnceAcrossUndoAndReload() throws {
        var realm = Realm.initial
        realm.completions = [completion(xp: 1240)]
        let habit = realm.rituals[1]
        let result = Progression.record(habit, in: &realm)
        XCTAssertEqual(result?.milestone, 5)
        XCTAssertEqual(result?.level, 5)
        XCTAssertEqual(realm.celebratedMilestone, 5)
        realm = try JSONDecoder().decode(Realm.self, from: JSONEncoder().encode(realm))
        XCTAssertNil(Progression.record(habit, in: &realm))
        XCTAssertEqual(Progression.level(Progression.xp(realm)), 4)
        let repeated = Progression.record(habit, in: &realm)
        XCTAssertTrue(repeated?.leveledUp == true)
        XCTAssertNil(repeated?.milestone)
    }

    func testNonMilestoneLevelDoesNotShowCelebration() {
        var realm = Realm.initial
        realm.completions = [completion(xp: 190)]
        let result = Progression.record(realm.rituals[1], in: &realm)
        XCTAssertEqual(result?.level, 2)
        XCTAssertTrue(result?.leveledUp == true)
        XCTAssertNil(result?.milestone)
        XCTAssertEqual(realm.celebratedMilestone, 0)
    }

    func testLaterMilestoneCanBeCelebrated() {
        var realm = Realm.initial
        realm.celebratedMilestone = 5
        realm.completions = [completion(xp: Progression.threshold(for: 10) - 10)]
        let result = Progression.record(realm.rituals[1], in: &realm)
        XCTAssertEqual(result?.milestone, 10)
    }

    func testEightCharacteristicsHaveIndependentProgress() {
        var realm = Realm()
        realm.completions = Skill.allCases.map { completion(xp: 200, skill: $0) }
        let snapshot = RealmSnapshot(realm: realm)
        XCTAssertEqual(Skill.allCases.count, 8)
        XCTAssertEqual(snapshot.skillProgress.count, 8)
        XCTAssertTrue(snapshot.skillProgress.values.allSatisfy { $0.level == 2 && $0.earned == 0 })
        XCTAssertEqual(snapshot.xp, 1600)
    }

    func testHistoricalStreakAchievementSurvivesMissedDays() {
        var realm = Realm()
        realm.completions = (1...7).map { completion(String(format: "2026-01-%02d", $0)) }
        let later = ISO8601DateFormatter().date(from: "2026-10-03T12:00:00Z")!
        XCTAssertEqual(Progression.streak(realm.completions, now: later), 0)
        XCTAssertEqual(Progression.bestStreak(realm.completions), 7)
        XCTAssertTrue(AchievementCatalog.evaluate(realm).first { $0.id == "streak7" }!.unlocked)
    }

    func testUndoRecalculatesAchievementsRatherThanKeepingUnearnedRewards() {
        var realm = Realm.initial
        let habit = realm.rituals[0]
        _ = Progression.record(habit, in: &realm)
        XCTAssertTrue(AchievementCatalog.evaluate(realm).first { $0.id == "first" }!.unlocked)
        _ = Progression.record(habit, in: &realm)
        XCTAssertFalse(AchievementCatalog.evaluate(realm).first { $0.id == "first" }!.unlocked)
    }

    func testAchievementCatalogHasUniqueIDsAndBoundedProgress() {
        XCTAssertEqual(AchievementCatalog.all.count, 24)
        XCTAssertEqual(Set(AchievementCatalog.all.map(\.id)).count, 24)
        var realm = Realm()
        realm.completions = [completion(xp: 100_000)]
        XCTAssertTrue(AchievementCatalog.evaluate(realm).allSatisfy { (0...1).contains($0.fraction) })
    }

    func testLegacySaveMigratesWithoutLosingHistoryOrXP() throws {
        var realm = Realm.initial
        realm.name = "Анна"
        realm.rituals[0].title = "Пробудить тело"
        realm.rituals[0].intention = "20 минут движения — шаг из тени"
        realm.completions = [completion(xp: 1500)]
        var json = try JSONSerialization.jsonObject(with: JSONEncoder().encode(realm)) as! [String: Any]
        for key in ["schemaVersion", "theme", "celebratedMilestone"] { json.removeValue(forKey: key) }
        let migrated = try JSONDecoder().decode(Realm.self, from: JSONSerialization.data(withJSONObject: json))
        XCTAssertEqual(migrated.name, "Анна")
        XCTAssertEqual(migrated.rituals[0].id, realm.rituals[0].id)
        XCTAssertEqual(migrated.rituals[0].title, "Двигаться 20 минут")
        XCTAssertEqual(migrated.completions[0].id, realm.completions[0].id)
        XCTAssertEqual(Progression.xp(migrated), 1500)
        XCTAssertEqual(migrated.theme, .obsidian)
        XCTAssertEqual(migrated.celebratedMilestone, 5)
        XCTAssertEqual(migrated.schemaVersion, 2)
    }

    @MainActor func testThemePersistsAcrossRepositoryReload() throws {
        let directory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        defer { try? FileManager.default.removeItem(at: directory) }
        let url = directory.appendingPathComponent("realm.json")
        let repository = RealmRepository(url: url)
        for theme in AppTheme.allCases {
            try repository.update { $0.theme = theme }
            XCTAssertEqual(RealmRepository(url: url).realm.theme, theme)
        }
    }

    func testUnknownThemeFallsBackWithoutBreakingSave() throws {
        var json = try JSONSerialization.jsonObject(with: JSONEncoder().encode(Realm.initial)) as! [String: Any]
        json["theme"] = "future-theme"
        let realm = try JSONDecoder().decode(Realm.self, from: JSONSerialization.data(withJSONObject: json))
        XCTAssertEqual(realm.theme, .obsidian)
        XCTAssertEqual(realm.rituals.count, 3)
    }
}
