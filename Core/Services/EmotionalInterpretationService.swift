//
//  EmotionalInterpretationService.swift
//  Astrolog
//
//  Created by Claude on 26.10.2025.
//

// Core/Services/EmotionalInterpretationService.swift
import Foundation
import SwiftUI
import Combine

/// Сервис для добавления эмоциональных аспектов в астрологические интерпретации
/// Делает астрологию более человечной и эмоционально резонирующей
class EmotionalInterpretationService: ObservableObject {

    // MARK: - Published Properties
    @Published var emotionalContext: EmotionalContext?
    @Published var currentMoodInfluences: [MoodInfluence] = []

    // MARK: - Private Properties
    private let humanLanguageService: HumanLanguageService
    // private let emotionalDatabase = EmotionalAstrologyDatabase.shared // Временно отключено
    private let empathyEngine = EmpathyEngine()

    // MARK: - Initialization
    init() {
        self.humanLanguageService = HumanLanguageService()
    }

    // MARK: - Public Methods

    /// Добавить эмоциональный контекст к базовой интерпретации
    func enhanceInterpretation(
        _ baseInterpretation: String,
        planet: PlanetType,
        sign: ZodiacSign,
        aspect: AspectType? = nil,
        displayMode: DisplayMode = .human,
        userEmotionalState: EmotionalState? = nil
    ) -> EmotionallyEnhancedInterpretation {

        // Получаем эмоциональную подпись планеты в знаке
        let emotionalSignature = getEmotionalSignature(planet: planet, sign: sign)

        // Добавляем эмоциональные нюансы
        let emotionalLayer = createEmotionalLayer(
            signature: emotionalSignature,
            aspect: aspect,
            displayMode: displayMode
        )

        // Адаптируем под текущее состояние пользователя
        let personalizedLayer = personalizeForEmotionalState(
            layer: emotionalLayer,
            userState: userEmotionalState
        )

        // Создаем итоговую интерпретацию
        return EmotionallyEnhancedInterpretation(
            baseText: baseInterpretation,
            emotionalLayer: personalizedLayer,
            practicalEmotionalAdvice: generateEmotionalAdvice(
                signature: emotionalSignature,
                displayMode: displayMode
            ),
            emotionalResonance: calculateEmotionalResonance(
                planet: planet,
                sign: sign,
                aspect: aspect
            ),
            moodImpact: assessMoodImpact(emotionalSignature, aspect: aspect),
            healingGuidance: generateHealingGuidance(
                signature: emotionalSignature,
                displayMode: displayMode
            )
        )
    }

    /// Создать эмоциональный профиль для транзита
    func createTransitEmotionalProfile(
        transitingPlanet: PlanetType,
        natalPlanet: PlanetType?,
        aspect: AspectType,
        influence: TransitInfluence,
        displayMode: DisplayMode = .human
    ) -> TransitEmotionalProfile {

        let emotionalDynamics = analyzeTransitEmotionalDynamics(
            transitingPlanet: transitingPlanet,
            natalPlanet: natalPlanet,
            aspect: aspect,
            influence: influence
        )

        let language = displayMode == .human || displayMode == .beginner ? LanguageStyle.simple : .complex

        return TransitEmotionalProfile(
            emotionalTheme: emotionalDynamics.theme,
            feelingTones: emotionalDynamics.feelingTones,
            emotionalChallenge: createEmotionalChallenge(dynamics: emotionalDynamics, language: language),
            emotionalOpportunity: createEmotionalOpportunity(dynamics: emotionalDynamics, language: language),
            supportiveActions: generateSupportiveActions(dynamics: emotionalDynamics, language: language),
            affirmation: createAffirmation(dynamics: emotionalDynamics, language: language)
        )
    }

    /// Анализировать эмоциональную совместимость аспектов
    func analyzeAspectEmotionalResonance(
        aspect: Aspect,
        displayMode: DisplayMode = .human
    ) -> AspectEmotionalResonance {

        let resonance = calculateAspectEmotionalResonance(aspect)
        let language = displayMode == .human || displayMode == .beginner ? LanguageStyle.simple : .complex

        return AspectEmotionalResonance(
            resonanceType: resonance.type,
            emotionalQuality: resonance.quality,
            humanDescription: createHumanEmotionalDescription(resonance: resonance, language: language),
            integrationAdvice: createIntegrationAdvice(resonance: resonance, language: language),
            warningSignals: identifyEmotionalWarningSignals(resonance: resonance),
            growthOpportunities: identifyEmotionalGrowthOpportunities(resonance: resonance, language: language)
        )
    }

