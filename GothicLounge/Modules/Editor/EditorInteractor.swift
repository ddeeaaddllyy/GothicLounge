import Foundation
@MainActor final class EditorInteractor: EditorInteractorInput {
    private let repository: any RealmRepositoryProtocol
    private let reminders: any ReminderServiceProtocol
    init(repository: any RealmRepositoryProtocol, reminders: any ReminderServiceProtocol) { self.repository = repository; self.reminders = reminders }
    func save(_ draft: RitualDraft, existing: Ritual?) async throws -> String? {
        let title = draft.title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !title.isEmpty, title.count <= 60 else { throw RitualValidationError.emptyTitle }
        guard existing != nil || repository.realm.rituals.filter({ !$0.archived }).count < 50 else { throw RitualValidationError.limit }
        var ritual = existing ?? Ritual(title: title, intention: "", skill: draft.skill, reward: draft.reward)
        ritual.title = title; ritual.intention = String(draft.intention.prefix(140)); ritual.skill = draft.skill
        ritual.reward = [10, 20, 30, 50].contains(draft.reward) ? draft.reward : 20
        let time = Calendar.current.dateComponents([.hour, .minute], from: draft.time)
        ritual.hour = time.hour ?? 9; ritual.minute = time.minute ?? 0
        var warning: String?
        ritual.reminder = draft.reminder
        if draft.reminder {
            let allowed = try await reminders.authorize()
            if !allowed { ritual.reminder = false; warning = "Привычка сохранена без напоминания. Разрешите уведомления в настройках iOS, затем включите напоминание снова." }
        }
        try repository.update { realm in
            if let index = realm.rituals.firstIndex(where: { $0.id == ritual.id }) { realm.rituals[index] = ritual }
            else { realm.rituals.append(ritual) }
        }
        do { try await reminders.synchronize(repository.realm.rituals) }
        catch { warning = "Привычка сохранена, но напоминания не удалось обновить. Повторите синхронизацию в настройках." }
        return warning
    }
}
