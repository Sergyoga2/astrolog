//
//  RecommendationEngine.swift
//  Astrolog
//
//  Created by Claude on 26.10.2025.
//

// Core/Services/RecommendationEngine.swift
import Foundation
import SwiftUI
import Combine

// typealias Element = ZodiacSign.Element // Удалено из-за конфликтов

/// Движок умных рекомендаций на основе транзитов и персональной карты
class RecommendationEngine: ObservableObject {

    // MARK: - Published Properties
    @Published var dailyRecommendations: [DailyRecommendation] = []
    @Published var isGenerating = false

    // MARK: - Private Properties
    private let humanLanguageService: HumanLanguageService
    private let interpretationEngine: InterpretationEngine

    // Базы знаний для рекомендаций
    private let transitRecommendations = TransitRecommendationDatabase()
    private let personalityInsights = PersonalityInsightDatabase()

    // MARK: - Initialization
    init() {
        self.humanLanguageService = HumanLanguageService()
        self.interpretationEngine = InterpretationEngine()
    }

    // MARK: - Public Methods

    /// Генерировать персональные рекомендации на основе транзитов и натальной карты
    func generateRecommendations(
        for birthChart: BirthChart,
        transits: [Transit],
        displayMode: DisplayMode = .human
    ) async {
        await MainActor.run {
            isGenerating = true
        }

        var recommendations: [DailyRecommendation] = []

        // 1. Анализируем каждый транзит
        for transit in transits.prefix(5) {
            if let recommendation = await createTransitRecommendation(
                transit: transit,
                birthChart: birthChart,
                displayMode: displayMode
            ) {
                recommendations.append(recommendation)
            }
        }

        // 2. Добавляем общие рекомендации на основе натальной карты
        let personalRecommendations = await generatePersonalRecommendations(
            birthChart: birthChart,
            transits: transits,
            displayMode: displayMode
        )
        recommendations.append(contentsOf: personalRecommendations)

        // 3. Добавляем контекстуальные рекомендации (время года, день недели)
        let contextualRecommendations = generateContextualRecommendations(
            date: Date(),
            displayMode: displayMode
        )
        recommendations.append(contentsOf: contextualRecommendations)

        // 4. Приоритизируем и фильтруем
        let finalRecommendations = prioritizeRecommendations(recommendations)

        await MainActor.run {
            self.dailyRecommendations = finalRecommendations
            self.isGenerating = false
        }
    }

    // MARK: - Private Methods

    private func createTransitRecommendation(
        transit: Transit,
        birthChart: BirthChart,
        displayMode: DisplayMode
    ) async -> DailyRecommendation? {
        // Получаем базовые данные о транзите
        let transitKey = TransitKey(
            transitingPlanet: transit.transitingPlanet,
            natalPlanet: transit.natalPlanet,
            aspect: transit.aspectType,
            influence: transit.influence
        )

        guard let baseRecommendation = transitRecommendations.getRecommendation(for: transitKey) else {
            return nil
        }

        // Персонализируем на основе натальной карты
        let personalizedContent = personalizeRecommendation(
            base: baseRecommendation,
            transit: transit,
            birthChart: birthChart,
            displayMode: displayMode
        )

        return DailyRecommendation(
            category: personalizedContent.category,
            title: personalizedContent.title,
            description: personalizedContent.description,
            action: personalizedContent.action,
            emoji: personalizedContent.emoji,
            priority: calculatePriority(for: transit, base: baseRecommendation)
        )
    }

    private func personalizeRecommendation(
        base: BaseRecommendation,
        transit: Transit,
        birthChart: BirthChart,
        displayMode: DisplayMode
    ) -> PersonalizedRecommendation {
        // Адаптируем язык под режим отображения
        let language = getLanguageStyle(for: displayMode)

        // Учитываем контекст натальной карты
        let personalContext = getPersonalContext(from: birthChart, for: transit)

        // Генерируем персонализированный контент
        let title = personalizeTitle(base.title, context: personalContext, language: language)
        let description = personalizeDescription(base.description, context: personalContext, language: language, transit: transit)
        let action = personalizeAction(base.action, context: personalContext, language: language)

        return PersonalizedRecommendation(
            category: base.category,
            title: title,
            description: description,
            action: action,
            emoji: selectEmoji(for: transit, base: base)
        )
    }

