//
//  EmotionalModels.swift
//  Astrolog
//
//  Created by Claude on 26.10.2025.
//

// Core/Models/EmotionalModels.swift
import Foundation
import SwiftUI

// MARK: - Core Emotional Structures

/// Эмоциональная подпись планеты в знаке
struct EmotionalSignature {
    let coreEmotion: CoreEmotion
    let expressionStyle: EmotionalExpressionStyle
    let emotionalNeeds: [EmotionalNeed]
    let triggers: [EmotionalTrigger]
    let healing: HealingApproach
}

/// Базовая эмоция
struct CoreEmotion {
    let name: String
    let simpleDescription: String
    let complexDescription: String
    let intensity: Double // 0-1
    let stability: Double // 0-1

    var essence: String { simpleDescription }
    var psychologicalFunction: String { complexDescription }
    var moodInfluence: MoodImpact {
        MoodImpact(
            positiveShift: intensity * stability,
            negativeShift: intensity * (1 - stability),
            energyChange: intensity,
            stabilityEffect: stability
        )
    }
}

/// Стиль эмоционального выражения
struct EmotionalExpressionStyle {
    let name: String
    let spontaneity: Double // Спонтанность выражения (0-1)
    let intensity: Double // Интенсивность выражения (0-1)
    let duration: Double // Длительность переживания (0-1)
    let psychologicalMechanism: String // Психологический механизм
}

/// Эмоциональная потребность
struct EmotionalNeed {
    let category: EmotionalNeedCategory
    let description: String
    let humanAdvice: String
    let technicalAdvice: String
    let practicalAction: String
    let expectedBenefit: String
    let priority: Int // 1-5
}

enum EmotionalNeedCategory {
    case recognition, safety, understanding, love, action, growth
    case structure, freedom, transcendence, transformation
    case comfort, variety, nurturing, appreciation, usefulness
    case harmony, depth, adventure, accomplishment, uniqueness, connection
}

/// Эмоциональный триггер
struct EmotionalTrigger {
    let name: String
    let description: String
    let intensity: Double
    let commonSituations: [String]
    let copingStrategies: [String]
}

/// Подход к исцелению
struct HealingApproach {
    let primaryApproach: String
    let simpleDescription: String
    let technicalDescription: String
    let practicalSteps: [String]
    let expectedTimeframe: String
    let supportiveActivities: [String]

    static let `default` = HealingApproach(
        primaryApproach: "Комплексный подход",
        simpleDescription: "Многосторонее исцеление",
        technicalDescription: "Интегративный метод восстановления",
        practicalSteps: ["Самоанализ", "Практические упражнения"],
        expectedTimeframe: "1-3 месяца",
        supportiveActivities: ["Медитация", "Терапия"]
    )

    static func blend(_ approach1: HealingApproach, _ approach2: HealingApproach) -> HealingApproach {
        return HealingApproach(
            primaryApproach: "\(approach1.primaryApproach) + \(approach2.primaryApproach)",
            simpleDescription: "Комбинированный подход к исцелению",
            technicalDescription: "Синтез \(approach1.primaryApproach.lowercased()) и \(approach2.primaryApproach.lowercased())",
            practicalSteps: Array(Set(approach1.practicalSteps + approach2.practicalSteps)),
            expectedTimeframe: "2-4 недели",
            supportiveActivities: Array(Set(approach1.supportiveActivities + approach2.supportiveActivities))
        )
    }
}

// MARK: - Planetary Emotions

/// Планетарная эмоция
struct PlanetaryEmotion {
    let archetype: String
    let essence: String
    let core: CoreEmotion
    let baseIntensity: Double
    let keywords: [String]
    let needs: [EmotionalNeed]
    let transformationCapacity: Double

    func compatibilityWith(_ other: PlanetaryEmotion) -> Double {
        // Базовая совместимость эмоций
        let intensityCompatibility = 1.0 - abs(baseIntensity - other.baseIntensity)
        let stabilityCompatibility = 1.0 - abs(core.stability - other.core.stability)
        return (intensityCompatibility + stabilityCompatibility) / 2.0
    }

