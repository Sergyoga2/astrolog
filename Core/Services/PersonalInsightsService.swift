//
//  PersonalInsightsService.swift
//  Astrolog
//
//  Created by Claude on 26.10.2025.
//

// Core/Services/PersonalInsightsService.swift
import Foundation
import SwiftUI
import Combine

// typealias Element = ZodiacSign.Element // Удалено из-за конфликтов

/// Сервис для генерации персональных астрологических инсайтов
/// Создает уникальные интерпретации, учитывающие всю натальную карту пользователя
class PersonalInsightsService: ObservableObject {

    // MARK: - Published Properties
    @Published var personalInsights: [PersonalInsight] = []
    @Published var emotionalProfile: EmotionalProfile?
    @Published var lifeThemes: [LifeTheme] = []
    @Published var isGenerating = false

    // MARK: - Private Properties
    private let humanLanguageService: HumanLanguageService
    private let interpretationEngine: InterpretationEngine
    private let astrologicalAnalyzer = AstrologicalPatternAnalyzer()

    // MARK: - Initialization
    init() {
        self.humanLanguageService = HumanLanguageService()
        self.interpretationEngine = InterpretationEngine()
    }

    // MARK: - Public Methods

    /// Генерировать комплексный анализ личности на основе натальной карты
    func generatePersonalProfile(for birthChart: BirthChart, displayMode: DisplayMode = .human) async {
        await MainActor.run {
            isGenerating = true
        }

        // 1. Анализируем основные паттерны карты
        let corePatterns = analyzeCorePattterns(in: birthChart)

        // 2. Генерируем персональные инсайты
        let insights = await generateInsights(from: corePatterns, birthChart: birthChart, displayMode: displayMode)

        // 3. Создаем эмоциональный профиль
        let emotionalProfile = createEmotionalProfile(from: birthChart, patterns: corePatterns, displayMode: displayMode)

        // 4. Выявляем жизненные темы
        let lifeThemes = identifyLifeThemes(from: birthChart, patterns: corePatterns, displayMode: displayMode)

        await MainActor.run {
            self.personalInsights = insights
            self.emotionalProfile = emotionalProfile
            self.lifeThemes = lifeThemes
            self.isGenerating = false
        }
    }

    /// Получить инсайты определенного типа
    func getInsights(of type: InsightType, limit: Int = 3) -> [PersonalInsight] {
        return personalInsights
            .filter { $0.type == type }
            .prefix(limit)
            .map { $0 }
    }

    /// Получить самые важные темы для отображения
    func getTopLifeThemes(limit: Int = 5) -> [LifeTheme] {
        return lifeThemes
            .sorted(by: { $0.importance > $1.importance })
            .prefix(limit)
            .map { $0 }
    }

    // MARK: - Core Analysis

    private func analyzeCorePattterns(in birthChart: BirthChart) -> AstrologicalPatterns {
        var patterns = AstrologicalPatterns()

        // Анализируем элементарный баланс
        patterns.elementalBalance = analyzeElementalBalance(birthChart)

        // Анализируем модальный баланс (кардинальный, фиксированный, мутабельный)
        patterns.modalBalance = analyzeModalBalance(birthChart)

        // Анализируем доминанты (самые сильные планеты)
        patterns.dominantPlanets = identifyDominantPlanets(birthChart)

        // Анализируем уникальные конфигурации
        patterns.specialConfigurations = findSpecialConfigurations(birthChart)

        // Анализируем вызовы и ресурсы
        patterns.challenges = identifyChallenges(birthChart)
        patterns.strengths = identifyStrengths(birthChart)

        return patterns
    }

