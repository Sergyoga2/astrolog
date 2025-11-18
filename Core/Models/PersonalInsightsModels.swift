//
//  PersonalInsightsModels.swift
//  Astrolog
//
//  Created by Claude on 26.10.2025.
//

// Core/Models/PersonalInsightsModels.swift
import Foundation
import SwiftUI

// MARK: - PersonalInsights Main Model

struct PersonalInsights {
    let id: UUID
    let userId: String
    let chartId: String
    let generatedAt: Date

    // Основные персональные данные
    let corePersonalityDescription: String
    let lifeTheme: LifeTheme
    let uniqueTraits: [PersonalTrait]
    let emotionalBalance: String

    // Планетарные инсайты
    let dominantPlanetaryInfluences: [PlanetaryInfluence]
    let planetaryInsights: [PlanetaryInsight]

    // Аспектные инсайты
    let aspectPatterns: [AspectPattern]
    let aspectInsights: [AspectInsight]
    let overallHarmony: HarmonyLevel

    // Инсайты домов
    let houseInsights: [HouseInsight]

    init(
        id: UUID = UUID(),
        userId: String,
        chartId: String,
        generatedAt: Date = Date(),
        corePersonalityDescription: String,
        lifeTheme: LifeTheme,
        uniqueTraits: [PersonalTrait],
        emotionalBalance: String,
        dominantPlanetaryInfluences: [PlanetaryInfluence],
        planetaryInsights: [PlanetaryInsight],
        aspectPatterns: [AspectPattern],
        aspectInsights: [AspectInsight],
        overallHarmony: HarmonyLevel,
        houseInsights: [HouseInsight]
    ) {
        self.id = id
        self.userId = userId
        self.chartId = chartId
        self.generatedAt = generatedAt
        self.corePersonalityDescription = corePersonalityDescription
        self.lifeTheme = lifeTheme
        self.uniqueTraits = uniqueTraits
        self.emotionalBalance = emotionalBalance
        self.dominantPlanetaryInfluences = dominantPlanetaryInfluences
        self.planetaryInsights = planetaryInsights
        self.aspectPatterns = aspectPatterns
        self.aspectInsights = aspectInsights
        self.overallHarmony = overallHarmony
        self.houseInsights = houseInsights
    }
}

// MARK: - Life Theme

struct LifeTheme {
    let id: UUID
    let title: String
    let description: String
    let keywords: [String]
    let color: Color
    let importance: Double // 0.0 - 1.0

    static let defaultTheme = LifeTheme(
        id: UUID(),
        title: "Путь самопознания",
        description: "Ваш путь связан с глубоким изучением себя и своих возможностей",
        keywords: ["самопознание", "рост", "развитие"],
        color: .cosmicViolet,
        importance: 0.8
    )
}

// MARK: - Personal Trait

struct PersonalTrait {
    let id: UUID
    let displayName: String
    let basicDescription: String
    let humanDescription: String
    let detailedDescription: String
    let category: TraitCategory
    let personalRelevance: Double // 0.0 - 1.0
    let source: TraitSource

    enum TraitCategory {
        case personality
        case emotional
        case mental
        case social
        case spiritual

        var color: Color {
            switch self {
            case .personality: return .fireElement
            case .emotional: return .waterElement
            case .mental: return .airElement
            case .social: return .earthElement
            case .spiritual: return .cosmicViolet
            }
        }

        var emoji: String {
            switch self {
            case .personality: return "🎭"
            case .emotional: return "💖"
            case .mental: return "🧠"
            case .social: return "👥"
            case .spiritual: return "🔮"
            }
        }
    }

    enum TraitSource {
        case sun, moon, ascendant, planets, aspects, houses
    }
}

// MARK: - Planetary Models

struct PlanetaryInfluence {
    let id: UUID
    let planet: PlanetType
    let strength: Double // 0.0 - 1.0
    let description: String

    init(planet: PlanetType, strength: Double, description: String) {
        self.id = UUID()
        self.planet = planet
        self.strength = strength
        self.description = description
    }
}

struct PlanetaryInsight {
    let id: UUID
    let planet: PlanetType
    let personalizedDescription: String
    let emotionalImpact: String
    let practicalAdvice: String
    let keywords: [String]
}

// MARK: - Aspect Models

struct AspectPattern {
    let id: UUID
    let technicalName: String
    let humanName: String
    let basicDescription: String
    let humanDescription: String
    let detailedDescription: String
    let symbol: String
    let color: Color

    static let tStellium = AspectPattern(
        id: UUID(),
        technicalName: "T-Square",
        humanName: "Внутренний конфликт",
        basicDescription: "Напряжение между разными частями личности",
        humanDescription: "У вас есть внутренний конфликт, который может быть источником роста",
        detailedDescription: "T-Square создает динамическое напряжение...",
        symbol: "⟙",
        color: .fireElement
    )
}

struct AspectInsight {
    let id: UUID
    let planet1: PlanetType
    let planet2: PlanetType
    let aspectType: AspectType
    let personalizedDescription: String
    let emotionalResonance: String
    let growthOpportunity: String
}

// MARK: - Harmony Level

enum HarmonyLevel {
    case high
    case moderate
    case challenging

    var percentage: Double {
        switch self {
        case .high: return 0.8
        case .moderate: return 0.6
        case .challenging: return 0.4
        }
    }

    var description: String {
        switch self {
        case .high: return "Высокая гармония"
        case .moderate: return "Умеренная гармония"
        case .challenging: return "Вызовы для роста"
        }
    }
}

// MARK: - House Insights

struct HouseInsight {
    let id: UUID
    let house: Int
    let personalizedDescription: String
    let lifeAreaFocus: String
    let developmentAdvice: String
    let currentInfluences: [String]
}

// MARK: - Extensions for Missing Types


enum Modality {
    case cardinal
    case fixed
    case mutable

    var displayName: String {
        switch self {
        case .cardinal: return "Кардинальный"
        case .fixed: return "Фиксированный"
        case .mutable: return "Мутабельный"
        }
    }
}

// MARK: - Missing Extensions

extension AspectType {
    var influence: AspectInfluence {
        switch self {
        case .trine, .sextile: return .harmonious
        case .square, .opposition: return .challenging
        case .conjunction: return .neutral
        }
    }
}

enum AspectInfluence {
    case harmonious
    case challenging
    case neutral

    var displayName: String {
        switch self {
        case .harmonious: return "Гармоничное"
        case .challenging: return "Напряженное"
        case .neutral: return "Нейтральное"
        }
    }
}

enum AspectStrength {
    case weak
    case moderate
    case strong
    case veryStrong

    var displayName: String {
        switch self {
        case .weak: return "Слабый"
        case .moderate: return "Умеренный"
        case .strong: return "Сильный"
        case .veryStrong: return "Очень сильный"
        }
    }
}

extension Aspect {
    var strength: AspectStrength {
        switch abs(orb) {
        case 0...1: return .veryStrong
        case 1...3: return .strong
        case 3...6: return .moderate
        default: return .weak
        }
    }
}