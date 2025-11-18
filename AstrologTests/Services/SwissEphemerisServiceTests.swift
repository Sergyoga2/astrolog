import Testing
import Foundation
@testable import Astrolog

@MainActor
struct SwissEphemerisServiceTests {
    let service = SwissEphemerisService()

    // MARK: - Birth Chart Calculation Tests

    @Test func testCalculateBirthChart() async throws {
        let birthData = BirthData(
            date: Date(timeIntervalSince1970: 946684800), // 2000-01-01
            timeZone: TimeZone(identifier: "Europe/Moscow")!,
            latitude: 55.7558,
            longitude: 37.6176,
            cityName: "Moscow",
            countryName: "Russia",
            isTimeExact: true
        )

        let chart = try await service.calculateBirthChart(from: birthData)

        #expect(chart.planets.count > 0, "Chart should have planets")
        #expect(chart.houses.count == 12, "Chart should have 12 houses")
        #expect(chart.location.contains("Moscow"), "Chart location should contain city name")
        #expect(chart.latitude == birthData.latitude, "Chart latitude should match")
        #expect(chart.longitude == birthData.longitude, "Chart longitude should match")
    }

    @Test func testCalculateBirthChartWithDifferentLocations() async throws {
        // Test for New York
        let nyBirthData = BirthData(
            date: Date(),
            timeZone: TimeZone(identifier: "America/New_York")!,
            latitude: 40.7128,
            longitude: -74.0060,
            cityName: "New York",
            countryName: "USA",
            isTimeExact: true
        )

        let nyChart = try await service.calculateBirthChart(from: nyBirthData)
        #expect(nyChart.planets.count > 0, "NY chart should have planets")

        // Test for London
        let londonBirthData = BirthData(
            date: Date(),
            timeZone: TimeZone(identifier: "Europe/London")!,
            latitude: 51.5074,
            longitude: -0.1278,
            cityName: "London",
            countryName: "United Kingdom",
            isTimeExact: true
        )

        let londonChart = try await service.calculateBirthChart(from: londonBirthData)
        #expect(londonChart.planets.count > 0, "London chart should have planets")

        // Charts should have same planets but potentially different house positions
        #expect(nyChart.planets.count == londonChart.planets.count, "Both charts should have same number of planets")
    }

    @Test func testBirthChartHasMajorPlanets() async throws {
        let birthData = BirthData(
            date: Date(),
            timeZone: TimeZone.current,
            latitude: 0,
            longitude: 0,
            cityName: "Equator",
            countryName: "Ocean",
            isTimeExact: true
        )

        let chart = try await service.calculateBirthChart(from: birthData)

        // Check for major planets
        let planetTypes = chart.planets.map { $0.name }

        let expectedPlanets = ["Sun", "Moon", "Mercury", "Venus", "Mars", "Jupiter", "Saturn"]

        for expected in expectedPlanets {
            #expect(planetTypes.contains(expected), "\(expected) should be in the chart")
        }
    }

    @Test func testBirthChartHasHouses() async throws {
        let birthData = BirthData(
            date: Date(),
            timeZone: TimeZone.current,
            latitude: 51.5074,
            longitude: -0.1278,
            cityName: "London",
            countryName: "UK",
            isTimeExact: true
        )

        let chart = try await service.calculateBirthChart(from: birthData)

        #expect(chart.houses.count == 12, "Chart should have exactly 12 houses")

        // Verify houses are numbered 1-12
        let houseNumbers = chart.houses.map { $0.number }
        for i in 1...12 {
            #expect(houseNumbers.contains(i), "House \(i) should exist")
        }
    }

    @Test func testBirthChartHasAspects() async throws {
        let birthData = BirthData(
            date: Date(timeIntervalSince1970: 946684800),
            timeZone: TimeZone(identifier: "UTC")!,
            latitude: 0,
            longitude: 0,
            cityName: "Greenwich",
            countryName: "UK",
            isTimeExact: true
        )

        let chart = try await service.calculateBirthChart(from: birthData)

        #expect(chart.aspects.count > 0, "Chart should have some aspects")

        // Verify aspects have valid properties
        for aspect in chart.aspects {
            #expect(!aspect.planet1.isEmpty, "Aspect should have planet1")
            #expect(!aspect.planet2.isEmpty, "Aspect should have planet2")
            #expect(aspect.planet1 != aspect.planet2, "Aspect planets should be different")
        }
    }

    // MARK: - Compatibility Tests

    @Test func testCalculateCompatibility() async throws {
        let birthData1 = BirthData(
            date: Date(timeIntervalSince1970: 946684800),
            timeZone: TimeZone(identifier: "Europe/Moscow")!,
            latitude: 55.7558,
            longitude: 37.6176,
            cityName: "Moscow",
            countryName: "Russia",
            isTimeExact: true
        )

        let birthData2 = BirthData(
            date: Date(timeIntervalSince1970: 978220800),
            timeZone: TimeZone(identifier: "Europe/London")!,
            latitude: 51.5074,
            longitude: -0.1278,
            cityName: "London",
            countryName: "UK",
            isTimeExact: true
        )

        let chart1 = try await service.calculateBirthChart(from: birthData1)
        let chart2 = try await service.calculateBirthChart(from: birthData2)

        let compatibility = try await service.calculateCompatibility(chart1: chart1, chart2: chart2)

        #expect(compatibility.overallScore >= 0, "Compatibility score should be non-negative")
        #expect(compatibility.overallScore <= 100, "Compatibility score should not exceed 100")
        #expect(!compatibility.description.isEmpty, "Compatibility should have description")
        #expect(compatibility.strengths.count > 0, "Compatibility should have strengths")
        #expect(compatibility.challenges.count > 0, "Compatibility should have challenges")
    }