    /// Создать эмоциональную карту дня
    func createDailyEmotionalMap(
        transits: [Transit],
        birthChart: BirthChart,
        displayMode: DisplayMode = .human
    ) async -> DailyEmotionalMap {

        var emotionalInfluences: [EmotionalInfluence] = []

        // Анализируем каждый транзит с эмоциональной стороны
        for transit in transits.prefix(5) {
            let influence = await createEmotionalInfluence(from: transit, birthChart: birthChart, displayMode: displayMode)
            emotionalInfluences.append(influence)
        }

        // Определяем доминирующую эмоциональную тему дня
        let dominantTheme = determineDominantEmotionalTheme(influences: emotionalInfluences)

        // Создаем эмоциональный прогноз
        let forecast = createEmotionalForecast(
            theme: dominantTheme,
            influences: emotionalInfluences,
            displayMode: displayMode
        )

        // Генерируем рекомендации по эмоциональному благополучию
        let wellbeingAdvice = generateEmotionalWellbeingAdvice(
            theme: dominantTheme,
            birthChart: birthChart,
            displayMode: displayMode
        )

        return DailyEmotionalMap(
            date: Date(),
            dominantTheme: dominantTheme,
            influences: emotionalInfluences,
            forecast: forecast,
            wellbeingAdvice: wellbeingAdvice,
            emotionalWeather: determineEmotionalWeather(influences: emotionalInfluences)
        )
    }

    // MARK: - Private Methods

    private func getEmotionalSignature(planet: PlanetType, sign: ZodiacSign) -> EmotionalSignature {
        let planetEmotion = emotionalDatabase.getPlanetaryEmotion(planet)
        let signExpression = emotionalDatabase.getSignEmotionalExpression(sign)

        return EmotionalSignature(
            coreEmotion: blendEmotions(planetEmotion.core, signExpression.core),
            expressionStyle: signExpression.style,
            emotionalNeeds: combineEmotionalNeeds(planetEmotion.needs, signExpression.needs),
            triggers: identifyEmotionalTriggers(planet: planet, sign: sign),
            healing: identifyHealingApproaches(planet: planet, sign: sign)
        )
    }

    private func createEmotionalLayer(
        signature: EmotionalSignature,
        aspect: AspectType?,
        displayMode: DisplayMode
    ) -> EmotionalLayer {

        let language = displayMode == .human || displayMode == .beginner ? LanguageStyle.simple : .complex

        let emotional = language == .simple ?
            createSimpleEmotionalDescription(signature: signature, aspect: aspect) :
            createComplexEmotionalDescription(signature: signature, aspect: aspect)

        return EmotionalLayer(
            emotionalNuance: emotional.nuance,
            feelingDescription: emotional.feeling,
            emotionalAdvice: emotional.advice,
            empathyConnection: empathyEngine.generateEmpathyConnection(signature: signature)
        )
    }

    private func createSimpleEmotionalDescription(
        signature: EmotionalSignature,
        aspect: AspectType?
    ) -> (nuance: String, feeling: String, advice: String) {

        let baseFeeling = signature.coreEmotion.simpleDescription
        let aspectModifier = aspect?.emotionalModifier ?? ""

        let feeling = aspect != nil ? "\(baseFeeling) \(aspectModifier)" : baseFeeling

        return (
            nuance: "На эмоциональном уровне вы можете почувствовать \(signature.coreEmotion.simpleDescription.lowercased())",
            feeling: "Это проявится как \(feeling.lowercased())",
            advice: "Помните: \(signature.emotionalNeeds.first?.humanAdvice ?? "ваши чувства важны и имеют смысл")"
        )
    }

    private func createComplexEmotionalDescription(
        signature: EmotionalSignature,
        aspect: AspectType?
    ) -> (nuance: String, feeling: String, advice: String) {

        return (
            nuance: "Эмоциональная архитектура данной конфигурации основана на \(signature.coreEmotion.complexDescription)",
            feeling: "Психологическая интеграция происходит через \(signature.expressionStyle.psychologicalMechanism)",
            advice: "Рекомендуется развивать \(signature.healing.primaryApproach) как основной метод эмоциональной интеграции"
        )
    }

