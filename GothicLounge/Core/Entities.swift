import Foundation

enum Skill: String, Codable, CaseIterable, Identifiable {
    case vitality, wisdom, discipline, spirit, focus, creativity, balance, communication

    var id: String { rawValue }
    var title: String {
        switch self {
        case .vitality: "Выносливость"
        case .wisdom: "Знания"
        case .discipline: "Дисциплина"
        case .spirit: "Осознанность"
        case .focus: "Концентрация"
        case .creativity: "Творчество"
        case .balance: "Восстановление"
        case .communication: "Общение"
        }
    }
    var icon: String {
        switch self {
        case .vitality: "figure.walk"
        case .wisdom: "book.closed"
        case .discipline: "checkmark.shield"
        case .spirit: "leaf"
        case .focus: "scope"
        case .creativity: "paintbrush.pointed"
        case .balance: "bed.double"
        case .communication: "bubble.left.and.bubble.right"
        }
    }
    var examples: String {
        switch self {
        case .vitality: "Прогулки, тренировки и движение"
        case .wisdom: "Чтение, языки и обучение"
        case .discipline: "Планирование и полезные распорядки"
        case .spirit: "Дневник, дыхание и внимание к себе"
        case .focus: "Работа без отвлечений"
        case .creativity: "Музыка, рисунок и новые идеи"
        case .balance: "Сон, отдых и восстановление"
        case .communication: "Встречи, звонки и новые знакомства"
        }
    }
}

enum AppTheme: String, Codable, CaseIterable, Identifiable {
    case obsidian, graphite, midnight, paper
    var id: String { rawValue }
    var title: String {
        switch self {
        case .obsidian: "Обсидиан"
        case .graphite: "Графит"
        case .midnight: "Полночь"
        case .paper: "Бумага"
        }
    }
    var subtitle: String {
        switch self {
        case .obsidian: "Чёрный и мягкое золото"
        case .graphite: "Серый и серебро"
        case .midnight: "Глубокий синий и лавандовый"
        case .paper: "Светлая и тёплая"
        }
    }
}

struct Ritual: Codable, Identifiable, Equatable {
    var id = UUID()
    var title: String
    var intention: String
    var skill: Skill
    var reward: Int
    var reminder: Bool = false
    var hour: Int = 9
    var minute: Int = 0
    var archived: Bool = false
    var createdAt = Date()
}

struct Completion: Codable, Identifiable {
    var id = UUID()
    let ritualID: UUID
    let title: String
    let skill: Skill
    let reward: Int
    let day: String
    let date: Date
}

struct Realm: Codable {
    var rituals: [Ritual] = []
    var completions: [Completion] = []
    var name = "Мой профиль"
    var haptics = true
    var ambience = true
    var theme: AppTheme = .obsidian
    var celebratedMilestone = 0
    var schemaVersion = 2

    init(rituals: [Ritual] = []) { self.rituals = rituals }

    private enum CodingKeys: String, CodingKey {
        case rituals, completions, name, haptics, ambience, theme, celebratedMilestone, schemaVersion
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        rituals = try values.decode([Ritual].self, forKey: .rituals)
        completions = try values.decode([Completion].self, forKey: .completions)
        name = try values.decodeIfPresent(String.self, forKey: .name) ?? "Мой профиль"
        haptics = try values.decodeIfPresent(Bool.self, forKey: .haptics) ?? true
        ambience = try values.decodeIfPresent(Bool.self, forKey: .ambience) ?? true
        let savedTheme = try values.decodeIfPresent(String.self, forKey: .theme)
        theme = savedTheme.flatMap(AppTheme.init(rawValue:)) ?? .obsidian
        let earnedXP = completions.reduce(0) { $0 + $1.reward }
        celebratedMilestone = try values.decodeIfPresent(Int.self, forKey: .celebratedMilestone)
            ?? (Progression.level(earnedXP) / 5 * 5)
        schemaVersion = 2
        if !values.contains(.schemaVersion) {
            // Only rename untouched starter templates; user-created habits retain their text.
            for index in rituals.indices {
                switch (rituals[index].title, rituals[index].intention) {
                case ("Пробудить тело", "20 минут движения — шаг из тени"):
                    rituals[index].title = "Двигаться 20 минут"
                    rituals[index].intention = "Прогулка или небольшая тренировка"
                case ("Открыть гримуар", "Прочитать 10 страниц книги"):
                    rituals[index].title = "Прочитать 10 страниц"
                    rituals[index].intention = "Книга, которую давно хотелось прочесть"
                case ("Час безмолвия", "10 минут наедине с собой"):
                    rituals[index].title = "Сделать паузу"
                default: break
                }
            }
        }
    }

    static var initial: Realm {
        Realm(rituals: [
            Ritual(title: "Двигаться 20 минут", intention: "Прогулка или небольшая тренировка", skill: .vitality, reward: 30),
            Ritual(title: "Прочитать 10 страниц", intention: "Книга, которую давно хотелось прочесть", skill: .wisdom, reward: 20),
            Ritual(title: "Сделать паузу", intention: "10 минут без спешки и отвлечений", skill: .spirit, reward: 20)
        ])
    }
}

struct LevelProgress: Equatable {
    let level: Int
    let earned: Int
    let required: Int
    var fraction: Double { Double(earned) / Double(required) }
}

struct CompletionOutcome {
    let reward: Int
    let level: Int
    let leveledUp: Bool
    let milestone: Int?
}

