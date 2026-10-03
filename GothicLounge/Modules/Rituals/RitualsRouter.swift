import Combine
import SwiftUI
struct MilestoneRoute: Identifiable { let level: Int; var id: Int { level } }
struct EditorRoute: Identifiable { let id = UUID(); let ritual: Ritual? }
@MainActor final class RitualsRouter: ObservableObject, RitualsRouterInput {
    @Published var editor: EditorRoute?
    @Published var milestone: MilestoneRoute?
    func showMilestone(_ level: Int) { milestone = MilestoneRoute(level: level) }
    func closeMilestone() { milestone = nil }
    private let repository: any RealmRepositoryProtocol
    private let reminders: any ReminderServiceProtocol
    init(repository: any RealmRepositoryProtocol, reminders: any ReminderServiceProtocol) {
        self.repository = repository; self.reminders = reminders
    }
    func openEditor(_ ritual: Ritual?) { editor = EditorRoute(ritual: ritual) }
    func destination(_ route: EditorRoute) -> EditorView {
        EditorRouter.build(ritual: route.ritual, repository: repository, reminders: reminders) { [weak self] in self?.editor = nil }
    }
    static func build(repository: any RealmRepositoryProtocol, reminders: any ReminderServiceProtocol) -> RitualsView {
        let router = RitualsRouter(repository: repository, reminders: reminders)
        let interactor = RitualsInteractor(repository: repository, reminders: reminders)
        return RitualsView(presenter: RitualsPresenter(interactor: interactor, router: router), router: router)
    }
}