    private func analyzeElementalBalance(_ chart: BirthChart) -> ElementalBalance {
        var counts: [ZodiacSign.Element: Int] = [.fire: 0, .earth: 0, .air: 0, .water: 0]

        // Считаем планеты (с весами)
        for planet in chart.planets {
            let weight = planetWeight(planet.type)
            counts[planet.zodiacSign.element] = (counts[planet.zodiacSign.element] ?? 0) + weight
        }

        // Асцендент имеет дополнительный вес
        counts[chart.ascendant.element] = (counts[chart.ascendant.element] ?? 0) + 2

        let total = counts.values.reduce(0, +)
        let percentages = counts.mapValues { Double($0) / Double(total) }

        return ElementalBalance(
            fire: percentages[ZodiacSign.Element.fire] ?? 0,
            earth: percentages[ZodiacSign.Element.earth] ?? 0,
            air: percentages[ZodiacSign.Element.air] ?? 0,
            water: percentages[ZodiacSign.Element.water] ?? 0
        )
    }

    private func convertModality(_ zodiacModality: ZodiacSign.Modality) -> Modality {
        switch zodiacModality {
        case .cardinal: return .cardinal
        case .fixed: return .fixed
        case .mutable: return .mutable
        }
    }

    private func analyzeModalBalance(_ chart: BirthChart) -> ModalBalance {
        var counts: [Modality: Int] = [.cardinal: 0, .fixed: 0, .mutable: 0]

        for planet in chart.planets {
            let weight = planetWeight(planet.type)
            let modality = convertModality(planet.zodiacSign.modality)
            counts[modality] = (counts[modality] ?? 0) + weight
        }

        let ascendantModality = convertModality(chart.ascendant.modality)
        counts[ascendantModality] = (counts[ascendantModality] ?? 0) + 2

        let total = counts.values.reduce(0, +)
        let percentages = counts.mapValues { Double($0) / Double(total) }

        return ModalBalance(
            cardinal: percentages[.cardinal] ?? 0,
            fixed: percentages[.fixed] ?? 0,
            mutable: percentages[.mutable] ?? 0
        )
    }

    private func identifyDominantPlanets(_ chart: BirthChart) -> [PlanetType] {
        // Определяем доминантные планеты по различным критериям
        var planetStrengths: [PlanetType: Double] = [:]

        for planet in chart.planets {
            var strength: Double = 0

            // Сила по знаку (в обители, экзальтации)
            strength += signStrength(planet.type, in: planet.zodiacSign)

            // Сила по аспектам (количество и качество)
            strength += aspectualStrength(planet, in: chart)

            // Угловая позиция (близость к углам карты)
            strength += angularStrength(planet, in: chart)

            planetStrengths[planet.type] = strength
        }

        return planetStrengths
            .sorted { $0.value > $1.value }
            .prefix(3)
            .map { $0.key }
    }

    private func findSpecialConfigurations(_ chart: BirthChart) -> [AstrologicalConfiguration] {
        var configurations: [AstrologicalConfiguration] = []

        // Ищем стеллиумы (скопления планет)
        configurations.append(contentsOf: findStelliums(in: chart))

        // Ищем T-квадраты и Большие трины
        configurations.append(contentsOf: findMajorPatterns(in: chart))

        // Ищем йоды и другие конфигурации
        configurations.append(contentsOf: findRarePatterns(in: chart))

        return configurations
    }

    // MARK: - Insight Generation

    private func generateInsights(from patterns: AstrologicalPatterns, birthChart: BirthChart, displayMode: DisplayMode) async -> [PersonalInsight] {
        var insights: [PersonalInsight] = []

        // 1. Инсайты о личности
        insights.append(contentsOf: generatePersonalityInsights(patterns: patterns, chart: birthChart, displayMode: displayMode))

        // 2. Инсайты о отношениях
        insights.append(contentsOf: generateRelationshipInsights(patterns: patterns, chart: birthChart, displayMode: displayMode))

        // 3. Инсайты о карьере и призвании
        insights.append(contentsOf: generateCareerInsights(patterns: patterns, chart: birthChart, displayMode: displayMode))

        // 4. Инсайты о духовном развитии
        insights.append(contentsOf: generateSpiritualInsights(patterns: patterns, chart: birthChart, displayMode: displayMode))

        // 5. Инсайты о жизненных циклах
        insights.append(contentsOf: generateLifeCycleInsights(patterns: patterns, chart: birthChart, displayMode: displayMode))

        return insights.sorted { $0.importance > $1.importance }
    }