    @Test func testCompatibilityWithSameChart() async throws {
        let birthData = BirthData(
            date: Date(),
            timeZone: TimeZone.current,
            latitude: 40.7128,
            longitude: -74.0060,
            cityName: "New York",
            countryName: "USA",
            isTimeExact: true
        )

        let chart = try await service.calculateBirthChart(from: birthData)

        let compatibility = try await service.calculateCompatibility(chart1: chart, chart2: chart)

        // Same chart should have high compatibility
        #expect(compatibility.overallScore >= 70, "Same chart should have high compatibility")
    }

    // MARK: - Daily Horoscope Tests

    @Test func testGenerateDailyHoroscope() async throws {
        let horoscope = try await service.generateDailyHoroscope(for: .aries, date: Date())

        #expect(!horoscope.prediction.isEmpty, "Horoscope should have prediction")
        #expect(horoscope.energyLevel > 0, "Horoscope should have energy level")
        #expect(horoscope.energyLevel <= 100, "Energy level should not exceed 100")
        #expect(horoscope.luckyNumbers.count > 0, "Horoscope should have lucky numbers")
        #expect(!horoscope.luckyColor.isEmpty, "Horoscope should have lucky color")
    }

    @Test func testGenerateHoroscopeForAllSigns() async throws {
        let allSigns: [ZodiacSign] = [
            .aries, .taurus, .gemini, .cancer, .leo, .virgo,
            .libra, .scorpio, .sagittarius, .capricorn, .aquarius, .pisces
        ]

        for sign in allSigns {
            let horoscope = try await service.generateDailyHoroscope(for: sign, date: Date())
            #expect(!horoscope.prediction.isEmpty, "Horoscope for \(sign) should have prediction")
        }
    }

    // MARK: - Current Transits Tests

    @Test func testGetCurrentTransits() async throws {
        let transits = try await service.getCurrentTransits()

        #expect(transits.count > 0, "Should have current transits")

        for transit in transits {
            #expect(!transit.planet.isEmpty, "Transit should have planet")
            #expect(!transit.sign.isEmpty, "Transit should have sign")
            #expect(!transit.influence.isEmpty, "Transit should have influence")
        }
    }

    // MARK: - Edge Cases

    @Test func testCalculateChartForLeapYear() async throws {
        // Test for February 29, 2000 (leap year)
        let leapYearDate = Date(timeIntervalSince1970: 951782400) // 2000-02-29
        let birthData = BirthData(
            date: leapYearDate,
            timeZone: TimeZone(identifier: "UTC")!,
            latitude: 0,
            longitude: 0,
            cityName: "Greenwich",
            countryName: "UK",
            isTimeExact: true
        )

        let chart = try await service.calculateBirthChart(from: birthData)

        #expect(chart.planets.count > 0, "Leap year chart should calculate successfully")
    }

    @Test func testCalculateChartForExtremeLatitudes() async throws {
        // Test for high latitude (near Arctic Circle)
        let arcticBirthData = BirthData(
            date: Date(),
            timeZone: TimeZone(identifier: "Europe/Oslo")!,
            latitude: 69.6492,
            longitude: 18.9553,
            cityName: "Tromsø",
            countryName: "Norway",
            isTimeExact: true
        )

        let chart = try await service.calculateBirthChart(from: arcticBirthData)

        #expect(chart.planets.count > 0, "Arctic chart should calculate successfully")
        #expect(chart.houses.count == 12, "Arctic chart should still have 12 houses")
    }

    @Test func testCalculateChartForDifferentTimezones() async throws {
        let date = Date(timeIntervalSince1970: 946684800)

        // Same moment in time, different timezones
        let birthDataUTC = BirthData(
            date: date,
            timeZone: TimeZone(identifier: "UTC")!,
            latitude: 0,
            longitude: 0,
            cityName: "Greenwich",
            countryName: "UK",
            isTimeExact: true
        )

        let birthDataTokyo = BirthData(
            date: date,
            timeZone: TimeZone(identifier: "Asia/Tokyo")!,
            latitude: 35.6762,
            longitude: 139.6503,
            cityName: "Tokyo",
            countryName: "Japan",
            isTimeExact: true
        )

        let chartUTC = try await service.calculateBirthChart(from: birthDataUTC)
        let chartTokyo = try await service.calculateBirthChart(from: birthDataTokyo)

        // Both charts should be calculated successfully
        #expect(chartUTC.planets.count > 0, "UTC chart should have planets")
        #expect(chartTokyo.planets.count > 0, "Tokyo chart should have planets")
    }
}
