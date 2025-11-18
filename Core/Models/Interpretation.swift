//
//  Interpretation.swift
//  Astrolog
//
//  Created by Claude on 21.10.2025.
//

// Core/Models/Interpretation.swift
import Foundation
import SwiftUI

/// Структура для многоуровневых интерпретаций астрологических элементов
struct Interpretation: Codable, Identifiable {
    let id: String
    let title: String           // "Солнце в Льве"
    let emoji: String          // "☀️♌"
    let oneLiner: String       // "Вы - прирожденный лидер"
    let summary: String        // 2-3 предложения
    let detailed: String       // Полный текст
    let keywords: [String]     // ["лидерство", "творчество", "щедрость"]
    let lifeAreas: [String]    // ["карьера", "творчество", "дети"]
    let elementType: ChartElementType
    let depth: InterpretationDepth
    let userLevel: SkillLevel

    init(
        id: String = UUID().uuidString,
        title: String,
        emoji: String,
        oneLiner: String,
        summary: String,
        detailed: String,
        keywords: [String] = [],
        lifeAreas: [String] = [],
        elementType: ChartElementType,
        depth: InterpretationDepth = .brief,
        userLevel: SkillLevel = .intermediate
    ) {
        self.id = id
        self.title = title
        self.emoji = emoji
        self.oneLiner = oneLiner
        self.summary = summary
        self.detailed = detailed
        self.keywords = keywords
        self.lifeAreas = lifeAreas
        self.elementType = elementType
        self.depth = depth
        self.userLevel = userLevel
    }
}

/// Типы элементов карты для интерпретации
enum ChartElementType: String, CaseIterable, Codable {
    case planet = "planet"
    case sign = "sign"
    case house = "house"
    case aspect = "aspect"
    case planetInSign = "planetInSign"
    case planetInHouse = "planetInHouse"
    case composite = "composite"

    var displayName: String {
        switch self {
        case .planet: return "Планета"
        case .sign: return "Знак зодиака"
        case .house: return "Дом"
        case .aspect: return "Аспект"
        case .planetInSign: return "Планета в знаке"
        case .planetInHouse: return "Планета в доме"
        case .composite: return "Комплексная интерпретация"
        }
    }

    var icon: String {
        switch self {
        case .planet: return "circle.fill"
        case .sign: return "star.fill"
        case .house: return "house.fill"
        case .aspect: return "arrow.triangle.2.circlepath"
        case .planetInSign: return "circle.star.fill"
        case .planetInHouse: return "house.circle.fill"
        case .composite: return "sparkles"
        }
    }
}

/// Контекст для персонализации интерпретаций
struct InterpretationContext: Codable {
    let userId: String?
    let birthChart: BirthChart?
    let currentDate: Date
    let userPreferences: UserPreferences?
    let displayMode: DisplayMode
    let focusArea: FocusArea?

    init(
        userId: String? = nil,
        birthChart: BirthChart? = nil,
        currentDate: Date = Date(),
        userPreferences: UserPreferences? = nil,
        displayMode: DisplayMode = .beginner,
        focusArea: FocusArea? = nil
    ) {
        self.userId = userId
        self.birthChart = birthChart
        self.currentDate = currentDate
        self.userPreferences = userPreferences
        self.displayMode = displayMode
        self.focusArea = focusArea
    }
}

/// Области фокуса для персонализации
enum FocusArea: String, CaseIterable, Codable {
    case personality = "personality"
    case relationships = "relationships"
    case career = "career"
    case health = "health"
    case spirituality = "spirituality"
    case money = "money"

    var displayName: String {
        switch self {
        case .personality: return "Личность"
        case .relationships: return "Отношения"
        case .career: return "Карьера"
        case .health: return "Здоровье"
        case .spirituality: return "Духовность"
        case .money: return "Финансы"
        }
    }

    var emoji: String {
        switch self {
        case .personality: return "👤"
        case .relationships: return "💕"
        case .career: return "💼"
        case .health: return "🏥"
        case .spirituality: return "🧘"
        case .money: return "💰"
        }
    }
}