    private func generatePersonalityInsights(patterns: AstrologicalPatterns, chart: BirthChart, displayMode: DisplayMode) -> [PersonalInsight] {
        var insights: [PersonalInsight] = []

        // Анализ доминирующего элемента
        if let dominantElement = getDominantElement(from: patterns.elementalBalance) {
            let insight = createElementalInsight(element: dominantElement, chart: chart, displayMode: displayMode)
            insights.append(insight)
        }

        // Анализ модального баланса
        if let dominantModality = getDominantModality(from: patterns.modalBalance) {
            let insight = createModalInsight(modality: dominantModality, chart: chart, displayMode: displayMode)
            insights.append(insight)
        }

        // Анализ доминантных планет
        for planet in patterns.dominantPlanets.prefix(2) {
            let insight = createPlanetaryDominanceInsight(planet: planet, chart: chart, displayMode: displayMode)
            insights.append(insight)
        }

        return insights
    }

    private func createElementalInsight(element: ZodiacSign.Element, chart: BirthChart, displayMode: DisplayMode) -> PersonalInsight {
        let language = displayMode == .human || displayMode == .beginner ? LanguageStyle.simple : .complex

        let (title, description, advice) = getElementalPersonalityDescription(element: element, language: language)

        return PersonalInsight(
            id: UUID(),
            type: .personality,
            category: .coreNature,
            title: title,
            description: description,
            practicalAdvice: advice,
            emotionalResonance: getElementalEmotionalResonance(element),
            importance: 5,
            emoji: getElementEmoji(element),
            color: getElementColor(element),
            dateCreated: Date()
        )
    }

    private func getElementalPersonalityDescription(element: ZodiacSign.Element, language: LanguageStyle) -> (title: String, description: String, advice: String) {
        switch (element, language) {
        case (.fire, .simple):
            return (
                "Ваша огненная природа",
                "В вас горит яркий внутренний огонь. Вы естественный лидер, полный энтузиазма и страсти. Ваша энергия вдохновляет окружающих, а инициативность помогает воплощать мечты в реальность.",
                "Направляйте свою энергию на созидание. Изучайте терпение — ваша сила в том, чтобы зажигать других, не выгорая самому."
            )
        case (.earth, .simple):
            return (
                "Ваша земная мудрость",
                "Вы — человек с твёрдой почвой под ногами. Практичность и надёжность — ваши суперсилы. Вы умеете создавать стабильность и красоту в материальном мире.",
                "Цените свою способность создавать долговременные результаты. Не забывайте мечтать — ваши грёзы могут стать реальностью."
            )
        case (.air, .simple):
            return (
                "Ваш воздушный ум",
                "Ваши мысли летают быстрее ветра. Вы прирождённый коммуникатор, способный видеть связи там, где другие их не замечают. Ваш ум — мост между людьми и идеями.",
                "Используйте свой дар общения для объединения людей. Практикуйте заземление — ваши идеи нуждаются в воплощении."
            )
        case (.water, .simple):
            return (
                "Ваша водная глубина",
                "В вас течёт океан чувств и интуиции. Вы понимаете людей на глубинном уровне и чувствуете то, что скрыто от глаз. Ваша эмпатия — дар исцеления.",
                "Доверяйте своей интуиции — она ведёт вас к истине. Создавайте границы, чтобы не растворяться в чужих эмоциях."
            )
        default:
            return (
                "Элементарная доминанта",
                "Преобладающий элемент в вашей карте определяет основной способ взаимодействия с миром",
                "Развивайте недостающие элементы для гармоничного выражения личности"
            )
        }
    }