    private func personalizeForEmotionalState(
        layer: EmotionalLayer,
        userState: EmotionalState?
    ) -> EmotionalLayer {

        guard let userState = userState else { return layer }

        // Адаптируем интерпретацию под текущее эмоциональное состояние пользователя
        let personalizedNuance = adaptToUserState(layer.emotionalNuance, userState: userState)
        let personalizedAdvice = personalizeAdvice(layer.emotionalAdvice, userState: userState)

        return EmotionalLayer(
            emotionalNuance: personalizedNuance,
            feelingDescription: layer.feelingDescription,
            emotionalAdvice: personalizedAdvice,
            empathyConnection: enhanceEmpathyForUserState(layer.empathyConnection, userState: userState)
        )
    }

    private func generateEmotionalAdvice(
        signature: EmotionalSignature,
        displayMode: DisplayMode
    ) -> [EmotionalAdvice] {

        let language = displayMode == .human || displayMode == .beginner ? LanguageStyle.simple : .complex

        return signature.emotionalNeeds.map { need in
            EmotionalAdvice(
                category: need.category,
                suggestion: language == .simple ? need.humanAdvice : need.technicalAdvice,
                practicalStep: need.practicalAction,
                emotionalBenefit: need.expectedBenefit
            )
        }
    }

    private func calculateEmotionalResonance(
        planet: PlanetType,
        sign: ZodiacSign,
        aspect: AspectType?
    ) -> EmotionalResonanceMetrics {

        let planetResonance = emotionalDatabase.getPlanetResonance(planet)
        let signResonance = emotionalDatabase.getSignResonance(sign)
        let aspectResonance = aspect?.resonanceModifier ?? 1.0

        return EmotionalResonanceMetrics(
            intensity: (planetResonance.intensity + signResonance.intensity) * aspectResonance / 2.0,
            stability: min(planetResonance.stability, signResonance.stability),
            accessibility: (planetResonance.accessibility + signResonance.accessibility) / 2.0,
            integrationDifficulty: max(planetResonance.complexity, signResonance.complexity) * aspectResonance
        )
    }

    private func analyzeTransitEmotionalDynamics(
        transitingPlanet: PlanetType,
        natalPlanet: PlanetType?,
        aspect: AspectType,
        influence: TransitInfluence
    ) -> TransitEmotionalDynamics {

        let transitingEmotion = emotionalDatabase.getPlanetaryEmotion(transitingPlanet)
        let natalEmotion = natalPlanet.map { emotionalDatabase.getPlanetaryEmotion($0) }

        let interaction = natalEmotion.map {
            analyzeEmotionalInteraction(transiting: transitingEmotion, natal: $0, aspect: aspect)
        }

        let theme = determineEmotionalTheme(
            transitingEmotion: transitingEmotion,
            interaction: interaction,
            influence: influence
        )

        return TransitEmotionalDynamics(
            theme: theme,
            feelingTones: extractFeelingTones(from: interaction, influence: influence),
            intensityLevel: calculateEmotionalIntensity(
                transitingEmotion: transitingEmotion,
                aspect: aspect,
                influence: influence
            ),
            duration: estimateEmotionalDuration(planet: transitingPlanet, aspect: aspect),
            integrationPath: determineIntegrationPath(theme: theme, influence: influence)
        )
    }

    private func createEmotionalInfluence(
        from transit: Transit,
        birthChart: BirthChart,
        displayMode: DisplayMode
    ) async -> EmotionalInfluence {

        let profile = createTransitEmotionalProfile(
            transitingPlanet: transit.transitingPlanet,
            natalPlanet: transit.natalPlanet,
            aspect: transit.aspectType,
            influence: transit.influence,
            displayMode: displayMode
        )

        return EmotionalInfluence(
            source: .transit(transit),
            emotionalProfile: profile,
            intensity: Double(transit.impactLevel.priority) / 5.0,
            timeframe: transit.duration,
            personalRelevance: calculatePersonalEmotionalRelevance(
                transit: transit,
                birthChart: birthChart
            )
        )
    }

    // MARK: - Helper Methods

    private func blendEmotions(_ emotion1: CoreEmotion, _ emotion2: CoreEmotion) -> CoreEmotion {
        // Создаем синтез эмоций планеты и знака
        return CoreEmotion(
            name: "\(emotion1.name) через \(emotion2.name)",
            simpleDescription: emotion2.simpleDescription + " " + emotion1.essence,
            complexDescription: "\(emotion1.psychologicalFunction) проявляется через \(emotion2.complexDescription)",
            intensity: (emotion1.intensity + emotion2.intensity) / 2.0,
            stability: min(emotion1.stability, emotion2.stability)
        )
    }

    private func combineEmotionalNeeds(_ needs1: [EmotionalNeed], _ needs2: [EmotionalNeed]) -> [EmotionalNeed] {
        var combined = needs1
        for need2 in needs2 {
            if !combined.contains(where: { $0.category == need2.category }) {
                combined.append(need2)
            }
        }
        return combined.sorted { $0.priority > $1.priority }
    }

