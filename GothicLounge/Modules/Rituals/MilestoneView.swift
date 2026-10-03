import SwiftUI

struct MilestoneView: View {
    @Environment(\.gothicPalette) private var palette
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var appeared = false
    @State private var burst = false
    let level: Int
    let dismiss: () -> Void

    var body: some View {
        VStack(spacing: 24) {
            Spacer(minLength: 24)
            ZStack {
                ForEach(0..<20) { index in
                    let angle = Double(index) * .pi / 10
                    Capsule().fill(index.isMultiple(of: 2) ? palette.gold : palette.plum)
                        .frame(width: 3, height: index.isMultiple(of: 3) ? 10 : 5)
                        .rotationEffect(.radians(angle))
                        .offset(x: cos(angle) * (burst ? 140 : 62), y: sin(angle) * (burst ? 140 : 62))
                        .opacity(reduceMotion ? 0 : burst ? 0 : 0.85)
                }
                Circle().stroke(palette.gold.opacity(0.2), lineWidth: 1).frame(width: 190, height: 190)
                    .scaleEffect(appeared ? 1 : 0.8)
                VStack(spacing: 4) {
                    Image(systemName: "laurel.leading").font(.system(size: 35, weight: .light))
                    Text("\(level)").font(Gothic.serif(76))
                    Text("УРОВЕНЬ").font(.system(size: 11)).tracking(3)
                }.foregroundStyle(palette.gold).scaleEffect(appeared ? 1 : 0.7)
            }.frame(height: 250)
            Text("Отличная работа!").font(Gothic.serif(32)).multilineTextAlignment(.center)
            Text("Вы достигли \(level)-го уровня.\nЭто результат ваших ежедневных действий.")
                .font(.system(size: 16)).foregroundStyle(palette.muted).multilineTextAlignment(.center).lineSpacing(6)
            Spacer(minLength: 20)
            GoldButton(title: "Продолжить", icon: "checkmark", action: dismiss).accessibilityIdentifier("dismissMilestone")
        }.padding(32).frame(maxWidth: .infinity).background(palette.background).foregroundStyle(palette.ivory)
            .presentationDetents([.large]).presentationDragIndicator(.visible)
            .onAppear {
                withAnimation(reduceMotion ? nil : .spring(response: 0.8, dampingFraction: 0.65)) { appeared = true }
                withAnimation(reduceMotion ? nil : .easeOut(duration: 2).delay(0.2)) { burst = true }
            }
    }
}
