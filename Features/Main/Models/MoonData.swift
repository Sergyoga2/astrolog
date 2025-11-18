//
//  MoonData.swift
//  Astrolog
//
//  Created by Claude on 18.11.2025.
//
// Features/Main/Models/MoonData.swift
import Foundation

struct MoonData: Codable, Equatable {
    let phase: MoonPhase
    let zodiacSign: ZodiacSign
    let dayOfCycle: Int
    let recommendations: [String]
    let warnings: [String]
    let nextPhase: NextPhaseInfo
    let voidOfCourse: TimeRange?

    init(
        phase: MoonPhase,
        zodiacSign: ZodiacSign,
        dayOfCycle: Int,
        recommendations: [String],
        warnings: [String],
        nextPhase: NextPhaseInfo,
        voidOfCourse: TimeRange? = nil
    ) {
        self.phase = phase
        self.zodiacSign = zodiacSign
        self.dayOfCycle = dayOfCycle
        self.recommendations = recommendations
        self.warnings = warnings
        self.nextPhase = nextPhase
        self.voidOfCourse = voidOfCourse
    }
}

struct MoonPhase: Codable, Equatable {
    let name: String                         // "Убывающая Луна"
    let emoji: String                        // "🌗"
    let percentage: Double                   // 0.0-1.0

    init(name: String, emoji: String, percentage: Double = 0.5) {
        self.name = name
        self.emoji = emoji
        self.percentage = percentage
    }
}

struct NextPhaseInfo: Codable, Equatable {
    let name: String
    let countdown: String                    // "5 дней 14 часов"
    let zodiacSign: String
    let description: String

    init(name: String, countdown: String, zodiacSign: String, description: String) {
        self.name = name
        self.countdown = countdown
        self.zodiacSign = zodiacSign
        self.description = description
    }
}

// MARK: - Moon Phase Helper
extension MoonPhase {
    static var newMoon: MoonPhase {
        MoonPhase(name: "Новолуние", emoji: "🌑", percentage: 0.0)
    }

    static var waxingCrescent: MoonPhase {
        MoonPhase(name: "Растущий полумесяц", emoji: "🌒", percentage: 0.125)
    }

    static var firstQuarter: MoonPhase {
        MoonPhase(name: "Первая четверть", emoji: "🌓", percentage: 0.25)
    }

    static var waxingGibbous: MoonPhase {
        MoonPhase(name: "Растущая Луна", emoji: "🌔", percentage: 0.375)
    }

    static var fullMoon: MoonPhase {
        MoonPhase(name: "Полнолуние", emoji: "🌕", percentage: 0.5)
    }

    static var waningGibbous: MoonPhase {
        MoonPhase(name: "Убывающая Луна", emoji: "🌖", percentage: 0.625)
    }

    static var lastQuarter: MoonPhase {
        MoonPhase(name: "Последняя четверть", emoji: "🌗", percentage: 0.75)
    }

    static var waningCrescent: MoonPhase {
        MoonPhase(name: "Убывающий полумесяц", emoji: "🌘", percentage: 0.875)
    }
}

// MARK: - Mock Data Extension
extension MoonData {
    static var mock: MoonData {
        MoonData(
            phase: .waningGibbous,
            zodiacSign: .virgo,
            dayOfCycle: 21,
            recommendations: [
                "Завершайте начатые проекты",
                "Наводите порядок в делах и пространстве",
                "Анализируйте прошедший месяц",
                "Планируйте следующий цикл"
            ],
            warnings: [
                "Не начинайте глобально новое",
                "Избегайте больших трат",
                "Отложите важные контракты"
            ],
            nextPhase: NextPhaseInfo(
                name: "Новолуние",
                countdown: "5 дней 14 часов",
                zodiacSign: "Скорпион",
                description: "Время для глубоких изменений"
            ),
            voidOfCourse: .create(startHour: 15, startMinute: 30, endHour: 19, endMinute: 0)
        )
    }
}