    private func identifyEmotionalTriggers(planet: PlanetType, sign: ZodiacSign) -> [EmotionalTrigger] {
        let planetTriggers = emotionalDatabase.getPlanetTriggers(planet)
        let signTriggers = emotionalDatabase.getSignTriggers(sign)

        return (planetTriggers + signTriggers).map { triggerName in
            EmotionalTrigger(
                name: triggerName,
                description: "Описание триггера: \(triggerName)",
                intensity: 0.5,
                commonSituations: ["Ситуация 1", "Ситуация 2"],
                copingStrategies: ["Стратегия 1", "Стратегия 2"]
            )
        }
    }

    private func identifyHealingApproaches(planet: PlanetType, sign: ZodiacSign) -> HealingApproach {
        let planetHealing = emotionalDatabase.getPlanetHealing(planet)
        let signHealing = emotionalDatabase.getSignHealing(sign)

        return HealingApproach(
            primaryApproach: "Комбинированный подход",
            simpleDescription: signHealing.simpleDescription,
            technicalDescription: "Интегрированный подход: \(planetHealing) + \(signHealing.simpleDescription)",
            practicalSteps: signHealing.practicalSteps,
            expectedTimeframe: "2-4 недели",
            supportiveActivities: ["Медитация", "Рефлексия"]
        )
    }

    private func assessMoodImpact(_ signature: EmotionalSignature, aspect: AspectType?) -> MoodImpact {
        let baseImpact = signature.coreEmotion.moodInfluence
        let aspectMultiplier = aspect?.moodMultiplier ?? 1.0

        return MoodImpact(
            positiveShift: baseImpact.positive * aspectMultiplier,
            negativeShift: baseImpact.negative * aspectMultiplier,
            energyChange: baseImpact.energy * aspectMultiplier,
            stabilityEffect: baseImpact.stability / aspectMultiplier
        )
    }

    private func generateHealingGuidance(
        signature: EmotionalSignature,
        displayMode: DisplayMode
    ) -> HealingGuidance {

        let language = displayMode == .human || displayMode == .beginner ? LanguageStyle.simple : .complex

        return HealingGuidance(
            primaryMethod: signature.healing.primaryApproach,
            description: language == .simple ?
                signature.healing.simpleDescription :
                signature.healing.technicalDescription,
            practicalSteps: signature.healing.practicalSteps,
            timeframe: signature.healing.expectedTimeframe,
            supportiveActivities: signature.healing.supportiveActivities
        )
    }

    // Additional helper methods for completeness
    private func adaptToUserState(_ text: String, userState: EmotionalState) -> String {
        // Адаптируем текст под эмоциональное состояние пользователя
        return text + " Учитывая ваше текущее состояние, особенно важно обратить внимание на \(userState.primaryConcern)."
    }

    private func personalizeAdvice(_ advice: String, userState: EmotionalState) -> String {
        return advice + " В вашем случае рекомендуется \(userState.recommendedAction)."
    }

    private func enhanceEmpathyForUserState(_ connection: EmpathyConnection, userState: EmotionalState) -> EmpathyConnection {
        return EmpathyConnection(
            resonancePhrase: connection.resonancePhrase + " Мы понимаем, что сейчас вам \(userState.empathyPhrase).",
            validationMessage: connection.validationMessage,
            encouragement: connection.encouragement + " Ваши чувства в этой ситуации абсолютно естественны."
        )
    }

    private func analyzeEmotionalInteraction(
        transiting: PlanetaryEmotion,
        natal: PlanetaryEmotion,
        aspect: AspectType
    ) -> EmotionalInteraction {

        return EmotionalInteraction(
            harmonyLevel: calculateEmotionalHarmony(transiting, natal, aspect),
            tensionPoints: identifyEmotionalTensions(transiting, natal, aspect),
            integrationOpportunity: identifyIntegrationOpportunity(transiting, natal, aspect),
            transformationPotential: calculateTransformationPotential(transiting, natal, aspect)
        )
    }

    private func determineEmotionalTheme(
        transitingEmotion: PlanetaryEmotion,
        interaction: EmotionalInteraction?,
        influence: TransitInfluence
    ) -> EmotionalTheme {

        // Определяем эмоциональную тему на основе взаимодействия
        return EmotionalTheme(
            name: "\(transitingEmotion.archetype) \(influence.rawValue.lowercased())",
            description: "Период \(transitingEmotion.essence.lowercased()) с \(influence.rawValue.lowercased()) оттенком",
            keywords: transitingEmotion.keywords + influence.emotionalKeywords,
            evolutionaryPurpose: interaction?.integrationOpportunity ?? "Развитие эмоциональной мудрости"
        )
    }

