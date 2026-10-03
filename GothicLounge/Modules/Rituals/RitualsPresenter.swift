import Foundation
import Combine
@MainActor final class RitualsPresenter: ObservableObject, RitualsPresenterInput {
    @Published private(set) var state = RitualsState()
    @Published var error: String?
    @Published private(set) var reward: String?
    @Published private(set) var celebration = 0
    private let interactor: any RitualsInteractorInput
    private let router: any RitualsRouterInput
    private var subscription: AnyCancellable?
    private var rewardTask: Task<Void, Never>?
    init(interactor: any RitualsInteractorInput, router: any RitualsRouterInput) {
        self.interactor = interactor; self.router = router
        subscription = interactor.changes.sink { [weak self] in self?.refresh() }
        refresh()
        error = interactor.loadError
    }
    func refresh() {
        let snapshot = interactor.fetch()
        let realm = snapshot.realm
        let rows = realm.rituals.filter { !$0.archived }.map { ritual in
            RitualRow(id: ritual.id, title: ritual.title, intention: ritual.intention, skill: ritual.skill,
                      reward: "+\(ritual.reward) XP", streak: "\(snapshot.ritualStreaks[ritual.id, default: 0])",
                      reminder: ritual.reminder ? String(format: "%02d:%02d", ritual.hour, ritual.minute) : nil,
                      completed: snapshot.completedToday.contains(ritual.id))
        }
        let done = rows.filter(\.completed).count
        let progress = snapshot.levelProgress
        let formatter = DateFormatter(); formatter.locale = Locale(identifier: "ru_RU"); formatter.dateFormat = "EEEE, d MMMM"
        state = RitualsState(rows: rows, date: formatter.string(from: Date()).uppercased(),
            progress: rows.isEmpty ? 0 : Double(done) / Double(rows.count), summary: "\(done) из \(rows.count) привычек выполнено",
            level: String(format: "%02d", snapshot.level), xp: "\(progress.earned) / \(progress.required) XP", levelProgress: progress.fraction,
            streak: "\(snapshot.streak)", total: "\(realm.completions.count)", ambience: realm.ambience, haptics: realm.haptics)
    }
    func toggle(_ id: UUID) {
        do {
            if let outcome = try interactor.toggle(id) {
                rewardTask?.cancel()
                reward = outcome.leveledUp ? "Новый уровень · \(outcome.level)" : "+\(outcome.reward) XP"
                if let milestone = outcome.milestone { router.showMilestone(milestone) }
                celebration += 1
                rewardTask = Task { [weak self] in
                    try? await Task.sleep(for: .seconds(2.5))
                    guard !Task.isCancelled else { return }
                    self?.reward = nil
                }
            } else { rewardTask?.cancel(); reward = nil }
        } catch { self.error = "Не удалось сохранить выполнение. Попробуйте ещё раз." }
    }
    func create() { router.openEditor(nil) }
    func edit(_ id: UUID) { router.openEditor(interactor.fetch().realm.rituals.first { $0.id == id }) }
    func archive(_ id: UUID) {
        Task {
            do { try await interactor.archive(id) }
            catch { self.error = "Не удалось обновить привычку или её напоминание. Проверьте настройки уведомлений." }
        }
    }
}