    func tensionsWith(_ other: PlanetaryEmotion, aspect: AspectType) -> [EmotionalTension] {
        var tensions: [EmotionalTension] = []

        if aspect == .square || aspect == .opposition {
            if abs(baseIntensity - other.baseIntensity) > 0.4 {
                tensions.append(EmotionalTension(
                    type: .intensityClash,
                    description: "Конфликт интенсивностей между \(archetype) и \(other.archetype)",
                    severity: abs(baseIntensity - other.baseIntensity),
                    integrationStrategy: "Найти баланс между \(essence) и \(other.essence)"
                ))
            }
        }

        return tensions
    }
}

/// Эмоциональное напряжение
struct EmotionalTension {
    let type: EmotionalTensionType
    let description: String
    let severity: Double // 0-1
    let integrationStrategy: String
}

enum EmotionalTensionType {
    case intensityClash
    case stabilityConflict
    case expressionIncompatibility
    case needsConflict
}

/// Выражение эмоций знака зодиака
struct SignEmotionalExpression {
    let style: EmotionalExpressionStyle
    let core: CoreEmotion
    let needs: [EmotionalNeed]

    var expression: String { core.simpleDescription }
    var archetypeExpression: String { core.complexDescription }
}

// MARK: - Enhanced Interpretations

/// Эмоционально обогащенная интерпретация
struct EmotionallyEnhancedInterpretation {
    let baseText: String
    let emotionalLayer: EmotionalLayer
    let practicalEmotionalAdvice: [EmotionalAdvice]
    let emotionalResonance: EmotionalResonanceMetrics
    let moodImpact: MoodImpact
    let healingGuidance: HealingGuidance

    var fullInterpretation: String {
        return baseText + "\n\n" + emotionalLayer.emotionalNuance + "\n\n" + emotionalLayer.feelingDescription
    }
}

/// Эмоциональный слой интерпретации
struct EmotionalLayer {
    let emotionalNuance: String
    let feelingDescription: String
    let emotionalAdvice: String
    let empathyConnection: EmpathyConnection
}

/// Эмоциональный совет
struct EmotionalAdvice {
    let category: EmotionalNeedCategory
    let suggestion: String
    let practicalStep: String
    let emotionalBenefit: String
}

/// Метрики эмоционального резонанса
struct EmotionalResonanceMetrics {
    let intensity: Double // Интенсивность эмоционального воздействия
    let stability: Double // Стабильность эмоционального состояния
    let accessibility: Double // Доступность для осознания
    let integrationDifficulty: Double // Сложность интеграции
}

/// Воздействие на настроение
struct MoodImpact {
    let positiveShift: Double // Положительное влияние на настроение
    let negativeShift: Double // Отрицательное влияние
    let energyChange: Double // Изменение уровня энергии
    let stabilityEffect: Double // Влияние на эмоциональную стабильность

    var positive: Double { positiveShift }
    var negative: Double { negativeShift }
    var energy: Double { energyChange }
    var stability: Double { stabilityEffect }
}

/// Руководство по исцелению
struct HealingGuidance {
    let primaryMethod: String
    let description: String
    let practicalSteps: [String]
    let timeframe: String
    let supportiveActivities: [String]
}

/// Связь эмпатии
struct EmpathyConnection {
    let resonancePhrase: String // Фраза резонанса с пользователем
    let validationMessage: String // Валидация чувств
    let encouragement: String // Поддержка и ободрение
}

// MARK: - Transit Emotional Profiles

/// Эмоциональный профиль транзита
struct TransitEmotionalProfile {
    let emotionalTheme: EmotionalTheme
    let feelingTones: [FeelingTone]
    let emotionalChallenge: EmotionalChallenge?
    let emotionalOpportunity: EmotionalOpportunity?
    let supportiveActions: [String]
    let affirmation: String
}

/// Эмоциональная тема
struct EmotionalTheme {
    let name: String
    let description: String
    let keywords: [String]
    let evolutionaryPurpose: String

    var isHarmonious: Bool { keywords.contains { harmonousKeywords.contains($0) } }
    var isChallenging: Bool { keywords.contains { challengingKeywords.contains($0) } }