    private func generatePersonalRecommendations(
        birthChart: BirthChart,
        transits: [Transit],
        displayMode: DisplayMode
    ) async -> [DailyRecommendation] {
        var recommendations: [DailyRecommendation] = []

        // Рекомендации на основе Солнца
        if let sunRecommendation = createSunBasedRecommendation(birthChart: birthChart, displayMode: displayMode) {
            recommendations.append(sunRecommendation)
        }

        // Рекомендации на основе Луны и эмоционального состояния
        if let moonRecommendation = createMoonBasedRecommendation(birthChart: birthChart, transits: transits, displayMode: displayMode) {
            recommendations.append(moonRecommendation)
        }

        // Рекомендации на основе доминирующих элементов
        if let elementRecommendation = createElementBasedRecommendation(birthChart: birthChart, displayMode: displayMode) {
            recommendations.append(elementRecommendation)
        }

        return recommendations
    }

    private func createSunBasedRecommendation(birthChart: BirthChart, displayMode: DisplayMode) -> DailyRecommendation? {
        guard let sun = birthChart.planets.first(where: { $0.type == .sun }) else { return nil }

        let sunTranslation = humanLanguageService.translateZodiacSign(sun.zodiacSign)
        let language = getLanguageStyle(for: displayMode)

        let title = language == .simple ? "Развивайте свою силу" : "Активизация солярной энергии"
        let description = language == .simple ?
            "Сегодня отличный день для проявления вашей природной \(sunTranslation.personality.lowercased())" :
            "Солнце в \(sun.zodiacSign.displayName) поддерживает развитие ваших \(sunTranslation.strengths.first?.lowercased() ?? "лидерских") качеств"

        let action = language == .simple ?
            "Займитесь тем, что приносит вам радость и энергию" :
            "Сфокусируйтесь на проектах, требующих вашего уникального подхода"

        return DailyRecommendation(
            category: .creativity,
            title: title,
            description: description,
            action: action,
            emoji: humanLanguageService.signEmoji(sun.zodiacSign),
            priority: 3
        )
    }

    private func createMoonBasedRecommendation(birthChart: BirthChart, transits: [Transit], displayMode: DisplayMode) -> DailyRecommendation? {
        guard let moon = birthChart.planets.first(where: { $0.type == .moon }) else { return nil }

        let moonTranslation = humanLanguageService.translateZodiacSign(moon.zodiacSign)
        let language = getLanguageStyle(for: displayMode)

        // Учитываем транзиты к Луне
        let moonTransits = transits.filter { $0.natalPlanet == .moon }
        let isEmotionallyStressed = moonTransits.contains { $0.influence == .challenging }

        let title = language == .simple ?
            (isEmotionallyStressed ? "Береги эмоции" : "Следуй интуиции") :
            "Лунная поддержка"

        let description = language == .simple ?
            "Ваши эмоции сегодня особенно \(isEmotionallyStressed ? "чувствительны" : "мудры"). Прислушивайтесь к внутреннему голосу." :
            "Луна в \(moon.zodiacSign.displayName) \(isEmotionallyStressed ? "требует бережного отношения к эмоциональному состоянию" : "способствует развитию интуитивных способностей")"

        let action = isEmotionallyStressed ?
            "Уделите время релаксации и восстановлению" :
            "Доверьтесь своей интуиции в важных решениях"

        return DailyRecommendation(
            category: .health,
            title: title,
            description: description,
            action: action,
            emoji: "🌙",
            priority: isEmotionallyStressed ? 5 : 3
        )
    }

    private func createElementBasedRecommendation(birthChart: BirthChart, displayMode: DisplayMode) -> DailyRecommendation? {
        let elements = birthChart.getDominantElements()
        guard let dominantElement = elements.first else { return nil }

        let language = getLanguageStyle(for: displayMode)

        let (title, description, action, emoji) = getElementRecommendation(
            element: dominantElement,
            language: language
        )

        return DailyRecommendation(
            category: .spirituality,
            title: title,
            description: description,
            action: action,
            emoji: emoji,
            priority: 2
        )
    }

