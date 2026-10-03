import Foundation
@MainActor protocol EditorInteractorInput { func save(_ draft: RitualDraft, existing: Ritual?) async throws -> String? }
@MainActor protocol EditorPresenterInput: AnyObject { func save(); func cancel() }
@MainActor protocol EditorRouterInput { func close() }
enum RitualValidationError: LocalizedError {
    case emptyTitle, limit
    var errorDescription: String? {
        switch self {
        case .emptyTitle: "Название должно содержать от 1 до 60 символов."
        case .limit: "Можно иметь до 50 активных привычек. Перенесите ненужные привычки в архив."
        }
    }
}
