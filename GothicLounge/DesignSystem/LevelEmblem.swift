import SwiftUI

struct LevelEmblem: View {
    @Environment(\.gothicPalette) private var palette
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    let level: String
    let progress: Double
    var animated = true
    var body: some View {
        ZStack {
            Circle().stroke(palette.gold.opacity(0.13), lineWidth: 2)
            Circle().trim(from: 0, to: progress).stroke(palette.gold, style: StrokeStyle(lineWidth: 2, lineCap: .round))
                .rotationEffect(.degrees(-90))
            Circle().stroke(palette.gold.opacity(0.09), lineWidth: 1).padding(7)
            VStack(spacing: 3) {
                Text(level).font(Gothic.serif(32)).contentTransition(.numericText())
                Text("УРОВЕНЬ").font(.system(size: 7, weight: .medium)).tracking(1.4)
            }.foregroundStyle(palette.gold)
        }.animation(reduceMotion || !animated ? nil : .spring(response: 0.7), value: progress)
            .accessibilityElement(children: .ignore).accessibilityLabel("Уровень \(level)")
    }
}
