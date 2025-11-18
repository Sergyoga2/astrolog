//
//  ChartDisplayModeManager.swift
//  Astrolog
//
//  Created by Claude on 21.10.2025.
//

// Core/Services/ChartDisplayModeManager.swift
import Foundation
import SwiftUI
import Combine

/// Менеджер для управления режимами отображения натальной карты
class ChartDisplayModeManager: ObservableObject {

    // MARK: - Published Properties

    @Published var currentMode: DisplayMode = .beginner {
        didSet {
            saveCurrentMode()
            interpretationEngine.setDefaultDepth(currentMode.recommendedDepth)
            updateFilteredContent()
        }
    }

    @Published var hasCompletedOnboarding: Bool = false {
        didSet {
            saveOnboardingState()
        }
    }

    @Published var userSkillLevel: SkillLevel = .novice {
        didSet {
            saveUserSkillLevel()
            // Автоматически подстраиваем режим под уровень навыков
            if shouldAutoAdjustMode {
                currentMode = userSkillLevel.recommendedDisplayMode
            }
        }
    }

    @Published var filteredContent: FilteredChartContent?

    // MARK: - Configuration Properties

    @Published var shouldAutoAdjustMode: Bool = false
    @Published var shouldShowAdvancedFeatures: Bool = false
    @Published var preferredInterpretationStyle: InterpretationStyle = .balanced

    // MARK: - Private Properties

    public let interpretationEngine: InterpretationEngine
    private let userDefaults = UserDefaults.standard
    private var cancellables = Set<AnyCancellable>()

    // UserDefaults keys
    private enum UserDefaultsKeys {
        static let currentMode = "chart_display_mode"
        static let hasCompletedOnboarding = "chart_onboarding_completed"
        static let userSkillLevel = "user_skill_level"
        static let shouldAutoAdjustMode = "should_auto_adjust_mode"
        static let interpretationStyle = "interpretation_style"
    }

    // MARK: - Initialization

    init(interpretationEngine: InterpretationEngine = InterpretationEngine()) {
        self.interpretationEngine = interpretationEngine
        loadSettings()
        setupBindings()
    }

    // MARK: - Public Methods

    /// Фильтровать содержимое карты по текущему режиму
    func filterContent(for chart: BirthChart) -> FilteredChartContent {
        let filteredChart = FilteredChartContent(
            originalChart: chart,
            displayMode: currentMode,
            filteredPlanets: filterPlanets(chart.planets),
            filteredAspects: filterAspects(chart.aspects),
            filteredHouses: filterHouses(chart.houses),
            shouldShowHouses: currentMode.showHouses,
            shouldShowAspectOrbs: currentMode.showAspectOrbs,
            maxAspectOrb: currentMode.maxAspectOrb
        )

        DispatchQueue.main.async {
            self.filteredContent = filteredChart
        }

        return filteredChart
    }

    /// Проверить, должен ли элемент отображаться в текущем режиме
    func shouldShowElement(_ element: ChartElement) -> Bool {
        switch element {
        case .planet(let planet):
            return currentMode.allowedPlanets.contains(planet.type)

        case .aspect(let aspect):
            return currentMode.allowedAspects.contains(aspect.type) &&
                   aspect.orb <= currentMode.maxAspectOrb

        case .house(let house):
            return currentMode.showHouses

        case .sign(_):
            return true // Знаки всегда отображаются

        case .interpretation(let interpretation):
            return interpretation.isAppropriate(for: currentMode)
        }
    }

    /// Получить интерпретацию с учетом текущего режима
    func getInterpretation(
        for planet: PlanetType,
        in sign: ZodiacSign,
        chart: BirthChart
    ) -> Interpretation {
        let context = createInterpretationContext(for: chart)
        return interpretationEngine.getInterpretation(for: planet, in: sign, context: context)
    }

    /// Получить ключевые интерпретации для текущего режима
    func getKeyInterpretations(for chart: BirthChart) -> [Interpretation] {
        let context = createInterpretationContext(for: chart)
        let limit = currentMode == .beginner ? 3 : (currentMode == .intermediate ? 5 : 8)
        return interpretationEngine.getKeyInterpretations(for: chart, limit: limit, context: context)
    }