    private func getElementRecommendation(element: ZodiacSign.Element, language: LanguageStyle) -> (title: String, description: String, action: String, emoji: String) {
        switch (element, language) {
        case (.fire, .simple):
            return ("Действуй смело", "Ваша огненная энергия на пике", "Начните новые проекты", "🔥")
        case (.earth, .simple):
            return ("Практичность в деле", "Время для конкретных действий", "Займитесь практическими задачами", "🌱")
        case (.air, .simple):
            return ("Общение и идеи", "День для интеллектуального развития", "Изучайте новое и общайтесь", "💨")
        case (.water, .simple):
            return ("Чувствуй глубже", "Эмоциональная мудрость доступна", "Медитируйте и творите", "🌊")
        case (.fire, .complex):
            return ("Активизация огненной стихии", "Кардинальная энергия поддерживает инициативы", "Реализуйте лидерский потенциал", "🔥")
        case (.earth, .complex):
            return ("Материализация земных энергий", "Фиксированная энергия способствует стабильности", "Работайте над долгосрочными целями", "🌱")
        case (.air, .complex):
            return ("Ментальная активность", "Мутабельная энергия стимулирует коммуникацию", "Развивайте интеллектуальные связи", "💨")
        case (.water, .complex):
            return ("Эмоциональная глубина", "Водная стихия открывает интуитивные каналы", "Исследуйте подсознательные процессы", "🌊")
        }
    }

    private func generateContextualRecommendations(date: Date, displayMode: DisplayMode) -> [DailyRecommendation] {
        var recommendations: [DailyRecommendation] = []

        // Рекомендации на основе дня недели
        if let dayRecommendation = getDayOfWeekRecommendation(date: date, displayMode: displayMode) {
            recommendations.append(dayRecommendation)
        }

        // Сезонные рекомендации
        if let seasonRecommendation = getSeasonalRecommendation(date: date, displayMode: displayMode) {
            recommendations.append(seasonRecommendation)
        }

        return recommendations
    }

    private func getDayOfWeekRecommendation(date: Date, displayMode: DisplayMode) -> DailyRecommendation? {
        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: date)
        let language = getLanguageStyle(for: displayMode)

        switch weekday {
        case 1: // Воскресенье
            return DailyRecommendation(
                category: .spirituality,
                title: language == .simple ? "День восстановления" : "Солярный день отдыха",
                description: "Воскресенье — время для духовного обновления и отдыха",
                action: "Проведите время наедине с собой или близкими",
                emoji: "☀️",
                priority: 1
            )
        case 2: // Понедельник
            return DailyRecommendation(
                category: .career,
                title: language == .simple ? "Новое начало" : "Лунная активация",
                description: "Понедельник — идеальный день для новых начинаний",
                action: "Составьте план на неделю и начните важный проект",
                emoji: "🌙",
                priority: 2
            )
        default:
            return nil
        }
    }

    private func getSeasonalRecommendation(date: Date, displayMode: DisplayMode) -> DailyRecommendation? {
        let calendar = Calendar.current
        let month = calendar.component(.month, from: date)
        let language = getLanguageStyle(for: displayMode)

        switch month {
        case 12, 1, 2: // Зима
            return DailyRecommendation(
                category: .health,
                title: language == .simple ? "Зимнее восстановление" : "Сохранение внутренней энергии",
                description: "Зима — время для накопления сил и внутренней работы",
                action: "Уделите внимание медитации и планированию",
                emoji: "❄️",
                priority: 1
            )
        case 3, 4, 5: // Весна
            return DailyRecommendation(
                category: .creativity,
                title: language == .simple ? "Весенний рост" : "Активация творческих энергий",
                description: "Весна пробуждает творческие силы и новые возможности",
                action: "Начните новые проекты и знакомства",
                emoji: "🌱",
                priority: 2
            )
        default:
            return nil
        }
    }

    private func prioritizeRecommendations(_ recommendations: [DailyRecommendation]) -> [DailyRecommendation] {
        return recommendations
            .sorted { lhs, rhs in
                if lhs.priority != rhs.priority {
                    return lhs.priority > rhs.priority
                }
                return lhs.category.rawValue < rhs.category.rawValue
            }
            .prefix(6) // Ограничиваем количество
            .map { $0 }
    }

    // MARK: - Helper Methods

    private func getLanguageStyle(for displayMode: DisplayMode) -> LanguageStyle {
        switch displayMode {
        case .human, .beginner:
            return .simple
        case .intermediate:
            return .complex
        }
    }

    private func getPersonalContext(from birthChart: BirthChart, for transit: Transit) -> PersonalContext {
        return PersonalContext(
            sunSign: birthChart.planets.first { $0.type == .sun }?.zodiacSign ?? .aries,
            moonSign: birthChart.planets.first { $0.type == .moon }?.zodiacSign ?? .aries,
            ascendant: birthChart.ascendant,
            dominantElements: birthChart.getDominantElements()
        )
    }

    private func personalizeTitle(_ baseTitle: String, context: PersonalContext, language: LanguageStyle) -> String {
        // Простая персонализация заголовка
        return baseTitle
    }

    private func personalizeDescription(_ baseDescription: String, context: PersonalContext, language: LanguageStyle, transit: Transit) -> String {
        // Добавляем персональный контекст в описание
        let personalNote = language == .simple ?
            "Для вашего типа личности это особенно важно." :
            "С учетом вашего \(context.sunSign.displayName) Солнца, это влияние проявится через \(transit.influence.rawValue.lowercased()) энергии."

        return baseDescription + " " + personalNote
    }

    private func personalizeAction(_ baseAction: String?, context: PersonalContext, language: LanguageStyle) -> String? {
        return baseAction
    }

    private func selectEmoji(for transit: Transit, base: BaseRecommendation) -> String {
        return transit.emoji
    }

    private func calculatePriority(for transit: Transit, base: BaseRecommendation) -> Int {
        var priority = base.basePriority

        // Увеличиваем приоритет для мажорных транзитов
        priority += transit.impactLevel.priority

        // Учитываем влияние
        switch transit.influence {
        case .challenging:
            priority += 2
        case .transformative:
            priority += 1
        default:
            break
        }

        return min(priority, 5)
    }
}

