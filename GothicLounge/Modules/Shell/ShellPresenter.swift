import Foundation
import Combine
@MainActor final class ShellPresenter: ObservableObject, ShellPresenterInput {
    @Published var error: String?
    @Published private(set) var theme: AppTheme
    private var subscription: AnyCancellable?
    private let interactor: any ShellInteractorInput
    private let router: any ShellRouterInput
    init(interactor: any ShellInteractorInput, router: any ShellRouterInput) { self.interactor = interactor; self.router = router
        theme = interactor.theme()
        subscription = interactor.changes.sink { [weak self] in self?.theme = interactor.theme() }
    }
    func select(_ tab: RealmTab) { router.navigate(to: tab) }
    func activate() {
        Task { do { try await interactor.activate() } catch { self.error = "Напоминания не удалось обновить. Повторите синхронизацию в настройках." } }
    }
}
