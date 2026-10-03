import Combine
@MainActor protocol ChronicleInteractorInput {
    var changes: AnyPublisher<Void, Never> { get }
    func fetch() -> RealmSnapshot
}
@MainActor protocol ChroniclePresenterInput: AnyObject { func refresh() }
@MainActor protocol ChronicleRouterInput { func closeDetails(); func show(title: String, text: String, icon: String) }