    /// Перейти к следующему режиму (для прогрессии пользователя)
    func advanceToNextMode() {
        switch currentMode {
        case .human:
            if userSkillLevel.rawValue >= SkillLevel.intermediate.rawValue {
                currentMode = .beginner
            }
        case .beginner:
            if userSkillLevel.rawValue >= SkillLevel.intermediate.rawValue {
                currentMode = .intermediate
            }
        case .intermediate:
            break // Уже максимальный режим
        }
    }

    /// Установить режим с проверкой уровня пользователя
    func setMode(_ mode: DisplayMode, force: Bool = false) {
        // Позволяем пользователю выбирать любой режим
        currentMode = mode
    }

    /// Завершить онбординг и перейти в подходящий режим
    func completeOnboarding(with skillLevel: SkillLevel) {
        hasCompletedOnboarding = true
        userSkillLevel = skillLevel
        currentMode = skillLevel.recommendedDisplayMode
    }

    /// Сбросить к режиму по умолчанию
    func resetToDefault() {
        currentMode = .beginner
        userSkillLevel = .novice
        hasCompletedOnboarding = false
        shouldAutoAdjustMode = true
    }

    // MARK: - Configuration Methods

    /// Включить/отключить автоматическую подстройку режима
    func setAutoAdjustMode(_ enabled: Bool) {
        shouldAutoAdjustMode = enabled
        userDefaults.set(enabled, forKey: UserDefaultsKeys.shouldAutoAdjustMode)
    }

    /// Установить предпочитаемый стиль интерпретации
    func setInterpretationStyle(_ style: InterpretationStyle) {
        preferredInterpretationStyle = style
        interpretationEngine.setDefaultStyle(style)
        saveInterpretationStyle()
    }

    /// Получить статистику использования режимов
    func getModeUsageStats() -> ModeUsageStats {
        return ModeUsageStats(
            currentMode: currentMode,
            timeInCurrentMode: Date().timeIntervalSince(Date()), // Заглушка
            totalModeChanges: 0, // Заглушка
            preferredComplexity: userSkillLevel
        )
    }

    // MARK: - Advanced Filtering Methods

    /// Получить приоритетные планеты для отображения в текущем режиме
    func getPriorityPlanets(from chart: BirthChart) -> [Planet] {
        let allowedPlanets = filterPlanets(chart.planets)

        switch currentMode {
        case .human:
            // Только Солнце, Луна, Асцендент для человечного режима
            return allowedPlanets.filter { planet in
                [.sun, .moon, .ascendant].contains(planet.type)
            }.sorted { $0.type.priority < $1.type.priority }

        case .beginner:
            // Основная троица: Солнце, Луна, Асцендент
            return allowedPlanets.filter { planet in
                [.sun, .moon, .ascendant].contains(planet.type)
            }.sorted { $0.type.priority < $1.type.priority }

        case .intermediate:
            // Все планеты, отсортированные по важности
            return allowedPlanets.sorted { $0.type.priority < $1.type.priority }
        }
    }

    /// Получить наиболее значимые аспекты для текущего режима
    func getSignificantAspects(from chart: BirthChart) -> [Aspect] {
        let filteredAspects = filterAspects(chart.aspects)

        switch currentMode {
        case .human:
            // Для человечного режима не показываем аспекты
            return []

        case .beginner:
            // Только точные мажорные аспекты
            return filteredAspects.filter { aspect in
                aspect.orb <= 3.0 && aspect.type.isMajor
            }.sorted { $0.orb < $1.orb }

        case .intermediate:
            // Все отфильтрованные аспекты
            return filteredAspects.sorted { aspect1, aspect2 in
                // Сортируем по важности типа аспекта, затем по орбу
                if aspect1.type.importance != aspect2.type.importance {
                    return aspect1.type.importance > aspect2.type.importance
                }
                return abs(aspect1.orb) < abs(aspect2.orb)
            }
        }
    }

    /// Получить дома для отображения с учетом режима
    func getRelevantHouses(from chart: BirthChart) -> [House] {
        guard currentMode.showHouses else { return [] }

        let houses = chart.houses

        switch currentMode {
        case .human:
            return [] // Дома не показываем в человечном режиме

        case .beginner:
            return [] // Дома не показываем для новичков

        case .intermediate:
            // Показываем все дома
            return houses.sorted { $0.number < $1.number }
        }
    }

