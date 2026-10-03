import Foundation
import Combine
@MainActor final class EditorPresenter: ObservableObject, EditorPresenterInput {
    @Published var draft: RitualDraft
    @Published var message: String?
    @Published private(set) var saving = false
    private var saved = false
    let heading: String
    private let existing: Ritual?
    private let interactor: any EditorInteractorInput
    private let router: any EditorRouterInput
    init(ritual: Ritual?, interactor: any EditorInteractorInput, router: any EditorRouterInput) {
        existing = ritual; draft = RitualDraft(ritual: ritual); heading = ritual == nil ? "Новая привычка" : "Изменить привычку"
        self.interactor = interactor; self.router = router
    }
    func save() {
        guard !saving else { return }; saving = true
        Task {
            defer { saving = false }
            do {
                let warning = try await interactor.save(draft, existing: existing)
                saved = true
                if let warning { message = warning } else { router.close() }
            } catch { message = error.localizedDescription }
        }
    }
    func acknowledge() { message = nil; if saved { router.close() } }
    func cancel() { guard !saving else { return }; router.close() }
}
