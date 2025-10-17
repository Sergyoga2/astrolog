// Core/Services/SwissEphemerisService.swift
import Foundation

class SwissEphemerisService: AstrologyServiceProtocol {
    
    init() {
        print("SwissEphemeris service initialized with simplified calculations")
    }
    
    func calculateBirthChart(from birthData: BirthData) async throws -> BirthChart {
        return try await withCheckedThrowingContinuation { continuation in
            Task.detached {
                do {
                    let chart = try self.performChartCalculation(birthData: birthData)
                    continuation.resume(returning: chart)
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    func generateDailyHoroscope(for sunSign: ZodiacSign, date: Date = Date()) async throws -> DailyHoroscope {
        return try await EnhancedMockAstrologyService().generateDailyHoroscope(for: sunSign, date: date)
    }
    
    func calculateCompatibility(chart1: BirthChart, chart2: BirthChart) async throws -> CompatibilityResult {
        return try await withCheckedThrowingContinuation { continuation in
            Task.detached {
                do {
                    let compatibility = try self.performCompatibilityCalculation(chart1: chart1, chart2: chart2)
                    continuation.resume(returning: compatibility)
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    func getCurrentTransits() async throws -> [Transit] {
        return try await withCheckedThrowingContinuation { continuation in
            Task.detached {
                do {
                    let transits = try self.calculateCurrentTransits()
                    continuation.resume(returning: transits)
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    // MARK: - Private Calculation Methods
    
    private func performChartCalculation(birthData: BirthData) throws -> BirthChart {
        let julianDay = calculateJulianDay(from: birthData.date, timeZone: birthData.timeZone)
        
        print("Calculating chart for Julian Day: \(julianDay)")
        print("Birth location: \(birthData.latitude), \(birthData.longitude)")
        
        let planets = try calculatePlanets(julianDay: julianDay, birthData: birthData)
        let houses = try calculateHouses(julianDay: julianDay, birthData: birthData)
        let aspects = calculateAspects(from: planets)
        
        return BirthChart(
            userId: "user_123",
            name: "Swiss Ephemeris Chart",
            birthDate: birthData.date,
            birthTime: DateFormatter.localizedString(from: birthData.date, dateStyle: .none, timeStyle: .short),
            location: "\(birthData.cityName), \(birthData.countryName)",
            latitude: birthData.latitude,
            longitude: birthData.longitude,
            planets: planets,
            houses: houses,
            aspects: aspects
        )
    }
    
    private func calculateJulianDay(from date: Date, timeZone: TimeZone) -> Double {
        let utcDate = date.addingTimeInterval(-Double(timeZone.secondsFromGMT(for: date)))
        
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: utcDate)
        
        let year = Int32(components.year ?? 2000)
        let month = Int32(components.month ?? 1)
        let day = Int32(components.day ?? 1)
        let hour = Double(components.hour ?? 12)
        let minute = Double(components.minute ?? 0)
        let second = Double(components.second ?? 0)
        
        let totalHours = hour + minute/60.0 + second/3600.0
        let julianDay = SwissEphemerisWrapper.julianDay(year: year, month: month, day: day, hour: totalHours)
        
        return julianDay
    }
    
    private func calculatePlanets(julianDay: Double, birthData: BirthData) throws -> [Planet] {
        var planets: [Planet] = []
        
        let planetaryBodies: [(PlanetType, Int32)] = [
            (.sun, SE_SUN),
            (.moon, SE_MOON),
            (.mercury, SE_MERCURY),
            (.venus, SE_VENUS),
            (.mars, SE_MARS),
            (.jupiter, SE_JUPITER),
            (.saturn, SE_SATURN),
            (.uranus, SE_URANUS),
            (.neptune, SE_NEPTUNE),
            (.pluto, SE_PLUTO)
        ]
        
        for (planetType, seCode) in planetaryBodies {
            let result = SwissEphemerisWrapper.calculatePlanetPosition(julianDay: julianDay, planet: seCode)
            
            let longitude = result.longitude
            let zodiacSign = ZodiacSign(rawValue: Int(longitude / 30)) ?? .aries
            let house = calculateHousePosition(longitude: longitude, birthData: birthData, julianDay: julianDay)
            let isRetrograde = result.isRetrograde
            
            let planet = Planet(
                type: planetType,
                longitude: longitude,
                zodiacSign: zodiacSign,
                house: house,
                isRetrograde: isRetrograde
            )
            
            planets.append(planet)
            
            // ИСПРАВЛЕНО: убираем specifier из print
            print("\(planetType.displayName): \(String(format: "%.2f", longitude))° in \(zodiacSign.displayName), House \(house), Retrograde: \(isRetrograde)")
        }
        
        let ascendantAndMC = try calculateAscendantAndMC(julianDay: julianDay, birthData: birthData)
        planets.append(contentsOf: ascendantAndMC)
        
        return planets
    }
    
    private func calculateHousePosition(longitude: Double, birthData: BirthData, julianDay: Double) -> Int {
        let houseData = SwissEphemerisWrapper.calculateHouses(julianDay: julianDay, latitude: birthData.latitude, longitude: birthData.longitude)
        let ascendant = houseData.ascendant
        
        let relativeLongitude = (longitude - ascendant + 360).truncatingRemainder(dividingBy: 360)
        return Int(relativeLongitude / 30) + 1
    }
    
    private func calculateAscendantAndMC(julianDay: Double, birthData: BirthData) throws -> [Planet] {
        let houseData = SwissEphemerisWrapper.calculateHouses(julianDay: julianDay, latitude: birthData.latitude, longitude: birthData.longitude)
        
        let ascendantLongitude = houseData.ascendant
        let ascendantSign = ZodiacSign(rawValue: Int(ascendantLongitude / 30)) ?? .aries
        let ascendant = Planet(
            type: .ascendant,
            longitude: ascendantLongitude,
            zodiacSign: ascendantSign,
            house: 1,
            isRetrograde: false
        )
        
        let mcLongitude = houseData.midheaven
        let mcSign = ZodiacSign(rawValue: Int(mcLongitude / 30)) ?? .aries
        let midheaven = Planet(
            type: .midheaven,
            longitude: mcLongitude,
            zodiacSign: mcSign,
            house: 10,
            isRetrograde: false
        )
        
        // ИСПРАВЛЕНО: убираем specifier из print
        print("Ascendant: \(String(format: "%.2f", ascendantLongitude))° in \(ascendantSign.displayName)")
        print("Midheaven: \(String(format: "%.2f", mcLongitude))° in \(mcSign.displayName)")
        
        return [ascendant, midheaven]
    }
    
    private func calculateHouses(julianDay: Double, birthData: BirthData) throws -> [House] {
        let houseData = SwissEphemerisWrapper.calculateHouses(julianDay: julianDay, latitude: birthData.latitude, longitude: birthData.longitude)
        
        var houseObjects: [House] = []
        
        for (index, cuspLongitude) in houseData.houses.enumerated() {
            let houseNumber = index + 1
            let zodiacSign = ZodiacSign(rawValue: Int(cuspLongitude / 30)) ?? .aries
            
            let house = House(
                number: houseNumber,
                cuspLongitude: cuspLongitude,
                zodiacSign: zodiacSign,
                planetsInHouse: []
            )
            
            houseObjects.append(house)
        }
        
        return houseObjects
    }
    
    private func calculateAspects(from planets: [Planet]) -> [Aspect] {
        var aspects: [Aspect] = []
        
        let majorPlanets = planets.filter { planet in
            [.sun, .moon, .mercury, .venus, .mars, .jupiter, .saturn, .ascendant, .midheaven].contains(planet.type)
        }
        
        for i in 0..<majorPlanets.count {
            for j in (i+1)..<majorPlanets.count {
                let planet1 = majorPlanets[i]
                let planet2 = majorPlanets[j]
                
                if let (aspectType, orb) = calculateAspectType(between: planet1.longitude, and: planet2.longitude) {
                    let aspect = Aspect(
                        planet1: planet1.type,
                        planet2: planet2.type,
                        type: aspectType,
                        orb: orb,
                        isApplying: true
                    )
                    
                    aspects.append(aspect)
                    // ИСПРАВЛЕНО: убираем specifier из print
                    print("Aspect: \(planet1.type.symbol) \(aspectType.symbol) \(planet2.type.symbol) (orb: \(String(format: "%.1f", orb))°)")
                }
            }
        }
        
        return aspects
    }
    
    private func calculateAspectType(between longitude1: Double, and longitude2: Double) -> (AspectType, Double)? {
        let difference = abs(longitude1 - longitude2)
        let angle = min(difference, 360 - difference)
        
        let aspectTypes: [(AspectType, Double, Double)] = [
            (.conjunction, 0, 8),
            (.sextile, 60, 6),
            (.square, 90, 8),
            (.trine, 120, 8),
            (.opposition, 180, 8)
        ]
        
        for (aspectType, targetAngle, maxOrb) in aspectTypes {
            let orb = abs(angle - targetAngle)
            if orb <= maxOrb {
                return (aspectType, orb)
            }
        }
        
        return nil
    }
    
    private func performCompatibilityCalculation(chart1: BirthChart, chart2: BirthChart) throws -> CompatibilityResult {
        var totalScore = 0.0
        var aspectCount = 0
        
        for planet1 in chart1.planets {
            for planet2 in chart2.planets {
                if let (aspectType, _) = calculateAspectType(between: planet1.longitude, and: planet2.longitude) {
                    let score = getAspectScore(aspectType, planet1: planet1.type, planet2: planet2.type)
                    totalScore += score
                    aspectCount += 1
                }
            }
        }
        
        let averageScore = aspectCount > 0 ? totalScore / Double(aspectCount) : 50.0
        let normalizedScore = max(0, min(100, averageScore))
        
        return CompatibilityResult(
            chart1UserId: chart1.userId,
            chart2UserId: chart2.userId,
            overallScore: normalizedScore,
            categories: CompatibilityCategories(
                communication: max(0, min(100, normalizedScore + Double.random(in: -10...10))),
                emotional: max(0, min(100, normalizedScore + Double.random(in: -10...10))),
                intellectual: max(0, min(100, normalizedScore + Double.random(in: -10...10))),
                physical: max(0, min(100, normalizedScore + Double.random(in: -10...10))),
                spiritual: max(0, min(100, normalizedScore + Double.random(in: -10...10)))
            ),
            strengths: ["Хорошее взаимопонимание", "Дополняете друг друга"],
            challenges: ["Иногда различия в приоритетах"],
            advice: "Работайте над пониманием различий друг друга."
        )
    }
    
    private func getAspectScore(_ aspectType: AspectType, planet1: PlanetType, planet2: PlanetType) -> Double {
        switch aspectType {
        case .conjunction: return 70
        case .trine: return 85
        case .sextile: return 75
        case .square: return 45
        case .opposition: return 40
        }
    }
    
    private func calculateCurrentTransits() throws -> [Transit] {
        return []
    }
    
    private func loadUserBirthData() -> BirthData? {
        guard let data = UserDefaults.standard.data(forKey: "user_birth_data"),
              let birthData = try? JSONDecoder().decode(BirthData.self, from: data) else {
            return nil
        }
        return birthData
    }
}

enum AstrologyError: Error {
    case missingBirthData
    case calculationError(String)
    case invalidDate
    case ephemerisError
}

extension AstrologyError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .missingBirthData:
            return "Данные рождения не найдены. Пожалуйста, добавьте их в профиле."
        case .calculationError(let message):
            return "Ошибка расчета: \(message)"
        case .invalidDate:
            return "Некорректная дата рождения"
        case .ephemerisError:
            return "Ошибка доступа к астрономическим данным"
        }
    }
}
