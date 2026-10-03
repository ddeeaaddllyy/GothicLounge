import SwiftUI
struct ShellView: View {
    private var palette: ThemePalette { presenter.theme.palette }
    @StateObject var presenter: ShellPresenter
    @ObservedObject var router: ShellRouter
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.scenePhase) private var scenePhase
    @Namespace private var selection
    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                router.destination().id(router.tab).transition(.opacity)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .clipped()
            HStack(spacing: 0) {
                ForEach(RealmTab.allCases) { tab in
                    Button {
                        withAnimation(reduceMotion ? nil : .easeInOut(duration: 0.25)) { presenter.select(tab) }
                    } label: {
                        VStack(spacing: 7) {
                            ZStack {
                                if router.tab == tab { Capsule().fill(palette.gold.opacity(0.12)).matchedGeometryEffect(id: "selected", in: selection) }
                                Image(systemName: tab.icon).font(.system(size: 21, weight: .light)).frame(height: 32)
                            }.frame(width: 55, height: 32)
                            Text(tab.title).font(.system(size: 10))
                        }.foregroundStyle(router.tab == tab ? palette.gold : palette.muted).frame(maxWidth: .infinity).padding(.vertical, 11).contentShape(Rectangle())
                    }.buttonStyle(GothicButtonStyle()).accessibilityAddTraits(router.tab == tab ? .isSelected : []).accessibilityIdentifier("tab_\(tab.rawValue)")
                }
            }.padding(.horizontal, 12).background(palette.background)
                .overlay(alignment: .top) { Rectangle().fill(palette.gold.opacity(0.16)).frame(height: 1) }
        }
        .background(palette.background.ignoresSafeArea())
        .foregroundStyle(palette.ivory)
        .environment(\.gothicPalette, palette)
        .preferredColorScheme(palette.scheme).tint(palette.gold)
        .animation(reduceMotion ? nil : .easeInOut(duration: 0.3), value: presenter.theme)
        .task { presenter.activate() }
        .onChange(of: scenePhase) { _, phase in if phase == .active { presenter.activate() } }
        .alert("Напоминания", isPresented: Binding(get: { presenter.error != nil }, set: { if !$0 { presenter.error = nil } })) { Button("Понятно") { presenter.error = nil } } message: { Text(presenter.error ?? "") }
    }
}
