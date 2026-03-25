// NutrivioTheme.swift
// Nutrivio

import SwiftUI

struct NutrivioTheme {
    // MARK: - Nutricion (Verdes)
    static let mintGreen = Color(hex: "4ECDC4")
    static let emeraldGreen = Color(hex: "2ECC71")
    static let primaryGreen = Color(hex: "00B894")
    static let lightMint = Color(hex: "D5F5E3")

    // MARK: - Fitness (Azules)
    static let skyBlue = Color(hex: "74B9FF")
    static let cobaltBlue = Color(hex: "0984E3")
    static let deepBlue = Color(hex: "2D3436")

    // MARK: - Energia (Naranjas)
    static let peachOrange = Color(hex: "FFEAA7")
    static let energyOrange = Color(hex: "F39C12")
    static let carbsOrange = Color(hex: "E17055")

    // MARK: - Progreso (Dorados)
    static let goldLight = Color(hex: "FDCB6E")
    static let goldDark = Color(hex: "E1A100")

    // MARK: - Grasa (Azul suave)
    static let fatBlue = Color(hex: "6C5CE7")

    // MARK: - Fondos
    static let backgroundPrimary = Color(hex: "FAFAFA")
    static let backgroundCard = Color.white
    static let backgroundDark = Color(hex: "1A1A2E")

    // MARK: - Texto
    static let textPrimary = Color(hex: "2D3436")
    static let textSecondary = Color(hex: "636E72")
    static let textTertiary = Color(hex: "B2BEC3")

    // MARK: - Gradientes
    static let greenGradient = LinearGradient(
        colors: [mintGreen, emeraldGreen],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let blueGradient = LinearGradient(
        colors: [skyBlue, cobaltBlue],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let goldGradient = LinearGradient(
        colors: [goldLight, goldDark],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let sunriseGradient = LinearGradient(
        colors: [energyOrange, carbsOrange],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    // MARK: - Sombras
    static let cardShadow = Color.black.opacity(0.08)
    static let elevatedShadow = Color.black.opacity(0.15)

    // MARK: - Bordes
    static let cornerRadiusSmall: CGFloat = 12
    static let cornerRadiusMedium: CGFloat = 16
    static let cornerRadiusLarge: CGFloat = 24
}

// MARK: - Color Extension

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - View Modifiers

struct NutrivioCardModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(NutrivioTheme.backgroundCard)
            .clipShape(RoundedRectangle(cornerRadius: NutrivioTheme.cornerRadiusMedium))
            .shadow(color: NutrivioTheme.cardShadow, radius: 12, x: 0, y: 4)
    }
}

extension View {
    func nutrivioCard() -> some View {
        modifier(NutrivioCardModifier())
    }
}
