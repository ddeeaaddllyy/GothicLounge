import Foundation
import Combine
@MainActor final class ChroniclePresenter: ObservableObject, ChroniclePresenterInput {
    @Published private(set) var state = ChronicleState()
    private let interactor: any ChronicleInteractorInput
    private let router: any ChronicleRouterInput
    private var subscription: AnyCancellable?
    init(interactor: any ChronicleInteractorInput, router: any ChronicleRouterInput) {
        self.interactor = interactor; self.router = router
        subscription = interactor.changes.sink { [weak self] in self?.refresh() }; refresh()
    }
    func refresh() {
        let snapshot = interactor.fetch(); let realm = snapshot.realm; let calendar = Calendar.current
        let formatter = DateFormatter(); formatter.locale = Locale(identifier: "ru_RU"); formatter.dateFormat = "d MMM · HH:mm"
        let days = snapshot.calendarDays.map { day in
            DayState(id: day.key, label: "\(calendar.component(.day, from: day.date))", count: day.count, today: day.isToday)
        }
        state = ChronicleState(days: days, entries: realm.completions.sorted { $0.date > $1.date }.map {
            ChronicleEntry(id: $0.id, title: $0.title, date: formatter.string(from: $0.date), reward: "+\($0.reward) XP", skill: $0.skill)
        }, total: "\(realm.completions.count)", streak: "\(snapshot.streak)", xp: "\(snapshot.xp)", period: "ПОСЛЕДНИЕ 28 ДНЕЙ")
    }
    func select(_ day: DayState) { router.show(title: day.id, text: "Привычек выполнено: \(day.count).\n\nСерия растёт, когда вы завершаете хотя бы одну привычку в день. Сегодняшний день можно завершить до полуночи.", icon: day.count > 0 ? "flame" : "moon") }
}
