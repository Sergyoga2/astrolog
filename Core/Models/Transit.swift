//
//  Transit.swift
//  Astrolog
//
//  Created by Claude on 26.10.2025.
//

// Core/Models/Transit.swift
import Foundation
import SwiftUI

/// Модель транзита - взаимодействие текущей планеты с натальной картой
struct Transit: Identifiable, Codable {
    let id: UUID
    let transitingPlanet: PlanetType
    let natalPlanet: PlanetType?
    let aspectType: AspectType
    let orb: Double
    let influence: TransitInfluence
    let duration: DateInterval
    let peak: Date
    let interpretation: String
    let humanDescription: String  // Для человеческого режима
    let emoji: String

    init(
        id: UUID = UUID(),
        transitingPlanet: PlanetType,
        natalPlanet: PlanetType?,
        aspectType: AspectType,
        orb: Double,
        influence: TransitInfluence,
        duration: DateInterval,
        peak: Date,
        interpretation: String,
        humanDescription: String,
        emoji: String
    ) {
        self.id = id
        self.transitingPlanet = transitingPlanet
        self.natalPlanet = natalPlanet
        self.aspectType = aspectType
        self.orb = orb
        self.influence = influence
        self.duration = duration
        self.peak = peak
        self.interpretation = interpretation
        self.humanDescription = humanDescription
        self.emoji = emoji
    }

    /// Является ли транзит активным в данный момент
    var isActive: Bool {
        duration.contains(Date())
    }

    /// Интенсивность транзита (0-1) на основе орба
    var intensity: Double {
        let maxOrb = aspectType.maxOrb
        return max(0, 1 - (orb / maxOrb))
    }

    /// Тип влияния транзита
    var impactLevel: TransitImpact {
        switch intensity {
        case 0.8...1.0: return .major
        case 0.5...0.8: return .moderate
        case 0.2...0.5: return .minor
        default: return .subtle
        }
    }
}

/// Влияние транзита
enum TransitInfluence: String, CaseIterable, Codable {
    case harmonious = "Гармоничное"
    case challenging = "Напряженное"
    case transformative = "Трансформирующее"
    case neutral = "Нейтральное"

    var color: Color {
        switch self {
        case .harmonious: return .earthElement
        case .challenging: return .fireElement
        case .transformative: return .cosmicViolet
        case .neutral: return .airElement
        }
    }

    var icon: String {
        switch self {
        case .harmonious: return "heart.fill"
        case .challenging: return "bolt.fill"
        case .transformative: return "sparkles"
        case .neutral: return "circle.fill"
        }
    }
}

/// Сила воздействия транзита
enum TransitImpact: String, CaseIterable {
    case major = "Сильное"
    case moderate = "Умеренное"
    case minor = "Слабое"
    case subtle = "Тонкое"

    var priority: Int {
        switch self {
        case .major: return 4
        case .moderate: return 3
        case .minor: return 2
        case .subtle: return 1
        }
    }
}

/// Дневная информация с транзитами и инсайтами
struct DailyInsight: Identifiable, Codable {
    let id: UUID
    let date: Date
    let overallEnergy: String
    let emotionalTone: EmotionalTone
    let keyTransits: [Transit]
    let lunarPhase: LunarPhase
    let recommendations: [DailyRecommendation]
    let affirmation: String
    let emoji: String

    init(
        id: UUID = UUID(),
        date: Date,
        overallEnergy: String,
        emotionalTone: EmotionalTone,
        keyTransits: [Transit],
        lunarPhase: LunarPhase,
        recommendations: [DailyRecommendation],
        affirmation: String,
        emoji: String
    ) {
        self.id = id
        self.date = date
        self.overallEnergy = overallEnergy
        self.emotionalTone = emotionalTone
        self.keyTransits = keyTransits
        self.lunarPhase = lunarPhase
        self.recommendations = recommendations
        self.affirmation = affirmation
        self.emoji = emoji
    }

    /// Общая энергетика дня (0-1)
    var energyLevel: Double {
        let harmonious = keyTransits.filter { $0.influence == .harmonious }.count
        let challenging = keyTransits.filter { $0.influence == .challenging }.count
        let total = max(1, keyTransits.count)

        return Double(harmonious) / Double(total)
    }
}

/// Эмоциональный тон дня
enum EmotionalTone: String, CaseIterable, Codable {
    case uplifting = "Вдохновляющий"
    case challenging = "Испытывающий"
    case transformative = "Преобразующий"
    case peaceful = "Спокойный"
    case energetic = "Энергичный"
    case reflective = "Рефлексивный"

    var color: Color {
        switch self {
        case .uplifting: return .starYellow
        case .challenging: return .fireElement
        case .transformative: return .cosmicViolet
        case .peaceful: return .earthElement
        case .energetic: return .neonCyan
        case .reflective: return .waterElement
        }
    }

