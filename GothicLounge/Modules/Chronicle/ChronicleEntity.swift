import Foundation
struct DayState: Identifiable {
    let id: String
    let label: String
    let count: Int
    let today: Bool
}
struct ChronicleEntry: Identifiable {
    let id: UUID
    let title: String
    let date: String
    let reward: String
    let skill: Skill
}
struct ChronicleState {
    var days: [DayState] = []
    var entries: [ChronicleEntry] = []
    var total = "0"
    var streak = "0"
    var xp = "0"
    var period = ""
}