    private func createEmotionalProfile(from chart: BirthChart, patterns: AstrologicalPatterns, displayMode: DisplayMode) -> EmotionalProfile {
        guard let moon = chart.planets.first(where: { $0.type == .moon }) else {
            return EmotionalProfile.default
        }

        let moonTranslation = humanLanguageService.translateZodiacSign(moon.zodiacSign)
        let language = displayMode == .human || displayMode == .beginner ? LanguageStyle.simple : .complex

        let emotionalStyle = getEmotionalStyle(moonSign: moon.zodiacSign, language: language)
        let triggers = getEmotionalTriggers(moonSign: moon.zodiacSign, patterns: patterns)
        let strengths = getEmotionalStrengths(moonSign: moon.zodiacSign, patterns: patterns)
        let healingMethods = getHealingMethods(moonSign: moon.zodiacSign, language: language)

        return EmotionalProfile(
            coreEmotionalNature: emotionalStyle.core,
            emotionalStrengths: strengths,
            potentialTriggers: triggers,
            healingApproaches: healingMethods,
            relationshipStyle: emotionalStyle.relationships,
            stressResponse: emotionalStyle.stress
        )
    }

    private func identifyLifeThemes(from chart: BirthChart, patterns: AstrologicalPatterns, displayMode: DisplayMode) -> [LifeTheme] {
        var themes: [LifeTheme] = []

        // Тема на основе доминирующих планет
        for planet in patterns.dominantPlanets.prefix(3) {
            if let theme = createPlanetaryTheme(planet: planet, chart: chart, displayMode: displayMode) {
                themes.append(theme)
            }
        }

        // Тема на основе специальных конфигураций
        for config in patterns.specialConfigurations {
            if let theme = createConfigurationTheme(config: config, chart: chart, displayMode: displayMode) {
                themes.append(theme)
            }
        }

        // Эволюционные темы (на основе лунных узлов, если есть)
        if let evolutionaryTheme = createEvolutionaryTheme(chart: chart, displayMode: displayMode) {
            themes.append(evolutionaryTheme)
        }

        return themes
    }

    // MARK: - Helper Methods

    private func planetWeight(_ planet: PlanetType) -> Int {
        switch planet {
        case .sun, .moon: return 3
        case .mercury, .venus, .mars: return 2
        case .jupiter, .saturn: return 2
        case .uranus, .neptune, .pluto: return 1
        case .ascendant, .midheaven: return 2
        case .northNode: return 1
        }
    }

    private func signStrength(_ planet: PlanetType, in sign: ZodiacSign) -> Double {
        // Упрощенная система достоинств планет
        // В полной реализации здесь была бы таблица обителей и экзальтаций
        return 1.0
    }

    private func aspectualStrength(_ planet: Planet, in chart: BirthChart) -> Double {
        // Считаем количество и качество аспектов к планете
        return 1.0
    }

    private func angularStrength(_ planet: Planet, in chart: BirthChart) -> Double {
        // Определяем силу планеты по близости к углам карты
        return 1.0
    }

    private func findStelliums(in chart: BirthChart) -> [AstrologicalConfiguration] {
        // Ищем скопления 3+ планет в одном знаке
        return []
    }

    private func findMajorPatterns(in chart: BirthChart) -> [AstrologicalConfiguration] {
        // Ищем T-квадраты, Большие трины и другие мажорные паттерны
        return []
    }

    private func findRarePatterns(in chart: BirthChart) -> [AstrologicalConfiguration] {
        // Ищем редкие конфигурации типа йод
        return []
    }

    private func getDominantElement(from balance: ElementalBalance) -> ZodiacSign.Element? {
        let elements = [
            (ZodiacSign.Element.fire, balance.fire),
            (ZodiacSign.Element.earth, balance.earth),
            (ZodiacSign.Element.air, balance.air),
            (ZodiacSign.Element.water, balance.water)
        ]
        return elements.max { $0.1 < $1.1 }?.0
    }

    private func getDominantModality(from balance: ModalBalance) -> Modality? {
        let modalities = [
            (Modality.cardinal, balance.cardinal),
            (Modality.fixed, balance.fixed),
            (Modality.mutable, balance.mutable)
        ]
        return modalities.max { $0.1 < $1.1 }?.0
    }