    /// Фильтровать интерпретации по релевантности для текущего режима
    func filterInterpretations(_ interpretations: [Interpretation]) -> [Interpretation] {
        return interpretations.filter { interpretation in
            isInterpretationRelevant(interpretation)
        }.sorted { interpretation1, interpretation2 in
            // Сортируем по типу элемента и глубине
            if interpretation1.elementType != interpretation2.elementType {
                return interpretation1.elementType.priority < interpretation2.elementType.priority
            }
            return interpretation1.depth.sortOrder < interpretation2.depth.sortOrder
        }
    }

    /// Получить рекомендуемое количество элементов для отображения
    func getRecommendedElementCount(for elementType: ChartElementType) -> Int {
        switch (currentMode, elementType) {
        case (.human, .planet), (.human, .planetInSign):
            return 3  // Только большая тройка
        case (.human, .aspect):
            return 0  // Аспекты не показываем в человечном режиме
        case (.human, .house):
            return 0  // Дома не показываем в человечном режиме

        case (.beginner, .planet), (.beginner, .planetInSign):
            return 3
        case (.beginner, .aspect):
            return 2
        case (.beginner, .house):
            return 0

        case (.intermediate, .planet), (.intermediate, .planetInSign):
            return 6
        case (.intermediate, .aspect):
            return 5
        case (.intermediate, .house):
            return 4

        case (.intermediate, _):
            return 15

        default:
            return 5
        }
    }

    /// Определить, должен ли элемент быть выделен как особо важный
    func isElementHighlighted(_ element: ChartElement) -> Bool {
        switch element {
        case .planet(let planet):
            // Выделяем основные планеты в режиме новичка
            if currentMode == .beginner {
                return [.sun, .moon, .ascendant].contains(planet.type)
            }
            return planet.type.isPersonalPlanet

        case .aspect(let aspect):
            // Выделяем точные аспекты
            return abs(aspect.orb) <= 2.0

        case .house(let house):
            // Выделяем угловые дома
            return [1, 4, 7, 10].contains(house.number)

        case .sign(_):
            return false

        case .interpretation(let interpretation):
            return interpretation.elementType == .planetInSign && interpretation.depth == currentMode.recommendedDepth
        }
    }

    /// Получить контекстную информацию для элемента
    func getContextInfo(for element: ChartElement) -> ElementContextInfo? {
        guard currentMode != .beginner else { return nil }

        switch element {
        case .planet(let planet):
            return ElementContextInfo(
                title: planet.type.displayName,
                description: getBasicPlanetInfo(planet.type),
                showInTooltip: true,
                importance: planet.type.isPersonalPlanet ? .high : .medium
            )

        case .aspect(let aspect):
            return ElementContextInfo(
                title: aspect.type.symbol,
                description: getBasicAspectInfo(aspect.type),
                showInTooltip: true,
                importance: aspect.type.isMajor ? .high : .low
            )

        case .house(let house):
            return ElementContextInfo(
                title: "\(house.number) дом",
                description: getBasicHouseInfo(house.number),
                showInTooltip: currentMode == .intermediate,
                importance: [1, 4, 7, 10].contains(house.number) ? .high : .medium
            )

        default:
            return nil
        }
    }
}

// MARK: - Private Methods

private extension ChartDisplayModeManager {

    func loadSettings() {
        // Загружаем сохраненные настройки
        if let modeRawValue = userDefaults.object(forKey: UserDefaultsKeys.currentMode) as? String,
           let savedMode = DisplayMode(rawValue: modeRawValue) {
            currentMode = savedMode
        }

        hasCompletedOnboarding = userDefaults.bool(forKey: UserDefaultsKeys.hasCompletedOnboarding)

        if let skillRawValue = userDefaults.object(forKey: UserDefaultsKeys.userSkillLevel) as? String,
           let savedSkill = SkillLevel(rawValue: skillRawValue) {
            userSkillLevel = savedSkill
        }

        shouldAutoAdjustMode = userDefaults.object(forKey: UserDefaultsKeys.shouldAutoAdjustMode) as? Bool ?? true

        if let styleRawValue = userDefaults.object(forKey: UserDefaultsKeys.interpretationStyle) as? String,
           let savedStyle = InterpretationStyle(rawValue: styleRawValue) {
            preferredInterpretationStyle = savedStyle
            interpretationEngine.setDefaultStyle(savedStyle)
        }
    }

    func setupBindings() {
        // Связываем изменения режима с обновлением фильтрованного контента
        $currentMode
            .debounce(for: .milliseconds(300), scheduler: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.updateFilteredContent()
            }
            .store(in: &cancellables)
    }

