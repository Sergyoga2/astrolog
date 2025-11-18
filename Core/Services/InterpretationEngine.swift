//
//  InterpretationEngine.swift
//  Astrolog
//
//  Created by Claude on 21.10.2025.
//

// Core/Services/InterpretationEngine.swift
import Foundation
import SwiftUI
import Combine

/// Основной движок для генерации интерпретаций астрологических элементов
class InterpretationEngine: ObservableObject {

    // MARK: - Properties

    @Published var currentDepth: InterpretationDepth = .brief
    @Published var currentStyle: InterpretationStyle = .balanced
    @Published var culturalContext: CulturalContext = .western

    private let interpretationDatabase: InterpretationDatabase

    // MARK: - Initialization

    init() {
        self.interpretationDatabase = InterpretationDatabase()
    }

    // MARK: - Public Methods

    /// Получить интерпретацию для планеты в знаке зодиака
    func getInterpretation(
        for planet: PlanetType,
        in sign: ZodiacSign,
        context: InterpretationContext? = nil
    ) -> Interpretation {
        let elementType: ChartElementType = .planetInSign
        let id = "\(planet.rawValue)_in_\(sign.rawValue)"

        // Проверяем контекст для персонализации
        let effectiveContext = context ?? InterpretationContext()
        let depth = effectiveContext.userPreferences?.detailLevel ?? currentDepth
        let style = effectiveContext.userPreferences?.interpretationStyle ?? currentStyle

        // Получаем базовую интерпретацию из базы данных
        if let existingInterpretation = interpretationDatabase.getInterpretation(for: id) {
            return existingInterpretation
        }

        // Генерируем новую интерпретацию
        return generatePlanetInSignInterpretation(
            planet: planet,
            sign: sign,
            depth: depth,
            style: style,
            context: effectiveContext
        )
    }

    /// Получить интерпретацию для планеты в доме
    func getInterpretation(
        for planet: PlanetType,
        in house: Int,
        context: InterpretationContext? = nil
    ) -> Interpretation {
        let elementType: ChartElementType = .planetInHouse
        let id = "\(planet.rawValue)_in_house_\(house)"

        let effectiveContext = context ?? InterpretationContext()
        let depth = effectiveContext.userPreferences?.detailLevel ?? currentDepth
        let style = effectiveContext.userPreferences?.interpretationStyle ?? currentStyle

        if let existingInterpretation = interpretationDatabase.getInterpretation(for: id) {
            return existingInterpretation
        }

        return generatePlanetInHouseInterpretation(
            planet: planet,
            house: house,
            depth: depth,
            style: style,
            context: effectiveContext
        )
    }

    /// Получить интерпретацию для аспекта между планетами
    func getInterpretation(
        for aspect: Aspect,
        context: InterpretationContext? = nil
    ) -> Interpretation {
        let id = "\(aspect.planet1.type.rawValue)_\(aspect.type.rawValue)_\(aspect.planet2.type.rawValue)"

        let effectiveContext = context ?? InterpretationContext()
        let depth = effectiveContext.userPreferences?.detailLevel ?? currentDepth
        let style = effectiveContext.userPreferences?.interpretationStyle ?? currentStyle

        if let existingInterpretation = interpretationDatabase.getInterpretation(for: id) {
            return existingInterpretation
        }

        return generateAspectInterpretation(
            aspect: aspect,
            depth: depth,
            style: style,
            context: effectiveContext
        )
    }

    /// Получить комплексную интерпретацию для всей карты
    func getComprehensiveInterpretation(
        for chart: BirthChart,
        focusArea: FocusArea? = nil,
        context: InterpretationContext? = nil
    ) -> Interpretation {
        let effectiveContext = context ?? InterpretationContext(birthChart: chart, focusArea: focusArea)

        let depth = effectiveContext.userPreferences?.detailLevel ?? currentDepth
        let style = effectiveContext.userPreferences?.interpretationStyle ?? currentStyle

        return generateComprehensiveInterpretation(
            chart: chart,
            focusArea: focusArea,
            depth: depth,
            style: style,
            context: effectiveContext
        )
    }

