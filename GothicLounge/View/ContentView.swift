import SwiftUI
import UIKit

struct ContentView: View {
    @State private var name: String = ""
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Welcome home ^^")
            TextField("Enter name", text: $name)
                .textFieldStyle(.roundedBorder)
            
            Button("Apply") {
                print(name)
            }
        }
    }
    
}

#Preview {
    @Previewable @State var previewIsOn = false
    ContentView()
}