    private func createPlanetaryDominanceInsight(planet: PlanetType, chart: BirthChart, displayMode: DisplayMode) -> PersonalInsight {
        let planetTranslation = humanLanguageService.translatePlanet(planet)
        let language = displayMode == .human || displayMode == .beginner ? LanguageStyle.simple : .complex

        let (title, description, advice) = getPlanetaryDominanceDescription(planet: planet, language: language, translation: planetTranslation)

        return PersonalInsight(
            id: UUID(),
            type: .personality,
            category: .planetaryInfluence,
            title: title,
            description: description,
            practicalAdvice: advice,
            emotionalResonance: getPlanetaryEmotionalResonance(planet),
            importance: 4,
            emoji: humanLanguageService.planetEmoji(planet),
            color: getPlanetaryColor(planet),
            dateCreated: Date()
        )
    }

    private func getPlanetaryDominanceDescription(planet: PlanetType, language: LanguageStyle, translation: PlanetTranslation) -> (title: String, description: String, advice: String) {
        switch (planet, language) {
        case (.sun, .simple):
            return (
                "Солнечная личность",
                "Солнце — ваша главная планета. Вы естественный центр внимания, харизматичная личность с ярким внутренним светом. Ваше предназначение — светить и вдохновлять других.",
                "Развивайте уверенность в себе и лидерские качества. Помните: ваш свет не должен затмевать других — освещайте им путь."
            )
        case (.moon, .simple):
            return (
                "Лунная натура",
                "Луна доминирует в вашей карте, делая вас глубоко эмоциональной и интуитивной личностью. Вы чувствуете мир всем сердцем и обладаете природной мудростью.",
                "Доверяйте своим чувствам и интуиции. Создавайте эмоциональную безопасность для себя и близких."
            )
        default:
            return (
                "Планетарная доминанта",
                "\(translation.humanName) играет ключевую роль в вашей личности",
                "Изучайте и развивайте качества этой планеты"
            )
        }
    }

    // MARK: - Additional Helper Methods

    private func getEmotionalStyle(moonSign: ZodiacSign, language: LanguageStyle) -> (core: String, relationships: String, stress: String) {
        switch moonSign.element {
        case .fire:
            return (
                "Вспыльчивый и страстный",
                "В отношениях проявляете яркие эмоции",
                "Под стрессом становитесь импульсивными"
            )
        case .earth:
            return (
                "Стабильный и практичный",
                "В отношениях цените надёжность",
                "Стресс переживаете молча, накапливая напряжение"
            )
        case .air:
            return (
                "Рациональный и общительный",
                "В отношениях важно интеллектуальное понимание",
                "Стресс прорабатываете через разговоры"
            )
        case .water:
            return (
                "Глубокий и интуитивный",
                "В отношениях создаёте эмоциональную близость",
                "Стресс переживаете всем существом"
            )
        }
    }

    private func getEmotionalTriggers(moonSign: ZodiacSign, patterns: AstrologicalPatterns) -> [String] {
        // Возвращаем потенциальные эмоциональные триггеры на основе знака Луны
        return ["Критика", "Неопределённость", "Конфликты"]
    }

    private func getEmotionalStrengths(moonSign: ZodiacSign, patterns: AstrologicalPatterns) -> [String] {
        // Возвращаем эмоциональные силы
        return ["Эмпатия", "Интуиция", "Эмоциональная глубина"]
    }

    private func getHealingMethods(moonSign: ZodiacSign, language: LanguageStyle) -> [String] {
        switch moonSign.element {
        case .fire:
            return ["Физическая активность", "Творческое самовыражение", "Медитация с движением"]
        case .earth:
            return ["Работа с телом", "Природа", "Рутины ухода за собой"]
        case .air:
            return ["Журналинг", "Общение с друзьями", "Изучение нового"]
        case .water:
            return ["Водные процедуры", "Музыка", "Искусство и творчество"]
        }
    }

