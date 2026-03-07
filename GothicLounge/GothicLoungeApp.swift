import SwiftUI

@main
struct GothicLoungeApp: App {
    @State var isPresented: Bool = false
    var body: some Scene {
        WindowGroup {
            ContentView()
            AppView()
        }
    }
}