    /// Получить список ключевых интерпретаций для обзорной вкладки
    func getKeyInterpretations(
        for chart: BirthChart,
        limit: Int = 5,
        context: InterpretationContext? = nil
    ) -> [Interpretation] {
        var interpretations: [Interpretation] = []

        // Солнце, Луна, Асцендент - основная троица
        if let sun = chart.planets.first(where: { $0.type == .sun }) {
            interpretations.append(getInterpretation(for: .sun, in: sun.zodiacSign, context: context))
        }

        if let moon = chart.planets.first(where: { $0.type == .moon }) {
            interpretations.append(getInterpretation(for: .moon, in: moon.zodiacSign, context: context))
        }

        interpretations.append(getInterpretation(for: .ascendant, in: chart.ascendant, context: context))

        // Добавляем наиболее значимые аспекты
        let significantAspects = chart.aspects
            .filter { $0.type == .conjunction || $0.type == .opposition || $0.type == .trine }
            .sorted { $0.orb < $1.orb }
            .prefix(limit - interpretations.count)

        for aspect in significantAspects {
            interpretations.append(getInterpretation(for: aspect, context: context))
        }

        return Array(interpretations.prefix(limit))
    }

    // MARK: - Configuration Methods

    /// Установить уровень детализации по умолчанию
    func setDefaultDepth(_ depth: InterpretationDepth) {
        currentDepth = depth
    }

    /// Установить стиль интерпретации по умолчанию
    func setDefaultStyle(_ style: InterpretationStyle) {
        currentStyle = style
    }

    /// Установить культурный контекст
    func setCulturalContext(_ context: CulturalContext) {
        culturalContext = context
        interpretationDatabase.updateCulturalContext(context)
    }
}

// MARK: - Private Generation Methods

private extension InterpretationEngine {

    func generatePlanetInSignInterpretation(
        planet: PlanetType,
        sign: ZodiacSign,
        depth: InterpretationDepth,
        style: InterpretationStyle,
        context: InterpretationContext
    ) -> Interpretation {

        let title = "\(planet.displayName) в \(sign.displayName)"
        let emoji = "\(planet.symbol)\(sign.symbol)"

        // Получаем базовые характеристики
        let planetKeywords = interpretationDatabase.getKeywords(for: planet)
        let signKeywords = interpretationDatabase.getKeywords(for: sign)
        let combinedKeywords = planetKeywords + signKeywords

        let lifeAreas = interpretationDatabase.getLifeAreas(for: planet, in: sign)

        // Генерируем тексты разной глубины
        let oneLiner = generateOneLiner(planet: planet, sign: sign, style: style)
        let summary = generateSummary(planet: planet, sign: sign, style: style, context: context)
        let detailed = generateDetailed(planet: planet, sign: sign, style: style, context: context)

        return Interpretation(
            title: title,
            emoji: emoji,
            oneLiner: oneLiner,
            summary: summary,
            detailed: detailed,
            keywords: Array(combinedKeywords.prefix(5)),
            lifeAreas: Array(lifeAreas.prefix(3)),
            elementType: .planetInSign,
            depth: depth,
            userLevel: context.userPreferences?.detailLevel == .detailed ? .advanced : .intermediate
        )
    }

    func generatePlanetInHouseInterpretation(
        planet: PlanetType,
        house: Int,
        depth: InterpretationDepth,
        style: InterpretationStyle,
        context: InterpretationContext
    ) -> Interpretation {

        let title = "\(planet.displayName) в \(house) доме"
        let emoji = "\(planet.symbol)🏠"

        let keywords = interpretationDatabase.getHouseKeywords(for: house) + interpretationDatabase.getKeywords(for: planet)
        let lifeAreas = interpretationDatabase.getHouseLifeAreas(for: house)

        let oneLiner = generateHouseOneLiner(planet: planet, house: house, style: style)
        let summary = generateHouseSummary(planet: planet, house: house, style: style, context: context)
        let detailed = generateHouseDetailed(planet: planet, house: house, style: style, context: context)

        return Interpretation(
            title: title,
            emoji: emoji,
            oneLiner: oneLiner,
            summary: summary,
            detailed: detailed,
            keywords: Array(keywords.prefix(5)),
            lifeAreas: Array(lifeAreas.prefix(3)),
            elementType: .planetInHouse,
            depth: depth
        )
    }

