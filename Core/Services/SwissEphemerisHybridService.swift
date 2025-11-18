// Core/Services/SwissEphemerisHybridService.swift
import Foundation

/// Hybrid Swiss Ephemeris Service
/// Uses real Swiss Ephemeris library when available, falls back to simplified calculations
@MainActor
class SwissEphemerisHybridService: AstrologyServiceProtocol {

    private let useRealEphemeris: Bool
    private let realWrapper: SwissEphemerisRealWrapper?
    private let simplifiedService: SwissEphemerisService

    init() {
        // Check if real Swiss Ephemeris is available
        #if SWISS_EPHEMERIS_AVAILABLE
        self.useRealEphemeris = true
        self.realWrapper = SwissEphemerisRealWrapper.shared
        print("✅ SwissEphemeris: Using REAL astronomical calculations")
        #else
        self.useRealEphemeris = false
        self.realWrapper = nil
        print("⚠️  SwissEphemeris: Using SIMPLIFIED calculations (for MVP)")
        print("    To enable real calculations, integrate Swiss Ephemeris C library")
        print("    See: SWISS_EPHEMERIS_INTEGRATION.md")
        #endif

        self.simplifiedService = SwissEphemerisService()
    }

    // MARK: - AstrologyServiceProtocol Implementation

    func calculateBirthChart(from birthData: BirthData) async throws -> BirthChart {
        #if SWISS_EPHEMERIS_AVAILABLE
        if useRealEphemeris, let wrapper = realWrapper {
            return try await calculateBirthChartReal(from: birthData, using: wrapper)
        }
        #endif

        // Fallback to simplified calculations
        return try await simplifiedService.calculateBirthChart(from: birthData)
    }

    func generateDailyHoroscope(for sunSign: ZodiacSign, date: Date = Date()) async throws -> DailyHoroscope {
        // Horoscope generation doesn't depend on ephemeris precision
        return try await simplifiedService.generateDailyHoroscope(for: sunSign, date: date)
    }

    func calculateCompatibility(chart1: BirthChart, chart2: BirthChart) async throws -> CompatibilityResult {
        // Compatibility calculation works with existing charts
        return try await simplifiedService.calculateCompatibility(chart1: chart1, chart2: chart2)
    }

    func getCurrentTransits() async throws -> [DailyTransit] {
        #if SWISS_EPHEMERIS_AVAILABLE
        if useRealEphemeris, let wrapper = realWrapper {
            return try await calculateTransitsReal(using: wrapper)
        }
        #endif

        return try await simplifiedService.getCurrentTransits()
    }

    // MARK: - Real Swiss Ephemeris Calculations

    #if SWISS_EPHEMERIS_AVAILABLE
    private func calculateBirthChartReal(
        from birthData: BirthData,
        using wrapper: SwissEphemerisRealWrapper
    ) async throws -> BirthChart {
        let julianDay = wrapper.dateToJulianDay(date: birthData.date, timeZone: birthData.timeZone)

        print("📊 Calculating chart with REAL Swiss Ephemeris")
        print("   Julian Day: \(julianDay)")
        print("   Location: \(birthData.latitude)°, \(birthData.longitude)°")

        // Calculate planets
        let planetPositions = try await wrapper.calculateAllPlanets(julianDay: julianDay)
        let planets = convertToPlanets(planetPositions)

        // Calculate houses
        let houseData = try await wrapper.calculateHouses(
            julianDay: julianDay,
            latitude: birthData.latitude,
            longitude: birthData.longitude,
            houseSystem: .placidus
        )
        let houses = convertToHouses(houseData)

        // Calculate aspects
        let aspects = calculateAspects(from: planets)

        return BirthChart(
            id: UUID().uuidString,
            userId: "user",
            name: "Birth Chart",
            birthDate: birthData.date,
            birthTime: formatTime(birthData.date),
            location: "\(birthData.cityName), \(birthData.countryName)",
            latitude: birthData.latitude,
            longitude: birthData.longitude,
            planets: planets,
            houses: houses,
            aspects: aspects,
            calculatedAt: Date()
        )
    }