enum Progression {
    static func day(_ date: Date, calendar: Calendar = .current) -> String {
        let c = calendar.dateComponents([.year, .month, .day], from: date)
        return String(format: "%04d-%02d-%02d", c.year!, c.month!, c.day!)
    }
    static func xp(_ realm: Realm, skill: Skill? = nil) -> Int {
        realm.completions.filter { skill == nil || $0.skill == skill }.reduce(0) { $0 + $1.reward }
    }
    static func requirement(for level: Int) -> Int { 200 + 75 * (max(level, 1) - 1) }
    static func threshold(for level: Int) -> Int {
        let steps = max(level - 1, 0)
        return 200 * steps + 75 * steps * max(steps - 1, 0) / 2
    }
    static func progress(_ xp: Int) -> LevelProgress {
        var remaining = max(xp, 0)
        var level = 1
        while remaining >= requirement(for: level) {
            remaining -= requirement(for: level)
            level += 1
        }
        return LevelProgress(level: level, earned: remaining, required: requirement(for: level))
    }
    static func level(_ xp: Int) -> Int { progress(xp).level }

    static func bestStreak(_ entries: [Completion], calendar: Calendar = .current) -> Int {
        let keys = Set(entries.map(\.day)).sorted()
        var best = 0
        var current = 0
        var previous: Date?
        for key in keys {
            let parts = key.split(separator: "-").compactMap { Int($0) }
            guard parts.count == 3,
                  let date = calendar.date(from: DateComponents(year: parts[0], month: parts[1], day: parts[2])) else { continue }
            current = previous.flatMap { calendar.dateComponents([.day], from: $0, to: date).day } == 1 ? current + 1 : 1
            best = max(best, current)
            previous = date
        }
        return best
    }

    static func record(_ ritual: Ritual, in realm: inout Realm, now: Date = Date()) -> CompletionOutcome? {
        let previous = level(xp(realm))
        guard toggle(ritual, in: &realm, now: now) else { return nil }
        let next = level(xp(realm))
        let milestone = next / 5 * 5
        let shouldCelebrate = next > previous && milestone >= 5 && milestone > realm.celebratedMilestone
        if shouldCelebrate { realm.celebratedMilestone = milestone }
        return CompletionOutcome(reward: ritual.reward, level: next, leveledUp: next > previous,
                                 milestone: shouldCelebrate ? milestone : nil)
    }
    static func streak(_ entries: [Completion], ritualID: UUID? = nil, now: Date = Date(), calendar: Calendar = .current) -> Int {
        let days = Set(entries.filter { ritualID == nil || $0.ritualID == ritualID }.map(\.day))
        var date = calendar.startOfDay(for: now)
        if !days.contains(day(date, calendar: calendar)) {
            date = calendar.date(byAdding: .day, value: -1, to: date)!
        }
        var count = 0
        while days.contains(day(date, calendar: calendar)) {
            count += 1
            date = calendar.date(byAdding: .day, value: -1, to: date)!
        }
        return count
    }
    static func toggle(_ ritual: Ritual, in realm: inout Realm, now: Date = Date()) -> Bool {
        let today = day(now)
        if let index = realm.completions.firstIndex(where: { $0.ritualID == ritual.id && $0.day == today }) {
            realm.completions.remove(at: index)
            return false
        }
        realm.completions.append(Completion(ritualID: ritual.id, title: ritual.title, skill: ritual.skill, reward: ritual.reward, day: today, date: now))
        return true
    }
}

/// Domain snapshot produced by use cases; presenters only format its values.
struct RealmSnapshot {
    let realm: Realm
    let today: String
    let xp: Int
    let level: Int
    let streak: Int
    let skillXP: [Skill: Int]
    let skillLevels: [Skill: Int]
    let ritualStreaks: [UUID: Int]
    let completedToday: Set<UUID>
    let calendarDays: [ActivityDay]
    let achievements: [AchievementProgress]
    let levelProgress: LevelProgress
    let skillProgress: [Skill: LevelProgress]
    let bestStreak: Int
    let activeDays: Int

    init(realm: Realm, now: Date = Date(), calendar: Calendar = .current) {
        self.realm = realm
        today = Progression.day(now, calendar: calendar)
        xp = Progression.xp(realm)
        level = Progression.level(xp)
        streak = Progression.streak(realm.completions, now: now, calendar: calendar)
        skillXP = Dictionary(uniqueKeysWithValues: Skill.allCases.map { ($0, Progression.xp(realm, skill: $0)) })
        skillLevels = skillXP.mapValues { Progression.level($0) }
        ritualStreaks = Dictionary(uniqueKeysWithValues: realm.rituals.map {
            ($0.id, Progression.streak(realm.completions, ritualID: $0.id, now: now, calendar: calendar))
        })
        completedToday = Set(realm.completions.filter { $0.day == Progression.day(now, calendar: calendar) }.map(\.ritualID))
        calendarDays = (0..<28).reversed().map { offset in
            let date = calendar.date(byAdding: .day, value: -offset, to: now)!
            let key = Progression.day(date, calendar: calendar)
            return ActivityDay(date: date, key: key, count: realm.completions.filter { $0.day == key }.count, isToday: offset == 0)
        }
        levelProgress = Progression.progress(xp)
        skillProgress = skillXP.mapValues { Progression.progress($0) }
        bestStreak = Progression.bestStreak(realm.completions, calendar: calendar)
        activeDays = Set(realm.completions.map(\.day)).count
        achievements = AchievementCatalog.evaluate(realm, calendar: calendar)
    }
}
struct ActivityDay {
    let date: Date
    let key: String
    let count: Int
    let isToday: Bool
}
