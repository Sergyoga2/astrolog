//
//  EnhancedMockAstrologyService.swift
//  Astrolog
//
//  Created by Sergey on 19.09.2025.
//
// Core/Services/EnhancedMockAstrologyService.swift
import Foundation
import Combine

class EnhancedMockAstrologyService: AstrologyServiceProtocol {
    
    func calculateBirthChart(from birthData: BirthData) async throws -> BirthChart {
        try await Task.sleep(nanoseconds: 2_000_000_000)
        
        let planets = generatePlanets(for: birthData)
        let houses = generateHouses()
        let aspects = generateAspects()
        
        return BirthChart(
            userId: "user_123",
            planets: planets,
            houses: houses,
            aspects: aspects
        )
    }
    
    func generateDailyHoroscope(for sunSign: ZodiacSign, date: Date = Date()) async throws -> DailyHoroscope {
        try await Task.sleep(nanoseconds: 1_500_000_000)
        
        let template = getHoroscope(for: sunSign)
        
        return DailyHoroscope(
            date: date,
            sunSign: sunSign,
            generalForecast: template.general,
            loveAndRelationships: template.love,
            careerAndFinances: template.career,
            healthAndEnergy: template.health,
            luckyNumbers: generateLuckyNumbers(),
            luckyColors: generateLuckyColors(for: sunSign),
            advice: template.advice
        )
    }
    
    func calculateCompatibility(chart1: BirthChart, chart2: BirthChart) async throws -> CompatibilityResult {
        try await Task.sleep(nanoseconds: 2_000_000_000)
        
        let baseScore = Double.random(in: 55...95)
        
        return CompatibilityResult(
            chart1UserId: chart1.userId,
            chart2UserId: chart2.userId,
            overallScore: baseScore,
            categories: CompatibilityCategories(
                communication: max(0, min(100, baseScore + Double.random(in: -15...15))),
                emotional: max(0, min(100, baseScore + Double.random(in: -10...10))),
                intellectual: max(0, min(100, baseScore + Double.random(in: -12...12))),
                physical: max(0, min(100, baseScore + Double.random(in: -8...8))),
                spiritual: max(0, min(100, baseScore + Double.random(in: -5...5)))
            ),
            strengths: [
                "Отличное взаимопонимание в общении",
                "Похожие жизненные ценности",
                "Дополняете друг друга эмоционально"
            ],
            challenges: [
                "Различия в подходе к финансам",
                "Иногда конкуренция в творчестве"
            ],
            advice: "Цените различия друг друга и находите компромиссы в спорных вопросах."
        )
    }
    
    func getCurrentTransits() async throws -> [Transit] {
        try await Task.sleep(nanoseconds: 1_000_000_000)
        
        return [
            Transit(
                planet: .venus,
                aspectType: .trine,
                natalPlanet: .sun,
                startDate: Date(),
                endDate: Calendar.current.date(byAdding: .day, value: 15, to: Date()) ?? Date(),
                description: "Венера образует тригон к вашему натальному Солнцу",
                influence: "Период гармонии в отношениях и творческого вдохновения"
            ),
            Transit(
                planet: .mars,
                aspectType: .square,
                natalPlanet: .mercury,
                startDate: Date(),
                endDate: Calendar.current.date(byAdding: .day, value: 7, to: Date()) ?? Date(),
                description: "Марс образует квадрат к вашему Меркурию",
                influence: "Возможны конфликты в общении, будьте осторожны с словами"
            )
        ]
    }
    
    // MARK: - Private Methods
    
    private func generatePlanets(for birthData: BirthData) -> [Planet] {
        var planets: [Planet] = []
        
        for planetType in PlanetType.allCases {
            let sign = getRandomSign()
            let house = Int.random(in: 1...12)
            let longitude = Double(sign.rawValue * 30) + Double.random(in: 0...30)
            
            let planet = Planet(
                type: planetType,
                longitude: longitude,
                zodiacSign: sign,
                house: house,
                isRetrograde: Bool.random()
            )
            planets.append(planet)
        }
        
        return planets
    }
    
    private func generateHouses() -> [House] {
        var houses: [House] = []
        
        for number in 1...12 {
            let house = House(
                number: number,
                cuspLongitude: Double((number - 1) * 30),
                zodiacSign: getRandomSign(),
                planetsInHouse: []
            )
            houses.append(house)
        }
        
        return houses
    }
    
    private func generateAspects() -> [Aspect] {
        let aspects: [Aspect] = [
            Aspect(
                planet1: .sun,
                planet2: .moon,
                type: .trine,
                orb: 3.2,
                isApplying: true
            ),
            Aspect(
                planet1: .venus,
                planet2: .mars,
                type: .conjunction,
                orb: 1.8,
                isApplying: false
            )
        ]
        
        return aspects
    }
    
    private func getRandomSign() -> ZodiacSign {
        return ZodiacSign.allCases.randomElement() ?? .aries
    }
    
