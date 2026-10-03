import SwiftUI
@MainActor final class EditorRouter: EditorRouterInput {
    private let dismiss: () -> Void
    init(dismiss: @escaping () -> Void) { self.dismiss = dismiss }
    func close() { dismiss() }
    static func build(ritual: Ritual?, repository: any RealmRepositoryProtocol, reminders: any ReminderServiceProtocol, dismiss: @escaping () -> Void) -> EditorView {
        let router = EditorRouter(dismiss: dismiss)
        return EditorView(presenter: EditorPresenter(ritual: ritual, interactor: EditorInteractor(repository: repository, reminders: reminders), router: router))
    }
}
