//
//  TooltipService.swift
//  Astrolog
//
//  Created by Claude on 21.10.2025.
//

// Core/Services/TooltipService.swift
import Foundation
import SwiftUI
import Combine

/// Сервис для управления контекстными подсказками в приложении
class TooltipService: ObservableObject {

    // MARK: - Published Properties

    @Published var currentTooltip: TooltipData?
    @Published var tooltipPosition: CGPoint = .zero
    @Published var isTooltipVisible: Bool = false
    @Published var tooltipOpacity: Double = 0.0

    // MARK: - Configuration Properties

    @Published var isTooltipEnabled: Bool = true
    @Published var tooltipDelay: TimeInterval = 0.8
    @Published var tooltipDuration: TimeInterval = 0.3
    @Published var shouldShowAdvancedTooltips: Bool = false

    // MARK: - Private Properties

    private var tooltipTimer: Timer?
    private var hideTimer: Timer?
    private var cancellables = Set<AnyCancellable>()
    private let interpretationEngine: InterpretationEngine

    // MARK: - Initialization

    init(interpretationEngine: InterpretationEngine = InterpretationEngine()) {
        self.interpretationEngine = interpretationEngine
        setupBindings()
        loadSettings()
    }

    // MARK: - Public Methods

    /// Показать подсказку для элемента карты
    func showTooltip(
        for element: ChartElement,
        at position: CGPoint,
        in displayMode: DisplayMode,
        delayed: Bool = true
    ) {
        guard isTooltipEnabled else { return }

        // Отменяем предыдущие таймеры
        cancelTimers()

        // Создаем данные для подсказки
        let tooltipData = createTooltipData(for: element, displayMode: displayMode)

        if delayed {
            // Показываем с задержкой
            tooltipTimer = Timer.scheduledTimer(withTimeInterval: tooltipDelay, repeats: false) { [weak self] _ in
                self?.displayTooltip(tooltipData, at: position)
            }
        } else {
            // Показываем сразу
            displayTooltip(tooltipData, at: position)
        }
    }

    /// Показать подсказку для интерпретации
    func showInterpretationTooltip(
        _ interpretation: Interpretation,
        at position: CGPoint,
        showFullText: Bool = false
    ) {
        guard isTooltipEnabled else { return }

        let tooltipData = TooltipData(
            title: interpretation.title,
            content: showFullText ? interpretation.summary : interpretation.oneLiner,
            icon: interpretation.emoji,
            type: .interpretation,
            priority: .medium,
            style: .detailed,
            contextualInfo: ContextualInfo(
                keywords: interpretation.keywords.prefix(3).map { String($0) },
                lifeAreas: interpretation.lifeAreas.prefix(2).map { String($0) },
                elementType: interpretation.elementType
            )
        )

        displayTooltip(tooltipData, at: position)
    }

    /// Показать образовательную подсказку
    func showEducationalTooltip(
        title: String,
        content: String,
        at position: CGPoint,
        relatedConcepts: [String] = []
    ) {
        let tooltipData = TooltipData(
            title: title,
            content: content,
            icon: "lightbulb.fill",
            type: .educational,
            priority: .high,
            style: .educational,
            contextualInfo: ContextualInfo(
                keywords: relatedConcepts,
                lifeAreas: [],
                elementType: nil
            )
        )

        displayTooltip(tooltipData, at: position)
    }

    /// Скрыть текущую подсказку
    func hideTooltip(animated: Bool = true) {
        cancelTimers()

        if animated {
            withAnimation(.easeOut(duration: tooltipDuration)) {
                tooltipOpacity = 0.0
            }

            hideTimer = Timer.scheduledTimer(withTimeInterval: tooltipDuration, repeats: false) { [weak self] _ in
                self?.clearTooltip()
            }
        } else {
            clearTooltip()
        }
    }

