import SwiftUI

struct MenuView: View {
    var body: some View {
        ScrollView {
            Text("This is our home.")
                .font(Font.largeTitle.bold())
            Text("Take a rest my friend")
                .font(Font.system(size: 20, weight: .semibold))
        }
    }
}

#Preview {
    MenuView()
}
