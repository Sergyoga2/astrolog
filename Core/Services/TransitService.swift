//
//  TransitService.swift
//  Astrolog
//
//  Created by Claude on 26.10.2025.
//

// Core/Services/TransitService.swift
import Foundation
import SwiftUI
import Combine

/// Сервис для расчета и анализа текущих транзитов
class TransitService: ObservableObject {

    // MARK: - Published Properties
    @Published var currentTransits: [Transit] = []
    @Published var todayInsights: DailyInsight?
    @Published var isLoading = false
    @Published var lunarPhase: LunarPhase = .newMoon

    // MARK: - Private Properties
    private let astrologyService: AstrologyServiceProtocol
    private let humanLanguageService: HumanLanguageService
    private var cancellables = Set<AnyCancellable>()

    // Кэш транзитов для оптимизации
    private var transitCache: [String: [Transit]] = [:]
    private let cacheTimeout: TimeInterval = 3600 // 1 час

    // MARK: - Initialization
    init(astrologyService: AstrologyServiceProtocol = SwissEphemerisService()) {
        self.astrologyService = astrologyService
        self.humanLanguageService = HumanLanguageService()

        setupPeriodicUpdates()
        calculateLunarPhase()
    }

    // MARK: - Public Methods

    /// Рассчитать текущие транзиты для натальной карты
    func calculateCurrentTransits(for birthChart: BirthChart) async {
        await MainActor.run {
            isLoading = true
        }

        do {
            let currentDate = Date()
            let cacheKey = "\(currentDate.timeIntervalSince1970 / 3600)_\(birthChart.id)" // Кэш на час

            // Проверяем кэш
            if let cachedTransits = transitCache[cacheKey] {
                await MainActor.run {
                    self.currentTransits = cachedTransits
                    self.isLoading = false
                }
                await generateDailyInsights(for: birthChart, transits: cachedTransits)
                return
            }

            // Получаем текущие транзиты
            let dailyTransits = try await astrologyService.getCurrentTransits()

            // Конвертируем DailyTransit в Transit для совместимости
            var transits: [Transit] = []

            for dailyTransit in dailyTransits {
                if let natalPlanet = dailyTransit.natalPlanet,
                   let aspectType = dailyTransit.aspectType {
                    let transit = Transit(
                        transitingPlanet: dailyTransit.planet,
                        natalPlanet: natalPlanet,
                        aspectType: aspectType,
                        orb: 2.0, // Используем стандартный орб
                        influence: .harmonious, // Упрощенная логика
                        duration: DateInterval(start: dailyTransit.startDate, end: dailyTransit.endDate),
                        peak: Date(),
                        interpretation: dailyTransit.description,
                        humanDescription: dailyTransit.influence,
                        emoji: "✨"
                    )
                    transits.append(transit)
                }
            }

            // Сохраняем в кеш и генерируем insights

            // Сортируем по важности
            transits.sort { lhs, rhs in
                if lhs.impactLevel.priority != rhs.impactLevel.priority {
                    return lhs.impactLevel.priority > rhs.impactLevel.priority
                }
                return lhs.intensity > rhs.intensity
            }

            // Кэшируем результат
            transitCache[cacheKey] = transits

            await MainActor.run {
                self.currentTransits = transits
                self.isLoading = false
            }

            // Генерируем дневные инсайты
            await generateDailyInsights(for: birthChart, transits: transits)

        } catch {
            print("Ошибка расчета транзитов: \(error)")
            await MainActor.run {
                self.isLoading = false
                // Используем моки при ошибке
                self.currentTransits = createMockTransits()
            }
        }
    }

    /// Получить транзиты на определенную дату
    func getTransitsFor(date: Date, birthChart: BirthChart) async -> [Transit] {
        // Для простоты возвращаем текущие транзиты
        // В полной реализации здесь был бы расчет для конкретной даты
        return currentTransits
    }

    /// Получить самые важные транзиты для отображения
    func getTopTransits(count: Int = 5) -> [Transit] {
        return Array(currentTransits.prefix(count))
    }

    // MARK: - Private Methods

    private func setupPeriodicUpdates() {
        // Обновляем транзиты каждый час
        Timer.publish(every: 3600, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.calculateLunarPhase()
                // Обновление транзитов будет происходить при вызове calculateCurrentTransits
            }
            .store(in: &cancellables)
    }

    private func calculateAspect(from longitude1: Double, to longitude2: Double) -> (aspect: AspectType?, orb: Double) {
        let diff = abs(longitude1 - longitude2)
        let adjustedDiff = min(diff, 360 - diff)

        let aspects: [(AspectType, Double)] = [
            (.conjunction, 0),
            (.sextile, 60),
            (.square, 90),
            (.trine, 120),
            (.opposition, 180)
        ]

        for (aspectType, targetAngle) in aspects {
            let orb = abs(adjustedDiff - targetAngle)
            if orb <= aspectType.maxOrb {
                return (aspectType, orb)
            }
        }

        return (nil, 0)
    }

