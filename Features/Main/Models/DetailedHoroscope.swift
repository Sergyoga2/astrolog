//
//  DetailedHoroscope.swift
//  Astrolog
//
//  Created by Claude on 18.11.2025.
//
// Features/Main/Models/DetailedHoroscope.swift
import Foundation

struct DetailedHoroscope: Codable, Identifiable, Equatable {
    let id: UUID
    let date: Date
    let greeting: String
    let generalForecast: String              // 2-3 параграфа
    let careerAndFinances: String
    let loveAndRelationships: String
    let healthAndEnergy: String
    let friendsAndSocial: String
    let todoList: [String]                   // Что делать
    let avoidList: [String]                  // Чего избегать
    let bestTimeRanges: [TimeRange]          // Лучшее время
    let luckyColors: [String]
    let luckyNumber: Int

    init(
        id: UUID = UUID(),
        date: Date,
        greeting: String,
        generalForecast: String,
        careerAndFinances: String,
        loveAndRelationships: String,
        healthAndEnergy: String,
        friendsAndSocial: String,
        todoList: [String],
        avoidList: [String],
        bestTimeRanges: [TimeRange],
        luckyColors: [String],
        luckyNumber: Int
    ) {
        self.id = id
        self.date = date
        self.greeting = greeting
        self.generalForecast = generalForecast
        self.careerAndFinances = careerAndFinances
        self.loveAndRelationships = loveAndRelationships
        self.healthAndEnergy = healthAndEnergy
        self.friendsAndSocial = friendsAndSocial
        self.todoList = todoList
        self.avoidList = avoidList
        self.bestTimeRanges = bestTimeRanges
        self.luckyColors = luckyColors
        self.luckyNumber = luckyNumber
    }
}

// MARK: - Time Range
struct TimeRange: Codable, Equatable {
    let start: Date
    let end: Date

    func formatted() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return "\(formatter.string(from: start))-\(formatter.string(from: end))"
    }

    static func create(startHour: Int, startMinute: Int = 0, endHour: Int, endMinute: Int = 0) -> TimeRange {
        let calendar = Calendar.current
        let now = Date()

        var startComponents = calendar.dateComponents([.year, .month, .day], from: now)
        startComponents.hour = startHour
        startComponents.minute = startMinute

        var endComponents = calendar.dateComponents([.year, .month, .day], from: now)
        endComponents.hour = endHour
        endComponents.minute = endMinute

        let start = calendar.date(from: startComponents) ?? now
        let end = calendar.date(from: endComponents) ?? now

        return TimeRange(start: start, end: end)
    }
}

// MARK: - Mock Data Extension
extension DetailedHoroscope {
    static var mock: DetailedHoroscope {
        DetailedHoroscope(
            date: Date(),
            greeting: "Доброе утро! Сегодня особенный день для вас.",
            generalForecast: """
            Венера в вашем 7-м доме создает благоприятную атмосферу для отношений. Это отличное время, чтобы провести вечер с любимым человеком или наладить контакт с кем-то важным. Вы будете чувствовать себя особенно привлекательно и харизматично.

            Марс поддерживает ваши карьерные амбиции. Если вы давно думали о разговоре с руководством или о запуске нового проекта — действуйте сегодня. Энергия на вашей стороне.

            Луна в Деве помогает навести порядок в делах и завершить начатое. Используйте это время для систематизации и планирования.
            """,
            careerAndFinances: "Сегодня отличный день для переговоров и важных встреч. Ваши идеи будут услышаны. Избегайте импульсивных финансовых решений после 18:00.",
            loveAndRelationships: "Романтическая энергия на пике. Идеально для свидания или откровенного разговора. Партнер будет особенно внимателен к вашим словам.",
            healthAndEnergy: "Высокий уровень энергии до обеда. Планируйте важные дела на первую половину дня. Вечером позвольте себе отдохнуть.",
            friendsAndSocial: "Хороший день для знакомств. Кто-то из старых друзей может выйти на связь. Будьте открыты новым предложениям.",
            todoList: [
                "Назначьте важную встречу на утро",
                "Проведите время с партнером вечером",
                "Займитесь творческим проектом",
                "Позвоните старому другу"
            ],
            avoidList: [
                "Импульсивных покупок после 18:00",
                "Конфликтов с коллегами",
                "Серьезных финансовых решений в спешке"
            ],
            bestTimeRanges: [
                .create(startHour: 9, endHour: 12),
                .create(startHour: 19, endHour: 21)
            ],
            luckyColors: ["Зеленый", "Золотой"],
            luckyNumber: 7
        )
    }
}
