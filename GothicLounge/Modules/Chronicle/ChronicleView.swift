import SwiftUI
struct ChronicleView: View {
    @Environment(\.gothicPalette) private var palette
    @StateObject var presenter: ChroniclePresenter
    @ObservedObject var router: ChronicleRouter
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                PageHeading(eyebrow: "АКТИВНОСТЬ", title: "История", subtitle: "Все выполнения в одном месте.")
                HStack {
                    metric(presenter.state.total, "ВЫПОЛНЕНИЙ")
                    Spacer(); metric(presenter.state.streak, "ДНЕЙ ПОДРЯД")
                    Spacer(); metric(presenter.state.xp, "ВСЕГО XP")
                }.gothicCard()
                VStack(alignment: .leading, spacing: 20) {
                    HStack { Text("Календарь активности").font(Gothic.serif(21)); Spacer(); Image(systemName: "sparkles").foregroundStyle(palette.gold) }
                    Text(presenter.state.period).font(.system(size: 9)).tracking(2).foregroundStyle(palette.muted)
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 7), spacing: 10) {
                        ForEach(presenter.state.days) { day in
                            Button { presenter.select(day) } label: {
                                Text(day.label).font(.system(size: 12, design: .serif)).frame(maxWidth: .infinity).frame(height: 38)
                                    .foregroundStyle(day.count > 0 ? palette.background : palette.muted)
                                    .background(day.count > 0 ? palette.gold.opacity(min(0.45 + Double(day.count) * 0.15, 1)) : palette.gold.opacity(0.04), in: RoundedRectangle(cornerRadius: 8))
                                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(day.today ? palette.gold : palette.gold.opacity(0.1)))
                            }.buttonStyle(GothicButtonStyle()).accessibilityLabel("\(day.id), выполнено \(day.count)")
                        }
                    }
                    HStack { Text("Меньше"); ForEach(0..<4) { i in RoundedRectangle(cornerRadius: 3).fill(palette.gold.opacity(Double(i + 1) * 0.25)).frame(width: 12, height: 12) }; Text("Больше"); Spacer() }.font(.system(size: 10)).foregroundStyle(palette.muted)
                }.gothicCard()
                SectionHeading(title: "Последние выполнения")
                if presenter.state.entries.isEmpty {
                    VStack(spacing: 15) {
                        Image(systemName: "book.closed").font(.system(size: 35, weight: .ultraLight)).foregroundStyle(palette.gold)
                        Text("Пока нет выполнений").font(Gothic.serif(21))
                        Text("Отметьте привычку — здесь появится первая запись.").font(.system(size: 13)).foregroundStyle(palette.muted).multilineTextAlignment(.center)
                    }.frame(maxWidth: .infinity).gothicCard()
                }
                LazyVStack(spacing: 0) {
                    ForEach(presenter.state.entries) { entry in
                        HStack(spacing: 15) {
                            Image(systemName: entry.skill.icon).foregroundStyle(palette.skillColor(entry.skill)).frame(width: 35, height: 45)
                            VStack(alignment: .leading, spacing: 6) { Text(entry.title).font(Gothic.serif(18)); Text(entry.date).font(.system(size: 11)).foregroundStyle(palette.muted) }
                            Spacer(); Text(entry.reward).font(.system(size: 12)).foregroundStyle(palette.gold)
                        }.padding(.vertical, 16)
                        Rectangle().fill(palette.gold.opacity(0.1)).frame(height: 1)
                    }
                }
            }.padding(24).frame(maxWidth: 720).frame(maxWidth: .infinity).pageEntrance()
        }.onAppear(perform: presenter.refresh).sheet(item: $router.detail) { DetailView(detail: $0, close: router.closeDetails) }
    }
    private func metric(_ value: String, _ label: String) -> some View {
        VStack(spacing: 8) { Text(value).font(Gothic.serif(30)).foregroundStyle(palette.gold); Text(label).font(.system(size: 8)).tracking(1).foregroundStyle(palette.muted) }
    }
}
