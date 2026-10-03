import Combine
import SwiftUI
@MainActor final class CharacterRouter: ObservableObject, CharacterRouterInput {
    @Published var detail: DetailRoute?
    func closeDetails() { detail = nil }
    func show(title: String, text: String, icon: String) { detail = DetailRoute(title: title, text: text, icon: icon) }
    static func build(repository: any RealmRepositoryProtocol) -> CharacterView {
        let router = CharacterRouter()
        return CharacterView(presenter: CharacterPresenter(interactor: CharacterInteractor(repository: repository), router: router), router: router)
    }
}
