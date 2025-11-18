//
//  KeyEnergy.swift
//  Astrolog
//
//  Created by Claude on 18.11.2025.
//
// Features/Main/Models/KeyEnergy.swift
import Foundation
import SwiftUI

struct KeyEnergy: Codable, Identifiable, Equatable {
    let id: UUID
    let type: EnergyType
    let icon: String
    let title: String
    let description: String
    let duration: String
    let area: String                         // Сфера влияния
    let peakTime: String?
    let significance: Double                 // Для сортировки по важности (0-1)

    init(
        id: UUID = UUID(),
        type: EnergyType,
        icon: String,
        title: String,
        description: String,
        duration: String,
        area: String,
        peakTime: String? = nil,
        significance: Double = 0.5
    ) {
        self.id = id
        self.type = type
        self.icon = icon
        self.title = title
        self.description = description
        self.duration = duration
        self.area = area
        self.peakTime = peakTime
        self.significance = significance
    }
}

enum EnergyType: String, Codable {
    case planetary
    case aspect
    case retrograde

    var displayName: String {
        switch self {
        case .planetary: return "Планетарное влияние"
        case .aspect: return "Аспект"
        case .retrograde: return "Ретроградность"
        }
    }

    var color: Color {
        switch self {
        case .planetary: return .cosmicPink
        case .aspect: return .neonPurple
        case .retrograde: return .starYellow
        }
    }
}

// MARK: - Mock Data Extension
extension KeyEnergy {
    static var mockPlanetary: KeyEnergy {
        KeyEnergy(
            type: .planetary,
            icon: "🔴",
            title: "Марс в действии",
            description: "Сильная энергия для действий и принятия решений",
            duration: "До 31 октября",
            area: "Карьера, амбиции",
            significance: 0.8
        )
    }

    static var mockAspect: KeyEnergy {
        KeyEnergy(
            type: .aspect,
            icon: "💫",
            title: "Венера-Юпитер",
            description: "Гармоничный аспект приносит удачу в отношениях",
            duration: "Сегодня",
            area: "Любовь, финансы",
            peakTime: "14:00-18:00",
            significance: 0.9
        )
    }

    static var mockRetrograde: KeyEnergy {
        KeyEnergy(
            type: .retrograde,
            icon: "⚠️",
            title: "Меркурий замедляется",
            description: "Проверяйте детали, перечитывайте сообщения",
            duration: "С 5 ноября",
            area: "Коммуникация, техника",
            significance: 0.7
        )
    }

    static var mockList: [KeyEnergy] {
        [mockAspect, mockPlanetary, mockRetrograde]
    }
}
