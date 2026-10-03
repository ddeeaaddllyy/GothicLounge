import Foundation

enum AchievementRule {
    case completions, streak, level, skills, skillLevel, activeDays, experience
}
struct AchievementDefinition: Identifiable {
    let id: String
    let title: String
    let detail: String
    let icon: String
    let rule: AchievementRule
    let target: Int
}
struct AchievementProgress: Identifiable {
    let definition: AchievementDefinition
    let value: Int
    var id: String { definition.id }
    var unlocked: Bool { value >= definition.target }
    var fraction: Double { min(Double(value) / Double(definition.target), 1) }
}

enum AchievementCatalog {
    static let all: [AchievementDefinition] = [
        .init(id: "first", title: "Первый шаг", detail: "Выполнить первую привычку.", icon: "checkmark", rule: .completions, target: 1),
        .init(id: "done10", title: "Хорошее начало", detail: "Выполнить привычки 10 раз.", icon: "checkmark.circle", rule: .completions, target: 10),
        .init(id: "done50", title: "В своём ритме", detail: "Выполнить привычки 50 раз.", icon: "waveform.path", rule: .completions, target: 50),
        .init(id: "done100", title: "Первая сотня", detail: "Выполнить привычки 100 раз.", icon: "star", rule: .completions, target: 100),
        .init(id: "done250", title: "Надёжный ритм", detail: "Выполнить привычки 250 раз.", icon: "checkmark.seal", rule: .completions, target: 250),
        .init(id: "done500", title: "Большая работа", detail: "Выполнить привычки 500 раз.", icon: "trophy", rule: .completions, target: 500),
        .init(id: "streak3", title: "Три дня подряд", detail: "Выполнять хотя бы одну привычку 3 дня подряд.", icon: "flame", rule: .streak, target: 3),
        .init(id: "streak7", title: "Целая неделя", detail: "Достичь серии в 7 дней.", icon: "calendar", rule: .streak, target: 7),
        .init(id: "streak14", title: "Две недели", detail: "Достичь серии в 14 дней.", icon: "calendar.badge.checkmark", rule: .streak, target: 14),
        .init(id: "streak30", title: "Месяц подряд", detail: "Достичь серии в 30 дней.", icon: "flame.fill", rule: .streak, target: 30),
        .init(id: "streak60", title: "Два месяца", detail: "Достичь серии в 60 дней.", icon: "sun.max", rule: .streak, target: 60),
        .init(id: "streak100", title: "Сто дней", detail: "Достичь серии в 100 дней.", icon: "medal", rule: .streak, target: 100),
        .init(id: "level5", title: "Уровень 5", detail: "Достичь общего уровня 5.", icon: "star.circle", rule: .level, target: 5),
        .init(id: "level10", title: "Уровень 10", detail: "Достичь общего уровня 10.", icon: "star.circle.fill", rule: .level, target: 10),
        .init(id: "level20", title: "Уровень 20", detail: "Достичь общего уровня 20.", icon: "crown", rule: .level, target: 20),
        .init(id: "level30", title: "Уровень 30", detail: "Достичь общего уровня 30.", icon: "crown.fill", rule: .level, target: 30),
        .init(id: "level50", title: "Уровень 50", detail: "Достичь общего уровня 50.", icon: "trophy.fill", rule: .level, target: 50),
        .init(id: "skills2", title: "Два направления", detail: "Получить опыт в 2 характеристиках.", icon: "square.grid.2x2", rule: .skills, target: 2),
        .init(id: "skills4", title: "Разносторонность", detail: "Получить опыт в 4 характеристиках.", icon: "square.grid.2x2.fill", rule: .skills, target: 4),
        .init(id: "skills8", title: "Все грани", detail: "Получить опыт во всех 8 характеристиках.", icon: "circle.grid.3x3", rule: .skills, target: 8),
        .init(id: "specialist", title: "Своя сильная сторона", detail: "Развить любую характеристику до уровня 5.", icon: "scope", rule: .skillLevel, target: 5),
        .init(id: "days30", title: "30 активных дней", detail: "Заниматься в течение 30 дней. Не обязательно подряд.", icon: "calendar.circle", rule: .activeDays, target: 30),
        .init(id: "xp1000", title: "Тысяча опыта", detail: "Накопить 1 000 XP.", icon: "bolt", rule: .experience, target: 1000),
        .init(id: "xp10000", title: "Десять тысяч", detail: "Накопить 10 000 XP.", icon: "bolt.fill", rule: .experience, target: 10000)
    ]

    static func evaluate(_ realm: Realm, calendar: Calendar = .current) -> [AchievementProgress] {
        let xp = Progression.xp(realm)
        let best = Progression.bestStreak(realm.completions, calendar: calendar)
        let skills = Set(realm.completions.map(\.skill)).count
        let active = Set(realm.completions.map(\.day)).count
        let skillLevel = Skill.allCases.map { Progression.level(Progression.xp(realm, skill: $0)) }.max() ?? 1
        return all.map { definition in
            let value: Int
            switch definition.rule {
            case .completions: value = realm.completions.count
            case .streak: value = best
            case .level: value = Progression.level(xp)
            case .skills: value = skills
            case .skillLevel: value = skillLevel
            case .activeDays: value = active
            case .experience: value = xp
            }
            return AchievementProgress(definition: definition, value: value)
        }
    }
}