    private func extractFeelingTones(from interaction: EmotionalInteraction?, influence: TransitInfluence) -> [FeelingTone] {
        var tones: [FeelingTone] = []

        switch influence {
        case .harmonious:
            tones = [.uplifting, .harmonious, .flowing]
        case .challenging:
            tones = [.intense, .transformative, .confronting]
        case .transformative:
            tones = [.deep, .evolutionary, .mystical]
        case .neutral:
            tones = [.balanced, .integrative, .subtle]
        }

        return tones
    }

    private func calculateEmotionalIntensity(
        transitingEmotion: PlanetaryEmotion,
        aspect: AspectType,
        influence: TransitInfluence
    ) -> Double {

        let baseIntensity = transitingEmotion.baseIntensity
        let aspectModifier = aspect.intensityMultiplier
        let influenceModifier = influence.intensityModifier

        return baseIntensity * aspectModifier * influenceModifier
    }

    private func estimateEmotionalDuration(planet: PlanetType, aspect: AspectType) -> EmotionalDuration {
        let baseDuration = planet.emotionalInfluenceDuration
        let aspectMultiplier = aspect.durationMultiplier

        // Работаем с TimeInterval значениями напрямую
        return EmotionalDuration(
            onset: .hours(Int(baseDuration.onset / 3600)),
            peak: .hours(Int((baseDuration.peak * aspectMultiplier) / 3600)),
            resolution: .hours(Int(baseDuration.resolution / 3600))
        )
    }

    private func determineIntegrationPath(theme: EmotionalTheme, influence: TransitInfluence) -> IntegrationPath {
        return IntegrationPath(
            phases: theme.integrationPhases,
            keyMilestones: theme.keyMilestones,
            supportNeeded: influence.requiredSupport,
            expectedOutcome: theme.evolutionaryPurpose
        )
    }

    private func determineDominantEmotionalTheme(influences: [EmotionalInfluence]) -> EmotionalTheme {
        // Находим доминирующую эмоциональную тему среди всех влияний
        let weightedThemes = influences.map { influence in
            (theme: influence.emotionalProfile.emotionalTheme, weight: influence.intensity * influence.personalRelevance)
        }

        let dominantTheme = weightedThemes.max { $0.weight < $1.weight }?.theme
        return dominantTheme ?? EmotionalTheme.neutral
    }

    private func createEmotionalForecast(
        theme: EmotionalTheme,
        influences: [EmotionalInfluence],
        displayMode: DisplayMode
    ) -> EmotionalForecast {

        let language = displayMode == .human || displayMode == .beginner ? LanguageStyle.simple : .complex

        return EmotionalForecast(
            overallTone: theme.description,
            keyInsights: theme.keywords.prefix(3).map { String($0) },
            recommendations: generateForecastRecommendations(theme: theme, language: language),
            warningAreas: identifyEmotionalWarnings(influences: influences),
            opportunityAreas: identifyEmotionalOpportunities(influences: influences, language: language)
        )
    }

    private func generateEmotionalWellbeingAdvice(
        theme: EmotionalTheme,
        birthChart: BirthChart,
        displayMode: DisplayMode
    ) -> [EmotionalWellbeingAdvice] {

        let language = displayMode == .human || displayMode == .beginner ? LanguageStyle.simple : .complex

        // Базовые советы на основе темы дня
        var advice: [EmotionalWellbeingAdvice] = []

        advice.append(EmotionalWellbeingAdvice(
            category: .selfCare,
            title: language == .simple ? "Забота о себе" : "Эмоциональная гигиена",
            description: theme.selfCareGuidance,
            practicalAction: theme.recommendedSelfCareAction,
            emotionalBenefit: "Повышение эмоциональной устойчивости"
        ))

        // Персональные советы на основе карты
        if let moonSign = birthChart.planets.first(where: { $0.type == .moon })?.zodiacSign {
            let moonAdvice = generateMoonBasedWellbeingAdvice(moonSign: moonSign, theme: theme, language: language)
            advice.append(moonAdvice)
        }

        return advice
    }

