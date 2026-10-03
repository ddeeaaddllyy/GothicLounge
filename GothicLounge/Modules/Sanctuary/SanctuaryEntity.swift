import Foundation
struct ArchivedRitual: Identifiable { let id: UUID; let title: String; let skill: Skill }
struct SanctuaryState {
    var name = ""
    var theme: AppTheme = .obsidian
    var haptics = true
    var ambience = true
    var notificationStatus = "Проверяем…"
    var archived: [ArchivedRitual] = []
}
