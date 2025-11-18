import Testing
import Foundation
@testable import Astrolog

@MainActor
struct SwissEphemerisServiceTests {
    let service = SwissEphemerisService()

    // MARK: - Planet Position Tests

    @Test func testCalculateSunPosition() async throws {
        // Test Sun position calculation for a known date
        let birthDate = Date(timeIntervalSince1970: 946684800) // 2000-01-01 00:00:00 UTC

        let positions = await service.calculatePlanetPositions(
            date: birthDate,
            latitude: 0,
            longitude: 0
        )

        #expect(positions.count > 0, "Should calculate planet positions")

        // Find Sun position
        let sunPosition = positions.first { $0.planet == .sun }
        #expect(sunPosition != nil, "Should calculate Sun position")

        if let sun = sunPosition {
            // Sun should be in Capricorn around Jan 1, 2000
            #expect(sun.longitude >= 0 && sun.longitude < 360, "Longitude should be valid (0-360)")
            #expect(sun.zodiacSign == .capricorn, "Sun should be in Capricorn on Jan 1")
        }
    }

    @Test func testCalculateMoonPosition() async throws {
        let birthDate = Date()

        let positions = await service.calculatePlanetPositions(
            date: birthDate,
            latitude: 51.5074, // London
            longitude: -0.1278
        )

        let moonPosition = positions.first { $0.planet == .moon }
        #expect(moonPosition != nil, "Should calculate Moon position")

        if let moon = moonPosition {
            #expect(moon.longitude >= 0 && moon.longitude < 360, "Moon longitude should be valid")
            #expect(moon.zodiacSign != nil, "Moon should have zodiac sign")
        }
    }

    @Test func testAllPlanetsCalculated() async throws {
        let birthDate = Date()

        let positions = await service.calculatePlanetPositions(
            date: birthDate,
            latitude: 40.7128, // New York
            longitude: -74.0060
        )

        // Should calculate at least the major planets
        let expectedPlanets: [Planet] = [.sun, .moon, .mercury, .venus, .mars, .jupiter, .saturn]

        for planet in expectedPlanets {
            let position = positions.first { $0.planet == planet }
            #expect(position != nil, "\(planet) position should be calculated")
        }
    }

    // MARK: - House Calculation Tests

    @Test func testCalculateHouses() async throws {
        let birthDate = Date(timeIntervalSince1970: 946684800) // 2000-01-01

        let houses = await service.calculateHouses(
            date: birthDate,
            latitude: 55.7558, // Moscow
            longitude: 37.6176
        )

        #expect(houses.count == 12, "Should calculate 12 houses")

        // First house cusp should be valid
        let firstHouse = houses.first { $0.number == 1 }
        #expect(firstHouse != nil, "First house should exist")

        if let house1 = firstHouse {
            #expect(house1.cusp >= 0 && house1.cusp < 360, "House cusp should be valid")
            #expect(house1.sign != nil, "House should have zodiac sign")
        }

        // All houses should have unique numbers
        let houseNumbers = Set(houses.map { $0.number })
        #expect(houseNumbers.count == 12, "All 12 houses should have unique numbers")
    }

    // MARK: - Aspect Calculation Tests

    @Test func testCalculateAspects() async throws {
        let birthDate = Date()

        let positions = await service.calculatePlanetPositions(
            date: birthDate,
            latitude: 0,
            longitude: 0
        )

        let aspects = await service.calculateAspects(positions: positions)

        #expect(aspects.count > 0, "Should calculate some aspects")

        // Check aspect properties
        for aspect in aspects {
            #expect(aspect.planet1 != aspect.planet2, "Aspect should be between different planets")
            #expect(aspect.angle >= 0 && aspect.angle <= 180, "Aspect angle should be valid")
            #expect(aspect.orb >= 0, "Orb should be non-negative")
        }
    }

