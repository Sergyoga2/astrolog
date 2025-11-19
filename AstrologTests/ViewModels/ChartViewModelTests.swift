import Testing
import Foundation
@testable import Astrolog

/// Tests for ChartViewModel
@Suite("ChartViewModel Tests")
struct ChartViewModelTests {

    // MARK: - Mock Astrology Service

    final class MockAstrologyService: AstrologyServiceProtocol {
        var shouldFail = false
        var calculatedChart: BirthChart?

        func calculateBirthChart(from birthData: BirthData) async throws -> BirthChart {
            if shouldFail {
                throw NSError(domain: "test", code: -1, userInfo: [NSLocalizedDescriptionKey: "Mock error"])
            }

            let chart = BirthChart(
                id: "test-chart",
                userId: "test-user",
                name: "Test Chart",
                birthDate: birthData.date,
                birthTime: "12:00",
                location: "\(birthData.cityName), \(birthData.countryName)",
                latitude: birthData.latitude,
                longitude: birthData.longitude,
                planets: [
                    Planet(name: "Sun", longitude: 280.0, latitude: 0.0, speed: 1.0, sign: "Capricorn", degree: 10.0, isRetrograde: false)
                ],
                houses: [
                    House(number: 1, cusp: 90.0, sign: "Aries", degree: 0.0)
                ],
                aspects: [],
                calculatedAt: Date()
            )

            calculatedChart = chart
            return chart
        }

        func generateDailyHoroscope(for sunSign: ZodiacSign, date: Date) async throws -> DailyHoroscope {
            throw NSError(domain: "test", code: -1, userInfo: nil)
        }

        func calculateCompatibility(chart1: BirthChart, chart2: BirthChart) async throws -> CompatibilityResult {
            throw NSError(domain: "test", code: -1, userInfo: nil)
        }

        func getCurrentTransits() async throws -> [DailyTransit] {
            return []
        }
    }

    // MARK: - Initialization Tests

    @Test("ViewModel initializes with default values")
    func testInitialization() async {
        let mockService = MockAstrologyService()
        let viewModel = ChartViewModel(astrologyService: mockService)

        #expect(viewModel.isLoading == false)
        #expect(viewModel.errorMessage == nil)
    }

    // MARK: - Birth Data Loading Tests

    @Test("Load birth data from UserDefaults when available")
    func testLoadBirthDataSuccess() async {
        let birthData = BirthData(
            date: Date(timeIntervalSince1970: 946684800),
            timeZone: TimeZone(identifier: "UTC")!,
            latitude: 51.5074,
            longitude: -0.1278,
            cityName: "London",
            countryName: "UK",
            isTimeExact: true
        )

        // Store in UserDefaults
        let encoded = try? JSONEncoder().encode(birthData)
        UserDefaults.standard.set(encoded, forKey: "user_birth_data")

        let mockService = MockAstrologyService()
        let viewModel = ChartViewModel(astrologyService: mockService)

        // Wait a moment for async calculation
        try? await Task.sleep(nanoseconds: 500_000_000)

        #expect(viewModel.hasBirthData == true)
        #expect(mockService.calculatedChart != nil, "Chart should have been calculated")

        // Cleanup
        UserDefaults.standard.removeObject(forKey: "user_birth_data")
    }

    @Test("Handle missing birth data gracefully")
    func testLoadBirthDataMissing() async {
        // Clear UserDefaults
        UserDefaults.standard.removeObject(forKey: "user_birth_data")

        let mockService = MockAstrologyService()
        let viewModel = ChartViewModel(astrologyService: mockService)

        #expect(viewModel.hasBirthData == false)
        #expect(viewModel.birthChart == nil)
    }

    // MARK: - Chart Calculation Tests

    @Test("Calculate chart successfully")
    func testCalculateChartSuccess() async {
        let mockService = MockAstrologyService()
        let viewModel = ChartViewModel(astrologyService: mockService)

        let birthData = BirthData(
            date: Date(timeIntervalSince1970: 946684800),
            timeZone: TimeZone(identifier: "UTC")!,
            latitude: 48.8566,
            longitude: 2.3522,
            cityName: "Paris",
            countryName: "France",
            isTimeExact: true
        )

        // Start calculation
        viewModel.calculateChart(from: birthData)

        // Wait for async completion
        try? await Task.sleep(nanoseconds: 500_000_000)

        #expect(viewModel.birthChart != nil, "Chart should be calculated")
        #expect(viewModel.isLoading == false, "Loading should be complete")
        #expect(viewModel.errorMessage == nil, "No error should occur")
        #expect(mockService.calculatedChart != nil, "Mock service should have calculated chart")
    }