    private func createTransit(
        transitingPlanet: Planet,
        natalPlanet: Planet,
        aspect: AspectType,
        orb: Double,
        currentDate: Date
    ) -> Transit {
        let influence = determineInfluence(
            transitingPlanet: transitingPlanet.type,
            natalPlanet: natalPlanet.type,
            aspect: aspect
        )

        let duration = calculateTransitDuration(
            transitingPlanet: transitingPlanet.type,
            aspect: aspect,
            currentDate: currentDate
        )

        let interpretation = generateInterpretation(
            transitingPlanet: transitingPlanet.type,
            natalPlanet: natalPlanet.type,
            aspect: aspect,
            influence: influence
        )

        let humanDescription = generateHumanDescription(
            transitingPlanet: transitingPlanet.type,
            natalPlanet: natalPlanet.type,
            aspect: aspect,
            influence: influence
        )

        let emoji = getTransitEmoji(transitingPlanet.type, influence)

        return Transit(
            transitingPlanet: transitingPlanet.type,
            natalPlanet: natalPlanet.type,
            aspectType: aspect,
            orb: orb,
            influence: influence,
            duration: duration,
            peak: calculatePeakDate(currentDate: currentDate, orb: orb),
            interpretation: interpretation,
            humanDescription: humanDescription,
            emoji: emoji
        )
    }

    private func calculateSignIngresses(_ planets: [Planet]) -> [Transit] {
        var ingresses: [Transit] = []
        let currentDate = Date()

        for planet in planets {
            // Проверяем, близка ли планета к границе знака
            let degreeInSign = planet.longitude.truncatingRemainder(dividingBy: 30)

            if degreeInSign < 2.0 || degreeInSign > 28.0 {
                // Планета близко к границе знака
                let currentSign = ZodiacSign.from(longitude: planet.longitude)

                let transit = Transit(
                    transitingPlanet: planet.type,
                    natalPlanet: nil,
                    aspectType: .conjunction, // Используем как аспект "входа"
                    orb: min(degreeInSign, 30 - degreeInSign),
                    influence: .transformative,
                    duration: calculateIngressDuration(planet.type, currentDate: currentDate),
                    peak: currentDate,
                    interpretation: "Переход в новый знак зодиака",
                    humanDescription: "\(planet.type.displayName) переходит в \(currentSign.displayName)",
                    emoji: getSignEmoji(currentSign)
                )

                ingresses.append(transit)
            }
        }

        return ingresses
    }

    private func determineInfluence(
        transitingPlanet: PlanetType,
        natalPlanet: PlanetType,
        aspect: AspectType
    ) -> TransitInfluence {
        // Гармоничные аспекты
        if aspect == .trine || aspect == .sextile {
            return .harmonious
        }

        // Напряженные аспекты
        if aspect == .square || aspect == .opposition {
            return .challenging
        }

        // Соединения зависят от планет
        if aspect == .conjunction {
            if isHarmoniousPlanetCombination(transitingPlanet, natalPlanet) {
                return .harmonious
            } else if isChallengingPlanetCombination(transitingPlanet, natalPlanet) {
                return .challenging
            } else if isTransformativePlanetCombination(transitingPlanet, natalPlanet) {
                return .transformative
            }
        }

        return .neutral
    }

    private func isHarmoniousPlanetCombination(_ planet1: PlanetType, _ planet2: PlanetType) -> Bool {
        let harmonious: Set<PlanetType> = [.venus, .jupiter, .sun, .moon]
        return harmonious.contains(planet1) && harmonious.contains(planet2)
    }

    private func isChallengingPlanetCombination(_ planet1: PlanetType, _ planet2: PlanetType) -> Bool {
        let challenging: Set<PlanetType> = [.mars, .saturn, .uranus, .neptune, .pluto]
        return challenging.contains(planet1) || challenging.contains(planet2)
    }

    private func isTransformativePlanetCombination(_ planet1: PlanetType, _ planet2: PlanetType) -> Bool {
        let transformative: Set<PlanetType> = [.pluto, .uranus, .neptune]
        return transformative.contains(planet1) || transformative.contains(planet2)
    }