    func generateAspectInterpretation(
        aspect: Aspect,
        depth: InterpretationDepth,
        style: InterpretationStyle,
        context: InterpretationContext
    ) -> Interpretation {

        let title = "\(aspect.planet1.type.displayName) \(aspect.type.symbol) \(aspect.planet2.type.displayName)"
        let emoji = "\(aspect.planet1.type.symbol)\(aspect.type.symbol)\(aspect.planet2.type.symbol)"

        let keywords = interpretationDatabase.getAspectKeywords(for: aspect.type)
        let lifeAreas = interpretationDatabase.getAspectLifeAreas(for: aspect.planet1.type, and: aspect.planet2.type)

        let oneLiner = generateAspectOneLiner(aspect: aspect, style: style)
        let summary = generateAspectSummary(aspect: aspect, style: style, context: context)
        let detailed = generateAspectDetailed(aspect: aspect, style: style, context: context)

        return Interpretation(
            title: title,
            emoji: emoji,
            oneLiner: oneLiner,
            summary: summary,
            detailed: detailed,
            keywords: Array(keywords.prefix(5)),
            lifeAreas: Array(lifeAreas.prefix(3)),
            elementType: .aspect,
            depth: depth
        )
    }

    func generateComprehensiveInterpretation(
        chart: BirthChart,
        focusArea: FocusArea?,
        depth: InterpretationDepth,
        style: InterpretationStyle,
        context: InterpretationContext
    ) -> Interpretation {

        let title = "Общий анализ карты"
        let emoji = "⭐️🔮"

        let oneLiner = "Ваша натальная карта раскрывает уникальные черты личности и жизненный потенциал"
        let summary = generateChartSummary(chart: chart, focusArea: focusArea, style: style)
        let detailed = generateChartDetailed(chart: chart, focusArea: focusArea, style: style, context: context)

        return Interpretation(
            title: title,
            emoji: emoji,
            oneLiner: oneLiner,
            summary: summary,
            detailed: detailed,
            keywords: ["личность", "потенциал", "развитие", "судьба"],
            lifeAreas: focusArea != nil ? [focusArea!.displayName] : ["общее развитие"],
            elementType: .composite,
            depth: depth
        )
    }

    // MARK: - Text Generation Helpers

    func generateOneLiner(planet: PlanetType, sign: ZodiacSign, style: InterpretationStyle) -> String {
        let base = interpretationDatabase.getOneLiner(planet: planet, sign: sign)
        return styleText(base, with: style)
    }

    func generateSummary(planet: PlanetType, sign: ZodiacSign, style: InterpretationStyle, context: InterpretationContext) -> String {
        let base = interpretationDatabase.getSummary(planet: planet, sign: sign)
        return personalizeText(styleText(base, with: style), for: context)
    }

    func generateDetailed(planet: PlanetType, sign: ZodiacSign, style: InterpretationStyle, context: InterpretationContext) -> String {
        let base = interpretationDatabase.getDetailed(planet: planet, sign: sign)
        return personalizeText(styleText(base, with: style), for: context)
    }

    func generateHouseOneLiner(planet: PlanetType, house: Int, style: InterpretationStyle) -> String {
        let base = interpretationDatabase.getHouseOneLiner(planet: planet, house: house)
        return styleText(base, with: style)
    }

    func generateHouseSummary(planet: PlanetType, house: Int, style: InterpretationStyle, context: InterpretationContext) -> String {
        let base = interpretationDatabase.getHouseSummary(planet: planet, house: house)
        return personalizeText(styleText(base, with: style), for: context)
    }