    private func determineEmotionalWeather(influences: [EmotionalInfluence]) -> EmotionalWeather {
        let totalIntensity = influences.reduce(0) { $0 + $1.intensity }
        let averageIntensity = totalIntensity / Double(influences.count)

        let harmonious = influences.filter { $0.emotionalProfile.emotionalTheme.isHarmonious }.count
        let challenging = influences.filter { $0.emotionalProfile.emotionalTheme.isChallenging }.count

        if challenging > harmonious && averageIntensity > 0.7 {
            return .stormy
        } else if harmonious > challenging && averageIntensity < 0.4 {
            return .calm
        } else if averageIntensity > 0.6 {
            return .intense
        } else {
            return .mixed
        }
    }

    private func calculatePersonalEmotionalRelevance(transit: Transit, birthChart: BirthChart) -> Double {
        // Рассчитываем личную эмоциональную релевантность транзита
        var relevance: Double = 0.5

        // Увеличиваем релевантность для личных планет
        if let natalPlanet = transit.natalPlanet {
            switch natalPlanet {
            case .sun, .moon, .mercury, .venus, .mars:
                relevance += 0.3
            default:
                relevance += 0.1
            }
        }

        // Увеличиваем для интенсивных транзитов
        relevance += Double(transit.impactLevel.priority) * 0.1

        return min(relevance, 1.0)
    }

    // Дополнительные helper-методы
    private func calculateEmotionalHarmony(_ emotion1: PlanetaryEmotion, _ emotion2: PlanetaryEmotion, _ aspect: AspectType) -> Double {
        let baseCompatibility = emotion1.compatibilityWith(emotion2)
        return baseCompatibility * aspect.harmonyModifier
    }

    private func identifyEmotionalTensions(_ emotion1: PlanetaryEmotion, _ emotion2: PlanetaryEmotion, _ aspect: AspectType) -> [EmotionalTension] {
        return emotion1.tensionsWith(emotion2, aspect: aspect)
    }

    private func identifyIntegrationOpportunity(_ emotion1: PlanetaryEmotion, _ emotion2: PlanetaryEmotion, _ aspect: AspectType) -> String {
        return "Интеграция \(emotion1.archetype) и \(emotion2.archetype) через \(aspect.integrationMethod)"
    }

    private func calculateTransformationPotential(_ emotion1: PlanetaryEmotion, _ emotion2: PlanetaryEmotion, _ aspect: AspectType) -> Double {
        return emotion1.transformationCapacity * emotion2.transformationCapacity * aspect.transformationMultiplier
    }

    private func generateForecastRecommendations(theme: EmotionalTheme, language: LanguageStyle) -> [String] {
        return theme.recommendationsFor(language: language)
    }

    private func identifyEmotionalWarnings(influences: [EmotionalInfluence]) -> [String] {
        return influences.compactMap { influence in
            influence.emotionalProfile.emotionalChallenge?.warningSign
        }
    }

    private func identifyEmotionalOpportunities(influences: [EmotionalInfluence], language: LanguageStyle) -> [String] {
        return influences.compactMap { influence in
            influence.emotionalProfile.emotionalOpportunity?.description(for: language)
        }
    }

    private func generateMoonBasedWellbeingAdvice(moonSign: ZodiacSign, theme: EmotionalTheme, language: LanguageStyle) -> EmotionalWellbeingAdvice {
        let moonHealing = emotionalDatabase.getSignHealing(moonSign)

        return EmotionalWellbeingAdvice(
            category: .emotional,
            title: language == .simple ? "Эмоциональная поддержка" : "Лунная эмоциональная интеграция",
            description: "С учетом вашей Луны в \(moonSign.displayName), сегодня особенно важно \(moonHealing.simpleDescription)",
            practicalAction: moonHealing.practicalSteps.first ?? "медитация",
            emotionalBenefit: "Гармонизация эмоционального состояния"
        )
    }

    // MARK: - Missing Helper Methods

    private func createEmotionalChallenge(dynamics: TransitEmotionalDynamics, language: LanguageStyle) -> EmotionalChallenge? {
        return EmotionalChallenge(
            description: "Эмоциональный вызов: работа с внутренними противоречиями",
            copingStrategies: ["Осознанность", "Самопринятие"],
            warningSign: "Эмоциональная перегрузка",
            supportNeeded: "Поддержка близких"
        )
    }

    private func createEmotionalOpportunity(dynamics: TransitEmotionalDynamics, language: LanguageStyle) -> EmotionalOpportunity? {
        return EmotionalOpportunity(
            description: "Эмоциональная возможность: развитие эмоциональной зрелости",
            actionSteps: ["Практика осознанности", "Развитие эмпатии"],
            potentialOutcome: "Эмоциональная мудрость"
        )
    }