    private func calculateTransitDuration(
        transitingPlanet: PlanetType,
        aspect: AspectType,
        currentDate: Date
    ) -> DateInterval {
        // Примерные длительности транзитов в днях
        let baseDuration: TimeInterval

        switch transitingPlanet {
        case .sun: baseDuration = 2 * 86400  // 2 дня
        case .moon: baseDuration = 0.5 * 86400  // 12 часов
        case .mercury: baseDuration = 3 * 86400  // 3 дня
        case .venus: baseDuration = 5 * 86400  // 5 дней
        case .mars: baseDuration = 7 * 86400  // 1 неделя
        case .jupiter: baseDuration = 14 * 86400  // 2 недели
        case .saturn: baseDuration = 30 * 86400  // 1 месяц
        case .uranus: baseDuration = 90 * 86400  // 3 месяца
        case .neptune: baseDuration = 120 * 86400  // 4 месяца
        case .pluto: baseDuration = 150 * 86400  // 5 месяцев
        case .ascendant, .midheaven, .northNode: baseDuration = 7 * 86400  // 1 неделя
        }

        let startDate = currentDate.addingTimeInterval(-baseDuration / 2)
        let endDate = currentDate.addingTimeInterval(baseDuration / 2)

        return DateInterval(start: startDate, end: endDate)
    }

    private func calculateIngressDuration(_ planet: PlanetType, currentDate: Date) -> DateInterval {
        let duration: TimeInterval = 7 * 86400 // 1 неделя для ингрессий
        let startDate = currentDate.addingTimeInterval(-duration / 2)
        let endDate = currentDate.addingTimeInterval(duration / 2)
        return DateInterval(start: startDate, end: endDate)
    }

    private func calculatePeakDate(currentDate: Date, orb: Double) -> Date {
        // Чем меньше орб, тем ближе к пику
        let daysFromPeak = orb / 2 // Примерная формула
        return currentDate.addingTimeInterval(-daysFromPeak * 86400)
    }

    private func generateInterpretation(
        transitingPlanet: PlanetType,
        natalPlanet: PlanetType,
        aspect: AspectType,
        influence: TransitInfluence
    ) -> String {
        let transitingName = transitingPlanet.displayName
        let natalName = natalPlanet.displayName
        let aspectName = aspect.displayName.lowercased()

        switch influence {
        case .harmonious:
            return "\(transitingName) образует гармоничный \(aspectName) к натальному \(natalName), создавая благоприятные возможности для роста и развития."
        case .challenging:
            return "\(transitingName) формирует напряженный \(aspectName) к натальному \(natalName), требуя преодоления препятствий и работы над собой."
        case .transformative:
            return "\(transitingName) создает трансформирующий \(aspectName) к натальному \(natalName), открывая путь к глубоким изменениям и новым возможностям."
        case .neutral:
            return "\(transitingName) образует \(aspectName) к натальному \(natalName), принося умеренные влияния и возможности для размышлений."
        }
    }

    private func generateHumanDescription(
        transitingPlanet: PlanetType,
        natalPlanet: PlanetType,
        aspect: AspectType,
        influence: TransitInfluence
    ) -> String {
        let transitingTranslation = humanLanguageService.translatePlanet(transitingPlanet)
        let natalTranslation = humanLanguageService.translatePlanet(natalPlanet)

        switch influence {
        case .harmonious:
            return "Сейчас ваша \(transitingTranslation.humanName.lowercased()) гармонично взаимодействует с \(natalTranslation.humanName.lowercased()) - отличное время для позитивных изменений"
        case .challenging:
            return "Ваша \(transitingTranslation.humanName.lowercased()) испытывает \(natalTranslation.humanName.lowercased()) - важно сохранять баланс и терпение"
        case .transformative:
            return "Происходит мощное преобразование в области \(natalTranslation.humanName.lowercased()) под влиянием \(transitingTranslation.humanName.lowercased())"
        case .neutral:
            return "Легкое влияние \(transitingTranslation.humanName.lowercased()) на вашу \(natalTranslation.humanName.lowercased())"
        }
    }

    private func getTransitEmoji(_ planet: PlanetType, _ influence: TransitInfluence) -> String {
        let planetEmoji = humanLanguageService.planetEmoji(planet)

        switch influence {
        case .harmonious: return "\(planetEmoji)✨"
        case .challenging: return "\(planetEmoji)⚡️"
        case .transformative: return "\(planetEmoji)🔮"
        case .neutral: return planetEmoji
        }
    }

    private func getSignEmoji(_ sign: ZodiacSign) -> String {
        return humanLanguageService.signEmoji(sign)
    }

    private func calculateLunarPhase() {
        // Упрощенный расчет лунной фазы
        let now = Date()
        let calendar = Calendar.current
        let dayOfYear = calendar.ordinality(of: .day, in: .year, for: now) ?? 1

        // Примерный цикл в 29.5 дней
        let lunarCycleDays = 29.5
        let phaseIndex = Int((Double(dayOfYear).truncatingRemainder(dividingBy: lunarCycleDays)) / lunarCycleDays * 8)

        lunarPhase = LunarPhase.allCases[min(phaseIndex, LunarPhase.allCases.count - 1)]
    }

