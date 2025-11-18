//
//  DailyAdvice.swift
//  Astrolog
//
//  Created by Claude on 18.11.2025.
//
// Features/Main/Models/DailyAdvice.swift
import Foundation

struct DailyAdvice: Codable, Identifiable, Equatable {
    let id: UUID
    let type: AdviceType
    let content: String
    let source: String?                      // Опциональный источник или контекст

    init(
        id: UUID = UUID(),
        type: AdviceType,
        content: String,
        source: String? = nil
    ) {
        self.id = id
        self.type = type
        self.content = content
        self.source = source
    }
}

enum AdviceType: String, Codable {
    case affirmation                         // Аффирмация
    case practicalAdvice                     // Практический совет
    case warning                             // Предупреждение
    case challenge                           // Вызов дня

    var icon: String {
        switch self {
        case .affirmation: return "💭"
        case .practicalAdvice: return "💡"
        case .warning: return "⚠️"
        case .challenge: return "🎯"
        }
    }

    var title: String {
        switch self {
        case .affirmation: return "Настрой на день"
        case .practicalAdvice: return "Совет от звезд"
        case .warning: return "Будьте внимательны"
        case .challenge: return "Challenge дня"
        }
    }
}

// MARK: - Mock Data Extension
extension DailyAdvice {
    static var mockAffirmation: DailyAdvice {
        DailyAdvice(
            type: .affirmation,
            content: "Я открыт новым возможностям и доверяю своей интуиции. Сегодняшняя энергия поддерживает смелые решения и новые начинания."
        )
    }

    static var mockPracticalAdvice: DailyAdvice {
        DailyAdvice(
            type: .practicalAdvice,
            content: "Сегодня благоприятное время для важных переговоров. Лучшие часы: 10:00-13:00. Подготовьтесь заранее, будьте уверены в своих аргументах.",
            source: "Меркурий в гармонии с Юпитером"
        )
    }

    static var mockWarning: DailyAdvice {
        DailyAdvice(
            type: .warning,
            content: """
            Меркурий образует напряженный аспект с Сатурном.

            Возможны:
            • Задержки в коммуникации
            • Технические сбои
            • Недопонимания

            Решение: Перепроверяйте детали, делайте резервные копии
            """,
            source: "Меркурий квадрат Сатурн"
        )
    }

    static var mockChallenge: DailyAdvice {
        DailyAdvice(
            type: .challenge,
            content: "Выйдите из зоны комфорта сегодня. Начните разговор с человеком, с которым давно хотели познакомиться, или попробуйте что-то новое в работе."
        )
    }
}
