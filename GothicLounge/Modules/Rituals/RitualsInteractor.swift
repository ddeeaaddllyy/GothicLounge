import Foundation
import Combine
@MainActor final class RitualsInteractor: RitualsInteractorInput {
    private let repository: any RealmRepositoryProtocol
    private let reminders: any ReminderServiceProtocol
    var changes: AnyPublisher<Void, Never> { repository.changes }
    var loadError: String? { repository.loadError }
    init(repository: any RealmRepositoryProtocol, reminders: any ReminderServiceProtocol) {
        self.repository = repository; self.reminders = reminders
    }
    func fetch() -> RealmSnapshot { RealmSnapshot(realm: repository.realm) }
    func toggle(_ id: UUID) throws -> CompletionOutcome? {
        guard let ritual = repository.realm.rituals.first(where: { $0.id == id && !$0.archived }) else { return nil }
        var outcome: CompletionOutcome?
        try repository.update { outcome = Progression.record(ritual, in: &$0) }
        return outcome
    }
    func archive(_ id: UUID) async throws {
        try repository.update { realm in
            if let index = realm.rituals.firstIndex(where: { $0.id == id }) { realm.rituals[index].archived = true }
        }
        try await reminders.synchronize(repository.realm.rituals)
    }
}
