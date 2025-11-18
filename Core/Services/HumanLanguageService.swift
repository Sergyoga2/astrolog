//
//  HumanLanguageService.swift
//  Astrolog
//
//  Created by Claude on 26.10.2025.
//

// Core/Services/HumanLanguageService.swift
import Foundation
import SwiftUI
import Combine

/// Сервис для перевода астрологических терминов в понятный человеческий язык
/// Основная задача: сделать астрологию доступной для новичков
class HumanLanguageService: ObservableObject {

    /// Переводит планету в человеческий язык
    func translatePlanet(_ planet: PlanetType) -> PlanetTranslation {
        switch planet {
        case .sun:
            return PlanetTranslation(
                humanName: "Ваша суть",
                emoji: "☀️",
                simpleDescription: "То, кем вы являетесь в глубине души",
                roleDescription: "Основа личности",
                keywords: ["индивидуальность", "творчество", "энергия"],
                color: .starYellow
            )

        case .moon:
            return PlanetTranslation(
                humanName: "Ваши эмоции",
                emoji: "🌙",
                simpleDescription: "Как вы чувствуете и что вам нужно для счастья",
                roleDescription: "Внутренний мир",
                keywords: ["чувства", "интуиция", "потребности"],
                color: .waterElement
            )

        case .ascendant:
            return PlanetTranslation(
                humanName: "Ваша подача",
                emoji: "🎭",
                simpleDescription: "Как вас видят и воспринимают другие люди",
                roleDescription: "Внешняя маска",
                keywords: ["первое впечатление", "стиль", "подход"],
                color: .airElement
            )

        case .mercury:
            return PlanetTranslation(
                humanName: "Ваше мышление",
                emoji: "🧠",
                simpleDescription: "Как вы думаете, учитесь и общаетесь",
                roleDescription: "Ум и речь",
                keywords: ["мысли", "общение", "обучение"],
                color: .neonCyan
            )

        case .venus:
            return PlanetTranslation(
                humanName: "Ваши отношения",
                emoji: "💕",
                simpleDescription: "Что вы любите и как строите отношения",
                roleDescription: "Любовь и красота",
                keywords: ["любовь", "красота", "ценности"],
                color: .neonPink
            )

        case .mars:
            return PlanetTranslation(
                humanName: "Ваша энергия",
                emoji: "🔥",
                simpleDescription: "Что вас мотивирует и как вы действуете",
                roleDescription: "Драйв и действие",
                keywords: ["мотивация", "энергия", "страсть"],
                color: .fireElement
            )

        default:
            return PlanetTranslation(
                humanName: planet.displayName,
                emoji: "⭐",
                simpleDescription: "Влияет на вашу личность",
                roleDescription: "Планетарное влияние",
                keywords: ["влияние"],
                color: .cosmicViolet
            )
        }
    }

