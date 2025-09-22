//
//  BirthChart.swift
//  Astrolog
//
//  Created by Sergey on 19.09.2025.
//
// Core/Models/BirthChart.swift
import Foundation

struct BirthChart: Codable, Identifiable {
    let id = UUID().uuidString
    let userId: String
    let planets: [Planet]
    let houses: [House]
    let aspects: [Aspect]
    let calculatedAt = Date()
    
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
    let id = UUID().uuidString
    let type: PlanetType
    let longitude: Double // 0-360 градусов
    let zodiacSign: ZodiacSign
    let house: Int // 1-12
    let isRetrograde: Bool
    
    // Градусы внутри знака (0-30)
    var degreeInSign: Double {
        longitude.truncatingRemainder(dividingBy: 30)
    }
}

struct House: Codable, Identifiable {
    let id = UUID().uuidString
    let number: Int // 1-12
    let cuspLongitude: Double
    let zodiacSign: ZodiacSign
    let planetsInHouse: [PlanetType]
}

struct Aspect: Codable, Identifiable {
    let id = UUID().uuidString
    let planet1: PlanetType
    let planet2: PlanetType
    let type: AspectType
    let orb: Double // отклонение от точного аспекта
    let isApplying: Bool // сходящийся или расходящийся
}

enum PlanetType: String, CaseIterable, Codable {
    case sun, moon, mercury, venus, mars, jupiter, saturn, uranus, neptune, pluto
    case ascendant, midheaven, northNode
    
    var symbol: String {
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
    
    var displayName: String {
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
}

enum AspectType: String, CaseIterable, Codable {
    case conjunction = "conjunction" // 0°
    case sextile = "sextile"         // 60°
    case square = "square"           // 90°
    case trine = "trine"             // 120°
    case opposition = "opposition"   // 180°
    
    var degrees: Double {
        switch self {
        case .conjunction: return 0
        case .sextile: return 60
        case .square: return 90
        case .trine: return 120
        case .opposition: return 180
        }
    }
    
    var symbol: String {
        switch self {
        case .conjunction: return "☌"
        case .sextile: return "⚹"
        case .square: return "□"
        case .trine: return "△"
        case .opposition: return "☍"
        }
    }
    
    var isHarmonic: Bool {
        switch self {
        case .sextile, .trine: return true
        case .conjunction, .square, .opposition: return false
        }
    }
}