    /// Переключить видимость подсказок
    func toggleTooltips(_ enabled: Bool) {
        isTooltipEnabled = enabled
        saveSettings()

        if !enabled {
            hideTooltip(animated: false)
        }
    }

    /// Установить режим продвинутых подсказок
    func setAdvancedTooltips(_ enabled: Bool) {
        shouldShowAdvancedTooltips = enabled
        saveSettings()
    }

    /// Получить подсказку для элемента без отображения
    func getTooltipData(for element: ChartElement, displayMode: DisplayMode) -> TooltipData {
        return createTooltipData(for: element, displayMode: displayMode)
    }

    // MARK: - Configuration Methods

    /// Установить задержку перед показом подсказки
    func setTooltipDelay(_ delay: TimeInterval) {
        tooltipDelay = max(0.1, min(delay, 3.0)) // Ограничиваем от 0.1 до 3 секунд
    }

    /// Установить продолжительность анимации
    func setAnimationDuration(_ duration: TimeInterval) {
        tooltipDuration = max(0.1, min(duration, 1.0))
    }

    // MARK: - Preset Methods

    /// Применить предустановки для режима новичка
    func applyBeginnerPreset() {
        tooltipDelay = 0.5
        shouldShowAdvancedTooltips = false
        isTooltipEnabled = true
    }

    /// Применить предустановки для среднего режима
    func applyIntermediatePreset() {
        tooltipDelay = 0.8
        shouldShowAdvancedTooltips = true
        isTooltipEnabled = true
    }

    /// Применить предустановки для экспертного режима
    func applyExpertPreset() {
        tooltipDelay = 1.0
        shouldShowAdvancedTooltips = true
        isTooltipEnabled = true
    }
}

// MARK: - Private Methods

private extension TooltipService {

    func setupBindings() {
        // Связываем изменение видимости с opacity
        $isTooltipVisible
            .sink { [weak self] isVisible in
                if isVisible {
                    withAnimation(.easeIn(duration: self?.tooltipDuration ?? 0.3)) {
                        self?.tooltipOpacity = 1.0
                    }
                }
            }
            .store(in: &cancellables)
    }

    func loadSettings() {
        let userDefaults = UserDefaults.standard
        isTooltipEnabled = userDefaults.object(forKey: "tooltip_enabled") as? Bool ?? true
        shouldShowAdvancedTooltips = userDefaults.object(forKey: "advanced_tooltips") as? Bool ?? false
        tooltipDelay = userDefaults.object(forKey: "tooltip_delay") as? TimeInterval ?? 0.8
    }

    func saveSettings() {
        let userDefaults = UserDefaults.standard
        userDefaults.set(isTooltipEnabled, forKey: "tooltip_enabled")
        userDefaults.set(shouldShowAdvancedTooltips, forKey: "advanced_tooltips")
        userDefaults.set(tooltipDelay, forKey: "tooltip_delay")
    }

    func displayTooltip(_ tooltipData: TooltipData, at position: CGPoint) {
        currentTooltip = tooltipData
        tooltipPosition = position
        isTooltipVisible = true
    }

    func clearTooltip() {
        currentTooltip = nil
        isTooltipVisible = false
        tooltipOpacity = 0.0
    }

    func cancelTimers() {
        tooltipTimer?.invalidate()
        tooltipTimer = nil
        hideTimer?.invalidate()
        hideTimer = nil
    }

    func createTooltipData(for element: ChartElement, displayMode: DisplayMode) -> TooltipData {
        switch element {
        case .planet(let planet):
            return createPlanetTooltip(planet: planet, displayMode: displayMode)

        case .aspect(let aspect):
            return createAspectTooltip(aspect: aspect, displayMode: displayMode)

        case .house(let house):
            return createHouseTooltip(house: house, displayMode: displayMode)

        case .sign(let sign):
            return createSignTooltip(sign: sign, displayMode: displayMode)

        case .interpretation(let interpretation):
            return createInterpretationTooltip(interpretation: interpretation, displayMode: displayMode)
        }
    }

