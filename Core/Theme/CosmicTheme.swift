//
//  CosmicTheme.swift
//  Astrolog
//
//  Created by Sergey on 22.09.2025.
//
// Core/Theme/CosmicTheme.swift
import SwiftUI

// MARK: - Cosmic Color Palette
extension Color {
    // Основные космические цвета
    static let cosmicDarkPurple = Color(hex: "1a0033")
    static let cosmicPurple = Color(hex: "4a148c")
    static let cosmicViolet = Color(hex: "7c4dff")
    static let cosmicPink = Color(hex: "e91e63")
    static let cosmicBlue = Color(hex: "2196f3")
    static let cosmicCyan = Color(hex: "00bcd4")
    static let cosmicTeal = Color(hex: "009688")
    
    // Неоновые акценты
    static let neonPurple = Color(hex: "b388ff")
    static let neonPink = Color(hex: "ff4081")
    static let neonBlue = Color(hex: "448aff")
    static let neonCyan = Color(hex: "18ffff")
    
    // Звездные оттенки
    static let starWhite = Color(hex: "fafafa")
    static let starYellow = Color(hex: "ffd54f")
    static let starOrange = Color(hex: "ffb74d")
    
    // Фоновые цвета
    static let spaceBlack = Color(hex: "000000")
    static let deepSpace = Color(hex: "0a0e27")
    static let darkNebula = Color(hex: "1a1a2e")
    static let nebulaPurple = Color(hex: "16213e")
    
    // Полупрозрачные для glassmorphism
    static let glassWhite = Color.white.opacity(0.1)
    static let glassPurple = Color.cosmicViolet.opacity(0.2)
    static let glassBlue = Color.cosmicBlue.opacity(0.15)
}

// Color from hex
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Gradients
struct CosmicGradients {
    // Основной космический градиент
    static let mainCosmic = LinearGradient(
        colors: [.cosmicDarkPurple, .cosmicPurple, .cosmicViolet],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    // Градиент галактики
    static let galaxy = LinearGradient(
        colors: [.deepSpace, .nebulaPurple, .cosmicPurple, .cosmicPink],
        startPoint: .top,
        endPoint: .bottom
    )
    
    // Градиент туманности
    static let nebula = RadialGradient(
        colors: [.cosmicViolet.opacity(0.8), .cosmicPink.opacity(0.4), .clear],
        center: .center,
        startRadius: 5,
        endRadius: 200
    )
    
    // Градиент северного сияния
    static let aurora = LinearGradient(
        colors: [.cosmicCyan, .cosmicTeal, .neonBlue, .neonPurple],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    // Градиент заката в космосе
    static let cosmicSunset = LinearGradient(
        colors: [.cosmicPink, .cosmicPurple, .deepSpace],
        startPoint: .top,
        endPoint: .bottom
    )
    
    // Мистический градиент для карт
    static let mysticCard = LinearGradient(
        colors: [
            Color.cosmicPurple.opacity(0.3),
            Color.cosmicViolet.opacity(0.2),
            Color.cosmicPink.opacity(0.1)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}

// MARK: - Typography
struct CosmicTypography {
    static let largeTitle = Font.system(size: 34, weight: .bold, design: .rounded)
    static let title = Font.system(size: 28, weight: .semibold, design: .rounded)
    static let headline = Font.system(size: 20, weight: .semibold, design: .rounded)
    static let body = Font.system(size: 17, weight: .regular, design: .rounded)
    static let caption = Font.system(size: 13, weight: .medium, design: .rounded)
    
    // Мистические шрифты для особых элементов
    static let zodiacSymbol = Font.system(size: 36, weight: .light, design: .serif)
    static let planetSymbol = Font.system(size: 28, weight: .ultraLight, design: .serif)
}

// MARK: - Spacing & Sizing
struct CosmicSpacing {
    static let tiny: CGFloat = 4
    static let small: CGFloat = 8
    static let medium: CGFloat = 16
    static let large: CGFloat = 24
    static let huge: CGFloat = 32
    static let massive: CGFloat = 48
}

// MARK: - Shadows & Glows
struct CosmicEffects {
    // Просто параметры для shadow, а не объекты типа Shadow
    static let glowShadowColor: Color = .neonPurple
    static let glowShadowRadius: CGFloat = 20.0
    static let glowShadowX: CGFloat = 0.0
    static let glowShadowY: CGFloat = 0.0

    static let deepShadowColor: Color = .spaceBlack.opacity(0.8)
    static let deepShadowRadius: CGFloat = 10.0
    static let deepShadowX: CGFloat = 0.0
    static let deepShadowY: CGFloat = 5.0

    static let starGlowColor: Color = .starWhite
    static let starGlowRadius: CGFloat = 15.0
    static let starGlowX: CGFloat = 0.0
    static let starGlowY: CGFloat = 0.0
}