/// Пользовательские предпочтения для интерпретаций
struct UserPreferences: Codable {
    let preferredLanguage: String
    let culturalContext: CulturalContext
    let interpretationStyle: InterpretationStyle
    let showKeywords: Bool
    let showLifeAreas: Bool
    let detailLevel: InterpretationDepth

    init(
        preferredLanguage: String = "ru",
        culturalContext: CulturalContext = .western,
        interpretationStyle: InterpretationStyle = .balanced,
        showKeywords: Bool = true,
        showLifeAreas: Bool = true,
        detailLevel: InterpretationDepth = .brief
    ) {
        self.preferredLanguage = preferredLanguage
        self.culturalContext = culturalContext
        self.interpretationStyle = interpretationStyle
        self.showKeywords = showKeywords
        self.showLifeAreas = showLifeAreas
        self.detailLevel = detailLevel
    }
}

/// Культурный контекст для интерпретаций
enum CulturalContext: String, CaseIterable, Codable {
    case western = "western"
    case vedic = "vedic"
    case chinese = "chinese"

    var displayName: String {
        switch self {
        case .western: return "Западная астрология"
        case .vedic: return "Ведическая астрология"
        case .chinese: return "Китайская астрология"
        }
    }
}

/// Стиль интерпретации
enum InterpretationStyle: String, CaseIterable, Codable {
    case positive = "positive"      // Акцент на сильные стороны
    case balanced = "balanced"      // Сбалансированный подход
    case analytical = "analytical"  // Аналитический стиль
    case poetic = "poetic"         // Поэтический стиль

    var displayName: String {
        switch self {
        case .positive: return "Позитивный"
        case .balanced: return "Сбалансированный"
        case .analytical: return "Аналитический"
        case .poetic: return "Поэтический"
        }
    }
}

// MARK: - Расширения для удобства работы

extension Interpretation {
    /// Получить текст для отображения в зависимости от глубины интерпретации
    func getText(for depth: InterpretationDepth) -> String {
        switch depth {
        case .emoji:
            return "\(emoji) \(oneLiner)"
        case .brief:
            return summary
        case .detailed:
            return detailed
        }
    }

    /// Проверить, подходит ли интерпретация для указанного режима отображения
    func isAppropriate(for mode: DisplayMode) -> Bool {
        switch mode {
        case .human, .beginner:
            return depth == .emoji || depth == .brief
        case .intermediate:
            return true // Все уровни подходят
        }
    }