    private func getHoroscope(for sign: ZodiacSign) -> (general: String, love: String, career: String, health: String, advice: String) {
        switch sign {
        case .aries:
            return (
                general: "Сегодня ваша энергия на пике. Отличный день для начала новых проектов.",
                love: "Страсть и инициатива в отношениях принесут результат.",
                career: "Время решительных действий и смелых решений.",
                health: "Высокий уровень энергии, но не забывайте о безопасности.",
                advice: "Действуйте, но не забывайте думать о последствиях."
            )
        case .taurus:
            return (
                general: "День стабильности и практичности. Сосредоточьтесь на материальных вопросах.",
                love: "В отношениях ценится надежность и постоянство.",
                career: "Хорошее время для финансового планирования.",
                health: "Обратите внимание на питание и физическую активность.",
                advice: "Терпение и упорство приведут к успеху."
            )
        case .gemini:
            return (
                general: "День общения и новой информации. Ваше любопытство будет вознаграждено.",
                love: "Интеллектуальная близость важнее физической.",
                career: "Отличное время для переговоров и презентаций.",
                health: "Следите за нервной системой, избегайте перенапряжения.",
                advice: "Будьте открыты к новым знакомствам и идеям."
            )
        case .cancer:
            return (
                general: "Интуиция подскажет правильный путь. Доверьтесь своим чувствам.",
                love: "Семья и близкие отношения в приоритете.",
                career: "Хороший день для работы в команде и заботы о коллегах.",
                health: "Обратите внимание на пищеварение и эмоциональное состояние.",
                advice: "Создайте уютную атмосферу вокруг себя."
            )
        case .leo:
            return (
                general: "Сегодня ваша харизма особенно сильна. Звезды благоволят творческим начинаниям.",
                love: "В отношениях период страсти и романтики. Не бойтесь проявлять чувства.",
                career: "Отличное время для презентаций и публичных выступлений.",
                health: "Энергия на высоком уровне, но не забывайте об отдыхе.",
                advice: "Доверьтесь своему сердцу и не бойтесь быть в центре внимания."
            )
        case .virgo:
            return (
                general: "День для детального анализа и планирования. Внимание к мелочам принесет успех.",
                love: "Практическая забота лучше громких слов.",
                career: "Идеальное время для организации и систематизации работы.",
                health: "Следите за режимом дня и правильным питанием.",
                advice: "Совершенство достигается в деталях."
            )
        case .libra:
            return (
                general: "День гармонии и справедливости. Стремитесь к балансу во всем.",
                love: "Романтика и красота украсят ваши отношения.",
                career: "Хорошее время для партнерства и сотрудничества.",
                health: "Займитесь эстетическими процедурами и релаксацией.",
                advice: "Ищите компромиссы и избегайте конфликтов."
            )
        case .scorpio:
            return (
                general: "Интенсивный день трансформаций. Глубокие изменения к лучшему.",
                love: "Страстность и глубина чувств определяют отношения.",
                career: "Время для важных решений и кардинальных перемен.",
                health: "Обратите внимание на восстановление и регенерацию.",
                advice: "Не бойтесь отпустить старое, чтобы принять новое."
            )
        case .sagittarius:
            return (
                general: "День приключений и новых горизонтов. Расширяйте свои границы.",
                love: "Свобода и искренность укрепляют отношения.",
                career: "Отличное время для обучения и развития навыков.",
                health: "Активный отдых на природе пойдет на пользу.",
                advice: "Следуйте за своими мечтами и не ограничивайте себя."
            )
        case .capricorn:
            return (
                general: "День амбиций и достижений. Упорный труд приносит результаты.",
                love: "Серьезные намерения и долгосрочные планы в отношениях.",
                career: "Время для карьерного роста и профессиональных достижений.",
                health: "Укрепляйте костную систему и суставы.",
                advice: "Терпение и дисциплина - ваши главные помощники."
            )
        case .aquarius:
            return (
                general: "День инноваций и оригинальности. Ваши необычные идеи найдут понимание.",
                love: "Дружба - основа крепких отношений.",
                career: "Хорошее время для работы с технологиями и в команде.",
                health: "Следите за кровообращением и нервной системой.",
                advice: "Будьте верны себе и не бойтесь выделяться."
            )
        case .pisces:
            return (
                general: "Интуитивный день, полный творчества и вдохновения.",
                love: "Эмпатия и понимание углубляют связь с партнером.",
                career: "Творческие проекты и работа с людьми принесут удовлетворение.",
                health: "Обратите внимание на ноги и лимфатическую систему.",
                advice: "Доверяйтесь интуиции и не забывайте о реальности."
            )
        }
    }
    
    private func generateLuckyNumbers() -> [Int] {
        return Array(1...49).shuffled().prefix(6).sorted()
    }
    
    private func generateLuckyColors(for sign: ZodiacSign) -> [String] {
        let colors = ["Красный", "Синий", "Зеленый", "Золотой", "Серебряный", "Фиолетовый"]
        return Array(colors.shuffled().prefix(3))
    }
}