// MARK: - Supporting Types

enum LanguageStyle {
    case simple
    case complex
}

struct PersonalContext {
    let sunSign: ZodiacSign
    let moonSign: ZodiacSign
    let ascendant: ZodiacSign
    let dominantElements: [ZodiacSign.Element]
}

struct PersonalizedRecommendation {
    let category: RecommendationCategory
    let title: String
    let description: String
    let action: String?
    let emoji: String
}

struct TransitKey: Hashable {
    let transitingPlanet: PlanetType
    let natalPlanet: PlanetType?
    let aspect: AspectType
    let influence: TransitInfluence
}

struct BaseRecommendation {
    let category: RecommendationCategory
    let title: String
    let description: String
    let action: String?
    let basePriority: Int
}

// MARK: - Knowledge Databases

class TransitRecommendationDatabase {
    private let recommendations: [TransitKey: BaseRecommendation]

    init() {
        var db: [TransitKey: BaseRecommendation] = [:]

        // Венера - гармоничные аспекты
        db[TransitKey(transitingPlanet: .venus, natalPlanet: .mars, aspect: .trine, influence: .harmonious)] =
            BaseRecommendation(
                category: .relationships,
                title: "Время для любви",
                description: "Гармоничная энергия между вашей привлекательностью и действием создает магнетизм",
                action: "Планируйте романтические встречи или творческие проекты",
                basePriority: 4
            )

        // Марс - напряженные аспекты
        db[TransitKey(transitingPlanet: .mars, natalPlanet: .mercury, aspect: .square, influence: .challenging)] =
            BaseRecommendation(
                category: .communication,
                title: "Осторожность в словах",
                description: "Импульсивная энергия может привести к конфликтам в общении",
                action: "Считайте до десяти перед важными разговорами",
                basePriority: 5
            )

        // Юпитер - расширяющие аспекты
        db[TransitKey(transitingPlanet: .jupiter, natalPlanet: .sun, aspect: .trine, influence: .harmonious)] =
            BaseRecommendation(
                category: .career,
                title: "Возможности роста",
                description: "Юпитер открывает двери к новым возможностям и успеху",
                action: "Подавайте заявки на повышение или новые проекты",
                basePriority: 4
            )

        self.recommendations = db
    }

    func getRecommendation(for key: TransitKey) -> BaseRecommendation? {
        return recommendations[key]
    }
}

class PersonalityInsightDatabase {
    // База данных инсайтов на основе натальной карты
    func getInsights(for birthChart: BirthChart) -> [String] {
        return [
            "Ваша индивидуальность проявляется через уникальную комбинацию планетарных энергий",
            "Сильные стороны натальной карты можно развивать через осознанную работу",
            "Вызовы в карте — это возможности для роста и трансформации"
        ]
    }
}

// MARK: - Extensions

extension BirthChart {
    func getDominantElements() -> [ZodiacSign.Element] {
        var elementCounts: [ZodiacSign.Element: Int] = [
            .fire: 0, .earth: 0, .air: 0, .water: 0
        ]

        // Считаем планеты
        for planet in planets {
            let element = planet.zodiacSign.element
            elementCounts[element] = (elementCounts[element] ?? 0) + 1
        }

        // Добавляем Асцендент
        let ascElement = ascendant.element
        elementCounts[ascElement] = (elementCounts[ascElement] ?? 0) + 1

        // Сортируем по количеству
        return elementCounts
            .sorted { $0.value > $1.value }
            .map { $0.key }
    }
}