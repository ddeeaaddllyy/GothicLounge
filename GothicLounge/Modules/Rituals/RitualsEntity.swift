import Foundation
struct RitualRow: Identifiable {
    let id: UUID
    let title: String
    let intention: String
    let skill: Skill
    let reward: String
    let streak: String
    let reminder: String?
    let completed: Bool
}
struct RitualsState {
    var rows: [RitualRow] = []
    var date = ""
    var progress = 0.0
    var summary = ""
    var level = "01"
    var xp = "0 / 200 XP"
    var levelProgress = 0.0
    var streak = "0"
    var total = "0"
    var ambience = true
    var haptics = true
}
