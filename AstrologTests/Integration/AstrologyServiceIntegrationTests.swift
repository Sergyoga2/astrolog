import Testing
import Foundation
@testable import Astrolog

/// Integration Tests for Astrology Service
/// Tests the complete astrology calculation pipeline
@Suite("Astrology Service Integration", .tags(.integration, .astrology))
struct AstrologyServiceIntegrationTests {

    // MARK: - End-to-End Birth Chart Tests

    @Test("Complete birth chart calculation flow")
    func testCompleteBirthChartFlow() async throws {
        let service = SwissEphemerisService()

        // Real birth data: January 1, 2000, 12:00 UTC, London
        let birthData = BirthData(
            date: Date(timeIntervalSince1970: 946728000), // 2000-01-01 12:00:00 UTC
            timeZone: TimeZone(identifier: "Europe/London")!,
            latitude: 51.5074,
            longitude: -0.1278,
            cityName: "London",
            countryName: "United Kingdom",
            isTimeExact: true
        )

        // Calculate chart
        let chart = try await service.calculateBirthChart(from: birthData)

        // Verify chart structure
        #expect(chart.planets.count >= 10, "Should have at least 10 planets")
        #expect(chart.houses.count == 12, "Should have exactly 12 houses")
        #expect(chart.aspects.count > 0, "Should have aspects")

        // Verify Sun position (should be in Capricorn ~280°)
        let sun = chart.planets.first { $0.name == "Sun" }
        #expect(sun != nil, "Sun should exist")
        #expect(sun!.longitude >= 270 && sun!.longitude <= 290, "Sun should be around 280° for Jan 1")

        // Verify Ascendant
        let firstHouse = chart.houses.first { $0.number == 1 }
        #expect(firstHouse != nil, "First house should exist")
        #expect(firstHouse!.cusp >= 0 && firstHouse!.cusp < 360, "Ascendant should be valid")

        // Verify major aspects exist
        let majorAspects = chart.aspects.filter { ["Conjunction", "Trine", "Square", "Opposition"].contains($0.type) }
        #expect(majorAspects.count > 0, "Should have major aspects")
    }

    @Test("Birth charts for different locations produce different ascendants")
    func testLocationDifference() async throws {
        let service = SwissEphemerisService()
        let sameDate = Date(timeIntervalSince1970: 946728000)

        // London chart
        let londonData = BirthData(
            date: sameDate,
            timeZone: TimeZone(identifier: "Europe/London")!,
            latitude: 51.5074,
            longitude: -0.1278,
            cityName: "London",
            countryName: "UK",
            isTimeExact: true
        )
        let londonChart = try await service.calculateBirthChart(from: londonData)

        // Tokyo chart
        let tokyoData = BirthData(
            date: sameDate,
            timeZone: TimeZone(identifier: "Asia/Tokyo")!,
            latitude: 35.6762,
            longitude: 139.6503,
            cityName: "Tokyo",
            countryName: "Japan",
            isTimeExact: true
        )
        let tokyoChart = try await service.calculateBirthChart(from: tokyoData)

        // Ascendants should be different
        let londonAsc = londonChart.houses.first { $0.number == 1 }!.cusp
        let tokyoAsc = tokyoChart.houses.first { $0.number == 1 }!.cusp

        #expect(abs(londonAsc - tokyoAsc) > 5, "Ascendants should differ significantly")

        // But Sun position should be similar (same time)
        let londonSun = londonChart.planets.first { $0.name == "Sun" }!.longitude
        let tokyoSun = tokyoChart.planets.first { $0.name == "Sun" }!.longitude

        #expect(abs(londonSun - tokyoSun) < 1, "Sun positions should be very close")
    }

    @Test("Birth charts at different times show Moon movement")
    func testMoonMovement() async throws {
        let service = SwissEphemerisService()

        // Chart at noon
        let noonData = BirthData(
            date: Date(timeIntervalSince1970: 946728000), // 2000-01-01 12:00 UTC
            timeZone: TimeZone(identifier: "UTC")!,
            latitude: 0,
            longitude: 0,
            cityName: "Greenwich",
            countryName: "UK",
            isTimeExact: true
        )
        let noonChart = try await service.calculateBirthChart(from: noonData)

        // Chart 12 hours later (midnight)
        let midnightData = BirthData(
            date: Date(timeIntervalSince1970: 946728000 + 43200), // +12 hours
            timeZone: TimeZone(identifier: "UTC")!,
            latitude: 0,
            longitude: 0,
            cityName: "Greenwich",
            countryName: "UK",
            isTimeExact: true
        )
        let midnightChart = try await service.calculateBirthChart(from: midnightData)

        // Moon moves ~13° per day, so ~6.5° in 12 hours
        let noonMoon = noonChart.planets.first { $0.name == "Moon" }!.longitude
        let midnightMoon = midnightChart.planets.first { $0.name == "Moon" }!.longitude

        let moonMovement = abs(midnightMoon - noonMoon)
        #expect(moonMovement >= 5 && moonMovement <= 8, "Moon should move ~6.5° in 12 hours")
    }