    var integrationPhases: [String] {
        return ["Осознание", "Принятие", "Интеграция", "Трансформация"]
    }

    var keyMilestones: [String] {
        return ["Первое осознание темы", "Эмоциональное принятие", "Практическая интеграция"]
    }

    var selfCareGuidance: String {
        if isHarmonious {
            return "Наслаждайтесь этим временем гармонии и используйте его для восстановления"
        } else if isChallenging {
            return "Будьте особенно бережны к себе в это время трансформации"
        } else {
            return "Поддерживайте баланс между активностью и отдыхом"
        }
    }

    var recommendedSelfCareAction: String {
        if isHarmonious {
            return "Творческая деятельность или время с близкими"
        } else {
            return "Медитация, терапия или другие поддерживающие практики"
        }
    }

    func recommendationsFor(language: LanguageStyle) -> [String] {
        if language == .simple {
            return [
                "Будьте терпеливы к себе",
                "Доверяйте процессу изменений",
                "Обращайтесь за поддержкой когда нужно"
            ]
        } else {
            return [
                "Интегрируйте эмоциональные переживания осознанно",
                "Используйте терапевтические техники для проработки",
                "Развивайте эмоциональный интеллект"
            ]
        }
    }

    static let neutral = EmotionalTheme(
        name: "Нейтральная",
        description: "Сбалансированное эмоциональное состояние",
        keywords: ["баланс", "стабильность"],
        evolutionaryPurpose: "Поддержание эмоционального равновесия"
    )

    private let harmonousKeywords = ["гармония", "поддержка", "исцеление", "рост", "любовь"]
    private let challengingKeywords = ["напряжение", "конфликт", "трансформация", "испытание"]
}

/// Эмоциональные тона
enum FeelingTone {
    case uplifting, harmonious, flowing
    case intense, transformative, confronting
    case deep, evolutionary, mystical
    case balanced, integrative, subtle
}

/// Эмоциональный вызов
struct EmotionalChallenge {
    let description: String
    let copingStrategies: [String]
    let warningSign: String?
    let supportNeeded: String
}

/// Эмоциональная возможность
struct EmotionalOpportunity {
    let description: String
    let actionSteps: [String]
    let potentialOutcome: String

    func description(for language: LanguageStyle) -> String {
        return language == .simple ?
            "Возможность для \(potentialOutcome.lowercased())" :
            "Развитие через \(description)"
    }
}

/// Динамика транзитных эмоций
struct TransitEmotionalDynamics {
    let theme: EmotionalTheme
    let feelingTones: [FeelingTone]
    let intensityLevel: Double
    let duration: EmotionalDuration
    let integrationPath: IntegrationPath
}

/// Длительность эмоционального воздействия
struct EmotionalDuration {
    let onset: TimeInterval
    let peak: TimeInterval
    let resolution: TimeInterval

    enum TimeUnit {
        case hours(Int)
        case days(Int)
        case weeks(Int)

        var timeInterval: TimeInterval {
            switch self {
            case .hours(let h): return TimeInterval(h * 3600)
            case .days(let d): return TimeInterval(d * 86400)
            case .weeks(let w): return TimeInterval(w * 604800)
            }
        }
    }

    init(onset: TimeUnit, peak: TimeUnit, resolution: TimeUnit) {
        self.onset = onset.timeInterval
        self.peak = peak.timeInterval
        self.resolution = resolution.timeInterval
    }
}

/// Путь интеграции
struct IntegrationPath {
    let phases: [String]
    let keyMilestones: [String]
    let supportNeeded: [String]
    let expectedOutcome: String
}

// MARK: - Aspect Emotional Resonance

/// Эмоциональный резонанс аспекта
struct AspectEmotionalResonance {
    let resonanceType: AspectResonanceType
    let emotionalQuality: EmotionalQuality
    let humanDescription: String
    let integrationAdvice: String
    let warningSignals: [String]
    let growthOpportunities: [String]
}

enum AspectResonanceType {
    case harmonic, dynamic, transformative, integrative
}

enum EmotionalQuality {
    case flowing, tense, intense, balanced, challenging, supportive
}