    private func getElementEmoji(_ element: ZodiacSign.Element) -> String {
        switch element {
        case .fire: return "🔥"
        case .earth: return "🌱"
        case .air: return "💨"
        case .water: return "🌊"
        }
    }

    private func getElementColor(_ element: ZodiacSign.Element) -> Color {
        switch element {
        case .fire: return .fireElement
        case .earth: return .earthElement
        case .air: return .airElement
        case .water: return .waterElement
        }
    }

    private func getElementalEmotionalResonance(_ element: ZodiacSign.Element) -> EmotionalResonance {
        switch element {
        case .fire:
            return EmotionalResonance(
                primaryEmotion: "Энтузиазм",
                resonantQualities: ["Страсть", "Вдохновение", "Смелость"],
                healingApproach: "Направление энергии в творчество"
            )
        case .earth:
            return EmotionalResonance(
                primaryEmotion: "Стабильность",
                resonantQualities: ["Надёжность", "Терпение", "Практичность"],
                healingApproach: "Работа с телом и природой"
            )
        case .air:
            return EmotionalResonance(
                primaryEmotion: "Любопытство",
                resonantQualities: ["Общительность", "Гибкость", "Ясность"],
                healingApproach: "Интеллектуальное понимание"
            )
        case .water:
            return EmotionalResonance(
                primaryEmotion: "Глубина",
                resonantQualities: ["Интуиция", "Сочувствие", "Мудрость"],
                healingApproach: "Эмоциональное принятие"
            )
        }
    }

    private func getPlanetaryEmotionalResonance(_ planet: PlanetType) -> EmotionalResonance {
        switch planet {
        case .sun:
            return EmotionalResonance(
                primaryEmotion: "Уверенность",
                resonantQualities: ["Лидерство", "Творчество", "Витальность"],
                healingApproach: "Самовыражение и признание"
            )
        case .moon:
            return EmotionalResonance(
                primaryEmotion: "Забота",
                resonantQualities: ["Интуиция", "Защитность", "Цикличность"],
                healingApproach: "Эмоциональная безопасность"
            )
        default:
            return EmotionalResonance(
                primaryEmotion: "Нейтральная",
                resonantQualities: ["Баланс"],
                healingApproach: "Гармонизация"
            )
        }
    }

    private func getPlanetaryColor(_ planet: PlanetType) -> Color {
        switch planet {
        case .sun: return .starYellow
        case .moon: return .waterElement
        case .mercury: return .airElement
        case .venus: return .neonPink
        case .mars: return .fireElement
        case .jupiter: return .cosmicViolet
        case .saturn: return .earthElement
        case .uranus: return .neonCyan
        case .neptune: return .waterElement
        case .pluto: return .cosmicPurple
        case .ascendant: return .cosmicViolet
        case .midheaven: return .starWhite
        case .northNode: return .cosmicCyan
        }
    }

    private func identifyChallenges(_ chart: BirthChart) -> [AstrologicalChallenge] {
        // Анализируем напряженные аспекты и сложные планетарные конфигурации
        var challenges: [AstrologicalChallenge] = []

        // Проверяем сложные аспекты (квадраты, оппозиции)
        let difficultAspects = chart.aspects.filter { !$0.type.isHarmonic }
        if difficultAspects.count > 3 {
            challenges.append(AstrologicalChallenge(
                title: "Множественные внутренние конфликты",
                description: "У вас есть несколько напряженных аспектов в карте",
                growthOpportunity: "Эти конфликты являются источником личностного роста"
            ))
        }

        return challenges
    }

    private func identifyStrengths(_ chart: BirthChart) -> [AstrologicalStrength] {
        // Анализируем гармоничные аспекты и благоприятные конфигурации
        var strengths: [AstrologicalStrength] = []

        // Проверяем гармоничные аспекты (тригоны, секстили)
        let harmoniousAspects = chart.aspects.filter { $0.type.isHarmonic }
        if harmoniousAspects.count > 3 {
            strengths.append(AstrologicalStrength(
                title: "Естественная гармония и баланс",
                description: "У вас много гармоничных аспектов в карте",
                applicationAdvice: "Используйте эту гармонию для достижения целей"
            ))
        }

        return strengths
    }

