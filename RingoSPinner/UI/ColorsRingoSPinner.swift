import SwiftUI

struct ColorsRingoSPinner {
    static func accent(for theme: String) -> Color {
        switch theme {
        case "neon": Color(red: 0.0, green: 1.0, blue: 0.8)
        case "sunrise": Color(red: 1.0, green: 0.6, blue: 0.2)
        default: Color(red: 0.4, green: 0.6, blue: 1.0)
        }
    }

    static func secondary(for theme: String) -> Color {
        switch theme {
        case "neon": Color(red: 0.6, green: 0.0, blue: 1.0)
        case "sunrise": Color(red: 1.0, green: 0.3, blue: 0.4)
        default: Color(red: 0.8, green: 0.4, blue: 1.0)
        }
    }

    static func background(for theme: String) -> Color {
        switch theme {
        case "neon": Color(red: 0.02, green: 0.02, blue: 0.08)
        case "sunrise": Color(red: 0.08, green: 0.04, blue: 0.02)
        default: Color(red: 0.04, green: 0.04, blue: 0.12)
        }
    }

    static func cardBackground(for theme: String) -> Color {
        switch theme {
        case "neon": Color.white.opacity(0.06)
        case "sunrise": Color.white.opacity(0.08)
        default: Color.white.opacity(0.07)
        }
    }

    static func glow(for theme: String) -> Color {
        accent(for: theme).opacity(0.3)
    }

    static func gradientColors(for theme: String) -> [Color] {
        switch theme {
        case "neon":
            [Color(red: 0.0, green: 0.5, blue: 0.4), Color(red: 0.3, green: 0.0, blue: 0.5)]
        case "sunrise":
            [Color(red: 0.5, green: 0.3, blue: 0.1), Color(red: 0.5, green: 0.1, blue: 0.2)]
        default:
            [Color(red: 0.2, green: 0.3, blue: 0.5), Color(red: 0.4, green: 0.2, blue: 0.5)]
        }
    }
}