    func generateHouseDetailed(planet: PlanetType, house: Int, style: InterpretationStyle, context: InterpretationContext) -> String {
        let base = interpretationDatabase.getHouseDetailed(planet: planet, house: house)
        return personalizeText(styleText(base, with: style), for: context)
    }

    func generateAspectOneLiner(aspect: Aspect, style: InterpretationStyle) -> String {
        let base = interpretationDatabase.getAspectOneLiner(aspect: aspect)
        return styleText(base, with: style)
    }

    func generateAspectSummary(aspect: Aspect, style: InterpretationStyle, context: InterpretationContext) -> String {
        let base = interpretationDatabase.getAspectSummary(aspect: aspect)
        return personalizeText(styleText(base, with: style), for: context)
    }

    func generateAspectDetailed(aspect: Aspect, style: InterpretationStyle, context: InterpretationContext) -> String {
        let base = interpretationDatabase.getAspectDetailed(aspect: aspect)
        return personalizeText(styleText(base, with: style), for: context)
    }

    func generateChartSummary(chart: BirthChart, focusArea: FocusArea?, style: InterpretationStyle) -> String {
        return interpretationDatabase.getChartSummary(chart: chart, focusArea: focusArea, style: style)
    }

    func generateChartDetailed(chart: BirthChart, focusArea: FocusArea?, style: InterpretationStyle, context: InterpretationContext) -> String {
        let base = interpretationDatabase.getChartDetailed(chart: chart, focusArea: focusArea, style: style)
        return personalizeText(base, for: context)
    }

    // MARK: - Text Processing Helpers

    func styleText(_ text: String, with style: InterpretationStyle) -> String {
        switch style {
        case .positive:
            return text.replacingOccurrences(of: "может", with: "способен")
                      .replacingOccurrences(of: "трудности", with: "вызовы")
        case .analytical:
            return "Анализ показывает: " + text
        case .poetic:
            return "✨ " + text.replacingOccurrences(of: ". ", with: "... ")
        case .balanced:
            return text
        }
    }

    func personalizeText(_ text: String, for context: InterpretationContext) -> String {
        guard let focusArea = context.focusArea else { return text }

        let focusText = " Особое внимание на \(focusArea.displayName.lowercased())."
        return text + focusText
    }
}

/// Заглушка для базы данных интерпретаций (будет расширена в будущем)
private class InterpretationDatabase {
    private var storedInterpretations: [String: Interpretation] = [:]

    func getInterpretation(for id: String) -> Interpretation? {
        return storedInterpretations[id]
    }

    func storeInterpretation(_ interpretation: Interpretation) {
        storedInterpretations[interpretation.id] = interpretation
    }

    func updateCulturalContext(_ context: CulturalContext) {
        // Обновление базы данных интерпретаций под культурный контекст
    }

    // MARK: - Mock Data Methods (заглушки для базовых данных)

    func getKeywords(for planet: PlanetType) -> [String] {
        switch planet {
        case .sun: return ["эго", "творчество", "лидерство", "самовыражение"]
        case .moon: return ["эмоции", "интуиция", "дом", "семья"]
        case .mercury: return ["общение", "мышление", "обучение", "путешествия"]
        case .venus: return ["любовь", "красота", "гармония", "отношения"]
        case .mars: return ["энергия", "действие", "конфликт", "страсть"]
        default: return ["влияние", "энергия", "развитие"]
        }
    }

    func getKeywords(for sign: ZodiacSign) -> [String] {
        switch sign {
        case .aries: return ["инициатива", "лидерство", "энергичность"]
        case .taurus: return ["стабильность", "практичность", "чувственность"]
        case .gemini: return ["общительность", "любознательность", "гибкость"]
        default: return ["характер", "проявление", "особенности"]
        }
    }

    func getLifeAreas(for planet: PlanetType, in sign: ZodiacSign) -> [String] {
        return ["карьера", "отношения", "творчество"]
    }

