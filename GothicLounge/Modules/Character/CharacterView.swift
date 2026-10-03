import SwiftUI
struct CharacterView: View {
    @Environment(\.gothicPalette) private var palette
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @StateObject var presenter: CharacterPresenter
    @ObservedObject var router: CharacterRouter

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                PageHeading(eyebrow: "ЛИЧНЫЙ ПРОГРЕСС", title: "Профиль", subtitle: "Ваши навыки, результаты и достижения.")
                HStack(spacing: 22) {
                    LevelEmblem(level: presenter.state.level, progress: presenter.state.progress, animated: presenter.state.ambience)
                        .frame(width: 100, height: 100)
                    VStack(alignment: .leading, spacing: 12) {
                        Text(presenter.state.name).font(Gothic.serif(26))
                        Text(presenter.state.xp).font(.system(size: 12, design: .monospaced)).foregroundStyle(palette.gold)
                        Button(action: presenter.explainLevel) {
                            Label("Как растёт уровень", systemImage: "info.circle").font(.system(size: 11)).foregroundStyle(palette.muted)
                        }.padding(.vertical, 5)
                    }
                    Spacer(minLength: 0)
                }.gothicCard()
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                    metric(presenter.state.bestStreak, "Лучшая серия", "flame")
                    metric(presenter.state.activeDays, "Активных дней", "calendar")
                    metric(presenter.state.totalCompletions, "Выполнений", "checkmark.circle")
                    metric(presenter.state.totalXP, "Всего XP", "bolt")
                }
                SectionHeading(title: "Характеристики", trailing: "8 НАПРАВЛЕНИЙ")
                ForEach(presenter.state.skills) { item in
                    Button { presenter.explainSkill(item.skill) } label: {
                        HStack(spacing: 16) {
                            Image(systemName: item.skill.icon).font(.system(size: 24, weight: .light))
                                .foregroundStyle(palette.skillColor(item.skill)).frame(width: 32)
                            VStack(alignment: .leading, spacing: 11) {
                                HStack {
                                    Text(item.skill.title).font(Gothic.serif(19)).foregroundStyle(palette.ivory)
                                    Spacer()
                                    Text("Ур. \(item.level)").font(.system(size: 11)).foregroundStyle(palette.gold)
                                }
                                XPBar(progress: item.progress, color: palette.skillColor(item.skill))
                                Text(item.xp).font(.system(size: 10, design: .monospaced)).foregroundStyle(palette.muted)
                            }
                        }.gothicCard()
                    }.buttonStyle(GothicButtonStyle())
                }
                SectionHeading(title: "Достижения", trailing: presenter.state.achievementSummary)
                Picker("Достижения", selection: $presenter.filter) {
                    ForEach(AchievementFilter.allCases) { Text($0.rawValue).tag($0) }
                }.pickerStyle(.segmented)
                if presenter.visibleAchievements.isEmpty {
                    Text("Здесь появятся полученные достижения.").font(.system(size: 14)).foregroundStyle(palette.muted).padding(.vertical, 20)
                }
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                    ForEach(presenter.visibleAchievements) { achievement in
                        Button { presenter.explain(achievement) } label: {
                            VStack(alignment: .leading, spacing: 14) {
                                HStack {
                                    Image(systemName: achievement.icon).font(.system(size: 25, weight: .light))
                                    Spacer()
                                    if achievement.unlocked { Image(systemName: "checkmark.circle.fill").font(.system(size: 13)) }
                                }.foregroundStyle(achievement.unlocked ? palette.gold : palette.muted)
                                Text(achievement.title).font(Gothic.serif(17)).foregroundStyle(palette.ivory)
                                    .frame(minHeight: 42, alignment: .topLeading)
                                XPBar(progress: achievement.progress)
                                Text(achievement.unlocked ? "Получено" : achievement.counter)
                                    .font(.system(size: 10, design: .monospaced)).foregroundStyle(palette.muted)
                            }.frame(maxWidth: .infinity, alignment: .leading).gothicCard()
                        }.buttonStyle(GothicButtonStyle())
                    }
                }.animation(reduceMotion ? nil : .easeInOut(duration: 0.25), value: presenter.filter)
            }.padding(24).frame(maxWidth: 720).frame(maxWidth: .infinity).pageEntrance()
        }.onAppear(perform: presenter.refresh)
            .sheet(item: $router.detail) { DetailView(detail: $0, close: router.closeDetails) }
    }
    private func metric(_ value: String, _ label: String, _ icon: String) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack { Text(value).font(Gothic.serif(27)); Spacer(); Image(systemName: icon).foregroundStyle(palette.gold) }
            Text(label).font(.system(size: 11)).foregroundStyle(palette.muted)
        }.gothicCard()
    }
}
