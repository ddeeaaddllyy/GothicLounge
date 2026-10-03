import Combine
@MainActor final class CharacterInteractor: CharacterInteractorInput {
    private let repository: any RealmRepositoryProtocol
    var changes: AnyPublisher<Void, Never> { repository.changes }
    init(repository: any RealmRepositoryProtocol) { self.repository = repository }
    func fetch() -> RealmSnapshot { RealmSnapshot(realm: repository.realm) }
}