    func getHouseKeywords(for house: Int) -> [String] {
        switch house {
        case 1: return ["личность", "внешность", "первое впечатление"]
        case 7: return ["партнерство", "отношения", "союзы"]
        case 10: return ["карьера", "репутация", "достижения"]
        default: return ["жизненная область", "опыт", "развитие"]
        }
    }

    func getHouseLifeAreas(for house: Int) -> [String] {
        switch house {
        case 1: return ["самоидентификация"]
        case 7: return ["партнерство"]
        case 10: return ["карьера"]
        default: return ["жизнь"]
        }
    }

    func getAspectKeywords(for aspectType: AspectType) -> [String] {
        switch aspectType {
        case .conjunction: return ["слияние", "усиление", "фокус"]
        case .trine: return ["гармония", "талант", "легкость"]
        case .square: return ["напряжение", "вызов", "рост"]
        case .opposition: return ["баланс", "противоположности", "осознание"]
        case .sextile: return ["возможности", "сотрудничество", "развитие"]
        }
    }

    func getAspectLifeAreas(for planet1: PlanetType, and planet2: PlanetType) -> [String] {
        return ["взаимодействие энергий", "синтез качеств"]
    }

    // Заглушки для получения текстов
    func getOneLiner(planet: PlanetType, sign: ZodiacSign) -> String {
        return "\(planet.displayName) в \(sign.displayName) придает особые черты характера"
    }

    func getSummary(planet: PlanetType, sign: ZodiacSign) -> String {
        return "Размещение \(planet.displayName) в знаке \(sign.displayName) создает уникальное сочетание энергий, влияющее на различные аспекты жизни."
    }

    func getDetailed(planet: PlanetType, sign: ZodiacSign) -> String {
        return "Детальный анализ положения \(planet.displayName) в \(sign.displayName) показывает глубокие взаимосвязи между планетарными энергиями и качествами знака зодиака."
    }

    func getHouseOneLiner(planet: PlanetType, house: Int) -> String {
        return "\(planet.displayName) в \(house) доме влияет на определенную сферу жизни"
    }

    func getHouseSummary(planet: PlanetType, house: Int) -> String {
        return "Положение \(planet.displayName) в \(house) доме указывает на активность в соответствующей жизненной сфере."
    }

    func getHouseDetailed(planet: PlanetType, house: Int) -> String {
        return "Подробный анализ \(planet.displayName) в \(house) доме раскрывает особенности проявления планетарных энергий в конкретной области жизни."
    }

    func getAspectOneLiner(aspect: Aspect) -> String {
        return "\(aspect.planet1.type.displayName) и \(aspect.planet2.type.displayName) создают \(aspect.type.isHarmonic ? "гармоничное" : "динамичное") взаимодействие"
    }

    func getAspectSummary(aspect: Aspect) -> String {
        return "Аспект \(aspect.type.symbol) между \(aspect.planet1.type.displayName) и \(aspect.planet2.type.displayName) формирует особое энергетическое взаимодействие."
    }

    func getAspectDetailed(aspect: Aspect) -> String {
        return "Глубокий анализ аспекта \(aspect.type.rawValue) показывает сложное взаимодействие между энергиями \(aspect.planet1.type.displayName) и \(aspect.planet2.type.displayName)."
    }

    func getChartSummary(chart: BirthChart, focusArea: FocusArea?, style: InterpretationStyle) -> String {
        return "Ваша натальная карта представляет уникальную комбинацию астрологических факторов, формирующих личность и жизненный путь."
    }

    func getChartDetailed(chart: BirthChart, focusArea: FocusArea?, style: InterpretationStyle) -> String {
        return "Комплексный анализ натальной карты включает взаимодействие планет, знаков зодиака, домов и аспектов, создающих сложную картину потенциалов и возможностей."
    }
}

// MARK: - Human Language Extension

/// Расширение InterpretationEngine для поддержки режима "human"
extension InterpretationEngine {

    /// Интегрированный сервис человеческого языка
    private var humanLanguageService: HumanLanguageService {
        return HumanLanguageService()
    }

