import SwiftUI

struct ThemePalette {
    let background: Color
    let surface: Color
    let gold: Color
    let ivory: Color
    let muted: Color
    let plum: Color
    let onAccent: Color
    let scheme: ColorScheme
}

extension AppTheme {
    var palette: ThemePalette {
        switch self {
        case .obsidian:
            ThemePalette(background: Color(hex: 0x101014), surface: Color(hex: 0x1B1B22), gold: Color(hex: 0xC9AF80),
                         ivory: Color(hex: 0xEEEAE2), muted: Color(hex: 0xA09CA8), plum: Color(hex: 0x786384), onAccent: Color(hex: 0x19171B), scheme: .dark)
        case .graphite:
            ThemePalette(background: Color(hex: 0x16191D), surface: Color(hex: 0x23282E), gold: Color(hex: 0xB8CDCC),
                         ivory: Color(hex: 0xF0F3F3), muted: Color(hex: 0xA1ABB5), plum: Color(hex: 0x667F8A), onAccent: Color(hex: 0x172225), scheme: .dark)
        case .midnight:
            ThemePalette(background: Color(hex: 0x101726), surface: Color(hex: 0x1B2539), gold: Color(hex: 0xB6B8EE),
                         ivory: Color(hex: 0xEEF0FD), muted: Color(hex: 0x9FAECD), plum: Color(hex: 0x7279BD), onAccent: Color(hex: 0x1C2044), scheme: .dark)
        case .paper:
            ThemePalette(background: Color(hex: 0xF4F1EB), surface: Color(hex: 0xFFFDFA), gold: Color(hex: 0x765737),
                         ivory: Color(hex: 0x302C29), muted: Color(hex: 0x726A63), plum: Color(hex: 0xAF9690), onAccent: Color(hex: 0xFFFFFF), scheme: .light)
        }
    }
}

extension Color {
    init(hex: UInt32) {
        self.init(red: Double((hex >> 16) & 255) / 255,
                  green: Double((hex >> 8) & 255) / 255, blue: Double(hex & 255) / 255)
    }
}
private struct ThemePaletteKey: EnvironmentKey {
    static let defaultValue = AppTheme.obsidian.palette
}
extension EnvironmentValues {
    var gothicPalette: ThemePalette {
        get { self[ThemePaletteKey.self] }
        set { self[ThemePaletteKey.self] = newValue }
    }
}

extension ThemePalette {
    func skillColor(_ skill: Skill) -> Color {
        guard scheme == .light else { return skill.color }
        switch skill {
        case .vitality: return Color(hex: 0xA44242)
        case .wisdom: return Color(hex: 0x6852A3)
        case .discipline: return gold
        case .spirit: return Color(hex: 0x28776F)
        case .focus: return Color(hex: 0x366A9E)
        case .creativity: return Color(hex: 0xA34778)
        case .balance: return Color(hex: 0x427650)
        case .communication: return Color(hex: 0x94622D)
        }
    }
}