    private func calculateTransitsReal(using wrapper: SwissEphemerisRealWrapper) async throws -> [DailyTransit] {
        let now = Date()
        let julianDay = wrapper.dateToJulianDay(date: now, timeZone: .current)

        let planetPositions = try await wrapper.calculateAllPlanets(julianDay: julianDay)

        var transits: [DailyTransit] = []

        for (planetType, position) in planetPositions {
            let transit = DailyTransit(
                planet: planetType.name,
                sign: position.zodiacSign.displayName,
                degree: Int(position.degreeInSign),
                influence: generateInfluence(for: planetType, in: position.zodiacSign),
                isRetrograde: position.isRetrograde
            )
            transits.append(transit)
        }

        return transits.sorted { $0.planet < $1.planet }
    }

    // MARK: - Conversion Helpers

    private func convertToPlanets(_ positions: [PlanetType: PlanetPosition]) -> [Planet] {
        var planets: [Planet] = []

        for (planetType, position) in positions {
            let planet = Planet(
                name: planetType.name,
                longitude: position.longitude,
                latitude: position.latitude,
                speed: position.longitudeSpeed,
                sign: position.zodiacSign.rawValue,
                degree: position.degreeInSign,
                isRetrograde: position.isRetrograde
            )
            planets.append(planet)
        }

        return planets.sorted { $0.name < $1.name }
    }

    private func convertToHouses(_ houseData: HouseData) -> [House] {
        var houses: [House] = []

        for (index, cusp) in houseData.cusps.enumerated() {
            let houseNumber = index + 1
            let sign = zodiacSignFromLongitude(cusp)

            let house = House(
                number: houseNumber,
                cusp: cusp,
                sign: sign.rawValue,
                degree: cusp.truncatingRemainder(dividingBy: 30)
            )
            houses.append(house)
        }

        return houses
    }

    private func calculateAspects(from planets: [Planet]) -> [Aspect] {
        var aspects: [Aspect] = []

        // Major aspects with orbs
        let aspectTypes: [(type: String, angle: Double, orb: Double)] = [
            ("Conjunction", 0, 8),
            ("Sextile", 60, 6),
            ("Square", 90, 8),
            ("Trine", 120, 8),
            ("Opposition", 180, 8)
        ]

        for i in 0..<planets.count {
            for j in (i+1)..<planets.count {
                let planet1 = planets[i]
                let planet2 = planets[j]
                let angle = abs(planet1.longitude - planet2.longitude)

                for aspectType in aspectTypes {
                    let diff = min(abs(angle - aspectType.angle), abs(360 - angle - aspectType.angle))

                    if diff <= aspectType.orb {
                        let aspect = Aspect(
                            planet1: planet1.name,
                            planet2: planet2.name,
                            type: aspectType.type,
                            angle: diff,
                            orb: aspectType.orb
                        )
                        aspects.append(aspect)
                    }
                }
            }
        }

        return aspects
    }

    private func generateInfluence(for planet: PlanetType, in sign: ZodiacSign) -> String {
        // Simplified influence based on planet-sign relationship
        switch planet {
        case .sun:
            return "Основная жизненная энергия в \(sign.displayName)"
        case .moon:
            return "Эмоциональное состояние под влиянием \(sign.displayName)"
        case .mercury:
            return "Мышление и коммуникация в стиле \(sign.displayName)"
        case .venus:
            return "Любовь и отношения окрашены \(sign.displayName)"
        case .mars:
            return "Действия и энергия в духе \(sign.displayName)"
        default:
            return "Транзит через \(sign.displayName)"
        }
    }

    private func zodiacSignFromLongitude(_ longitude: Double) -> ZodiacSign {
        let normalized = longitude.truncatingRemainder(dividingBy: 360)
        let index = Int(normalized / 30)
        let signs: [ZodiacSign] = [
            .aries, .taurus, .gemini, .cancer, .leo, .virgo,
            .libra, .scorpio, .sagittarius, .capricorn, .aquarius, .pisces
        ]
        return signs[index % 12]
    }

    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    #endif
}

// MARK: - PlanetType Extension

extension PlanetType {
    var name: String {
        switch self {
        case .sun: return "Sun"
        case .moon: return "Moon"
        case .mercury: return "Mercury"
        case .venus: return "Venus"
        case .mars: return "Mars"
        case .jupiter: return "Jupiter"
        case .saturn: return "Saturn"
        case .uranus: return "Uranus"
        case .neptune: return "Neptune"
        case .pluto: return "Pluto"
        case .northNode: return "North Node"
        case .southNode: return "South Node"
        case .chiron: return "Chiron"
        }
    }
}
