import Combine
@MainActor protocol CharacterInteractorInput {
    var changes: AnyPublisher<Void, Never> { get }
    func fetch() -> RealmSnapshot
}
@MainActor protocol CharacterPresenterInput: AnyObject { func refresh() }
@MainActor protocol CharacterRouterInput { func closeDetails(); func show(title: String, text: String, icon: String) }
