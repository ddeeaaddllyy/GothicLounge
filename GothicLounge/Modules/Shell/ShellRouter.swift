import Combine
import SwiftUI
@MainActor final class ShellRouter: ObservableObject, ShellRouterInput {
    @Published private(set) var tab: RealmTab = .rituals
    let rituals: RitualsView
    let character: CharacterView
    let chronicle: ChronicleView
    let sanctuary: SanctuaryView
    init(repository: any RealmRepositoryProtocol, reminders: any ReminderServiceProtocol) {
        rituals = RitualsRouter.build(repository: repository, reminders: reminders)
        character = CharacterRouter.build(repository: repository)
        chronicle = ChronicleRouter.build(repository: repository)
        sanctuary = SanctuaryRouter.build(repository: repository, reminders: reminders)
    }
    func navigate(to tab: RealmTab) { self.tab = tab }
    @ViewBuilder func destination() -> some View {
        switch tab {
        case .rituals: rituals
        case .character: character
        case .chronicle: chronicle
        case .sanctuary: sanctuary
        }
    }
    static func build() -> ShellView {
        #if DEBUG
        let repository = testRepository() ?? RealmRepository()
        #else
        let repository = RealmRepository()
        #endif
        let reminders = ReminderService()
        let router = ShellRouter(repository: repository, reminders: reminders)
        return ShellView(presenter: ShellPresenter(interactor: ShellInteractor(repository: repository, reminders: reminders), router: router), router: router)
    }
}
