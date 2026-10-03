import Foundation
import UserNotifications

@MainActor protocol ReminderServiceProtocol {
    func authorize() async throws -> Bool
    func synchronize(_ rituals: [Ritual]) async throws
    func status() async -> String
}

@MainActor final class ReminderService: ReminderServiceProtocol {
    private let center = UNUserNotificationCenter.current()
    func authorize() async throws -> Bool {
        try await center.requestAuthorization(options: [.alert, .sound, .badge])
    }
    func status() async -> String {
        switch await center.notificationSettings().authorizationStatus {
        case .authorized, .provisional, .ephemeral: return "Разрешены"
        case .denied: return "Выключены в iOS"
        case .notDetermined: return "Ещё не настроены"
        @unknown default: return "Неизвестно"
        }
    }
    func synchronize(_ rituals: [Ritual]) async throws {
        let pending = await center.pendingNotificationRequests()
        center.removePendingNotificationRequests(withIdentifiers: pending.filter { $0.identifier.hasPrefix("ritual.") }.map(\.identifier))
        for ritual in rituals where ritual.reminder && !ritual.archived {
            let content = UNMutableNotificationContent()
            content.title = "Ваш привычку ждёт"
            content.body = "\(ritual.title) · +\(ritual.reward) XP к навыку «\(ritual.skill.title)»"
            content.sound = .default
            let trigger = UNCalendarNotificationTrigger(dateMatching: DateComponents(hour: ritual.hour, minute: ritual.minute), repeats: true)
            try await center.add(UNNotificationRequest(identifier: "ritual.\(ritual.id)", content: content, trigger: trigger))
        }
    }
}