    // MARK: - Tooltip Creation Methods

    func createPlanetTooltip(planet: Planet, displayMode: DisplayMode) -> TooltipData {
        let basicInfo = getBasicPlanetInfo(planet.type)

        var content = basicInfo
        if shouldShowAdvancedTooltips && displayMode != .beginner {
            content += "\n\nВ \(planet.zodiacSign.displayName): \(getPlanetInSignInfo(planet.type, planet.zodiacSign))"
            if planet.isRetrograde {
                content += "\n🔄 Ретроградна"
            }
        }

        return TooltipData(
            title: planet.type.displayName,
            content: content,
            icon: planet.type.symbol,
            type: .planet,
            priority: planet.type.isPersonalPlanet ? .high : .medium,
            style: displayMode == .beginner ? .simple : .detailed,
            contextualInfo: ContextualInfo(
                keywords: getPlanetKeywords(planet.type),
                lifeAreas: getPlanetLifeAreas(planet.type),
                elementType: .planet
            )
        )
    }

    func createAspectTooltip(aspect: Aspect, displayMode: DisplayMode) -> TooltipData {
        let basicInfo = getBasicAspectInfo(aspect.type)

        var content = basicInfo
        if shouldShowAdvancedTooltips && displayMode != .beginner {
            content += "\n\nМежду \(aspect.planet1.type.displayName) и \(aspect.planet2.type.displayName)"
            content += "\nОрб: \(String(format: "%.1f", aspect.orb))°"
        }

        return TooltipData(
            title: "\(aspect.planet1.type.symbol) \(aspect.type.symbol) \(aspect.planet2.type.symbol)",
            content: content,
            icon: aspect.type.symbol,
            type: .aspect,
            priority: aspect.type.isMajor ? .high : .medium,
            style: displayMode == .beginner ? .simple : .detailed,
            contextualInfo: ContextualInfo(
                keywords: getAspectKeywords(aspect.type),
                lifeAreas: [],
                elementType: .aspect
            )
        )
    }

    func createHouseTooltip(house: House, displayMode: DisplayMode) -> TooltipData {
        let basicInfo = getBasicHouseInfo(house.number)

        var content = basicInfo
        if shouldShowAdvancedTooltips && displayMode != .beginner {
            content += "\n\nКуспид в \(house.zodiacSign.displayName)"
            if !house.planetsInHouse.isEmpty {
                let planetNames = house.planetsInHouse.map { $0.displayName }.joined(separator: ", ")
                content += "\nПланеты: \(planetNames)"
            }
        }

        return TooltipData(
            title: "\(house.number) дом",
            content: content,
            icon: "house.fill",
            type: .house,
            priority: [1, 4, 7, 10].contains(house.number) ? .high : .medium,
            style: displayMode == .beginner ? .simple : .detailed,
            contextualInfo: ContextualInfo(
                keywords: getHouseKeywords(house.number),
                lifeAreas: [getBasicHouseInfo(house.number)],
                elementType: .house
            )
        )
    }

    func createSignTooltip(sign: ZodiacSign, displayMode: DisplayMode) -> TooltipData {
        let basicInfo = getBasicSignInfo(sign)

        var content = basicInfo
        if shouldShowAdvancedTooltips && displayMode != .beginner {
            content += "\n\nСтихия: \(sign.element.displayName)"
            content += "\nМодальность: \(getSignModality(sign))"
        }

        return TooltipData(
            title: sign.displayName,
            content: content,
            icon: sign.symbol,
            type: .sign,
            priority: .medium,
            style: displayMode == .beginner ? .simple : .detailed,
            contextualInfo: ContextualInfo(
                keywords: getSignKeywords(sign),
                lifeAreas: [],
                elementType: .sign
            )
        )
    }

