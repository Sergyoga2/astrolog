//
//  ChartTab.swift
//  Astrolog
//
//  Created by Claude on 21.10.2025.
//

// Features/Chart/Models/ChartTab.swift
import SwiftUI

/// Вкладки для экрана натальной карты
enum ChartTab: String, CaseIterable, Identifiable {
    case today = "Сегодня"           // НОВЫЙ - текущие транзиты и влияния
    case overview = "Основное"       // ПЕРЕИМЕНОВАН - самое важное о личности
    case planets = "Планеты"         // Существующий
    case houses = "Сферы жизни"      // ПЕРЕИМЕНОВАН из houses - более понятно
    case aspects = "Взаимодействия"  // ПЕРЕИМЕНОВАН из aspects - понятнее чем "связи"
    case education = "Подсказки"     // ПЕРЕИМЕНОВАН из education - более точно

    var id: String { rawValue }

    /// Иконка вкладки
    var icon: String {
        switch self {
        case .today:
            return "sun.and.horizon.fill"  // Иконка для "Сегодня"
        case .overview:
            return "star.circle.fill"       // Основное о личности
        case .planets:
            return "circle.grid.cross.fill" // Планеты
        case .houses:
            return "building.2.fill"        // Сферы жизни (более понятно чем дом)
        case .aspects:
            return "arrow.triangle.merge"   // Взаимодействия
        case .education:
            return "questionmark.circle.fill" // Подсказки
        }
    }

    /// SF Symbol для выделенного состояния
    var selectedIcon: String {
        switch self {
        case .today:
            return "sun.and.horizon.fill"
        case .overview:
            return "star.circle.fill"
        case .planets:
            return "circle.grid.cross.fill"
        case .houses:
            return "building.2.fill"
        case .aspects:
            return "arrow.triangle.merge"
        case .education:
            return "questionmark.circle.fill"
        }
    }

    /// Цвет вкладки
    var color: Color {
        switch self {
        case .today:
            return .fireElement        // Оранжево-красный для "Сегодня"
        case .overview:
            return .starYellow        // Желтый для основного
        case .planets:
            return .cosmicViolet      // Фиолетовый для планет
        case .houses:
            return .earthElement      // Зелено-голубой для сфер жизни
        case .aspects:
            return .airElement        // Светло-желтый для взаимодействий
        case .education:
            return .neonCyan          // Голубой для подсказок
        }
    }

    /// Описание вкладки
    var description: String {
        switch self {
        case .today:
            return "Текущие транзиты, энергия дня и персональные рекомендации"
        case .overview:
            return "Ключевые элементы карты и основные интерпретации"
        case .planets:
            return "Планеты в знаках и домах с детальными описаниями"
        case .houses:
            return "Сферы жизни и их астрологические значения"
        case .aspects:
            return "Взаимодействия между планетами и их влияние"
        case .education:
            return "Подсказки, термины и обучающие материалы"
        }
    }

    /// Должна ли вкладка отображаться для данного режима
    func isAvailable(for displayMode: DisplayMode) -> Bool {
        switch self {
        case .today:
            return true // Всегда доступна - ключевая ценность приложения
        case .overview:
            return true
        case .planets:
            return true
        case .houses:
            return displayMode != .beginner
        case .aspects:
            return displayMode != .beginner
        case .education:
            return true
        }
    }

    /// Приоритет отображения (для сортировки)
    var priority: Int {
        switch self {
        case .today: return 0      // Первая - ежедневная ценность
        case .overview: return 1   // Основные характеристики
        case .planets: return 2    // Детали планет
        case .houses: return 3     // Сферы жизни
        case .aspects: return 4    // Взаимодействия
        case .education: return 5  // Подсказки
        }
    }

    /// Эмодзи для быстрой идентификации
    var emoji: String {
        switch self {
        case .today: return "🌅"      // Рассвет для "Сегодня"
        case .overview: return "⭐️"   // Звезда для основного
        case .planets: return "🪐"    // Планета
        case .houses: return "🏠"     // Дом для сфер жизни
        case .aspects: return "🔗"    // Связь для взаимодействий
        case .education: return "💡"  // Лампочка для подсказок
        }
    }

    /// Получить доступные вкладки для режима отображения
    static func availableTabs(for displayMode: DisplayMode) -> [ChartTab] {
        return ChartTab.allCases
            .filter { $0.isAvailable(for: displayMode) }
            .sorted { $0.priority < $1.priority }
    }

    /// Вкладка по умолчанию для режима
    static func defaultTab(for displayMode: DisplayMode) -> ChartTab {
        return .today // Начинаем с "Сегодня" для максимальной ценности
    }
}

/// Конфигурация контента для каждой вкладки
struct ChartTabConfig {
    let tab: ChartTab
    let displayMode: DisplayMode
    let birthChart: BirthChart

    /// Максимальное количество элементов для отображения на вкладке
    var maxElements: Int {
        switch (tab, displayMode) {
        case (.today, .human): return 1         // Только самое важное
        case (.today, .beginner): return 3      // Только ключевые транзиты
        case (.today, .intermediate): return 8  // Все активные транзиты

        case (.overview, .human): return 1      // Только основное
        case (.overview, .beginner): return 3
        case (.overview, .intermediate): return 8

        case (.planets, .human): return 3       // Только большая тройка
        case (.planets, .beginner): return 5
        case (.planets, .intermediate): return 13

        case (.houses, _): return displayMode == .intermediate ? 4 : 12
        case (.aspects, _): return displayMode == .intermediate ? 5 : 15

        case (.education, _): return 0 // Подсказки не ограничиваем
        }
    }

