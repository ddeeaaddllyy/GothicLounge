import SwiftUI
struct SanctuaryView: View {
    @Environment(\.gothicPalette) private var palette
    @StateObject var presenter: SanctuaryPresenter
    @Environment(\.scenePhase) private var scenePhase
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                PageHeading(eyebrow: "ПОД ВАШ ВКУС", title: "Настройки", subtitle: "Оформление, напоминания и личные настройки.")
                VStack(alignment: .leading, spacing: 16) {
                    SectionHeading(title: "Тема оформления")
                    Text("Применяется сразу и сохраняется на устройстве.")
                        .font(.system(size: 12)).foregroundStyle(palette.muted)
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                        ForEach(AppTheme.allCases) { theme in
                            Button { presenter.selectTheme(theme) } label: {
                                VStack(alignment: .leading, spacing: 12) {
                                    HStack(spacing: 6) {
                                        Circle().fill(theme.palette.gold).frame(width: 17, height: 17)
                                        Circle().fill(theme.palette.ivory).frame(width: 17, height: 17)
                                        Circle().fill(theme.palette.plum).frame(width: 17, height: 17)
                                        Spacer()
                                        if presenter.state.theme == theme {
                                            Image(systemName: "checkmark.circle.fill").foregroundStyle(theme.palette.gold)
                                        }
                                    }
                                    Text(theme.title).font(Gothic.serif(20)).foregroundStyle(theme.palette.ivory)
                                    Text(theme.subtitle).font(.system(size: 10)).foregroundStyle(theme.palette.muted)
                                        .frame(minHeight: 26, alignment: .topLeading)
                                }.padding(16).background(theme.palette.background, in: RoundedRectangle(cornerRadius: 14))
                                    .overlay(RoundedRectangle(cornerRadius: 14).stroke(presenter.state.theme == theme ? palette.gold : palette.muted.opacity(0.2), lineWidth: presenter.state.theme == theme ? 2 : 1))
                            }.buttonStyle(GothicButtonStyle()).accessibilityIdentifier("theme_\(theme.rawValue)")
                                .accessibilityLabel(theme.title)
                                .accessibilityAddTraits(presenter.state.theme == theme ? .isSelected : [])
                        }
                    }
                }
                VStack(alignment: .leading, spacing: 20) {
                    Label("Имя профиля", systemImage: "person.crop.circle").font(Gothic.serif(22)).foregroundStyle(palette.gold)
                    TextField("Ваше имя", text: $presenter.state.name).font(Gothic.serif(24)).padding(14).background(palette.background, in: RoundedRectangle(cornerRadius: 10))
                    Text("Так вы будете отображаться в профиле.").font(.system(size: 12)).foregroundStyle(palette.muted)
                }.gothicCard()
                VStack(alignment: .leading, spacing: 22) {
                    Text("Анимации и отклик").font(Gothic.serif(22))
                    Toggle("Анимация прогресса", isOn: $presenter.state.ambience)
                    Toggle("Тактильный отклик", isOn: $presenter.state.haptics)
                    Text("Уменьшение движения в настройках iOS отключает декоративные анимации автоматически.").font(.system(size: 12)).foregroundStyle(palette.muted).lineSpacing(3)
                }.font(.system(size: 14)).tint(palette.gold).gothicCard()
                GoldButton(title: "Сохранить настройки", icon: "checkmark", action: presenter.save)
                VStack(alignment: .leading, spacing: 18) {
                    Label("Напоминания", systemImage: "bell").font(Gothic.serif(22))
                    Text(presenter.state.notificationStatus).font(.system(size: 13)).foregroundStyle(palette.gold)
                    Text("Время задаётся отдельно для каждой привычки. Уведомления приходят ежедневно по местному времени.").font(.system(size: 12)).foregroundStyle(palette.muted).lineSpacing(3)
                    Button("Открыть настройки iOS", action: presenter.openSettings).font(.system(size: 14)).foregroundStyle(palette.gold).padding(.vertical, 8)
                    Button(presenter.syncing ? "Обновляем…" : "Обновить расписание", action: presenter.synchronize).font(.system(size: 14)).foregroundStyle(palette.gold).disabled(presenter.syncing).padding(.vertical, 8)
                }.gothicCard()
                if !presenter.state.archived.isEmpty {
                    SectionHeading(title: "Архив привычек")
                    ForEach(presenter.state.archived) { ritual in
                        HStack {
                            Image(systemName: ritual.skill.icon).foregroundStyle(palette.skillColor(ritual.skill))
                            Text(ritual.title).font(Gothic.serif(18))
                            Spacer()
                            Button { presenter.restore(ritual.id) } label: { Image(systemName: "arrow.uturn.backward").frame(width: 44, height: 44) }.foregroundStyle(palette.gold).accessibilityLabel("Восстановить \(ritual.title)")
                        }.gothicCard()
                    }
                }
                VStack(spacing: 12) {
                    Text("N O C T I S").font(Gothic.serif(22)).foregroundStyle(palette.gold)
                    Text("Привычки в вашем ритме").font(Gothic.serif(16)).italic()
                    Text("Данные хранятся только на этом устройстве.\nБез аккаунта и рекламы.").font(.system(size: 11)).foregroundStyle(palette.muted).multilineTextAlignment(.center).lineSpacing(4)
                    Text("GOTHIC LOUNGE · 1.0").font(.system(size: 8)).tracking(2).foregroundStyle(palette.muted)
                }.frame(maxWidth: .infinity).padding(.vertical, 20)
            }.padding(24).frame(maxWidth: 720).frame(maxWidth: .infinity).pageEntrance()
        }.onChange(of: scenePhase) { _, phase in if phase == .active { presenter.refresh() } }
            .alert("Настройки", isPresented: Binding(get: { presenter.message != nil }, set: { if !$0 { presenter.message = nil } })) { Button("Понятно") { presenter.message = nil } } message: { Text(presenter.message ?? "") }
    }
}
