import Foundation
import Combine
@MainActor final class SanctuaryInteractor: SanctuaryInteractorInput {
    private let repository: any RealmRepositoryProtocol
    private let reminders: any ReminderServiceProtocol
    var changes: AnyPublisher<Void, Never> { repository.changes }
    init(repository: any RealmRepositoryProtocol, reminders: any ReminderServiceProtocol) { self.repository = repository; self.reminders = reminders }
    func fetch() -> Realm { repository.realm }
    func save(name: String, haptics: Bool, ambience: Bool) throws {
        let name = String(name.trimmingCharacters(in: .whitespacesAndNewlines).prefix(30))
        try repository.update { $0.name = name.isEmpty ? "Мой профиль" : name; $0.haptics = haptics; $0.ambience = ambience }
    }
    func setTheme(_ theme: AppTheme) throws { try repository.update { $0.theme = theme } }
    func restore(_ id: UUID) async throws {
        guard repository.realm.rituals.filter({ !$0.archived }).count < 50 else { throw RitualValidationError.limit }
        try repository.update { realm in
            if let index = realm.rituals.firstIndex(where: { $0.id == id }) { realm.rituals[index].archived = false }
        }
        try await reminders.synchronize(repository.realm.rituals)
    }
    func synchronize() async throws { try await reminders.synchronize(repository.realm.rituals) }
    func notificationStatus() async -> String { await reminders.status() }
}