    /// Переводит знак зодиака в человеческий язык
    func translateZodiacSign(_ sign: ZodiacSign) -> ZodiacTranslation {
        switch sign {
        case .aries:
            return ZodiacTranslation(
                humanName: "Энергичный первопроходец",
                emoji: "🔥",
                personality: "Вы полны энергии и любите быть первым во всем",
                strengths: ["инициативность", "смелость", "энтузиазм"],
                challenges: ["нетерпеливость", "импульсивность"],
                description: "Прирожденный лидер, который не боится новых начинаний"
            )

        case .taurus:
            return ZodiacTranslation(
                humanName: "Стабильный и надежный",
                emoji: "🌱",
                personality: "Вы цените комфорт, стабильность и красоту",
                strengths: ["надежность", "терпеливость", "практичность"],
                challenges: ["упрямство", "сопротивление переменам"],
                description: "Человек, на которого всегда можно положиться"
            )

        case .gemini:
            return ZodiacTranslation(
                humanName: "Любознательный коммуникатор",
                emoji: "💨",
                personality: "Вы любопытны, общительны и всегда в движении",
                strengths: ["адаптивность", "коммуникабельность", "остроумие"],
                challenges: ["поверхностность", "нерешительность"],
                description: "Мастер общения с живым и гибким умом"
            )

        case .cancer:
            return ZodiacTranslation(
                humanName: "Заботливый и чувственный",
                emoji: "🦀",
                personality: "Вы глубоко чувствуете и заботитесь о близких",
                strengths: ["эмпатия", "заботливость", "интуиция"],
                challenges: ["обидчивость", "переменчивость настроения"],
                description: "Человек с большим сердцем и сильной интуицией"
            )

        case .leo:
            return ZodiacTranslation(
                humanName: "Творческий и харизматичный",
                emoji: "🦁",
                personality: "Вы любите быть в центре внимания и вдохновлять других",
                strengths: ["креативность", "щедрость", "лидерство"],
                challenges: ["гордыня", "потребность в признании"],
                description: "Прирожденный артист с королевскими замашками"
            )

        case .virgo:
            return ZodiacTranslation(
                humanName: "Практичный и внимательный",
                emoji: "🌾",
                personality: "Вы обращаете внимание на детали и стремитесь к совершенству",
                strengths: ["аналитичность", "трудолюбие", "надежность"],
                challenges: ["критичность", "перфекционизм"],
                description: "Мастер организации с острым вниманием к деталям"
            )

        case .libra:
            return ZodiacTranslation(
                humanName: "Гармоничный и дипломатичный",
                emoji: "⚖️",
                personality: "Вы стремитесь к балансу, красоте и справедливости",
                strengths: ["дипломатичность", "чувство стиля", "справедливость"],
                challenges: ["нерешительность", "избегание конфликтов"],
                description: "Миротворец с изысканным вкусом"
            )

        case .scorpio:
            return ZodiacTranslation(
                humanName: "Глубокий и интенсивный",
                emoji: "🦂",
                personality: "Вы чувствуете все очень глубоко и обладаете сильной интуицией",
                strengths: ["проницательность", "страстность", "трансформация"],
                challenges: ["ревнивость", "скрытность"],
                description: "Человек глубин с мощной внутренней силой"
            )

        case .sagittarius:
            return ZodiacTranslation(
                humanName: "Свободный и оптимистичный",
                emoji: "🏹",
                personality: "Вы любите приключения и всегда смотрите на светлую сторону жизни",
                strengths: ["оптимизм", "широта взглядов", "честность"],
                challenges: ["нетактичность", "безответственность"],
                description: "Вечный путешественник и философ жизни"
            )

        case .capricorn:
            return ZodiacTranslation(
                humanName: "Целеустремленный и дисциплинированный",
                emoji: "🏔️",
                personality: "Вы ставите высокие цели и методично их достигаете",
                strengths: ["дисциплина", "амбициозность", "ответственность"],
                challenges: ["пессимизм", "чрезмерная серьезность"],
                description: "Строитель собственной судьбы с железной волей"
            )

        case .aquarius:
            return ZodiacTranslation(
                humanName: "Независимый и новаторский",
                emoji: "🌊",
                personality: "Вы цените свободу и всегда идете своим уникальным путем",
                strengths: ["оригинальность", "независимость", "гуманность"],
                challenges: ["отстраненность", "упрямство"],
                description: "Революционер мысли и защитник свободы"
            )

        case .pisces:
            return ZodiacTranslation(
                humanName: "Чувствительный и творческий",
                emoji: "🐟",
                personality: "Вы глубоко сочувствуете другим и видите мир через призму творчества",
                strengths: ["сочувствие", "креативность", "духовность"],
                challenges: ["излишняя чувствительность", "избегание реальности"],
                description: "Мечтатель с большим сердцем и богатым воображением"
            )
        }
    }

    /// Переводит комбинацию планеты в знаке в человеческую интерпретацию
    func translatePlanetInSign(_ planet: PlanetType, in sign: ZodiacSign) -> String {
        let planetTranslation = translatePlanet(planet)
        let signTranslation = translateZodiacSign(sign)

        switch planet {
        case .sun:
            return "Ваша основная энергия проявляется как \(signTranslation.personality.lowercased())"

        case .moon:
            return "Эмоционально вы \(signTranslation.personality.lowercased())"

        case .ascendant:
            return "Люди воспринимают вас как человека, который \(signTranslation.personality.lowercased())"

        case .mercury:
            return "Ваше мышление работает так: \(signTranslation.personality.lowercased())"

        case .venus:
            return "В любви и отношениях \(signTranslation.personality.lowercased())"

        case .mars:
            return "Ваша мотивация: \(signTranslation.personality.lowercased())"

        default:
            return "\(planetTranslation.humanName) проявляется через то, что \(signTranslation.personality.lowercased())"
        }
    }