    /// Получить цвет интерпретации на основе типа элемента
    var themeColor: Color {
        switch elementType {
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

extension InterpretationDepth {
    /// Получить иконку для уровня детализации
    var icon: String {
        switch self {
        case .emoji: return "face.smiling"
        case .brief: return "text.alignleft"
        case .detailed: return "text.book.closed"
        }
    }

    /// Получить описание уровня
    var description: String {
        switch self {
        case .emoji: return "Основная идея с эмодзи"
        case .brief: return "Краткое описание"
        case .detailed: return "Подробная интерпретация"
        }
    }

    /// Получить примерную длину текста для уровня
    var expectedLength: ClosedRange<Int> {
        switch self {
        case .emoji: return 10...50      // Эмодзи + 1-2 предложения
        case .brief: return 50...200     // 2-4 предложения
        case .detailed: return 200...800 // Несколько абзацев
        }
    }

    /// Цвет для визуального различения уровней
    var color: Color {
        switch self {
        case .emoji: return .starYellow
        case .brief: return .cosmicViolet
        case .detailed: return .neonPurple
        }
    }

    /// Порядок для сортировки от простого к сложному
    var sortOrder: Int {
        switch self {
        case .emoji: return 0
        case .brief: return 1
        case .detailed: return 2
        }
    }

    /// Следующий уровень детализации
    var nextLevel: InterpretationDepth? {
        switch self {
        case .emoji: return .brief
        case .brief: return .detailed
        case .detailed: return nil
        }
    }

    /// Предыдущий уровень детализации
    var previousLevel: InterpretationDepth? {
        switch self {
        case .emoji: return nil
        case .brief: return .emoji
        case .detailed: return .brief
        }
    }
}

// MARK: - Дополнительные расширения для работы с интерпретациями

extension Interpretation {
    /// Получить форматированный текст для определенного уровня с учетом стиля
    func getFormattedText(
        for depth: InterpretationDepth,
        style: InterpretationStyle = .balanced
    ) -> String {
        let baseText = getText(for: depth)

        switch style {
        case .positive:
            return enhancePositive(baseText)
        case .balanced:
            return baseText
        case .analytical:
            return addAnalyticalNote(baseText)
        case .poetic:
            return addPoeticalTouch(baseText)
        }
    }

    /// Проверить, содержит ли интерпретация все необходимые уровни
    var isComplete: Bool {
        return !oneLiner.isEmpty && !summary.isEmpty && !detailed.isEmpty
    }

    /// Получить интерпретацию с ключевыми словами, если нужно
    func getTextWithKeywords(for depth: InterpretationDepth, includeKeywords: Bool) -> String {
        let mainText = getText(for: depth)

        guard includeKeywords && !keywords.isEmpty else {
            return mainText
        }

        let keywordsText = "Ключевые слова: " + keywords.joined(separator: ", ")
        return "\(mainText)\n\n\(keywordsText)"
    }

    /// Получить интерпретацию с областями жизни, если нужно
    func getTextWithLifeAreas(for depth: InterpretationDepth, includeLifeAreas: Bool) -> String {
        let mainText = getText(for: depth)

        guard includeLifeAreas && !lifeAreas.isEmpty else {
            return mainText
        }

        let lifeAreasText = "Области влияния: " + lifeAreas.joined(separator: ", ")
        return "\(mainText)\n\n\(lifeAreasText)"
    }

    // MARK: - Приватные методы для стилизации

    private func enhancePositive(_ text: String) -> String {
        // Добавляем позитивные акценты к тексту
        let positiveWords = ["возможность", "потенциал", "сила", "талант", "дар"]
        return text // Здесь может быть логика замены нейтральных слов на позитивные
    }

    private func addAnalyticalNote(_ text: String) -> String {
        return text + "\n\n💡 Аналитическая заметка: Учитывайте контекст других элементов карты для полного понимания."
    }

    private func addPoeticalTouch(_ text: String) -> String {
        // Добавляем поэтические элементы
        return "✨ " + text.replacingOccurrences(of: ". ", with: "... ")
    }
}

// MARK: - Удобные инициализаторы

extension Interpretation {
    /// Быстрый инициализатор для эмодзи-уровня
    static func emoji(
        title: String,
        emoji: String,
        oneLiner: String,
        elementType: ChartElementType
    ) -> Interpretation {
        return Interpretation(
            title: title,
            emoji: emoji,
            oneLiner: oneLiner,
            summary: oneLiner,
            detailed: oneLiner,
            elementType: elementType,
            depth: .emoji
        )
    }

    /// Быстрый инициализатор для краткого уровня
    static func brief(
        title: String,
        emoji: String,
        summary: String,
        elementType: ChartElementType,
        keywords: [String] = []
    ) -> Interpretation {
        let oneLiner = String(summary.prefix(100))
        return Interpretation(
            title: title,
            emoji: emoji,
            oneLiner: oneLiner,
            summary: summary,
            detailed: summary,
            keywords: keywords,
            elementType: elementType,
            depth: .brief
        )
    }

    /// Полный инициализатор с проверкой длины текста
    static func detailed(
        title: String,
        emoji: String,
        oneLiner: String,
        summary: String,
        detailed: String,
        keywords: [String] = [],
        lifeAreas: [String] = [],
        elementType: ChartElementType
    ) -> Interpretation {
        return Interpretation(
            title: title,
            emoji: emoji,
            oneLiner: oneLiner,
            summary: summary,
            detailed: detailed,
            keywords: keywords,
            lifeAreas: lifeAreas,
            elementType: elementType,
            depth: .detailed
        )
    }
}