    private func generateSupportiveActions(dynamics: TransitEmotionalDynamics, language: LanguageStyle) -> [String] {
        return ["Медитация", "Ведение дневника эмоций", "Практика осознанности"]
    }

    private func createAffirmation(dynamics: TransitEmotionalDynamics, language: LanguageStyle) -> String {
        return "Я принимаю свои эмоции и учусь с ними работать конструктивно"
    }

    private func calculateAspectEmotionalResonance(_ aspect: Aspect) -> (type: AspectResonanceType, quality: EmotionalQuality) {
        return (type: .harmonic, quality: .supportive)
    }

    private func createHumanEmotionalDescription(resonance: (type: AspectResonanceType, quality: EmotionalQuality), language: LanguageStyle) -> String {
        return "Этот аспект создает поддерживающую эмоциональную энергию"
    }

    private func createIntegrationAdvice(resonance: (type: AspectResonanceType, quality: EmotionalQuality), language: LanguageStyle) -> String {
        return "Используйте эту энергию для эмоционального роста"
    }

    private func identifyEmotionalWarningSignals(resonance: (type: AspectResonanceType, quality: EmotionalQuality)) -> [String] {
        return ["Эмоциональная перегрузка", "Внутренний конфликт"]
    }

    private func identifyEmotionalGrowthOpportunities(resonance: (type: AspectResonanceType, quality: EmotionalQuality), language: LanguageStyle) -> [String] {
        return ["Развитие эмпатии", "Углубление самопонимания"]
    }

    private var emotionalDatabase: EmotionalDatabase {
        return EmotionalDatabase()
    }
}

// MARK: - EmotionalDatabase

struct EmotionalDatabase {
    func getSignHealing(_ sign: ZodiacSign) -> (simpleDescription: String, practicalSteps: [String]) {
        return (
            simpleDescription: "практиковать самозаботу",
            practicalSteps: ["Медитация", "Дыхательные упражнения", "Ведение дневника"]
        )
    }

    func getPlanetaryEmotion(_ planet: PlanetType) -> PlanetaryEmotion {
        return PlanetaryEmotion(
            archetype: "Архетип планеты",
            essence: "Сущность планеты",
            core: CoreEmotion(name: "Базовая эмоция", simpleDescription: "Простое описание", complexDescription: "Сложное описание", intensity: 0.5, stability: 0.5),
            baseIntensity: 0.5,
            keywords: ["ключевое слово"],
            needs: [],
            transformationCapacity: 0.5
        )
    }

    func getSignEmotionalExpression(_ sign: ZodiacSign) -> SignEmotionalExpression {
        return SignEmotionalExpression(
            style: EmotionalExpressionStyle(name: "Стиль", spontaneity: 0.5, intensity: 0.5, duration: 0.5, psychologicalMechanism: "Механизм"),
            core: CoreEmotion(name: "Базовая эмоция", simpleDescription: "Простое описание", complexDescription: "Сложное описание", intensity: 0.5, stability: 0.5),
            needs: []
        )
    }

    func getPlanetResonance(_ planet: PlanetType) -> EmotionalResonanceData {
        return EmotionalResonanceData(intensity: 0.5, stability: 0.5, accessibility: 0.5, complexity: 0.5)
    }

    func getSignResonance(_ sign: ZodiacSign) -> EmotionalResonanceData {
        return EmotionalResonanceData(intensity: 0.5, stability: 0.5, accessibility: 0.5, complexity: 0.5)
    }

    func getPlanetTriggers(_ planet: PlanetType) -> [String] {
        return ["Планетарный триггер"]
    }

    func getSignTriggers(_ sign: ZodiacSign) -> [String] {
        return ["Знаковый триггер"]
    }

    func getPlanetHealing(_ planet: PlanetType) -> String {
        return "Планетарное исцеление"
    }

    func getCoreEmotion(for element: ZodiacSign.Element) -> String {
        switch element {
        case .fire: return "Энтузиазм"
        case .earth: return "Стабильность"
        case .air: return "Любознательность"
        case .water: return "Сочувствие"
        }
    }

    func getEmotionalThemes(for modality: ZodiacSign.Modality) -> [String] {
        switch modality {
        case .cardinal: return ["Инициатива", "Лидерство"]
        case .fixed: return ["Постоянство", "Устойчивость"]
        case .mutable: return ["Адаптивность", "Гибкость"]
        }
    }
}

// MARK: - Supporting Extensions

