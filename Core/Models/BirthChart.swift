//
//  BirthChart.swift
//  Astrolog
//
//  Created by Sergey on 19.09.2025.
//
// Core/Models/BirthChart.swift
import Foundation
import SwiftUI

struct BirthChart: Codable, Identifiable {
    let id: String
    let userId: String
    let name: String
    let birthDate: Date
    let birthTime: String
    let location: String
    let latitude: Double
    let longitude: Double
    let planets: [Planet]
    let houses: [House]
    let aspects: [Aspect]
    let calculatedAt: Date
    
    // Основные элементы для интерпретации
    var sunSign: ZodiacSign {
        planets.first { $0.type == .sun }?.zodiacSign ?? .aries
    }
    
    var moonSign: ZodiacSign {
        planets.first { $0.type == .moon }?.zodiacSign ?? .aries
    }
    
    var ascendant: ZodiacSign {
        planets.first { $0.type == .ascendant }?.zodiacSign ?? .aries
    }
}

struct Planet: Codable, Identifiable {
    let id: String
    let type: PlanetType
    let longitude: Double // 0-360 градусов
    let zodiacSign: ZodiacSign
    let house: Int // 1-12
    let isRetrograde: Bool

    // Для совместимости с Firebase API
    var name: String { type.displayName }
    var sign: String { zodiacSign.displayName }
    var degree: Double { longitude }

    // Градусы внутри знака (0-30)
    var degreeInSign: Double {
        longitude.truncatingRemainder(dividingBy: 30)
    }
}

struct House: Codable, Identifiable {
    let id: String
    let number: Int // 1-12
    let cuspLongitude: Double
    let zodiacSign: ZodiacSign
    let planetsInHouse: [PlanetType]

    // Computed property для совместимости
    var planets: [Planet] {
        // Заглушка - в реальности нужно будет получать планеты из общего списка
        return []
    }
}

struct Aspect: Codable, Identifiable {
    let id: String
    let planet1Type: PlanetType
    let planet2Type: PlanetType
    let type: AspectType
    let orb: Double // отклонение от точного аспекта
    let isApplying: Bool // сходящийся или расходящийся

    // Computed properties для совместимости
    var planet1: Planet {
        Planet.mockPlanets.first { $0.type == planet1Type } ?? Planet.mockPlanets[0]
    }

    var planet2: Planet {
        Planet.mockPlanets.first { $0.type == planet2Type } ?? Planet.mockPlanets[1]
    }
}

public enum PlanetType: String, CaseIterable, Codable {
    case sun, moon, mercury, venus, mars, jupiter, saturn, uranus, neptune, pluto
    case ascendant, midheaven, northNode

    public var symbol: String {
        switch self {
        case .sun: return "☉"
        case .moon: return "☽"
        case .mercury: return "☿"
        case .venus: return "♀"
        case .mars: return "♂"
        case .jupiter: return "♃"
        case .saturn: return "♄"
        case .uranus: return "♅"
        case .neptune: return "♆"
        case .pluto: return "♇"
        case .ascendant: return "↗"
        case .midheaven: return "MC"
        case .northNode: return "☊"
        }
    }

    public var displayName: String {
        switch self {
        case .sun: return "Солнце"
        case .moon: return "Луна"
        case .mercury: return "Меркурий"
        case .venus: return "Венера"
        case .mars: return "Марс"
        case .jupiter: return "Юпитер"
        case .saturn: return "Сатурн"
        case .uranus: return "Уран"
        case .neptune: return "Нептун"
        case .pluto: return "Плутон"
        case .ascendant: return "Асцендент"
        case .midheaven: return "Середина неба"
        case .northNode: return "Северный узел"
        }
    }

    var color: Color {
        switch self {
        case .sun: return .starYellow
        case .moon: return .starWhite
        case .mercury: return .neonCyan
        case .venus: return .cosmicPink
        case .mars: return .neonPink
        case .jupiter: return .cosmicViolet
        case .saturn: return .cosmicPurple
        case .uranus: return .neonBlue
        case .neptune: return .cosmicBlue
        case .pluto: return .cosmicDarkPurple
        case .ascendant: return .neonPurple
        case .midheaven: return .starOrange
        case .northNode: return .cosmicCyan
        }
    }
}

