import SwiftUI

struct AppView: View {
    init() {
        UITabBar.appearance().isHidden = true
    }
    
    @State var selectTabView = "menu"
    let items: [(key: String, icon: String)] = [
        ("Menu", "house"),
        ("News (!!)", "newspaper"),
        ("Bag", "timelapse"),
        ("Account", "person")
    ]
    
    var body: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $selectTabView) {
                MenuView()
                    .tag("Menu")
                Text("News")
                    .tag("News (!!)")
                Text("Shopping cart")
                    .tag("Bag")
                Text("Account")
                    .tag("Account")
            }
            
            HStack {
                ForEach(items, id: \.key) { tab in
                    TabBarItem(
                        selectTabView: tab.key,
                        selectAvatar: tab.icon,
                        selected: $selectTabView
                    )
                }
                
            }
            .padding(.top, 15)
            .frame(maxWidth: .infinity)
            .background(.gray)
        }

    }
}

#Preview {
    AppView()
}
