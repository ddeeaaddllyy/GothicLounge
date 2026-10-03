import Foundation
enum RealmTab: String, CaseIterable, Identifiable {
    case rituals, character, chronicle, sanctuary
    var id: String { rawValue }
    var title: String { switch self { case .rituals: "Привычки"; case .character: "Профиль"; case .chronicle: "История"; case .sanctuary: "Настройки" } }
    var icon: String { switch self { case .rituals: "checklist"; case .character: "person.crop.circle"; case .chronicle: "book.closed"; case .sanctuary: "slider.horizontal.3" } }
}