enum ZodiacSign: Int, CaseIterable, Codable {
    case aries = 0, taurus, gemini, cancer, leo, virgo
    case libra, scorpio, sagittarius, capricorn, aquarius, pisces
    
    var symbol: String {
        let symbols = ["♈", "♉", "♊", "♋", "♌", "♍", "♎", "♏", "♐", "♑", "♒", "♓"]
        return symbols[rawValue]
    }
    
    var displayName: String {
        switch self {
        case .aries: return "Овен"
        case .taurus: return "Телец"
        case .gemini: return "Близнецы"
        case .cancer: return "Рак"
        case .leo: return "Лев"
        case .virgo: return "Дева"
        case .libra: return "Весы"
        case .scorpio: return "Скорпион"
        case .sagittarius: return "Стрелец"
        case .capricorn: return "Козерог"
        case .aquarius: return "Водолей"
        case .pisces: return "Рыбы"
        }
    }
    
    var element: Element {
        switch self {
        case .aries, .leo, .sagittarius: return .fire
        case .taurus, .virgo, .capricorn: return .earth
        case .gemini, .libra, .aquarius: return .air
        case .cancer, .scorpio, .pisces: return .water
        }
    }

    var modality: Modality {
        switch self {
        case .aries, .cancer, .libra, .capricorn: return .cardinal
        case .taurus, .leo, .scorpio, .aquarius: return .fixed
        case .gemini, .virgo, .sagittarius, .pisces: return .mutable
        }
    }

    var color: Color {
        switch self {
        case .aries: return .starOrange
        case .taurus: return .cosmicTeal
        case .gemini: return .starYellow
        case .cancer: return .starWhite
        case .leo: return .starOrange
        case .virgo: return .cosmicTeal
        case .libra: return .cosmicPink
        case .scorpio: return .neonPink
        case .sagittarius: return .neonPurple
        case .capricorn: return .deepSpace
        case .aquarius: return .neonBlue
        case .pisces: return .cosmicViolet
        }
    }

    /// Цвет стихии знака зодиака (элементарное кодирование)
    var elementColor: Color {
        switch element {
        case .fire: return .fireElement
        case .earth: return .earthElement
        case .air: return .airElement
        case .water: return .waterElement
        }
    }

    enum Element: String, CaseIterable {
        case fire = "fire"
        case earth = "earth"
        case air = "air"
        case water = "water"
        
        var displayName: String {
            switch self {
            case .fire: return "Огонь"
            case .earth: return "Земля"
            case .air: return "Воздух"
            case .water: return "Вода"
            }
        }
    }

    enum Modality: String, CaseIterable {
        case cardinal = "cardinal"
        case fixed = "fixed"
        case mutable = "mutable"

        var displayName: String {
            switch self {
            case .cardinal: return "Кардинальный"
            case .fixed: return "Фиксированный"
            case .mutable: return "Изменчивый"
            }
        }
    }

    /// Получить знак зодиака по долготе (0-360 градусов)
    static func from(longitude: Double) -> ZodiacSign {
        let normalizedLongitude = longitude.truncatingRemainder(dividingBy: 360)
        let signIndex = Int(normalizedLongitude / 30) % 12
        return ZodiacSign(rawValue: signIndex) ?? .aries
    }
}

public enum AspectType: String, CaseIterable, Codable {
    case conjunction = "conjunction" // 0°
    case sextile = "sextile"         // 60°
    case square = "square"           // 90°
    case trine = "trine"             // 120°
    case opposition = "opposition"   // 180°

    public var degrees: Double {
        switch self {
        case .conjunction: return 0
        case .sextile: return 60
        case .square: return 90
        case .trine: return 120
        case .opposition: return 180
        }
    }

    public var symbol: String {
        switch self {
        case .conjunction: return "☌"
        case .sextile: return "⚹"
        case .square: return "□"
        case .trine: return "△"
        case .opposition: return "☍"
        }
    }

    public var displayName: String {
        switch self {
        case .conjunction: return "Соединение"
        case .sextile: return "Секстиль"
        case .square: return "Квадратура"
        case .trine: return "Тригон"
        case .opposition: return "Оппозиция"
        }
    }

