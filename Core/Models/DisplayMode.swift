//
//  DisplayMode.swift
//  Astrolog
//
//  Created by Claude on 21.10.2025.
//

// Core/Models/DisplayMode.swift
import Foundation
import SwiftUI

/// Режимы отображения натальной карты для разных уровней пользователей
public enum DisplayMode: String, CaseIterable, Codable {
    case human = "Новичок"
    case beginner = "Опытный"
    case intermediate = "Эксперт"

    /// Иконка для режима
    public var icon: String {
        switch self {
        case .human:
            return "graduationcap.fill"
        case .beginner:
            return "star.fill"
        case .intermediate:
            return "crown.fill"
        }
    }

    /// Описание режима для пользователя
    public var description: String {
        switch self {
        case .human:
            return "Понятные объяснения без астрологических терминов"
        case .beginner:
            return "Основная информация с простыми астрологическими терминами"
        case .intermediate:
            return "Полная информация со всеми астрологическими деталями"
        }
    }

    /// Цвет режима
    public var color: Color {
        switch self {
        case .human:
            return .neonPink
        case .beginner:
            return .beginnerGreen
        case .intermediate:
            return .cosmicViolet
        }
    }

    /// Максимальное количество планет для отображения
    public var maxPlanets: Int {
        switch self {
        case .human:
            return 3 // Только Солнце, Луна, Асцендент
        case .beginner:
            return 5 // Солнце, Луна, Меркурий, Венера, Марс
        case .intermediate:
            return 13 // Все планеты + Асцендент, MC, Северный узел
        }
    }

    /// Планеты для отображения в данном режиме
    public var allowedPlanets: [PlanetType] {
        switch self {
        case .human:
            return [.sun, .moon, .ascendant] // Только большая тройка
        case .beginner:
            return [.sun, .moon, .mercury, .venus, .mars]
        case .intermediate:
            return PlanetType.allCases
        }
    }

    /// Типы аспектов для отображения
    public var allowedAspects: [AspectType] {
        switch self {
        case .human:
            return [] // Аспекты не показываем в человечном режиме
        case .beginner:
            return [.conjunction, .opposition, .trine] // Только основные
        case .intermediate:
            return AspectType.allCases
        }
    }

    /// Показывать ли дома
    public var showHouses: Bool {
        switch self {
        case .human, .beginner:
            return false
        case .intermediate:
            return true
        }
    }

    /// Показывать ли орбы аспектов
    public var showAspectOrbs: Bool {
        switch self {
        case .human, .beginner:
            return false
        case .intermediate:
            return true
        }
    }

    /// Максимальный орб для аспектов
    public var maxAspectOrb: Double {
        switch self {
        case .human:
            return 0.0 // Аспекты не используются
        case .beginner:
            return 6.0 // Только точные аспекты
        case .intermediate:
            return 10.0
        }
    }

    /// Режим по умолчанию для новых пользователей
    public static var defaultMode: DisplayMode {
        return .human // Начинаем с самого понятного режима
    }

    /// Использовать ли человеческий язык вместо астрологических терминов
    public var useHumanLanguage: Bool {
        return self == .human
    }

    /// Показывать ли символы планет и знаков
    public var showSymbols: Bool {
        switch self {
        case .human:
            return false  // Только текст и эмодзи
        case .beginner, .intermediate:
            return true
        }
    }

    /// Рекомендуемая глубина описания
    public var recommendedDepth: InterpretationDepth {
        return InterpretationDepth.forDisplayMode(self)
    }
}

/// Расширение для определения уровня навыков пользователя
public enum SkillLevel: String, CaseIterable, Codable {
    case novice = "Новичок"
    case intermediate = "Изучающий"
    case advanced = "Продвинутый"

    /// Рекомендуемый режим отображения для уровня навыков
    public var recommendedDisplayMode: DisplayMode {
        switch self {
        case .novice:
            return .human    // Новичкам - понятный режим
        case .intermediate:
            return .beginner
        case .advanced:
            return .intermediate
        }
    }
}

/// Расширение для интерпретации данных
public enum InterpretationDepth: String, CaseIterable, Codable {
    case emoji = "Эмодзи"
    case brief = "Краткий"
    case detailed = "Подробный"

    /// Соответствие глубины интерпретации режиму отображения
    public static func forDisplayMode(_ mode: DisplayMode) -> InterpretationDepth {
        switch mode {
        case .human:
            return .emoji    // Самый простой уровень
        case .beginner:
            return .emoji
        case .intermediate:
            return .detailed
        }
    }
}