    @Test("Calculate chart handles errors")
    func testCalculateChartError() async {
        let mockService = MockAstrologyService()
        mockService.shouldFail = true

        let viewModel = ChartViewModel(astrologyService: mockService)

        let birthData = BirthData(
            date: Date(timeIntervalSince1970: 946684800),
            timeZone: TimeZone(identifier: "UTC")!,
            latitude: 0.0,
            longitude: 0.0,
            cityName: "Test",
            countryName: "Test",
            isTimeExact: true
        )

        viewModel.calculateChart(from: birthData)

        // Wait for async completion
        try? await Task.sleep(nanoseconds: 500_000_000)

        #expect(viewModel.birthChart == nil, "Chart should not be set on error")
        #expect(viewModel.isLoading == false, "Loading should complete")
        #expect(viewModel.errorMessage != nil, "Error message should be set")
    }

    @Test("Loading state is managed during calculation")
    func testLoadingState() async {
        let mockService = MockAstrologyService()
        let viewModel = ChartViewModel(astrologyService: mockService)

        #expect(viewModel.isLoading == false, "Should start as not loading")

        let birthData = BirthData(
            date: Date(timeIntervalSince1970: 946684800),
            timeZone: TimeZone(identifier: "UTC")!,
            latitude: 0.0,
            longitude: 0.0,
            cityName: "Test",
            countryName: "Test",
            isTimeExact: true
        )

        viewModel.calculateChart(from: birthData)

        // Very briefly it should be loading (hard to test reliably)
        // After completion it should be false
        try? await Task.sleep(nanoseconds: 500_000_000)

        #expect(viewModel.isLoading == false)
    }

    // MARK: - Refresh Tests

    @Test("Refresh chart reloads birth data")
    func testRefreshChart() async {
        let birthData = BirthData(
            date: Date(timeIntervalSince1970: 946684800),
            timeZone: TimeZone(identifier: "UTC")!,
            latitude: 51.5074,
            longitude: -0.1278,
            cityName: "London",
            countryName: "UK",
            isTimeExact: true
        )

        // Store in UserDefaults
        let encoded = try? JSONEncoder().encode(birthData)
        UserDefaults.standard.set(encoded, forKey: "user_birth_data")

        let mockService = MockAstrologyService()
        let viewModel = ChartViewModel(astrologyService: mockService)

        // Wait for initial load
        try? await Task.sleep(nanoseconds: 500_000_000)

        // Clear chart
        viewModel.birthChart = nil
        mockService.calculatedChart = nil

        // Refresh
        viewModel.refreshChart()

        // Wait for refresh
        try? await Task.sleep(nanoseconds: 500_000_000)

        #expect(mockService.calculatedChart != nil, "Chart should be recalculated")

        // Cleanup
        UserDefaults.standard.removeObject(forKey: "user_birth_data")
    }

    // MARK: - Error Message Tests

    @Test("Error message is cleared on successful calculation")
    func testErrorMessageCleared() async {
        let mockService = MockAstrologyService()
        let viewModel = ChartViewModel(astrologyService: mockService)

        // Set error first
        viewModel.errorMessage = "Previous error"

        let birthData = BirthData(
            date: Date(timeIntervalSince1970: 946684800),
            timeZone: TimeZone(identifier: "UTC")!,
            latitude: 0.0,
            longitude: 0.0,
            cityName: "Test",
            countryName: "Test",
            isTimeExact: true
        )

        viewModel.calculateChart(from: birthData)

        // Wait for completion
        try? await Task.sleep(nanoseconds: 500_000_000)

        #expect(viewModel.errorMessage == nil, "Error should be cleared on success")
    }