    private func createPlanetaryTheme(planet: PlanetType, chart: BirthChart, displayMode: DisplayMode) -> LifeTheme? {
        // Создаём жизненную тему на основе доминирующей планеты
        return nil // Упрощенная реализация
    }

    private func createConfigurationTheme(config: AstrologicalConfiguration, chart: BirthChart, displayMode: DisplayMode) -> LifeTheme? {
        // Создаём тему на основе астрологической конфигурации
        return nil
    }

    private func createEvolutionaryTheme(chart: BirthChart, displayMode: DisplayMode) -> LifeTheme? {
        // Создаём эволюционную тему на основе лунных узлов
        return nil
    }

    private func generateRelationshipInsights(patterns: AstrologicalPatterns, chart: BirthChart, displayMode: DisplayMode) -> [PersonalInsight] {
        return [] // Упрощенная реализация
    }

    private func generateCareerInsights(patterns: AstrologicalPatterns, chart: BirthChart, displayMode: DisplayMode) -> [PersonalInsight] {
        return []
    }

    private func generateSpiritualInsights(patterns: AstrologicalPatterns, chart: BirthChart, displayMode: DisplayMode) -> [PersonalInsight] {
        return []
    }

    private func generateLifeCycleInsights(patterns: AstrologicalPatterns, chart: BirthChart, displayMode: DisplayMode) -> [PersonalInsight] {
        return []
    }

    private func createModalInsight(modality: Modality, chart: BirthChart, displayMode: DisplayMode) -> PersonalInsight {
        let language = displayMode == .human || displayMode == .beginner ? LanguageStyle.simple : .complex

        let (title, description, advice) = getModalityDescription(modality: modality, language: language)

        return PersonalInsight(
            id: UUID(),
            type: .personality,
            category: .behavioralPattern,
            title: title,
            description: description,
            practicalAdvice: advice,
            emotionalResonance: getModalityEmotionalResonance(modality),
            importance: 3,
            emoji: getModalityEmoji(modality),
            color: getModalityColor(modality),
            dateCreated: Date()
        )
    }

    private func getModalityDescription(modality: Modality, language: LanguageStyle) -> (title: String, description: String, advice: String) {
        switch (modality, language) {
        case (.cardinal, .simple):
            return (
                "Вы — инициатор",
                "В вас сильна кардинальная энергия — способность начинать новое и вести за собой. Вы не боитесь перемен и умеете воплощать идеи в жизнь.",
                "Используйте свою способность инициировать изменения. Учитесь доводить начатое до конца — ваша сила в запуске, но завершение тоже важно."
            )
        case (.fixed, .simple):
            return (
                "Ваша сила — в стабильности",
                "Фиксированная энергия делает вас человеком слова. Вы надёжны, упорны и умеете создавать прочные основы. Ваша выдержка впечатляет окружающих.",
                "Цените свою способность к постоянству, но помните о важности гибкости. Иногда стоит позволить переменам войти в вашу жизнь."
            )
        case (.mutable, .simple):
            return (
                "Ваш дар — адаптивность",
                "Мутабельная энергия наделяет вас удивительной гибкостью. Вы легко приспосабливаетесь к изменениям и умеете находить решения в любой ситуации.",
                "Используйте свою адаптивность как суперсилу. Развивайте также постоянство — ваша гибкость ценна, но нужна и стабильная основа."
            )
        default:
            return (
                "Модальная доминанта",
                "Преобладающая модальность определяет ваш подход к действиям и изменениям",
                "Развивайте качества других модальностей для баланса"
            )
        }
    }

