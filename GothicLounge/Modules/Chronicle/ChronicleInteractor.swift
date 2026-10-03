import Combine
@MainActor final class ChronicleInteractor: ChronicleInteractorInput {
    private let repository: any RealmRepositoryProtocol
    var changes: AnyPublisher<Void, Never> { repository.changes }
    init(repository: any RealmRepositoryProtocol) { self.repository = repository }
    func fetch() -> RealmSnapshot { RealmSnapshot(realm: repository.realm) }
}
