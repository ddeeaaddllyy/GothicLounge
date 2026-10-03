import Combine
import SwiftUI
@MainActor final class ChronicleRouter: ObservableObject, ChronicleRouterInput {
    @Published var detail: DetailRoute?
    func closeDetails() { detail = nil }
    func show(title: String, text: String, icon: String) { detail = DetailRoute(title: title, text: text, icon: icon) }
    static func build(repository: any RealmRepositoryProtocol) -> ChronicleView {
        let router = ChronicleRouter()
        return ChronicleView(presenter: ChroniclePresenter(interactor: ChronicleInteractor(repository: repository), router: router), router: router)
    }
}
