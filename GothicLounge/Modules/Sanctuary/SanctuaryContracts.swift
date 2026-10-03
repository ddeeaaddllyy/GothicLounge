import Foundation
import Combine
@MainActor protocol SanctuaryInteractorInput {
    var changes: AnyPublisher<Void, Never> { get }
    func fetch() -> Realm
    func save(name: String, haptics: Bool, ambience: Bool) throws
    func setTheme(_ theme: AppTheme) throws
    func restore(_ id: UUID) async throws
    func synchronize() async throws
    func notificationStatus() async -> String
}
@MainActor protocol SanctuaryPresenterInput: AnyObject { func refresh(); func save(); func restore(_ id: UUID); func synchronize() }
@MainActor protocol SanctuaryRouterInput { func openSystemSettings() }
