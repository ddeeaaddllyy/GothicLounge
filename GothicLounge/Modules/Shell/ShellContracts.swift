import Foundation
import Combine
@MainActor protocol ShellInteractorInput { var changes: AnyPublisher<Void, Never> { get }; func theme() -> AppTheme; func activate() async throws }
@MainActor protocol ShellPresenterInput: AnyObject { func select(_ tab: RealmTab); func activate() }
@MainActor protocol ShellRouterInput { func navigate(to tab: RealmTab) }