    func createInterpretationTooltip(interpretation: Interpretation, displayMode: DisplayMode) -> TooltipData {
        return TooltipData(
            title: interpretation.title,
            content: interpretation.oneLiner,
            icon: interpretation.emoji,
            type: .interpretation,
            priority: .high,
            style: .detailed,
            contextualInfo: ContextualInfo(
                keywords: Array(interpretation.keywords.prefix(3)),
                lifeAreas: Array(interpretation.lifeAreas.prefix(2)),
                elementType: interpretation.elementType
            )
        )
    }

    // MARK: - Info Helper Methods

    func getBasicPlanetInfo(_ planetType: PlanetType) -> String {
        switch planetType {
        case .sun: return "Основа личности, творческое самовыражение, жизненная сила"
        case .moon: return "Эмоции, подсознание, потребности, семейные связи"
        case .mercury: return "Мышление, общение, обучение, передвижения"
        case .venus: return "Любовь, красота, ценности, гармония"
        case .mars: return "Энергия, действие, желания, конфликты"
        case .jupiter: return "Расширение, рост, мудрость, удача"
        case .saturn: return "Структура, ограничения, дисциплина, уроки"
        case .uranus: return "Революция, инновации, свобода, неожиданность"
        case .neptune: return "Интуиция, иллюзии, духовность, искусство"
        case .pluto: return "Трансформация, власть, глубинные изменения"
        case .ascendant: return "Внешнее проявление, первое впечатление, подход к жизни"
        case .midheaven: return "Карьера, репутация, жизненные цели"
        case .northNode: return "Путь развития души, кармические задачи"
        }
    }

    func getBasicAspectInfo(_ aspectType: AspectType) -> String {
        switch aspectType {
        case .conjunction: return "Слияние и усиление энергий планет"
        case .trine: return "Гармоничное взаимодействие, природные таланты"
        case .square: return "Напряжение и вызовы для личностного роста"
        case .opposition: return "Необходимость баланса противоположных сил"
        case .sextile: return "Возможности для развития и сотрудничества"
        }
    }

    func getBasicHouseInfo(_ houseNumber: Int) -> String {
        switch houseNumber {
        case 1: return "Личность и самопрезентация"
        case 2: return "Ценности и материальные ресурсы"
        case 3: return "Общение и ближайшее окружение"
        case 4: return "Дом и семейные корни"
        case 5: return "Творчество и самовыражение"
        case 6: return "Работа и повседневные дела"
        case 7: return "Партнерство и отношения"
        case 8: return "Трансформация и глубинные процессы"
        case 9: return "Философия и высшие знания"
        case 10: return "Карьера и общественное положение"
        case 11: return "Дружба и коллективные цели"
        case 12: return "Подсознание и духовность"
        default: return "Область жизненного опыта"
        }
    }

    func getBasicSignInfo(_ sign: ZodiacSign) -> String {
        switch sign {
        case .aries: return "Лидерство, инициатива, смелость"
        case .taurus: return "Стабильность, практичность, упорство"
        case .gemini: return "Общительность, любознательность, гибкость"
        case .cancer: return "Забота, эмоциональность, интуиция"
        case .leo: return "Творчество, великодушие, самоуверенность"
        case .virgo: return "Анализ, служение, совершенствование"
        case .libra: return "Гармония, справедливость, дипломатия"
        case .scorpio: return "Интенсивность, глубина, трансформация"
        case .sagittarius: return "Философия, приключения, оптимизм"
        case .capricorn: return "Амбиции, дисциплина, ответственность"
        case .aquarius: return "Индивидуальность, прогрессивность, дружба"
        case .pisces: return "Сочувствие, интуиция, творческое воображение"
        }
    }

    func getPlanetInSignInfo(_ planet: PlanetType, _ sign: ZodiacSign) -> String {
        return "Особое проявление энергии \(planet.displayName.lowercased()) через качества \(sign.displayName.lowercased())"
    }