extension AspectType {
    var emotionalModifier: String {
        switch self {
        case .conjunction: return "с интенсивной слитностью"
        case .sextile: return "с легкой гармонией"
        case .square: return "с внутренним напряжением"
        case .trine: return "с естественной гармонией"
        case .opposition: return "с поляризацией"
        }
    }

    var resonanceModifier: Double {
        switch self {
        case .conjunction: return 1.5
        case .trine: return 1.2
        case .sextile: return 1.1
        case .square: return 0.8
        case .opposition: return 0.7
        }
    }

    var moodMultiplier: Double {
        switch self {
        case .conjunction: return 1.4
        case .trine, .sextile: return 1.2
        case .square, .opposition: return 0.9
        }
    }

    var intensityMultiplier: Double {
        switch self {
        case .conjunction, .opposition: return 1.5
        case .square: return 1.3
        case .trine: return 1.1
        case .sextile: return 1.0
        }
    }

    var durationMultiplier: Double {
        switch self {
        case .conjunction: return 1.2
        case .opposition, .square: return 1.1
        case .trine, .sextile: return 1.0
        }
    }

    var harmonyModifier: Double {
        switch self {
        case .trine: return 1.5
        case .sextile: return 1.2
        case .conjunction: return 1.0
        case .square: return 0.6
        case .opposition: return 0.4
        }
    }

    var transformationMultiplier: Double {
        switch self {
        case .square, .opposition: return 1.4
        case .conjunction: return 1.2
        case .trine: return 0.8
        case .sextile: return 0.6
        }
    }

    var integrationMethod: String {
        switch self {
        case .conjunction: return "слияние энергий"
        case .trine: return "естественное течение"
        case .sextile: return "творческое сотрудничество"
        case .square: return "динамическое напряжение"
        case .opposition: return "балансировка полярностей"
        }
    }
}

extension TransitInfluence {
    var emotionalKeywords: [String] {
        switch self {
        case .harmonious:
            return ["поддерживающий", "гармонизирующий", "исцеляющий"]
        case .challenging:
            return ["трансформирующий", "испытывающий", "пробуждающий"]
        case .transformative:
            return ["глубинный", "эволюционный", "мистический"]
        case .neutral:
            return ["интегрирующий", "балансирующий", "стабилизирующий"]
        }
    }

    var intensityModifier: Double {
        switch self {
        case .transformative: return 1.4
        case .challenging: return 1.2
        case .harmonious: return 1.0
        case .neutral: return 0.8
        }
    }

    var requiredSupport: [String] {
        switch self {
        case .harmonious:
            return ["принятие благословений", "открытость к росту"]
        case .challenging:
            return ["терпение с собой", "поддержка близких", "профессиональная помощь"]
        case .transformative:
            return ["духовные практики", "глубокая саморефлексия", "доверие процессу"]
        case .neutral:
            return ["осознанность", "баланс активности и отдыха"]
        }
    }
}

extension PlanetType {
    var emotionalInfluenceDuration: EmotionalDuration {
        switch self {
        case .moon:
            return EmotionalDuration(onset: .hours(2), peak: .hours(6), resolution: .hours(4))
        case .mercury:
            return EmotionalDuration(onset: .hours(12), peak: .days(2), resolution: .days(1))
        case .venus:
            return EmotionalDuration(onset: .days(1), peak: .days(3), resolution: .days(2))
        case .sun:
            return EmotionalDuration(onset: .days(1), peak: .days(2), resolution: .days(1))
        case .mars:
            return EmotionalDuration(onset: .days(2), peak: .days(5), resolution: .days(3))
        case .jupiter:
            return EmotionalDuration(onset: .days(7), peak: .days(14), resolution: .days(7))
        case .saturn:
            return EmotionalDuration(onset: .days(14), peak: .days(30), resolution: .days(14))
        case .uranus:
            return EmotionalDuration(onset: .days(30), peak: .days(90), resolution: .days(30))
        case .neptune:
            return EmotionalDuration(onset: .days(45), peak: .days(120), resolution: .days(45))
        case .pluto:
            return EmotionalDuration(onset: .days(60), peak: .days(150), resolution: .days(60))
        case .ascendant:
            return EmotionalDuration(onset: .hours(24), peak: .days(3), resolution: .days(1))
        case .midheaven:
            return EmotionalDuration(onset: .days(7), peak: .days(14), resolution: .days(7))
        case .northNode:
            return EmotionalDuration(onset: .days(30), peak: .days(90), resolution: .days(30))
        }
    }
}

extension Array where Element: Hashable {
    func uniqued() -> [Element] {
        return Array(Set(self))
    }
}