    /// Генерирует упрощенное описание для большой тройки
    func generateBigThreeDescription(sun: Planet?, moon: Planet?, ascendant: Planet?) -> String {
        var parts: [String] = []

        if let sun = sun {
            let sunDesc = translateZodiacSign(sun.zodiacSign)
            parts.append("В основе вы \(sunDesc.humanName.lowercased())")
        }

        if let moon = moon {
            let moonDesc = translateZodiacSign(moon.zodiacSign)
            parts.append("эмоционально \(moonDesc.humanName.lowercased())")
        }

        if let ascendant = ascendant {
            let ascDesc = translateZodiacSign(ascendant.zodiacSign)
            parts.append("а людям кажетесь \(ascDesc.humanName.lowercased())")
        }

        return parts.joined(separator: ", ") + "."
    }

    /// Переводит астрологический термин в человеческий аналог
    func humanizeAstroTerm(_ term: String) -> String {
        let translations: [String: String] = [
            // Планеты
            "Солнце": "ваша суть",
            "Луна": "ваши эмоции",
            "Меркурий": "ваше мышление",
            "Венера": "ваши отношения",
            "Марс": "ваша энергия",
            "Юпитер": "ваш рост",
            "Сатурн": "ваши уроки",
            "Асцендент": "ваша подача",

            // Знаки (краткие версии)
            "Овен": "энергичный лидер",
            "Телец": "стабильный и надежный",
            "Близнецы": "любознательный коммуникатор",
            "Рак": "заботливый и чувственный",
            "Лев": "творческий и харизматичный",
            "Дева": "практичный и внимательный",
            "Весы": "гармоничный и дипломатичный",
            "Скорпион": "глубокий и интенсивный",
            "Стрелец": "свободный и оптимистичный",
            "Козерог": "целеустремленный",
            "Водолей": "независимый и новаторский",
            "Рыбы": "чувствительный и творческий",

            // Общие термины
            "натальная карта": "космический отпечаток момента вашего рождения",
            "планета": "космическое влияние",
            "знак зодиака": "энергетический тип",
            "дом": "сфера жизни",
            "аспект": "взаимодействие энергий",
            "транзит": "текущее космическое влияние",
            "соединение": "усиление энергии",
            "оппозиция": "внутреннее напряжение",
            "тригон": "гармоничный поток",
            "квадратура": "вызов для роста"
        ]

        return translations[term] ?? term.lowercased()
    }
}

// MARK: - Supporting Models

/// Перевод планеты в человеческий язык
struct PlanetTranslation {
    let humanName: String
    let emoji: String
    let simpleDescription: String
    let roleDescription: String
    let keywords: [String]
    let color: Color
}

/// Перевод знака зодиака в человеческий язык
struct ZodiacTranslation {
    let humanName: String
    let emoji: String
    let personality: String
    let strengths: [String]
    let challenges: [String]
    let description: String
}

// MARK: - Extension для использования в Views

extension HumanLanguageService {

    /// Быстрый перевод планеты для UI
    func planetEmoji(_ planet: PlanetType) -> String {
        return translatePlanet(planet).emoji
    }

    /// Быстрое человеческое имя планеты
    func planetHumanName(_ planet: PlanetType) -> String {
        return translatePlanet(planet).humanName
    }

    /// Быстрый перевод знака для UI
    func signEmoji(_ sign: ZodiacSign) -> String {
        return translateZodiacSign(sign).emoji
    }

    /// Быстрое человеческое имя знака
    func signHumanName(_ sign: ZodiacSign) -> String {
        return translateZodiacSign(sign).humanName
    }

    /// Генерирует простую интерпретацию для новичков
    func generateSimpleInterpretation(for planet: Planet) -> String {
        let planetTrans = translatePlanet(planet.type)
        let signTrans = translateZodiacSign(planet.zodiacSign)

        return "\(planetTrans.emoji) \(planetTrans.humanName): \(signTrans.personality)"
    }

    /// Создает мотивационное сообщение на основе планеты
    func generateMotivationalMessage(for planet: Planet) -> String {
        let signTrans = translateZodiacSign(planet.zodiacSign)

        switch planet.type {
        case .sun:
            return "Ваша сила в том, что \(signTrans.personality.lowercased()). Используйте это!"
        case .moon:
            return "Доверьтесь своим чувствам - \(signTrans.personality.lowercased())"
        case .ascendant:
            return "Людям нравится, что \(signTrans.personality.lowercased())"
        default:
            return signTrans.description
        }
    }
}

/// Глобальный экземпляр сервиса
let humanLanguageService = HumanLanguageService()