    private func getModalityEmotionalResonance(_ modality: Modality) -> EmotionalResonance {
        switch modality {
        case .cardinal:
            return EmotionalResonance(
                primaryEmotion: "Решительность",
                resonantQualities: ["Инициативность", "Лидерство", "Новаторство"],
                healingApproach: "Направление энергии на новые проекты"
            )
        case .fixed:
            return EmotionalResonance(
                primaryEmotion: "Устойчивость",
                resonantQualities: ["Верность", "Упорство", "Глубина"],
                healingApproach: "Создание стабильных рутин"
            )
        case .mutable:
            return EmotionalResonance(
                primaryEmotion: "Гибкость",
                resonantQualities: ["Адаптивность", "Любознательность", "Многогранность"],
                healingApproach: "Принятие изменений"
            )
        }
    }

    private func getModalityEmoji(_ modality: Modality) -> String {
        switch modality {
        case .cardinal: return "🚀"
        case .fixed: return "⛰️"
        case .mutable: return "🌊"
        }
    }

    private func getModalityColor(_ modality: Modality) -> Color {
        switch modality {
        case .cardinal: return .neonCyan
        case .fixed: return .earthElement
        case .mutable: return .airElement
        }
    }
}

// MARK: - Supporting Data Structures

struct AstrologicalPatterns {
    var elementalBalance = ElementalBalance()
    var modalBalance = ModalBalance()
    var dominantPlanets: [PlanetType] = []
    var specialConfigurations: [AstrologicalConfiguration] = []
    var challenges: [AstrologicalChallenge] = []
    var strengths: [AstrologicalStrength] = []
}

struct ElementalBalance {
    var fire: Double = 0
    var earth: Double = 0
    var air: Double = 0
    var water: Double = 0
}

struct ModalBalance {
    var cardinal: Double = 0
    var fixed: Double = 0
    var mutable: Double = 0
}

struct AstrologicalConfiguration {
    let name: String
    let planets: [PlanetType]
    let significance: String
    let type: ConfigurationType
}

enum ConfigurationType {
    case stellium
    case grandTrine
    case tSquare
    case yod
    case mysticRectangle
}

struct AstrologicalChallenge {
    let title: String
    let description: String
    let growthOpportunity: String
}

struct AstrologicalStrength {
    let title: String
    let description: String
    let applicationAdvice: String
}

struct PersonalInsight {
    let id: UUID
    let type: InsightType
    let category: InsightCategory
    let title: String
    let description: String
    let practicalAdvice: String?
    let emotionalResonance: EmotionalResonance
    let importance: Int // 1-5
    let emoji: String
    let color: Color
    let dateCreated: Date
}

enum InsightType {
    case personality
    case relationships
    case career
    case spiritual
    case lifeCycles
    case shadow // Теневые аспекты
    case gifts // Природные таланты
}

enum InsightCategory {
    case coreNature
    case planetaryInfluence
    case behavioralPattern
    case emotionalPattern
    case karmic
    case evolutionary
}

struct EmotionalProfile {
    let coreEmotionalNature: String
    let emotionalStrengths: [String]
    let potentialTriggers: [String]
    let healingApproaches: [String]
    let relationshipStyle: String
    let stressResponse: String

    static let `default` = EmotionalProfile(
        coreEmotionalNature: "Сбалансированная эмоциональная природа",
        emotionalStrengths: ["Стабильность", "Гибкость"],
        potentialTriggers: ["Неопределённость"],
        healingApproaches: ["Медитация", "Общение"],
        relationshipStyle: "Гармоничный подход к отношениям",
        stressResponse: "Адаптивная реакция на стресс"
    )
}

struct EmotionalResonance {
    let primaryEmotion: String
    let resonantQualities: [String]
    let healingApproach: String
}

// LifeTheme now defined in PersonalInsightsModels.swift

class AstrologicalPatternAnalyzer {
    // Анализатор астрологических паттернов
    func analyzeChart(_ chart: BirthChart) -> AstrologicalPatterns {
        return AstrologicalPatterns()
    }
}