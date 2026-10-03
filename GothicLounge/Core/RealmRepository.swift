import Foundation
import Combine

@MainActor protocol RealmRepositoryProtocol: AnyObject {
    var realm: Realm { get }
    var changes: AnyPublisher<Void, Never> { get }
    var loadError: String? { get }
    func update(_ mutation: (inout Realm) -> Void) throws
}

@MainActor final class RealmRepository: RealmRepositoryProtocol {
    private(set) var realm: Realm
    private(set) var loadError: String?
    private let url: URL
    private let subject = PassthroughSubject<Void, Never>()
    var changes: AnyPublisher<Void, Never> { subject.eraseToAnyPublisher() }

    init(url: URL? = nil) {
        self.url = url ?? URL.applicationSupportDirectory.appending(path: "GothicLounge/realm.json")
        do {
            if FileManager.default.fileExists(atPath: self.url.path) {
                realm = try JSONDecoder().decode(Realm.self, from: Data(contentsOf: self.url))
            } else {
                realm = .initial
            }
        } catch {
            realm = Realm()
            loadError = "Не удалось прочитать сохранение. Исходный файл сохранён. Перезапустите приложение или восстановите резервную копию."
        }
    }

    func update(_ mutation: (inout Realm) -> Void) throws {
        guard loadError == nil else { throw CocoaError(.fileReadCorruptFile) }
        var next = realm
        mutation(&next)
        let data = try JSONEncoder().encode(next)
        try FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
        try data.write(to: url, options: .atomic)
        realm = next
        subject.send()
    }
}
