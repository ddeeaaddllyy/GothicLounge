import Foundation
import Combine
@MainActor protocol RitualsInteractorInput {
    var changes: AnyPublisher<Void, Never> { get }
    func fetch() -> RealmSnapshot
    func toggle(_ id: UUID) throws -> CompletionOutcome?
    func archive(_ id: UUID) async throws
    var loadError: String? { get }
}
@MainActor protocol RitualsPresenterInput: AnyObject {
    func refresh()
    func toggle(_ id: UUID)
    func create()
    func edit(_ id: UUID)
    func archive(_ id: UUID)
}
@MainActor protocol RitualsRouterInput {
    func openEditor(_ ritual: Ritual?)
    func showMilestone(_ level: Int)
}
