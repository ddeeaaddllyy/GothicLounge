#if DEBUG
import Foundation

extension ShellRouter {
    /// UI tests use an isolated save. Release builds never read these variables.
    static func testRepository() -> RealmRepository? {
        let environment = ProcessInfo.processInfo.environment
        guard let value = environment["NOCTIS_TEST_SESSION"], let session = UUID(uuidString: value) else { return nil }
        let url = FileManager.default.temporaryDirectory.appending(path: "NoctisUITests/\(session.uuidString)/realm.json")
        let exists = FileManager.default.fileExists(atPath: url.path)
        let repository = RealmRepository(url: url)
        if !exists && environment["NOCTIS_TEST_MILESTONE"] == "1" {
            try? repository.update { realm in
                realm.completions = [Completion(ritualID: UUID(), title: "Предыдущие выполнения", skill: .wisdom,
                    reward: Progression.threshold(for: 5) - 10, day: "2020-01-01", date: Date(timeIntervalSince1970: 1_577_836_800))]
            }
        }
        return repository
    }
}
#endif
