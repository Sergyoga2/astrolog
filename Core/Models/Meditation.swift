import Foundation

/// Meditation session model
struct Meditation: Identifiable, Codable, Hashable {
    let id: String
    let title: String
    let description: String
    let duration: TimeInterval  // in seconds
    let category: MeditationCategory
    let audioURL: String  // Firebase Storage URL or local file
    let imageURL: String?  // Cover image
    let zodiacSign: String?  // Associated zodiac sign (optional)
    let benefits: [String]
    let level: MeditationLevel
    let isPremium: Bool

    // Playback metadata
    var playCount: Int
    var lastPlayedAt: Date?
    var isFavorite: Bool

    init(
        id: String = UUID().uuidString,
        title: String,
        description: String,
        duration: TimeInterval,
        category: MeditationCategory,
        audioURL: String,
        imageURL: String? = nil,
        zodiacSign: String? = nil,
        benefits: [String] = [],
        level: MeditationLevel = .beginner,
        isPremium: Bool = false,
        playCount: Int = 0,
        lastPlayedAt: Date? = nil,
        isFavorite: Bool = false
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.duration = duration
        self.category = category
        self.audioURL = audioURL
        self.imageURL = imageURL
        self.zodiacSign = zodiacSign
        self.benefits = benefits
        self.level = level
        self.isPremium = isPremium
        self.playCount = playCount
        self.lastPlayedAt = lastPlayedAt
        self.isFavorite = isFavorite
    }

    var durationFormatted: String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

// MARK: - Meditation Category

enum MeditationCategory: String, Codable, CaseIterable {
    case chakra = "Чакры"
    case sleep = "Сон"
    case stress = "Стресс"
    case focus = "Фокус"
    case healing = "Исцеление"
    case astrology = "Астрология"
    case moonPhases = "Фазы Луны"
    case planetary = "Планетарные"

    var icon: String {
        switch self {
        case .chakra:
            return "sparkles"
        case .sleep:
            return "moon.zzz"
        case .stress:
            return "leaf"
        case .focus:
            return "brain.head.profile"
        case .healing:
            return "heart.fill"
        case .astrology:
            return "star.circle"
        case .moonPhases:
            return "moon.stars"
        case .planetary:
            return "globe"
        }
    }
}

// MARK: - Meditation Level

enum MeditationLevel: String, Codable {
    case beginner = "Начинающий"
    case intermediate = "Средний"
    case advanced = "Продвинутый"
}

// MARK: - Meditation Progress

struct MeditationProgress: Identifiable, Codable {
    let id: String
    let userId: String
    let meditationId: String
    var completedSessions: Int
    var totalDuration: TimeInterval  // total time spent
    var streak: Int  // consecutive days
    var lastSessionDate: Date

    init(
        id: String = UUID().uuidString,
        userId: String,
        meditationId: String,
        completedSessions: Int = 0,
        totalDuration: TimeInterval = 0,
        streak: Int = 0,
        lastSessionDate: Date = Date()
    ) {
        self.id = id
        self.userId = userId
        self.meditationId = meditationId
        self.completedSessions = completedSessions
        self.totalDuration = totalDuration
        self.streak = streak
        self.lastSessionDate = lastSessionDate
    }
}

// MARK: - Firestore Extensions

extension Meditation {
    func toDictionary() -> [String: Any] {
        var dict: [String: Any] = [
            "id": id,
            "title": title,
            "description": description,
            "duration": duration,
            "category": category.rawValue,
            "audioURL": audioURL,
            "benefits": benefits,
            "level": level.rawValue,
            "isPremium": isPremium,
            "playCount": playCount,
            "isFavorite": isFavorite
        ]

        if let imageURL = imageURL {
            dict["imageURL"] = imageURL
        }

        if let zodiacSign = zodiacSign {
            dict["zodiacSign"] = zodiacSign
        }

        if let lastPlayed = lastPlayedAt {
            dict["lastPlayedAt"] = lastPlayed
        }

        return dict
    }

    static func fromDictionary(_ dict: [String: Any]) -> Meditation? {
        guard let id = dict["id"] as? String,
              let title = dict["title"] as? String,
              let description = dict["description"] as? String,
              let duration = dict["duration"] as? TimeInterval,
              let categoryString = dict["category"] as? String,
              let category = MeditationCategory(rawValue: categoryString),
              let audioURL = dict["audioURL"] as? String,
              let levelString = dict["level"] as? String,
              let level = MeditationLevel(rawValue: levelString) else {
            return nil
        }

        let benefits = dict["benefits"] as? [String] ?? []
        let isPremium = dict["isPremium"] as? Bool ?? false
        let playCount = dict["playCount"] as? Int ?? 0
        let isFavorite = dict["isFavorite"] as? Bool ?? false

        let lastPlayedAt: Date?
        if let timestamp = dict["lastPlayedAt"] as? Date {
            lastPlayedAt = timestamp
        } else {
            lastPlayedAt = nil
        }

        return Meditation(
            id: id,
            title: title,
            description: description,
            duration: duration,
            category: category,
            audioURL: audioURL,
            imageURL: dict["imageURL"] as? String,
            zodiacSign: dict["zodiacSign"] as? String,
            benefits: benefits,
            level: level,
            isPremium: isPremium,
            playCount: playCount,
            lastPlayedAt: lastPlayedAt,
            isFavorite: isFavorite
        )
    }
}

extension MeditationProgress {
    func toDictionary() -> [String: Any] {
        return [
            "id": id,
            "userId": userId,
            "meditationId": meditationId,
            "completedSessions": completedSessions,
            "totalDuration": totalDuration,
            "streak": streak,
            "lastSessionDate": lastSessionDate
        ]
    }

    static func fromDictionary(_ dict: [String: Any]) -> MeditationProgress? {
        guard let id = dict["id"] as? String,
              let userId = dict["userId"] as? String,
              let meditationId = dict["meditationId"] as? String else {
            return nil
        }

        let completedSessions = dict["completedSessions"] as? Int ?? 0
        let totalDuration = dict["totalDuration"] as? TimeInterval ?? 0
        let streak = dict["streak"] as? Int ?? 0

        let lastSessionDate: Date
        if let timestamp = dict["lastSessionDate"] as? Date {
            lastSessionDate = timestamp
        } else {
            lastSessionDate = Date()
        }

        return MeditationProgress(
            id: id,
            userId: userId,
            meditationId: meditationId,
            completedSessions: completedSessions,
            totalDuration: totalDuration,
            streak: streak,
            lastSessionDate: lastSessionDate
        )
    }
}