    // MARK: - Compatibility Tests

    @Test("Compatibility calculation between two charts")
    func testCompatibilityCalculation() async throws {
        let service = SwissEphemerisService()

        // Person 1: Sun in Aries
        let person1Data = BirthData(
            date: Date(timeIntervalSince1970: 954259200), // 2000-03-28 12:00 UTC
            timeZone: TimeZone(identifier: "UTC")!,
            latitude: 40.7128,
            longitude: -74.0060,
            cityName: "New York",
            countryName: "USA",
            isTimeExact: true
        )
        let chart1 = try await service.calculateBirthChart(from: person1Data)

        // Person 2: Sun in Leo
        let person2Data = BirthData(
            date: Date(timeIntervalSince1970: 965390400), // 2000-08-04 12:00 UTC
            timeZone: TimeZone(identifier: "UTC")!,
            latitude: 40.7128,
            longitude: -74.0060,
            cityName: "New York",
            countryName: "USA",
            isTimeExact: true
        )
        let chart2 = try await service.calculateBirthChart(from: person2Data)

        // Calculate compatibility
        let compatibility = try await service.calculateCompatibility(chart1: chart1, chart2: chart2)

        // Verify compatibility result
        #expect(compatibility.overallScore >= 0 && compatibility.overallScore <= 100, "Score should be 0-100")
        #expect(compatibility.aspects.count > 0, "Should have synastry aspects")
        #expect(compatibility.elementalBalance.count > 0, "Should have elemental balance")
        #expect(!compatibility.interpretation.isEmpty, "Should have interpretation")

        // Aries-Leo should have good compatibility (both fire signs)
        #expect(compatibility.overallScore >= 60, "Fire signs should have decent compatibility")
    }

    @Test("Self-compatibility returns high score")
    func testSelfCompatibility() async throws {
        let service = SwissEphemerisService()

        let birthData = BirthData(
            date: Date(timeIntervalSince1970: 946728000),
            timeZone: TimeZone(identifier: "UTC")!,
            latitude: 0,
            longitude: 0,
            cityName: "Greenwich",
            countryName: "UK",
            isTimeExact: true
        )
        let chart = try await service.calculateBirthChart(from: birthData)

        // Compare chart with itself
        let compatibility = try await service.calculateCompatibility(chart1: chart, chart2: chart)

        // Self-compatibility should be very high
        #expect(compatibility.overallScore >= 90, "Self-compatibility should be 90+")
    }

    // MARK: - Daily Horoscope Tests

    @Test("Daily horoscope generation for all zodiac signs")
    func testDailyHoroscopeAllSigns() async throws {
        let service = SwissEphemerisService()

        for sign in ZodiacSign.allCases {
            let horoscope = try await service.generateDailyHoroscope(for: sign, date: Date())

            #expect(horoscope.sign == sign.rawValue, "Sign should match")
            #expect(!horoscope.prediction.isEmpty, "Prediction should not be empty")
            #expect(horoscope.luckyNumbers.count > 0, "Should have lucky numbers")
            #expect(!horoscope.luckyColor.isEmpty, "Should have lucky color")
            #expect(horoscope.loveScore >= 0 && horoscope.loveScore <= 100, "Love score 0-100")
            #expect(horoscope.careerScore >= 0 && horoscope.careerScore <= 100, "Career score 0-100")
            #expect(horoscope.healthScore >= 0 && horoscope.healthScore <= 100, "Health score 0-100")
        }
    }

    @Test("Daily horoscope for specific date")
    func testDailyHoroscopeSpecificDate() async throws {
        let service = SwissEphemerisService()

        // Generate for past date
        let pastDate = Date(timeIntervalSince1970: 946728000) // 2000-01-01
        let horoscope = try await service.generateDailyHoroscope(for: .capricorn, date: pastDate)

        #expect(horoscope.date.timeIntervalSince1970 >= pastDate.timeIntervalSince1970 - 86400, "Date should match")
        #expect(!horoscope.prediction.isEmpty, "Should have prediction")
    }

    // MARK: - Current Transits Tests

    @Test("Current transits returns all major planets")
    func testCurrentTransits() async throws {
        let service = SwissEphemerisService()

        let transits = try await service.getCurrentTransits()

        #expect(transits.count >= 8, "Should have at least 8 transits (planets)")

        // Verify each transit has valid data
        for transit in transits {
            #expect(!transit.planet.isEmpty, "Planet name should not be empty")
            #expect(!transit.sign.isEmpty, "Sign should not be empty")
            #expect(transit.degree >= 0 && transit.degree < 30, "Degree should be 0-29")
            #expect(!transit.influence.isEmpty, "Influence should not be empty")
        }

        // Verify some known planets
        let planetNames = transits.map { $0.planet }
        #expect(planetNames.contains("Sun"), "Should have Sun")
        #expect(planetNames.contains("Moon"), "Should have Moon")
        #expect(planetNames.contains("Mercury"), "Should have Mercury")
    }

