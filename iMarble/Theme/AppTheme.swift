import SwiftUI

enum AppColorScheme: String, CaseIterable, Identifiable {
    case system
    case light
    case dark

    var id: String { rawValue }

    var colorScheme: ColorScheme? {
        switch self {
        case .system: return nil
        case .light: return .light
        case .dark: return .dark
        }
    }
}

enum AppTheme {
    static let orange = Color(red: 0.95, green: 0.44, blue: 0.05)
    static let orangeVibrant = Color(red: 1.0, green: 0.52, blue: 0.02)
    static let burntYellow = Color(red: 0.80, green: 0.58, blue: 0.09)
    static let mustard = Color(red: 0.72, green: 0.52, blue: 0.08)
    static let black = Color(red: 0.07, green: 0.06, blue: 0.05)
    static let charcoal = Color(red: 0.12, green: 0.10, blue: 0.09)
    static let cream = Color(red: 0.98, green: 0.94, blue: 0.86)

    static let backgroundGradient = LinearGradient(
        colors: [black, charcoal, Color(red: 0.18, green: 0.11, blue: 0.05)],
        startPoint: .top,
        endPoint: .bottom
    )

    static let accentGradient = LinearGradient(
        colors: [orangeVibrant, burntYellow],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let groundGradient = LinearGradient(
        colors: [Color(red: 0.30, green: 0.19, blue: 0.09), Color(red: 0.18, green: 0.11, blue: 0.05)],
        startPoint: .top,
        endPoint: .bottom
    )

    static func primaryText(for scheme: ColorScheme) -> Color {
        scheme == .dark ? cream : black
    }

    static func secondaryBackground(for scheme: ColorScheme) -> Color {
        scheme == .dark ? charcoal : cream
    }

    enum Typography {
        static func title() -> Font { .system(size: 40, weight: .heavy, design: .rounded) }
        static func headline() -> Font { .system(size: 22, weight: .bold, design: .rounded) }
        static func body() -> Font { .system(size: 17, weight: .medium, design: .rounded) }
        static func caption() -> Font { .system(size: 13, weight: .medium, design: .rounded) }
        static func buttonLabel() -> Font { .system(size: 18, weight: .bold, design: .rounded) }
    }

    static let cornerRadius: CGFloat = 18
    static let playerPalette: [String] = ["orange", "yellow", "red", "green", "blue", "purple"]

    static func color(named name: String) -> Color {
        switch name {
        case "orange": return orangeVibrant
        case "yellow": return burntYellow
        case "red": return Color(red: 0.82, green: 0.20, blue: 0.15)
        case "green": return Color(red: 0.30, green: 0.55, blue: 0.25)
        case "blue": return Color(red: 0.20, green: 0.45, blue: 0.75)
        case "purple": return Color(red: 0.50, green: 0.30, blue: 0.65)
        case "cateye": return Color(red: 0.20, green: 0.62, blue: 0.55)
        case "ox": return Color(red: 0.45, green: 0.10, blue: 0.10)
        case "grandmarble": return Color(red: 0.85, green: 0.70, blue: 0.20)
        default: return orangeVibrant
        }
    }

    static func symbol(forPlayerIndex index: Int) -> String {
        let symbols = ["circle.fill", "diamond.fill", "hexagon.fill", "seal.fill", "star.fill", "triangle.fill"]
        return symbols[index % symbols.count]
    }
}

struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(AppTheme.Typography.buttonLabel())
            .foregroundStyle(.white)
            .padding(.vertical, 14)
            .padding(.horizontal, 28)
            .background(AppTheme.accentGradient)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadius, style: .continuous))
            .shadow(color: AppTheme.orange.opacity(0.4), radius: configuration.isPressed ? 2 : 8, y: configuration.isPressed ? 1 : 4)
            .scaleEffect(configuration.isPressed ? 0.96 : 1)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(AppTheme.Typography.body())
            .foregroundStyle(AppTheme.cream)
            .padding(.vertical, 10)
            .padding(.horizontal, 20)
            .background(
                RoundedRectangle(cornerRadius: AppTheme.cornerRadius, style: .continuous)
                    .stroke(AppTheme.burntYellow, lineWidth: 1.5)
            )
            .scaleEffect(configuration.isPressed ? 0.96 : 1)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}
