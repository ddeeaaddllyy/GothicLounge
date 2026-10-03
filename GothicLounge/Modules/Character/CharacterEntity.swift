import Foundation
struct SkillState: Identifiable {
    let skill: Skill
    let level: String
    let xp: String
    let progress: Double
    var id: Skill { skill }
}
struct AchievementState: Identifiable {
    let id: String
    let title: String
    let icon: String
    let unlocked: Bool
    let explanation: String
    let progress: Double
    let counter: String
}
enum AchievementFilter: String, CaseIterable, Identifiable {
    case all = "Все", earned = "Получены", remaining = "В процессе"
    var id: String { rawValue }
}
struct CharacterState {
    var name = ""
    var rank = ""
    var level = "1"
    var xp = ""
    var progress = 0.0
    var skills: [SkillState] = []
    var achievements: [AchievementState] = []
    var achievementSummary = ""
    var bestStreak = "0"
    var activeDays = "0"
    var totalXP = "0"
    var totalCompletions = "0"
    var ambience = true
}