    var emoji: String {
        switch self {
        case .uplifting: return "✨"
        case .challenging: return "⚡️"
        case .transformative: return "🦋"
        case .peaceful: return "🕊"
        case .energetic: return "🔥"
        case .reflective: return "🌙"
        }
    }
}

/// Лунная фаза
enum LunarPhase: String, CaseIterable, Codable {
    case newMoon = "Новолуние"
    case waxingCrescent = "Растущая луна"
    case firstQuarter = "Первая четверть"
    case waxingGibbous = "Прибывающая луна"
    case fullMoon = "Полнолуние"
    case waningGibbous = "Убывающая луна"
    case thirdQuarter = "Последняя четверть"
    case waningCrescent = "Стареющая луна"

    var emoji: String {
        switch self {
        case .newMoon: return "🌑"
        case .waxingCrescent: return "🌒"
        case .firstQuarter: return "🌓"
        case .waxingGibbous: return "🌔"
        case .fullMoon: return "🌕"
        case .waningGibbous: return "🌖"
        case .thirdQuarter: return "🌗"
        case .waningCrescent: return "🌘"
        }
    }

    var influence: String {
        switch self {
        case .newMoon: return "Время новых начинаний и планирования"
        case .waxingCrescent: return "Период роста и развития идей"
        case .firstQuarter: return "Момент преодоления препятствий"
        case .waxingGibbous: return "Время совершенствования и доработки"
        case .fullMoon: return "Пик эмоций и завершение циклов"
        case .waningGibbous: return "Период благодарности и рефлексии"
        case .thirdQuarter: return "Время освобождения и прощения"
        case .waningCrescent: return "Подготовка к новому циклу"
        }
    }
}

/// Персональная рекомендация на день
struct DailyRecommendation: Identifiable, Codable {
    let id = UUID()
    let category: RecommendationCategory
    let title: String
    let description: String
    let action: String? // Что конкретно делать
    let emoji: String
    let priority: Int // 1-5, где 5 самое важное
}

/// Категория рекомендации
enum RecommendationCategory: String, CaseIterable, Codable {
    case relationships = "Отношения"
    case career = "Карьера"
    case health = "Здоровье"
    case creativity = "Творчество"
    case spirituality = "Духовность"
    case communication = "Общение"

    var icon: String {
        switch self {
        case .relationships: return "heart.fill"
        case .career: return "briefcase.fill"
        case .health: return "leaf.fill"
        case .creativity: return "paintbrush.fill"
        case .spirituality: return "star.fill"
        case .communication: return "message.fill"
        }
    }

    var color: Color {
        switch self {
        case .relationships: return .neonPink
        case .career: return .fireElement
        case .health: return .earthElement
        case .creativity: return .cosmicViolet
        case .spirituality: return .starYellow
        case .communication: return .airElement
        }
    }
}

// MARK: - Extensions

extension Transit {
    /// Краткое описание транзита для карточки
    var shortDescription: String {
        if let natalPlanet = natalPlanet {
            return "\(transitingPlanet.displayName) \(aspectType.symbol) \(natalPlanet.displayName)"
        } else {
            return "\(transitingPlanet.displayName) \(aspectType.displayName)"
        }
    }

    /// Полное астрологическое описание
    var fullDescription: String {
        if let natalPlanet = natalPlanet {
            return "\(transitingPlanet.displayName) образует \(aspectType.displayName) к натальному \(natalPlanet.displayName)"
        } else {
            return "\(transitingPlanet.displayName) \(aspectType.displayName)"
        }
    }

    /// Время до пика или после пика
    var timeToFromPeak: String {
        let now = Date()
        let interval = peak.timeIntervalSince(now)

        if interval > 0 {
            // До пика
            let days = Int(interval / 86400)
            if days == 0 {
                let hours = Int(interval / 3600)
                return "пик через \(hours)ч"
            } else {
                return "пик через \(days)д"
            }
        } else {
            // После пика
            let days = Int(-interval / 86400)
            if days == 0 {
                let hours = Int(-interval / 3600)
                return "пик \(hours)ч назад"
            } else {
                return "пик \(days)д назад"
            }
        }
    }
}

extension DailyInsight {
    /// Получить самые важные транзиты для отображения
    func getTopTransits(limit: Int) -> [Transit] {
        return keyTransits
            .sorted { lhs, rhs in
                if lhs.impactLevel.priority != rhs.impactLevel.priority {
                    return lhs.impactLevel.priority > rhs.impactLevel.priority
                }
                return lhs.intensity > rhs.intensity
            }
            .prefix(limit)
            .map { $0 }
    }

    /// Получить рекомендации по приоритету
    func getTopRecommendations(limit: Int) -> [DailyRecommendation] {
        return recommendations
            .sorted { $0.priority > $1.priority }
            .prefix(limit)
            .map { $0 }
    }
}