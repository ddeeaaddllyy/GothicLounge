import Foundation
struct RitualDraft {
    var title = ""
    var intention = ""
    var skill: Skill = .discipline
    var reward = 20
    var reminder = false
    var time = Calendar.current.date(from: DateComponents(hour: 9, minute: 0)) ?? Date()
    init(ritual: Ritual?) {
        guard let ritual else { return }
        title = ritual.title; intention = ritual.intention; skill = ritual.skill; reward = ritual.reward; reminder = ritual.reminder
        time = Calendar.current.date(from: DateComponents(hour: ritual.hour, minute: ritual.minute)) ?? Date()
    }
}