    @Test("Transits at different times show planet movement")
    func testTransitMovement() async throws {
        // This test would require controlling the current date
        // Placeholder for future implementation with date injection
    }

    // MARK: - Edge Cases

    @Test("Birth chart at extreme northern latitude")
    func testExtremeLatitude() async throws {
        let service = SwissEphemerisService()

        // Reykjavik, Iceland
        let birthData = BirthData(
            date: Date(timeIntervalSince1970: 946728000),
            timeZone: TimeZone(identifier: "Atlantic/Reykjavik")!,
            latitude: 64.1466,
            longitude: -21.9426,
            cityName: "Reykjavik",
            countryName: "Iceland",
            isTimeExact: true
        )

        let chart = try await service.calculateBirthChart(from: birthData)

        #expect(chart.planets.count >= 10, "Should calculate even at extreme latitude")
        #expect(chart.houses.count == 12, "Should have 12 houses")
    }

    @Test("Birth chart on leap day")
    func testLeapDay() async throws {
        let service = SwissEphemerisService()

        // February 29, 2000 (leap year)
        let birthData = BirthData(
            date: Date(timeIntervalSince1970: 951825600), // 2000-02-29 12:00 UTC
            timeZone: TimeZone(identifier: "UTC")!,
            latitude: 0,
            longitude: 0,
            cityName: "Greenwich",
            countryName: "UK",
            isTimeExact: true
        )

        let chart = try await service.calculateBirthChart(from: birthData)

        #expect(chart.planets.count >= 10, "Should handle leap day")

        // Sun should be in Pisces (~340°)
        let sun = chart.planets.first { $0.name == "Sun" }
        #expect(sun != nil, "Sun should exist")
        #expect(sun!.sign == "Pisces", "Sun should be in Pisces on Feb 29")
    }

    @Test("Birth chart at exact midnight")
    func testMidnightBirth() async throws {
        let service = SwissEphemerisService()

        // Midnight UTC
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "UTC")!
        var components = DateComponents()
        components.year = 2000
        components.month = 6
        components.day = 15
        components.hour = 0
        components.minute = 0
        components.second = 0

        let midnight = calendar.date(from: components)!

        let birthData = BirthData(
            date: midnight,
            timeZone: TimeZone(identifier: "UTC")!,
            latitude: 0,
            longitude: 0,
            cityName: "Greenwich",
            countryName: "UK",
            isTimeExact: true
        )

        let chart = try await service.calculateBirthChart(from: birthData)

        #expect(chart.planets.count >= 10, "Should handle midnight birth")
        #expect(chart.houses.count == 12, "Should have 12 houses")
    }

    @Test("Multiple concurrent chart calculations")
    func testConcurrentCalculations() async throws {
        let service = SwissEphemerisService()

        await withTaskGroup(of: Result<BirthChart, Error>.self) { group in
            // Calculate 10 charts concurrently
            for i in 0..<10 {
                group.addTask {
                    let birthData = BirthData(
                        date: Date(timeIntervalSince1970: 946728000 + Double(i * 86400)),
                        timeZone: TimeZone(identifier: "UTC")!,
                        latitude: Double(i * 10),
                        longitude: Double(i * 10),
                        cityName: "Test City \(i)",
                        countryName: "Test Country",
                        isTimeExact: true
                    )

                    do {
                        let chart = try await service.calculateBirthChart(from: birthData)
                        return .success(chart)
                    } catch {
                        return .failure(error)
                    }
                }
            }

            // Collect results
            var successCount = 0
            for await result in group {
                if case .success(let chart) = result {
                    #expect(chart.planets.count >= 10)
                    successCount += 1
                }
            }

            #expect(successCount == 10, "All concurrent calculations should succeed")
        }
    }

    // MARK: - Performance Tests

    @Test("Birth chart calculation completes within reasonable time")
    func testCalculationPerformance() async throws {
        let service = SwissEphemerisService()

        let birthData = BirthData(
            date: Date(timeIntervalSince1970: 946728000),
            timeZone: TimeZone(identifier: "UTC")!,
            latitude: 0,
            longitude: 0,
            cityName: "Greenwich",
            countryName: "UK",
            isTimeExact: true
        )

        let startTime = Date()
        _ = try await service.calculateBirthChart(from: birthData)
        let duration = Date().timeIntervalSince(startTime)

        #expect(duration < 5.0, "Chart calculation should complete in under 5 seconds")
    }
}
