import SwiftUI
struct EditorView: View {
    @Environment(\.gothicPalette) private var palette
    @StateObject var presenter: EditorPresenter
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 25) {
                    PageHeading(eyebrow: "ПРИВЫЧКИ", title: presenter.heading, subtitle: "Выберите понятное действие и подходящую нагрузку.")
                    VStack(alignment: .leading, spacing: 14) {
                        label("НАЗВАНИЕ")
                        TextField("Например, читать перед сном", text: $presenter.draft.title).font(Gothic.serif(20)).accessibilityIdentifier("ritualTitle")
                        Divider().overlay(palette.gold.opacity(0.2))
                        TextField("Описание · что именно вы сделаете?", text: $presenter.draft.intention, axis: .vertical).font(.system(size: 14)).lineLimit(2...4)
                    }.gothicCard()
                    label("КАКУЮ ХАРАКТЕРИСТИКУ РАЗВИВАЕМ?")
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                        ForEach(Skill.allCases) { skill in
                            Button { presenter.draft.skill = skill } label: {
                                VStack(spacing: 12) {
                                    Image(systemName: skill.icon).font(.system(size: 25, weight: .light))
                                    Text(skill.title).font(.system(size: 12))
                                }.foregroundStyle(palette.skillColor(skill)).frame(maxWidth: .infinity).padding(.vertical, 20)
                                    .background(palette.skillColor(skill).opacity(presenter.draft.skill == skill ? 0.16 : 0.04), in: RoundedRectangle(cornerRadius: 16))
                                    .overlay(RoundedRectangle(cornerRadius: 16).stroke(palette.skillColor(skill).opacity(presenter.draft.skill == skill ? 0.8 : 0.15)))
                            }.buttonStyle(GothicButtonStyle()).accessibilityAddTraits(presenter.draft.skill == skill ? .isSelected : [])
                        }
                    }.animation(reduceMotion ? nil : .easeInOut(duration: 0.25), value: presenter.draft.skill)
                    VStack(alignment: .leading, spacing: 15) {
                        label("СЛОЖНОСТЬ И НАГРАДА")
                        Picker("Опыт за выполнение", selection: $presenter.draft.reward) {
                            Text("10 XP").tag(10); Text("20 XP").tag(20); Text("30 XP").tag(30); Text("50 XP").tag(50)
                        }.pickerStyle(.segmented)
                        Text("Награда начисляется один раз в день. Выберите сложность, которая соответствует усилию.").font(.system(size: 12)).foregroundStyle(palette.muted)
                    }.gothicCard()
                    VStack(alignment: .leading, spacing: 14) {
                        Toggle(isOn: $presenter.draft.reminder) { Label("Напоминание", systemImage: "bell").font(Gothic.serif(20)) }.tint(palette.gold)
                        if presenter.draft.reminder {
                            DatePicker("Каждый день в", selection: $presenter.draft.time, displayedComponents: .hourAndMinute).font(.system(size: 14)).transition(.opacity.combined(with: .move(edge: .top)))
                        }
                        Text("Повторяется каждый день.").font(.system(size: 12)).foregroundStyle(palette.muted)
                    }.gothicCard().animation(reduceMotion ? nil : .easeInOut(duration: 0.3), value: presenter.draft.reminder)
                    GoldButton(title: presenter.saving ? "Сохраняем…" : "Сохранить привычку", icon: "seal", action: presenter.save).disabled(presenter.saving).accessibilityIdentifier("saveRitual")
                }.padding(24).frame(maxWidth: 640).frame(maxWidth: .infinity).pageEntrance()
            }.background(palette.background).foregroundStyle(palette.ivory)
                .toolbar { ToolbarItem(placement: .topBarTrailing) { Button("Закрыть", action: presenter.cancel).tint(palette.gold).disabled(presenter.saving) } }
                .interactiveDismissDisabled(presenter.saving)
                .alert("Привычки", isPresented: Binding(get: { presenter.message != nil }, set: { if !$0 { presenter.acknowledge() } })) { Button("Понятно", action: presenter.acknowledge) } message: { Text(presenter.message ?? "") }
        }.preferredColorScheme(palette.scheme)
    }
    private func label(_ text: String) -> some View { Text(text).font(.system(size: 10, weight: .medium)).tracking(2).foregroundStyle(palette.gold) }
}