    @Test("Error message contains error description")
    func testErrorMessageDescription() async {
        let mockService = MockAstrologyService()
        mockService.shouldFail = true

        let viewModel = ChartViewModel(astrologyService: mockService)

        let birthData = BirthData(
            date: Date(timeIntervalSince1970: 946684800),
            timeZone: TimeZone(identifier: "UTC")!,
            latitude: 0.0,
            longitude: 0.0,
            cityName: "Test",
            countryName: "Test",
            isTimeExact: true
        )

        viewModel.calculateChart(from: birthData)

        // Wait for completion
        try? await Task.sleep(nanoseconds: 500_000_000)

        #expect(viewModel.errorMessage?.contains("Mock error") == true, "Error message should contain error description")
    }

    // MARK: - Birth Chart Content Tests

    @Test("Calculated chart contains planets")
    func testChartContainsPlanets() async {
        let mockService = MockAstrologyService()
        let viewModel = ChartViewModel(astrologyService: mockService)

        let birthData = BirthData(
            date: Date(timeIntervalSince1970: 946684800),
            timeZone: TimeZone(identifier: "UTC")!,
            latitude: 0.0,
            longitude: 0.0,
            cityName: "Test",
            countryName: "Test",
            isTimeExact: true
        )

        viewModel.calculateChart(from: birthData)

        // Wait for completion
        try? await Task.sleep(nanoseconds: 500_000_000)

        #expect(viewModel.birthChart?.planets.count ?? 0 > 0, "Chart should contain planets")
    }

    @Test("Calculated chart contains houses")
    func testChartContainsHouses() async {
        let mockService = MockAstrologyService()
        let viewModel = ChartViewModel(astrologyService: mockService)

        let birthData = BirthData(
            date: Date(timeIntervalSince1970: 946684800),
            timeZone: TimeZone(identifier: "UTC")!,
            latitude: 0.0,
            longitude: 0.0,
            cityName: "Test",
            countryName: "Test",
            isTimeExact: true
        )

        viewModel.calculateChart(from: birthData)

        // Wait for completion
        try? await Task.sleep(nanoseconds: 500_000_000)

        #expect(viewModel.birthChart?.houses.count ?? 0 > 0, "Chart should contain houses")
    }

    // MARK: - Edge Cases

    @Test("Multiple calculations don't cause race conditions")
    func testMultipleCalculations() async {
        let mockService = MockAstrologyService()
        let viewModel = ChartViewModel(astrologyService: mockService)

        let birthData = BirthData(
            date: Date(timeIntervalSince1970: 946684800),
            timeZone: TimeZone(identifier: "UTC")!,
            latitude: 0.0,
            longitude: 0.0,
            cityName: "Test",
            countryName: "Test",
            isTimeExact: true
        )

        // Trigger multiple calculations
        viewModel.calculateChart(from: birthData)
        viewModel.calculateChart(from: birthData)
        viewModel.calculateChart(from: birthData)

        // Wait for all to complete
        try? await Task.sleep(nanoseconds: 1_000_000_000)

        // Should have a chart and no errors
        #expect(viewModel.birthChart != nil)
        #expect(viewModel.isLoading == false)
    }

    @Test("ViewModel with different birth data produces different charts")
    func testDifferentBirthData() async {
        let mockService = MockAstrologyService()
        let viewModel = ChartViewModel(astrologyService: mockService)

        let birthData1 = BirthData(
            date: Date(timeIntervalSince1970: 946684800),
            timeZone: TimeZone(identifier: "UTC")!,
            latitude: 51.5074,
            longitude: -0.1278,
            cityName: "London",
            countryName: "UK",
            isTimeExact: true
        )

        viewModel.calculateChart(from: birthData1)
        try? await Task.sleep(nanoseconds: 500_000_000)

        let chart1 = viewModel.birthChart

        let birthData2 = BirthData(
            date: Date(timeIntervalSince1970: 946684800),
            timeZone: TimeZone(identifier: "UTC")!,
            latitude: 48.8566,
            longitude: 2.3522,
            cityName: "Paris",
            countryName: "France",
            isTimeExact: true
        )

        viewModel.calculateChart(from: birthData2)
        try? await Task.sleep(nanoseconds: 500_000_000)

        let chart2 = viewModel.birthChart

        // Charts should be different (different locations)
        #expect(chart1?.location != chart2?.location)
    }
}
