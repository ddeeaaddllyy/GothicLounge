import Combine
import SwiftUI
struct RitualsView: View {
    @Environment(\.gothicPalette) private var palette
    @StateObject var presenter: RitualsPresenter
    @ObservedObject var router: RitualsRouter
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.scenePhase) private var scenePhase
    @State private var archiveID: UUID?
    @State private var showArchiveConfirmation = false
    private let midnightRefresh = Timer.publish(every: 60, on: .main, in: .common).autoconnect()
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                HStack {
                    Text("NOCTIS").font(Gothic.serif(18)).tracking(6)
                    Spacer()
                    Image(systemName: "moon.phase.waning.crescent").foregroundStyle(palette.gold)
                    Text("HABIT TRACKER").font(.system(size: 8)).tracking(2).foregroundStyle(palette.muted)
                }.padding(.top, 12)
                PageHeading(eyebrow: presenter.state.date, title: "Сегодня", subtitle: "Привычки, которым хочется уделить время.")
                hero
                HStack(spacing: 12) {
                    stat(icon: "flame", value: presenter.state.streak, label: "ДНЕЙ В СЕРИИ")
                    stat(icon: "seal", value: presenter.state.total, label: "ВЫПОЛНЕНИЙ")
                }
                HStack {
                    SectionHeading(title: "Мои привычки")
                    Button(action: presenter.create) { Image(systemName: "plus").frame(width: 42, height: 42).background(palette.gold.opacity(0.12), in: Circle()) }
                        .foregroundStyle(palette.gold).accessibilityLabel("Добавить привычку")
                }
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Text(presenter.state.summary).font(.system(size: 12)).foregroundStyle(palette.muted)
                        Spacer()
                        Text("\(Int(presenter.state.progress * 100))%").font(.system(size: 12, design: .monospaced)).foregroundStyle(palette.gold)
                    }
                    XPBar(progress: presenter.state.progress)
                }
                if presenter.state.rows.isEmpty {
                    VStack(spacing: 14) {
                        Image(systemName: "sparkles").font(.largeTitle).foregroundStyle(palette.gold)
                        Text("Начните с одной привычки").font(Gothic.serif(22)).multilineTextAlignment(.center)
                        GoldButton(title: "Добавить первую привычку", action: presenter.create)
                    }.gothicCard()
                }
                ForEach(presenter.state.rows) { row in
                    RitualRowView(row: row, toggle: { presenter.toggle(row.id) }, edit: { presenter.edit(row.id) }, archive: { archiveID = row.id; showArchiveConfirmation = true })
                }

            }.padding(24).frame(maxWidth: 720).frame(maxWidth: .infinity).pageEntrance()
        }
        .overlay(alignment: .top) {
            if let reward = presenter.reward {
                Label(reward, systemImage: "sparkles").font(.system(size: 14, weight: .medium)).padding(16)
                    .background(palette.gold, in: Capsule()).foregroundStyle(palette.onAccent).padding(.top, 8)
                    .transition(.asymmetric(insertion: .move(edge: .top).combined(with: .opacity), removal: .opacity))
                    .allowsHitTesting(false)
            }
        }
        .animation(reduceMotion ? nil : .spring(response: 0.45, dampingFraction: 0.8), value: presenter.reward)
        .sensoryFeedback(.success, trigger: presenter.celebration) { _, _ in presenter.state.haptics }
        .sheet(item: $router.editor) { router.destination($0) }
        .sheet(item: $router.milestone) { MilestoneView(level: $0.level, dismiss: router.closeMilestone) }
        .alert("Не удалось завершить действие", isPresented: Binding(get: { presenter.error != nil }, set: { if !$0 { presenter.error = nil } })) { Button("Понятно") { presenter.error = nil } } message: { Text(presenter.error ?? "") }
        .confirmationDialog("Убрать привычку в архив? Опыт и история сохранятся.", isPresented: $showArchiveConfirmation, titleVisibility: .visible) {
            Button("В архив", role: .destructive) { if let id = archiveID { presenter.archive(id) }; archiveID = nil }
        }
        .onReceive(midnightRefresh) { _ in presenter.refresh() }
        .onChange(of: scenePhase) { _, phase in if phase == .active { presenter.refresh() } }
    }
    private var hero: some View {
        HStack(spacing: 20) {
            LevelEmblem(level: presenter.state.level, progress: presenter.state.levelProgress,
                        animated: presenter.state.ambience).frame(width: 88, height: 88)
            VStack(alignment: .leading, spacing: 12) {
                Text("Ваш прогресс").font(Gothic.serif(23))
                HStack {
                    Text("До следующего уровня")
                    Spacer(minLength: 0)
                }.font(.system(size: 11)).foregroundStyle(palette.muted)
                XPBar(progress: presenter.state.levelProgress)
                Text(presenter.state.xp).font(.system(size: 11, design: .monospaced)).foregroundStyle(palette.gold)
            }
        }.gothicCard()
    }
    private func stat(icon: String, value: String, label: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon).font(.system(size: 23, weight: .ultraLight)).foregroundStyle(palette.gold)
            VStack(alignment: .leading, spacing: 5) {
                Text(value).font(Gothic.serif(26))
                Text(label).font(.system(size: 8)).tracking(1.2).foregroundStyle(palette.muted)
            }
            Spacer(minLength: 0)
        }.frame(maxWidth: .infinity).gothicCard()
    }
}
struct RitualRowView: View {
    @Environment(\.gothicPalette) private var palette
    let row: RitualRow
    let toggle: () -> Void
    let edit: () -> Void
    let archive: () -> Void
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    var body: some View {
        HStack(alignment: .center, spacing: 14) {
            Image(systemName: row.skill.icon).font(.system(size: 22, weight: .light)).foregroundStyle(palette.skillColor(row.skill))
                .frame(width: 44, height: 52).background(palette.skillColor(row.skill).opacity(0.09), in: RoundedRectangle(cornerRadius: 12))
            VStack(alignment: .leading, spacing: 7) {
                Text(row.title).font(Gothic.serif(19)).foregroundStyle(row.completed ? palette.muted : palette.ivory)
                Text(row.intention).font(.system(size: 11)).foregroundStyle(palette.muted).lineLimit(2)
                HStack(spacing: 12) {
                    Text(row.reward).foregroundStyle(palette.skillColor(row.skill))
                    Label(row.streak, systemImage: "flame").foregroundStyle(palette.gold)
                    if let time = row.reminder { Label(time, systemImage: "bell").foregroundStyle(palette.muted) }
                }.font(.system(size: 10, weight: .medium))
            }.frame(maxWidth: .infinity, alignment: .leading)
            Button(action: toggle) {
                Image(systemName: row.completed ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 29, weight: .ultraLight)).foregroundStyle(row.completed ? palette.gold : palette.muted.opacity(0.5))
                    .contentTransition(.symbolEffect(.replace)).frame(width: 44, height: 44)
            }.buttonStyle(GothicButtonStyle()).accessibilityLabel(row.completed ? "Отменить выполнение: \(row.title)" : "Выполнить: \(row.title)")
        }.gothicCard()
            .overlay(alignment: .topTrailing) {
                Menu { Button("Изменить", systemImage: "pencil", action: edit); Button("В архив", systemImage: "archivebox", action: archive) } label: {
                    Image(systemName: "ellipsis").font(.system(size: 13)).foregroundStyle(palette.muted).frame(width: 44, height: 28)
                }.accessibilityLabel("Действия с привычкой \(row.title)")
            }
            .animation(reduceMotion ? nil : .easeInOut(duration: 0.3), value: row.completed)
    }
}