    private func generateDailyInsights(for birthChart: BirthChart, transits: [Transit]) async {
        let topTransits = Array(transits.prefix(5))

        let emotionalTone = determineEmotionalTone(from: topTransits)
        let recommendations = generateRecommendations(from: topTransits, birthChart: birthChart)
        let overallEnergy = generateOverallEnergy(from: topTransits)
        let affirmation = generateAffirmation(for: emotionalTone)

        let insights = DailyInsight(
            date: Date(),
            overallEnergy: overallEnergy,
            emotionalTone: emotionalTone,
            keyTransits: topTransits,
            lunarPhase: lunarPhase,
            recommendations: recommendations,
            affirmation: affirmation,
            emoji: emotionalTone.emoji
        )

        await MainActor.run {
            self.todayInsights = insights
        }
    }

    private func determineEmotionalTone(from transits: [Transit]) -> EmotionalTone {
        let influences = transits.map { $0.influence }

        if influences.contains(.transformative) {
            return .transformative
        } else if influences.filter({ $0 == .challenging }).count > influences.filter({ $0 == .harmonious }).count {
            return .challenging
        } else if influences.contains(.harmonious) {
            return .uplifting
        } else {
            return .peaceful
        }
    }

    private func generateRecommendations(from transits: [Transit], birthChart: BirthChart) -> [DailyRecommendation] {
        var recommendations: [DailyRecommendation] = []

        for transit in transits.prefix(3) {
            let recommendation = createRecommendation(for: transit)
            recommendations.append(recommendation)
        }

        return recommendations
    }

    private func createRecommendation(for transit: Transit) -> DailyRecommendation {
        let category = getRecommendationCategory(for: transit.transitingPlanet)
        let priority = transit.impactLevel.priority

        let (title, description, action) = getRecommendationContent(
            planet: transit.transitingPlanet,
            influence: transit.influence
        )

        return DailyRecommendation(
            category: category,
            title: title,
            description: description,
            action: action,
            emoji: transit.emoji,
            priority: priority
        )
    }

    private func getRecommendationCategory(for planet: PlanetType) -> RecommendationCategory {
        switch planet {
        case .venus: return .relationships
        case .mars: return .career
        case .moon: return .health
        case .mercury: return .communication
        case .neptune, .pluto: return .spirituality
        default: return .creativity
        }
    }

    private func getRecommendationContent(
        planet: PlanetType,
        influence: TransitInfluence
    ) -> (title: String, description: String, action: String?) {
        switch (planet, influence) {
        case (.venus, .harmonious):
            return ("Время для любви", "Отличный день для романтики и творчества", "Уделите время близким людям")
        case (.mars, .challenging):
            return ("Сдержанность в действиях", "Избегайте конфликтов и поспешных решений", "Направьте энергию в спорт")
        case (.mercury, .harmonious):
            return ("Активное общение", "Прекрасное время для переговоров и обучения", "Заведите важные разговоры")
        default:
            return ("Внимание к изменениям", "Сегодня важно прислушаться к своей интуиции", "Медитируйте и размышляйте")
        }
    }

    private func generateOverallEnergy(from transits: [Transit]) -> String {
        let harmonious = transits.filter { $0.influence == .harmonious }.count
        let challenging = transits.filter { $0.influence == .challenging }.count

        if harmonious > challenging {
            return "Гармоничная и поддерживающая"
        } else if challenging > harmonious {
            return "Напряженная, требующая внимания"
        } else {
            return "Сбалансированная и стабильная"
        }
    }

    private func generateAffirmation(for tone: EmotionalTone) -> String {
        switch tone {
        case .uplifting:
            return "Я открыт новым возможностям и принимаю поддержку вселенной"
        case .challenging:
            return "Я сильный и способен преодолеть любые препятствия с мудростью"
        case .transformative:
            return "Я принимаю изменения как путь к своему истинному предназначению"
        case .peaceful:
            return "Я нахожусь в гармонии с собой и окружающим миром"
        case .energetic:
            return "Моя энергия направлена на создание позитивных изменений"
        case .reflective:
            return "Я прислушиваюсь к мудрости своего внутреннего голоса"
        }
    }

    private func createMockTransits() -> [Transit] {
        return [
            Transit(
                transitingPlanet: .venus,
                natalPlanet: .sun,
                aspectType: .trine,
                orb: 2.5,
                influence: .harmonious,
                duration: DateInterval(start: Date().addingTimeInterval(-86400), end: Date().addingTimeInterval(86400)),
                peak: Date(),
                interpretation: "Гармоничное влияние на самовыражение",
                humanDescription: "Прекрасное время для творчества и любви",
                emoji: "♀️✨"
            )
        ]
    }
}

// MARK: - Extensions

extension AspectType {
    var maxOrb: Double {
        switch self {
        case .conjunction: return 8.0
        case .sextile: return 6.0
        case .square: return 8.0
        case .trine: return 8.0
        case .opposition: return 8.0
        }
    }
}