    func saveCurrentMode() {
        userDefaults.set(currentMode.rawValue, forKey: UserDefaultsKeys.currentMode)
    }

    func saveOnboardingState() {
        userDefaults.set(hasCompletedOnboarding, forKey: UserDefaultsKeys.hasCompletedOnboarding)
    }

    func saveUserSkillLevel() {
        userDefaults.set(userSkillLevel.rawValue, forKey: UserDefaultsKeys.userSkillLevel)
    }

    func saveInterpretationStyle() {
        userDefaults.set(preferredInterpretationStyle.rawValue, forKey: UserDefaultsKeys.interpretationStyle)
    }

    func updateFilteredContent() {
        // Обновляем фильтрованный контент при изменении режима
        // Будет вызывано, когда у нас есть актуальная карта
    }

    func filterPlanets(_ planets: [Planet]) -> [Planet] {
        return planets.filter { planet in
            currentMode.allowedPlanets.contains(planet.type)
        }
    }

    func filterAspects(_ aspects: [Aspect]) -> [Aspect] {
        return aspects.filter { aspect in
            currentMode.allowedAspects.contains(aspect.type) &&
            aspect.orb <= currentMode.maxAspectOrb
        }
    }

    func filterHouses(_ houses: [House]) -> [House] {
        return currentMode.showHouses ? houses : []
    }

    func isModeSuitableForUser(_ mode: DisplayMode) -> Bool {
        switch mode {
        case .human:
            return true  // Human mode is suitable for everyone
        case .beginner:
            return true
        case .intermediate:
            return userSkillLevel.rawValue >= SkillLevel.advanced.rawValue
        }
    }

    func createInterpretationContext(for chart: BirthChart) -> InterpretationContext {
        let preferences = UserPreferences(
            interpretationStyle: preferredInterpretationStyle,
            detailLevel: currentMode.recommendedDepth
        )

        return InterpretationContext(
            birthChart: chart,
            userPreferences: preferences,
            displayMode: currentMode
        )
    }

    // MARK: - Helper Methods for Context Info

    func isInterpretationRelevant(_ interpretation: Interpretation) -> Bool {
        // Проверяем соответствие интерпретации текущему режиму
        guard interpretation.isAppropriate(for: currentMode) else { return false }

        // Проверяем уровень детализации
        let recommendedDepth = currentMode.recommendedDepth
        return interpretation.depth == recommendedDepth ||
               (currentMode == .intermediate && interpretation.depth != .emoji)
    }

    func getBasicPlanetInfo(_ planetType: PlanetType) -> String {
        switch planetType {
        case .sun: return "Основа личности, творческое самовыражение"
        case .moon: return "Эмоции, подсознание, потребности"
        case .mercury: return "Мышление, общение, обучение"
        case .venus: return "Любовь, красота, ценности"
        case .mars: return "Энергия, действие, желания"
        case .jupiter: return "Расширение, рост, мудрость"
        case .saturn: return "Структура, ограничения, дисциплина"
        case .ascendant: return "Внешнее проявление, первое впечатление"
        default: return "Планетарное влияние"
        }
    }

    func getBasicAspectInfo(_ aspectType: AspectType) -> String {
        switch aspectType {
        case .conjunction: return "Слияние и усиление энергий"
        case .trine: return "Гармоничное взаимодействие, таланты"
        case .square: return "Напряжение, вызовы для роста"
        case .opposition: return "Баланс противоположностей"
        case .sextile: return "Возможности для развития"
        }
    }

    func getBasicHouseInfo(_ houseNumber: Int) -> String {
        switch houseNumber {
        case 1: return "Личность, внешность, первые впечатления"
        case 2: return "Ресурсы, ценности, материальное"
        case 3: return "Общение, обучение, ближайшее окружение"
        case 4: return "Дом, семья, корни, основы"
        case 5: return "Творчество, любовь, дети, развлечения"
        case 6: return "Работа, здоровье, повседневные дела"
        case 7: return "Партнерство, отношения, союзы"
        case 8: return "Трансформация, общие ресурсы, глубины"
        case 9: return "Философия, высшее образование, путешествия"
        case 10: return "Карьера, репутация, общественное положение"
        case 11: return "Друзья, группы, надежды и мечты"
        case 12: return "Подсознание, духовность, скрытое"
        default: return "Сфера жизненного опыта"
        }
    }
}

// MARK: - Supporting Types

