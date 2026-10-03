import Foundation
import Combine
@MainActor final class SanctuaryPresenter: ObservableObject, SanctuaryPresenterInput {
    @Published var state = SanctuaryState()
    @Published var message: String?
    @Published private(set) var syncing = false
    private let interactor: any SanctuaryInteractorInput
    private let router: any SanctuaryRouterInput
    private var subscription: AnyCancellable?
    private var initialized = false
    init(interactor: any SanctuaryInteractorInput, router: any SanctuaryRouterInput) {
        self.interactor = interactor; self.router = router
        subscription = interactor.changes.sink { [weak self] in self?.refresh() }; refresh()
    }
    func refresh() {
        let realm = interactor.fetch()
        if !initialized {
            state.name = realm.name; state.haptics = realm.haptics; state.ambience = realm.ambience
            initialized = true
        }
        state.theme = realm.theme
        state.archived = realm.rituals.filter(\.archived).map { ArchivedRitual(id: $0.id, title: $0.title, skill: $0.skill) }
        Task { state.notificationStatus = await interactor.notificationStatus() }
    }
    func selectTheme(_ theme: AppTheme) {
        do { try interactor.setTheme(theme) }
        catch { message = "Не удалось сохранить тему. Попробуйте ещё раз." }
    }
    func save() {
        do { try interactor.save(name: state.name, haptics: state.haptics, ambience: state.ambience); message = "Настройки сохранены." }
        catch { message = "Не удалось сохранить настройки. Попробуйте ещё раз." }
    }
    func restore(_ id: UUID) {
        Task { do { try await interactor.restore(id) } catch { message = "Не удалось восстановить привычку или напоминание: \(error.localizedDescription)" } }
    }
    func synchronize() {
        guard !syncing else { return }; syncing = true
        Task {
            defer { syncing = false }
            do { try await interactor.synchronize(); state.notificationStatus = await interactor.notificationStatus(); message = "Расписание обновлено. Статус уведомлений: \(state.notificationStatus.lowercased())." }
            catch { message = "Не удалось обновить напоминания. Попробуйте снова." }
        }
    }
    func openSettings() { router.openSystemSettings() }
}