// MARK: - Daily Emotional Mapping

/// Дневная эмоциональная карта
struct DailyEmotionalMap {
    let date: Date
    let dominantTheme: EmotionalTheme
    let influences: [EmotionalInfluence]
    let forecast: EmotionalForecast
    let wellbeingAdvice: [EmotionalWellbeingAdvice]
    let emotionalWeather: EmotionalWeather
}

/// Эмоциональное влияние
struct EmotionalInfluence {
    let source: InfluenceSource
    let emotionalProfile: TransitEmotionalProfile
    let intensity: Double
    let timeframe: DateInterval
    let personalRelevance: Double // Насколько лично значимо для пользователя
}

enum InfluenceSource {
    case transit(Transit)
    case lunarPhase(LunarPhase)
    case personal(PersonalInsight)
}

/// Эмоциональный прогноз
struct EmotionalForecast {
    let overallTone: String
    let keyInsights: [String]
    let recommendations: [String]
    let warningAreas: [String]
    let opportunityAreas: [String]
}

/// Совет по эмоциональному благополучию
struct EmotionalWellbeingAdvice {
    let category: WellbeingCategory
    let title: String
    let description: String
    let practicalAction: String
    let emotionalBenefit: String
}

enum WellbeingCategory {
    case selfCare, emotional, physical, mental, spiritual, social
}

/// Эмоциональная погода
enum EmotionalWeather {
    case calm, mixed, intense, stormy

    var description: String {
        switch self {
        case .calm: return "Спокойная эмоциональная атмосфера"
        case .mixed: return "Переменчивая эмоциональная погода"
        case .intense: return "Интенсивные эмоциональные переживания"
        case .stormy: return "Бурные эмоциональные потоки"
        }
    }

    var icon: String {
        switch self {
        case .calm: return "🌤"
        case .mixed: return "⛅️"
        case .intense: return "🌟"
        case .stormy: return "⛈"
        }
    }
}

// MARK: - User Emotional State

/// Эмоциональное состояние пользователя
struct EmotionalState {
    let currentMood: Mood
    let stressLevel: Double // 0-1
    let energyLevel: Double // 0-1
    let primaryConcern: String
    let recommendedAction: String
    let empathyPhrase: String
}

enum Mood {
    case joyful, content, neutral, anxious, sad, angry, excited, peaceful

    var description: String {
        switch self {
        case .joyful: return "радостное"
        case .content: return "удовлетворенное"
        case .neutral: return "нейтральное"
        case .anxious: return "тревожное"
        case .sad: return "грустное"
        case .angry: return "гневное"
        case .excited: return "возбужденное"
        case .peaceful: return "спокойное"
        }
    }
}

// MARK: - Supporting Types

/// Эмоциональный контекст
struct EmotionalContext {
    let dominantEmotion: CoreEmotion
    let supportingEmotions: [CoreEmotion]
    let conflictingEmotions: [CoreEmotion]
    let integrationAdvice: String
}

/// Влияние настроения
struct MoodInfluence {
    let source: String
    let impact: MoodImpact
    let duration: TimeInterval
    let integrationTips: [String]
}

/// Эмоциональное взаимодействие
struct EmotionalInteraction {
    let harmonyLevel: Double
    let tensionPoints: [EmotionalTension]
    let integrationOpportunity: String
    let transformationPotential: Double
}

/// Данные эмоционального резонанса
struct EmotionalResonanceData {
    let intensity: Double
    let stability: Double
    let accessibility: Double
    let complexity: Double
}

// MARK: - Empathy Engine

/// Движок эмпатии
class EmpathyEngine {
    func generateEmpathyConnection(signature: EmotionalSignature) -> EmpathyConnection {
        let emotion = signature.coreEmotion.name.lowercased()

        return EmpathyConnection(
            resonancePhrase: "Мы понимаем, что сейчас вы можете чувствовать \(emotion)",
            validationMessage: "Ваши чувства абсолютно естественны и имеют глубокий смысл",
            encouragement: "Доверьтесь процессу - вы справитесь с этим"
        )
    }
}