    public var isHarmonic: Bool {
        switch self {
        case .sextile, .trine: return true
        case .conjunction, .square, .opposition: return false
        }
    }

    /// Цвет аспекта на основе его природы
    public var color: Color {
        switch self {
        case .sextile, .trine:
            return .positive // Гармоничные аспекты - зеленый
        case .square, .opposition:
            return .challenging // Напряженные аспекты - красный
        case .conjunction:
            return .neutral // Соединение - нейтральный серый
        }
    }

    /// Интенсивность влияния аспекта
    public var intensity: Double {
        switch self {
        case .conjunction: return 1.0
        case .opposition: return 0.9
        case .square: return 0.8
        case .trine: return 0.7
        case .sextile: return 0.6
        }
    }
}

// MARK: - Mock Data
extension BirthChart {
    static let mock = BirthChart(
        id: "mock-chart-id",
        userId: "mock-user-id",
        name: "Пример карты",
        birthDate: Date(),
        birthTime: "12:00",
        location: "Москва, Россия",
        latitude: 55.7558,
        longitude: 37.6176,
        planets: Planet.mockPlanets,
        houses: House.mockHouses,
        aspects: Aspect.mockAspects,
        calculatedAt: Date()
    )
}

extension Planet {
    static let mockPlanets: [Planet] = [
        Planet(id: "sun", type: .sun, longitude: 120, zodiacSign: .leo, house: 10, isRetrograde: false),
        Planet(id: "moon", type: .moon, longitude: 90, zodiacSign: .cancer, house: 9, isRetrograde: false),
        Planet(id: "ascendant", type: .ascendant, longitude: 0, zodiacSign: .aries, house: 1, isRetrograde: false),
        Planet(id: "mercury", type: .mercury, longitude: 110, zodiacSign: .leo, house: 10, isRetrograde: false),
        Planet(id: "venus", type: .venus, longitude: 130, zodiacSign: .virgo, house: 11, isRetrograde: false),
        Planet(id: "mars", type: .mars, longitude: 150, zodiacSign: .libra, house: 12, isRetrograde: false)
    ]
}

extension House {
    static let mockHouses: [House] = [
        House(id: "house1", number: 1, cuspLongitude: 0, zodiacSign: .aries, planetsInHouse: []),
        House(id: "house2", number: 2, cuspLongitude: 30, zodiacSign: .taurus, planetsInHouse: []),
        House(id: "house3", number: 3, cuspLongitude: 60, zodiacSign: .gemini, planetsInHouse: []),
        House(id: "house4", number: 4, cuspLongitude: 90, zodiacSign: .cancer, planetsInHouse: []),
        House(id: "house5", number: 5, cuspLongitude: 120, zodiacSign: .leo, planetsInHouse: []),
        House(id: "house6", number: 6, cuspLongitude: 150, zodiacSign: .virgo, planetsInHouse: []),
        House(id: "house7", number: 7, cuspLongitude: 180, zodiacSign: .libra, planetsInHouse: []),
        House(id: "house8", number: 8, cuspLongitude: 210, zodiacSign: .scorpio, planetsInHouse: []),
        House(id: "house9", number: 9, cuspLongitude: 240, zodiacSign: .sagittarius, planetsInHouse: []),
        House(id: "house10", number: 10, cuspLongitude: 270, zodiacSign: .capricorn, planetsInHouse: []),
        House(id: "house11", number: 11, cuspLongitude: 300, zodiacSign: .aquarius, planetsInHouse: []),
        House(id: "house12", number: 12, cuspLongitude: 330, zodiacSign: .pisces, planetsInHouse: [])
    ]
}

extension Aspect {
    static let mockAspects: [Aspect] = [
        Aspect(id: "aspect1", planet1Type: .sun, planet2Type: .moon, type: .trine, orb: 3.5, isApplying: true),
        Aspect(id: "aspect2", planet1Type: .sun, planet2Type: .ascendant, type: .square, orb: 2.1, isApplying: false),
        Aspect(id: "aspect3", planet1Type: .moon, planet2Type: .venus, type: .sextile, orb: 1.8, isApplying: true)
    ]
}