    @Test func testConjunctionDetection() async throws {
        // Create two positions very close together (conjunction)
        let positions = [
            PlanetPosition(planet: .sun, longitude: 100.0, latitude: 0, speed: 1.0, zodiacSign: .cancer, degree: 10.0),
            PlanetPosition(planet: .moon, longitude: 103.0, latitude: 0, speed: 13.0, zodiacSign: .cancer, degree: 13.0)
        ]

        let aspects = await service.calculateAspects(positions: positions)

        // Should detect conjunction (0° aspect) with orb of 3°
        let conjunction = aspects.first { $0.type == .conjunction }
        #expect(conjunction != nil, "Should detect conjunction between Sun and Moon")

        if let aspect = conjunction {
            #expect(aspect.angle < 10, "Conjunction angle should be small")
        }
    }

    // MARK: - Birth Chart Creation Tests

    @Test func testCreateBirthChart() async throws {
        let birthData = BirthData(
            birthDate: Date(timeIntervalSince1970: 946684800),
            birthTime: "12:00",
            location: "Moscow, Russia",
            latitude: 55.7558,
            longitude: 37.6176,
            timezone: "Europe/Moscow",
            timeUnknown: false
        )

        let chart = await service.calculateBirthChart(
            userId: "test_user",
            name: "Test Chart",
            birthData: birthData
        )

        #expect(chart.userId == "test_user", "Chart should have correct user ID")
        #expect(chart.name == "Test Chart", "Chart should have correct name")
        #expect(chart.planets.count > 0, "Chart should have planets")
        #expect(chart.houses.count == 12, "Chart should have 12 houses")
        #expect(chart.aspects.count > 0, "Chart should have aspects")
    }

    // MARK: - Ascendant Calculation Tests

    @Test func testCalculateAscendant() async throws {
        let birthDate = Date(timeIntervalSince1970: 946684800) // 2000-01-01 12:00

        let ascendant = await service.calculateAscendant(
            date: birthDate,
            latitude: 51.5074, // London
            longitude: -0.1278
        )

        #expect(ascendant >= 0 && ascendant < 360, "Ascendant should be valid degree")
    }

    // MARK: - Zodiac Sign Tests

    @Test func testZodiacSignFromDegree() {
        // Test zodiac sign calculation from longitude
        #expect(ZodiacSign.from(longitude: 0) == .aries, "0° should be Aries")
        #expect(ZodiacSign.from(longitude: 30) == .taurus, "30° should be Taurus")
        #expect(ZodiacSign.from(longitude: 60) == .gemini, "60° should be Gemini")
        #expect(ZodiacSign.from(longitude: 90) == .cancer, "90° should be Cancer")
        #expect(ZodiacSign.from(longitude: 180) == .libra, "180° should be Libra")
        #expect(ZodiacSign.from(longitude: 270) == .capricorn, "270° should be Capricorn")
        #expect(ZodiacSign.from(longitude: 359) == .pisces, "359° should be Pisces")
    }

    // MARK: - Compatibility Tests

    @Test func testCalculateCompatibility() async throws {
        let chart1 = BirthChart(
            id: "1",
            userId: "user1",
            name: "Person 1",
            birthDate: Date(timeIntervalSince1970: 946684800),
            birthTime: "12:00",
            location: "Moscow",
            latitude: 55.7558,
            longitude: 37.6176,
            planets: [],
            houses: [],
            aspects: [],
            calculatedAt: Date()
        )

        let chart2 = BirthChart(
            id: "2",
            userId: "user2",
            name: "Person 2",
            birthDate: Date(timeIntervalSince1970: 978220800),
            birthTime: "18:00",
            location: "London",
            latitude: 51.5074,
            longitude: -0.1278,
            planets: [],
            houses: [],
            aspects: [],
            calculatedAt: Date()
        )

        let compatibility = await service.calculateCompatibility(chart1: chart1, chart2: chart2)

        #expect(compatibility >= 0 && compatibility <= 100, "Compatibility should be 0-100%")
    }
}

// MARK: - Helper Extension

extension ZodiacSign {
    static func from(longitude: Double) -> ZodiacSign {
        let normalized = longitude.truncatingRemainder(dividingBy: 360)
        let index = Int(normalized / 30)

        let signs: [ZodiacSign] = [
            .aries, .taurus, .gemini, .cancer, .leo, .virgo,
            .libra, .scorpio, .sagittarius, .capricorn, .aquarius, .pisces
        ]

        return signs[index % 12]
    }
}