    /// Получить интерпретацию в человеческом стиле
    func getHumanInterpretation(
        for planet: PlanetType,
        in sign: ZodiacSign,
        context: InterpretationContext? = nil
    ) -> Interpretation {
        let humanService = humanLanguageService
        let planetTranslation = humanService.translatePlanet(planet)
        let signTranslation = humanService.translateZodiacSign(sign)

        // Создаем человеческую интерпретацию
        let humanText = humanService.translatePlanetInSign(planet, in: sign)
        let motivationalMessage = humanService.generateMotivationalMessage(
            for: Planet(id: "temp_\(planet.rawValue)", type: planet, longitude: 0, zodiacSign: sign, house: 1, isRetrograde: false)
        )

        return Interpretation(
            id: "human_\(planet.rawValue)_in_\(sign.rawValue)",
            title: "\(planetTranslation.emoji) \(planetTranslation.humanName)",
            emoji: planetTranslation.emoji,
            oneLiner: motivationalMessage,
            summary: humanText,
            detailed: "\(humanText) \(signTranslation.description)",
            keywords: planetTranslation.keywords + signTranslation.strengths,
            lifeAreas: [],
            elementType: .planetInSign
        )
    }

    /// Получить упрощенную интерпретацию большой тройки для режима human
    func getHumanBigThreeInterpretation(
        sun: Planet?,
        moon: Planet?,
        ascendant: Planet?
    ) -> Interpretation {
        let humanService = humanLanguageService
        let description = humanService.generateBigThreeDescription(
            sun: sun,
            moon: moon,
            ascendant: ascendant
        )

        var keywords: [String] = []
        var combinedEmoji = "✨"

        if let sun = sun {
            let sunTrans = humanService.translateZodiacSign(sun.zodiacSign)
            keywords.append(contentsOf: sunTrans.strengths)
            combinedEmoji = humanService.signEmoji(sun.zodiacSign)
        }

        return Interpretation(
            id: "human_big_three",
            title: "Ваша уникальность",
            emoji: combinedEmoji,
            oneLiner: description,
            summary: description,
            detailed: description,
            keywords: Array(Set(keywords)), // Убираем дубликаты
            lifeAreas: [],
            elementType: .composite
        )
    }

    /// Получить список человеческих интерпретаций для больших планет
    func getHumanKeyInterpretations(
        for chart: BirthChart,
        limit: Int = 3,
        context: InterpretationContext? = nil
    ) -> [Interpretation] {
        var interpretations: [Interpretation] = []
        let humanService = humanLanguageService

        // Только большая тройка в человеческом режиме
        if let sun = chart.planets.first(where: { $0.type == .sun }) {
            let interpretation = getHumanInterpretation(for: .sun, in: sun.zodiacSign, context: context)
            interpretations.append(interpretation)
        }

        if let moon = chart.planets.first(where: { $0.type == .moon }) {
            let interpretation = getHumanInterpretation(for: .moon, in: moon.zodiacSign, context: context)
            interpretations.append(interpretation)
        }

        // Асцендент
        let ascendantInterpretation = getHumanInterpretation(
            for: .ascendant,
            in: chart.ascendant,
            context: context
        )
        interpretations.append(ascendantInterpretation)

        return Array(interpretations.prefix(limit))
    }

    /// Определить, нужно ли использовать человеческий стиль
    func shouldUseHumanLanguage(for displayMode: DisplayMode) -> Bool {
        return displayMode.useHumanLanguage
    }

    /// Адаптировать существующую интерпретацию под человеческий язык
    func humanizeInterpretation(_ interpretation: Interpretation) -> Interpretation {
        let humanService = humanLanguageService

        // Переводим ключевые слова
        let humanizedKeywords = interpretation.keywords.map { keyword in
            humanService.humanizeAstroTerm(keyword)
        }

        // Упрощаем тексты
        let humanizedOneLiner = humanizeText(interpretation.oneLiner)
        let humanizedSummary = humanizeText(interpretation.summary)
        let humanizedDetailed = humanizeText(interpretation.detailed)

        return Interpretation(
            id: "humanized_\(interpretation.id)",
            title: interpretation.title,
            emoji: interpretation.emoji,
            oneLiner: humanizedOneLiner,
            summary: humanizedSummary,
            detailed: humanizedDetailed,
            keywords: humanizedKeywords,
            lifeAreas: interpretation.lifeAreas,
            elementType: interpretation.elementType
        )
    }

