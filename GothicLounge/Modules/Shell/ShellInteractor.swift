import Foundation
import Combine
@MainActor final class ShellInteractor: ShellInteractorInput {
    private let repository: any RealmRepositoryProtocol
    private let reminders: any ReminderServiceProtocol
    init(repository: any RealmRepositoryProtocol, reminders: any ReminderServiceProtocol) { self.repository = repository; self.reminders = reminders }
    var changes: AnyPublisher<Void, Never> { repository.changes }
    func theme() -> AppTheme { repository.realm.theme }
    func activate() async throws {
        guard repository.loadError == nil else { return }
        try await reminders.synchronize(repository.realm.rituals)
    }
}