    /// Показывать ли детальную информацию
    var showDetailedInfo: Bool {
        return displayMode != .beginner
    }

    /// Показывать ли дополнительные элементы управления
    var showAdvancedControls: Bool {
        return displayMode == .intermediate
    }

    /// Рекомендуемый размер контента
    var contentSize: ContentSize {
        switch displayMode {
        case .human: return .minimal
        case .beginner: return .compact
        case .intermediate: return .expanded
        }
    }

    enum ContentSize {
        case minimal, compact, standard, expanded

        var cardHeight: CGFloat {
            switch self {
            case .minimal: return 60
            case .compact: return 80
            case .standard: return 120
            case .expanded: return 160
            }
        }

        var spacing: CGFloat {
            switch self {
            case .minimal: return CosmicSpacing.extraSmall
            case .compact: return CosmicSpacing.small
            case .standard: return CosmicSpacing.medium
            case .expanded: return CosmicSpacing.large
            }
        }
    }
}

/// Состояние навигации по вкладкам
class ChartTabState: ObservableObject {
    @Published var selectedTab: ChartTab = .overview
    @Published var availableTabs: [ChartTab] = ChartTab.allCases

    private let displayModeManager: ChartDisplayModeManager

    init(displayModeManager: ChartDisplayModeManager) {
        self.displayModeManager = displayModeManager

        // Подписываемся на изменения режима отображения
        displayModeManager.$currentMode
            .map { ChartTab.availableTabs(for: $0) }
            .assign(to: &$availableTabs)

        // Если текущая вкладка становится недоступной, переключаемся на первую доступную
        displayModeManager.$currentMode
            .sink { [weak self] newMode in
                guard let self = self else { return }
                let newAvailableTabs = ChartTab.availableTabs(for: newMode)
                if !newAvailableTabs.contains(self.selectedTab) {
                    self.selectedTab = ChartTab.defaultTab(for: newMode)
                }
            }
            .store(in: &cancellables)
    }

    private var cancellables = Set<AnyCancellable>()

    /// Переключиться на вкладку
    func selectTab(_ tab: ChartTab) {
        guard availableTabs.contains(tab) else { return }
        withAnimation(.easeInOut(duration: 0.3)) {
            selectedTab = tab
        }
    }

    /// Перейти к следующей вкладке
    func nextTab() {
        guard let currentIndex = availableTabs.firstIndex(of: selectedTab),
              currentIndex < availableTabs.count - 1 else { return }

        selectTab(availableTabs[currentIndex + 1])
    }

    /// Перейти к предыдущей вкладке
    func previousTab() {
        guard let currentIndex = availableTabs.firstIndex(of: selectedTab),
              currentIndex > 0 else { return }

        selectTab(availableTabs[currentIndex - 1])
    }

    /// Получить конфигурацию для текущей вкладки
    func getConfig(for birthChart: BirthChart) -> ChartTabConfig {
        return ChartTabConfig(
            tab: selectedTab,
            displayMode: displayModeManager.currentMode,
            birthChart: birthChart
        )
    }

    /// Проверить, есть ли следующая вкладка
    var hasNextTab: Bool {
        guard let currentIndex = availableTabs.firstIndex(of: selectedTab) else { return false }
        return currentIndex < availableTabs.count - 1
    }

    /// Проверить, есть ли предыдущая вкладка
    var hasPreviousTab: Bool {
        guard let currentIndex = availableTabs.firstIndex(of: selectedTab) else { return false }
        return currentIndex > 0
    }
}

// MARK: - Supporting Extensions

extension ChartTab {
    /// Получить количество бейджа для вкладки (количество элементов)
    func getBadgeCount(for chart: BirthChart, displayMode: DisplayMode) -> Int? {
        switch self {
        case .today:
            return nil // Для "Сегодня" не показываем количество - акцент на актуальности

        case .overview:
            return nil // Для обзора не показываем количество

        case .planets:
            let allowedPlanets = displayMode.allowedPlanets
            return chart.planets.filter { allowedPlanets.contains($0.type) }.count

        case .houses:
            return displayMode.showHouses ? chart.houses.count : 0

        case .aspects:
            let allowedAspects = displayMode.allowedAspects
            let maxOrb = displayMode.maxAspectOrb
            return chart.aspects.filter {
                allowedAspects.contains($0.type) && $0.orb <= maxOrb
            }.count

        case .education:
            return nil // Подсказки не показывают количество в бейдже
        }
    }

    /// Показать бейдж с количеством элементов
    func shouldShowBadge(for displayMode: DisplayMode) -> Bool {
        switch self {
        case .today: return false     // "Сегодня" не показывает бэйджи - фокус на актуальности
        case .overview: return false
        case .planets: return displayMode != .beginner
        case .houses: return displayMode == .intermediate
        case .aspects: return displayMode == .intermediate
        case .education: return false // Подсказки не показывают бэйджи
        }
    }
}

import Combine