    /// Упростить астрологический текст для человеческого восприятия
    private func humanizeText(_ text: String) -> String {
        let humanService = humanLanguageService

        var humanizedText = text

        // Словарь замен астрологических терминов
        let replacements: [(String, String)] = [
            ("натальная карта", "космический отпечаток"),
            ("планета в знаке", "энергия проявляется"),
            ("аспект", "взаимодействие"),
            ("соединение", "усиление энергии"),
            ("оппозиция", "внутреннее напряжение"),
            ("тригон", "гармоничный поток"),
            ("квадратура", "вызов для роста"),
            ("транзит", "текущее влияние"),
            ("ретроградный", "внутренняя работа"),
            ("орб", "сила влияния"),
            ("куспид", "начало области"),
            ("элевация", "высота энергии")
        ]

        // Применяем замены
        for (astroTerm, humanTerm) in replacements {
            humanizedText = humanizedText.replacingOccurrences(
                of: astroTerm,
                with: humanTerm,
                options: [.caseInsensitive]
            )
        }

        return humanizedText
    }

    /// Создать персональную аффирмацию на основе планеты
    func createPersonalAffirmation(for planet: Planet) -> String {
        let humanService = humanLanguageService
        let signTranslation = humanService.translateZodiacSign(planet.zodiacSign)

        switch planet.type {
        case .sun:
            return "Я принимаю свою уникальность и силу. \(signTranslation.strengths.first?.capitalized ?? "Моя энергия") — это мой дар миру."

        case .moon:
            return "Мои чувства важны и ценны. Я доверяю своей интуиции и \(signTranslation.strengths.first?.lowercased() ?? "внутренней мудрости")."

        case .ascendant:
            return "Я естественно притягиваю то, что мне нужно. Моя \(signTranslation.strengths.first?.lowercased() ?? "особенность") открывает двери."

        default:
            return "Я использую свои \(signTranslation.strengths.joined(separator: " и ")) для создания лучшей жизни."
        }
    }

    /// Создать практический совет на основе планеты в знаке
    func createPracticalAdvice(for planet: Planet) -> String {
        let humanService = humanLanguageService
        let signTranslation = humanService.translateZodiacSign(planet.zodiacSign)

        switch planet.type {
        case .sun:
            return "💡 Развивайте свою \(signTranslation.strengths.first?.lowercased() ?? "индивидуальность"). Это ваш естественный путь к успеху и самореализации."

        case .moon:
            if signTranslation.challenges.isEmpty {
                return "🌙 Прислушивайтесь к своим эмоциям. Они подскажут, что вам действительно нужно для счастья."
            } else {
                return "🌙 Осознавайте свою склонность к \(signTranslation.challenges.first?.lowercased() ?? "эмоциональным реакциям"). Это поможет лучше управлять чувствами."
            }

        case .ascendant:
            return "🎭 Используйте свою естественную \(signTranslation.strengths.first?.lowercased() ?? "харизму") для построения отношений и достижения целей."

        default:
            return "✨ Развивайте \(signTranslation.strengths.joined(separator: " и ")) — это ваши сильные стороны."
        }
    }

    /// Получить интерпретацию адаптированную под DisplayMode
    func getAdaptiveInterpretation(
        for planet: PlanetType,
        in sign: ZodiacSign,
        displayMode: DisplayMode,
        context: InterpretationContext? = nil
    ) -> Interpretation {

        if displayMode.useHumanLanguage {
            // Возвращаем человеческую интерпретацию
            return getHumanInterpretation(for: planet, in: sign, context: context)
        } else {
            // Возвращаем стандартную интерпретацию
            return getInterpretation(for: planet, in: sign, context: context)
        }
    }
}