    func getSignModality(_ sign: ZodiacSign) -> String {
        switch sign {
        case .aries, .cancer, .libra, .capricorn: return "Кардинальная"
        case .taurus, .leo, .scorpio, .aquarius: return "Фиксированная"
        case .gemini, .virgo, .sagittarius, .pisces: return "Мутабельная"
        }
    }

    // MARK: - Keywords Helper Methods

    func getPlanetKeywords(_ planet: PlanetType) -> [String] {
        switch planet {
        case .sun: return ["личность", "творчество", "лидерство"]
        case .moon: return ["эмоции", "интуиция", "семья"]
        case .mercury: return ["общение", "мышление", "обучение"]
        case .venus: return ["любовь", "красота", "гармония"]
        case .mars: return ["энергия", "действие", "страсть"]
        default: return ["влияние", "развитие"]
        }
    }

    func getPlanetLifeAreas(_ planet: PlanetType) -> [String] {
        switch planet {
        case .sun: return ["карьера", "самореализация"]
        case .moon: return ["дом", "эмоции"]
        case .venus: return ["отношения", "творчество"]
        case .mars: return ["спорт", "конкуренция"]
        default: return ["общее влияние"]
        }
    }

    func getAspectKeywords(_ aspect: AspectType) -> [String] {
        switch aspect {
        case .conjunction: return ["слияние", "усиление"]
        case .trine: return ["гармония", "таланты"]
        case .square: return ["напряжение", "рост"]
        case .opposition: return ["баланс", "осознание"]
        case .sextile: return ["возможности", "развитие"]
        }
    }

    func getHouseKeywords(_ house: Int) -> [String] {
        switch house {
        case 1: return ["личность", "внешность"]
        case 7: return ["партнерство", "отношения"]
        case 10: return ["карьера", "репутация"]
        default: return ["жизненная сфера"]
        }
    }

    func getSignKeywords(_ sign: ZodiacSign) -> [String] {
        switch sign {
        case .aries: return ["лидерство", "инициатива"]
        case .taurus: return ["стабильность", "практичность"]
        case .gemini: return ["общение", "любознательность"]
        default: return ["качества знака"]
        }
    }
}

// MARK: - Supporting Types

/// Данные для отображения подсказки
struct TooltipData: Identifiable {
    let id = UUID()
    let title: String
    let content: String
    let icon: String
    let type: TooltipType
    let priority: TooltipPriority
    let style: TooltipStyle
    let contextualInfo: ContextualInfo?

    /// Максимальная ширина подсказки
    var maxWidth: CGFloat {
        switch style {
        case .simple: return 200
        case .detailed: return 280
        case .educational: return 320
        }
    }

    /// Цвет фона подсказки
    var backgroundColor: Color {
        switch type {
        case .planet: return .cosmicViolet.opacity(0.9)
        case .aspect: return .neonCyan.opacity(0.9)
        case .house: return .cosmicBlue.opacity(0.9)
        case .sign: return .neonPurple.opacity(0.9)
        case .interpretation: return .starYellow.opacity(0.9)
        case .educational: return .beginnerGreen.opacity(0.9)
        }
    }
}

/// Тип подсказки
enum TooltipType {
    case planet, aspect, house, sign, interpretation, educational
}

/// Приоритет подсказки
enum TooltipPriority {
    case low, medium, high

    var zIndex: Double {
        switch self {
        case .low: return 100
        case .medium: return 200
        case .high: return 300
        }
    }
}

/// Стиль отображения подсказки
enum TooltipStyle {
    case simple, detailed, educational

    var shouldShowContextualInfo: Bool {
        switch self {
        case .simple: return false
        case .detailed, .educational: return true
        }
    }
}

/// Контекстная информация для подсказки
struct ContextualInfo {
    let keywords: [String]
    let lifeAreas: [String]
    let elementType: ChartElementType?

    var hasContent: Bool {
        return !keywords.isEmpty || !lifeAreas.isEmpty
    }
}