import SwiftUI
import UIKit
@MainActor final class SanctuaryRouter: SanctuaryRouterInput {
    func openSystemSettings() { if let url = URL(string: UIApplication.openSettingsURLString) { UIApplication.shared.open(url) } }
    static func build(repository: any RealmRepositoryProtocol, reminders: any ReminderServiceProtocol) -> SanctuaryView {
        SanctuaryView(presenter: SanctuaryPresenter(interactor: SanctuaryInteractor(repository: repository, reminders: reminders), router: SanctuaryRouter()))
    }
}
