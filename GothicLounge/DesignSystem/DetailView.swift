import SwiftUI
struct DetailRoute: Identifiable { let id = UUID(); let title: String; let text: String; let icon: String }
struct DetailView: View {
    @Environment(\.gothicPalette) private var palette
    let detail: DetailRoute
    let close: () -> Void
    var body: some View {
        VStack(spacing: 25) {
            Image(systemName: detail.icon).font(.system(size: 48, weight: .ultraLight)).foregroundStyle(palette.gold)
            Text(detail.title).font(Gothic.serif(30)).multilineTextAlignment(.center)
            Text(detail.text).font(.system(size: 15)).foregroundStyle(palette.muted).multilineTextAlignment(.center).lineSpacing(6)
            GoldButton(title: "Продолжить путь", icon: "moon", action: close)
        }.padding(32).frame(maxWidth: .infinity, maxHeight: .infinity).background(palette.background).foregroundStyle(palette.ivory).presentationDetents([.medium]).preferredColorScheme(palette.scheme)
    }
}
