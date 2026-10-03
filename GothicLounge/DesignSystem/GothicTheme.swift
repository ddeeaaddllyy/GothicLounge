import SwiftUI

enum Gothic {
    static let background = Color(red: 0.045, green: 0.049, blue: 0.065)
    static let surface = Color(red: 0.086, green: 0.088, blue: 0.109)
    static let gold = Color(red: 0.79, green: 0.66, blue: 0.43)
    static let ivory = Color(red: 0.91, green: 0.88, blue: 0.81)
    static let muted = Color(red: 0.58, green: 0.57, blue: 0.62)
    static let plum = Color(red: 0.42, green: 0.29, blue: 0.46)
    static func serif(_ size: CGFloat) -> Font { .system(size: size, weight: .regular, design: .serif) }
}
extension Skill {
    var color: Color {
        switch self {
        case .vitality: Color(red: 0.72, green: 0.43, blue: 0.43)
        case .wisdom: Color(red: 0.57, green: 0.53, blue: 0.78)
        case .discipline: Gothic.gold
        case .spirit: Color(red: 0.43, green: 0.66, blue: 0.64)
        case .focus: Color(hex: 0x6F9CD1)
        case .creativity: Color(hex: 0xC786AE)
        case .balance: Color(hex: 0x74A487)
        case .communication: Color(hex: 0xC69A68)
        }
    }
}

struct GothicCard: ViewModifier {
    @Environment(\.gothicPalette) private var palette
    func body(content: Content) -> some View {
        content.padding(20).background(palette.surface, in: RoundedRectangle(cornerRadius: 20))
            .overlay(RoundedRectangle(cornerRadius: 20).stroke(palette.gold.opacity(0.16), lineWidth: 1))
    }
}
extension View {
    func gothicCard() -> some View { modifier(GothicCard()) }
    func pageEntrance() -> some View { modifier(PageEntrance()) }
}
struct PageEntrance: ViewModifier {
    @Environment(\.gothicPalette) private var palette
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var appeared = false
    func body(content: Content) -> some View {
        content.opacity(appeared ? 1 : 0).offset(y: appeared || reduceMotion ? 0 : 14)
            .onAppear { withAnimation(reduceMotion ? nil : .easeOut(duration: 0.6)) { appeared = true } }
    }
}
struct GothicButtonStyle: ButtonStyle {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    func makeBody(configuration: Configuration) -> some View {
        configuration.label.scaleEffect(configuration.isPressed && !reduceMotion ? 0.96 : 1)
            .opacity(configuration.isPressed ? 0.75 : 1)
            .animation(reduceMotion ? nil : .spring(response: 0.3, dampingFraction: 0.65), value: configuration.isPressed)
    }
}
struct SectionHeading: View {
    @Environment(\.gothicPalette) private var palette
    let title: String
    var trailing: String = ""
    var body: some View {
        HStack {
            Text(title).font(Gothic.serif(24)).foregroundStyle(palette.ivory)
            Spacer()
            Text(trailing).font(.system(size: 10, weight: .medium)).tracking(2).foregroundStyle(palette.gold)
        }.padding(.top, 8)
    }
}
struct PageHeading: View {
    @Environment(\.gothicPalette) private var palette
    let eyebrow: String
    let title: String
    let subtitle: String
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(eyebrow).font(.system(size: 10, weight: .semibold)).tracking(4).foregroundStyle(palette.gold)
            Text(title).font(Gothic.serif(34)).foregroundStyle(palette.ivory)
            Text(subtitle).font(.system(size: 13)).foregroundStyle(palette.muted).lineSpacing(4)
        }.frame(maxWidth: .infinity, alignment: .leading).padding(.top, 16)
    }
}
struct GoldButton: View {
    @Environment(\.gothicPalette) private var palette
    let title: String
    var icon = "plus"
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            Label(title, systemImage: icon).font(.system(size: 14, weight: .semibold))
                .frame(maxWidth: .infinity).padding(.vertical, 17)
                .foregroundStyle(palette.onAccent)
                .background(LinearGradient(colors: [palette.gold.opacity(0.85), palette.gold], startPoint: .topLeading, endPoint: .bottomTrailing), in: RoundedRectangle(cornerRadius: 14))
        }.buttonStyle(GothicButtonStyle())
    }
}
struct XPBar: View {
    @Environment(\.gothicPalette) private var palette
    let progress: Double
    var color: Color? = nil
    private var tint: Color { color ?? palette.gold }
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .leading) {
                Capsule().fill(tint.opacity(0.12))
                Capsule().fill(tint).frame(width: proxy.size.width * min(max(progress, 0), 1))
                    .shadow(color: tint.opacity(0.3), radius: 6)
            }
        }.frame(height: 4)
            .animation(reduceMotion ? nil : .spring(response: 0.8, dampingFraction: 0.8), value: progress)
            .accessibilityLabel("Прогресс \(Int(progress * 100)) процентов")
    }
}