/// Фильтрованное содержимое карты для определенного режима отображения
struct FilteredChartContent {
    let originalChart: BirthChart
    let displayMode: DisplayMode
    let filteredPlanets: [Planet]
    let filteredAspects: [Aspect]
    let filteredHouses: [House]
    let shouldShowHouses: Bool
    let shouldShowAspectOrbs: Bool
    let maxAspectOrb: Double

    var planetCount: Int { filteredPlanets.count }
    var aspectCount: Int { filteredAspects.count }
    var complexity: DisplayComplexity {
        switch displayMode {
        case .human: return .minimal
        case .beginner: return .simple
        case .intermediate: return .complex
        }
    }
}

/// Уровень сложности отображения
enum DisplayComplexity {
    case minimal, simple, moderate, complex

    var description: String {
        switch self {
        case .minimal: return "Минимальный"
        case .simple: return "Упрощенный"
        case .moderate: return "Умеренный"
        case .complex: return "Полный"
        }
    }
}

/// Элементы карты для фильтрации
enum ChartElement {
    case planet(Planet)
    case aspect(Aspect)
    case house(House)
    case sign(ZodiacSign)
    case interpretation(Interpretation)
}

/// Статистика использования режимов
struct ModeUsageStats {
    let currentMode: DisplayMode
    let timeInCurrentMode: TimeInterval
    let totalModeChanges: Int
    let preferredComplexity: SkillLevel
}

/// Контекстная информация для элементов карты
struct ElementContextInfo {
    let title: String
    let description: String
    let showInTooltip: Bool
    let importance: ElementImportance

    enum ElementImportance {
        case low, medium, high

        var priority: Int {
            switch self {
            case .low: return 0
            case .medium: return 1
            case .high: return 2
            }
        }

        var color: Color {
            switch self {
            case .low: return .neutral
            case .medium: return .cosmicViolet
            case .high: return .neonPurple
            }
        }
    }
}

// MARK: - Extensions

extension DisplayMode {
    /// Максимальное количество элементов для отображения одновременно
    var maxSimultaneousElements: Int {
        switch self {
        case .human: return 3       // Только основное
        case .beginner: return 8
        case .intermediate: return 25
        }
    }

    /// Должны ли отображаться дополнительные детали
    var showAdvancedDetails: Bool {
        return self == .intermediate
    }
}

// MARK: - Extensions for BirthChart Types

extension PlanetType {
    /// Приоритет планеты для отображения (чем меньше число, тем выше приоритет)
    var priority: Int {
        switch self {
        case .sun: return 1
        case .moon: return 2
        case .ascendant: return 3
        case .mercury: return 4
        case .venus: return 5
        case .mars: return 6
        case .midheaven: return 7
        case .jupiter: return 8
        case .saturn: return 9
        case .northNode: return 10
        case .uranus: return 11
        case .neptune: return 12
        case .pluto: return 13
        }
    }

    /// Является ли планета личной (быстро движущейся)
    var isPersonalPlanet: Bool {
        switch self {
        case .sun, .moon, .mercury, .venus, .mars:
            return true
        default:
            return false
        }
    }

    /// Является ли точка особо значимой (угловые точки)
    var isAngularPoint: Bool {
        switch self {
        case .ascendant, .midheaven:
            return true
        default:
            return false
        }
    }
}

extension AspectType {
    /// Является ли аспект мажорным (основным)
    var isMajor: Bool {
        switch self {
        case .conjunction, .opposition, .trine, .square:
            return true
        case .sextile:
            return false
        }
    }

    /// Важность аспекта (для сортировки)
    var importance: Double {
        switch self {
        case .conjunction: return 1.0
        case .opposition: return 0.9
        case .square: return 0.8
        case .trine: return 0.7
        case .sextile: return 0.5
        }
    }
}

extension ChartElementType {
    /// Приоритет типа элемента для отображения
    var priority: Int {
        switch self {
        case .planetInSign: return 1
        case .planet: return 2
        case .aspect: return 3
        case .house: return 4
        case .planetInHouse: return 5
        case .sign: return 6
        case .composite: return 7
        }
    }

    /// Цвет для визуального различения типов элементов
    var themeColor: Color {
        switch self {
        case .planet, .planetInSign, .planetInHouse:
            return .cosmicViolet
        case .sign:
            return .neonPurple
        case .house:
            return .cosmicBlue
        case .aspect:
            return .neonCyan
        case .composite:
            return .starYellow
        }
    }
}