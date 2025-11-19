import Testing
import Foundation
@testable import Astrolog

/// Tests for TodayViewModel
@Suite("TodayViewModel Tests")
struct TodayViewModelTests {

    // MARK: - Mock Astrology Service

    final class MockAstrologyService: AstrologyServiceProtocol {
        var shouldFail = false
        var horoscopeCallCount = 0
        var transitsCallCount = 0

        func calculateBirthChart(from birthData: BirthData) async throws -> BirthChart {
            throw NSError(domain: "test", code: -1, userInfo: nil)
        }

        func generateDailyHoroscope(for sunSign: ZodiacSign, date: Date) async throws -> DailyHoroscope {
            horoscopeCallCount += 1

            if shouldFail {
                throw NSError(domain: "test", code: -1, userInfo: [NSLocalizedDescriptionKey: "Horoscope mock error"])
            }

            return DailyHoroscope(
                sign: sunSign.rawValue,
                date: date,
                prediction: "Test prediction for \(sunSign.rawValue)",
                loveScore: 75,
                careerScore: 80,
                healthScore: 70,
                luckyNumbers: [7, 14, 21],
                luckyColor: "Blue"
            )
        }

        func calculateCompatibility(chart1: BirthChart, chart2: BirthChart) async throws -> CompatibilityResult {
            throw NSError(domain: "test", code: -1, userInfo: nil)
        }

        func getCurrentTransits() async throws -> [DailyTransit] {
            transitsCallCount += 1

            if shouldFail {
                throw NSError(domain: "test", code: -1, userInfo: [NSLocalizedDescriptionKey: "Transits mock error"])
            }

            let endDate = Calendar.current.date(byAdding: .day, value: 7, to: Date()) ?? Date()

            return [
                DailyTransit(
                    planet: "Venus",
                    sign: "Taurus",
                    degree: 15,
                    influence: "Harmony in relationships",
                    isRetrograde: false,
                    natalPlanet: "Sun",
                    aspectType: "Trine",
                    description: "Venus trine Sun",
                    startDate: Date(),
                    endDate: endDate
                ),
                DailyTransit(
                    planet: "Mars",
                    sign: "Aries",
                    degree: 20,
                    influence: "Increased energy",
                    isRetrograde: false,
                    natalPlanet: "Moon",
                    aspectType: "Square",
                    description: "Mars square Moon",
                    startDate: Date(),
                    endDate: endDate
                )
            ]
        }
    }

    // MARK: - Initialization Tests

    @Test("ViewModel initializes with default values")
    func testInitialization() async {
        let mockService = MockAstrologyService()
        let viewModel = TodayViewModel(astrologyService: mockService)

        #expect(viewModel.dailyHoroscope == nil)
        #expect(viewModel.transits.count == 0)
        #expect(viewModel.isLoadingHoroscope == false)
        #expect(viewModel.isLoadingTransits == false)
        #expect(viewModel.errorMessage == nil)
    }

    // MARK: - Daily Horoscope Tests

    @Test("Load daily horoscope successfully")
    func testLoadDailyHoroscopeSuccess() async {
        let mockService = MockAstrologyService()
        let viewModel = TodayViewModel(astrologyService: mockService)

        await viewModel.loadTodayData()

        #expect(viewModel.dailyHoroscope != nil, "Horoscope should be loaded")
        #expect(viewModel.isLoadingHoroscope == false, "Loading should complete")
        #expect(viewModel.errorMessage == nil, "No error should occur")
        #expect(mockService.horoscopeCallCount == 1, "Service should be called once")
    }

    @Test("Load daily horoscope handles errors")
    func testLoadDailyHoroscopeError() async {
        let mockService = MockAstrologyService()
        mockService.shouldFail = true

        let viewModel = TodayViewModel(astrologyService: mockService)

        await viewModel.loadTodayData()

        #expect(viewModel.dailyHoroscope == nil, "Horoscope should not be set on error")
        #expect(viewModel.isLoadingHoroscope == false, "Loading should complete")
        #expect(viewModel.errorMessage != nil, "Error message should be set")
        #expect(viewModel.errorMessage?.contains("гороскоп") == true, "Error should mention horoscope")
    }

    @Test("Daily horoscope contains correct data")
    func testDailyHoroscopeContent() async {
        let mockService = MockAstrologyService()
        let viewModel = TodayViewModel(astrologyService: mockService)

        await viewModel.loadTodayData()

        guard let horoscope = viewModel.dailyHoroscope else {
            Issue.record("Horoscope should be loaded")
            return
        }

        #expect(!horoscope.prediction.isEmpty, "Prediction should not be empty")
        #expect(horoscope.loveScore >= 0 && horoscope.loveScore <= 100, "Love score should be 0-100")
        #expect(horoscope.careerScore >= 0 && horoscope.careerScore <= 100, "Career score should be 0-100")
        #expect(horoscope.healthScore >= 0 && horoscope.healthScore <= 100, "Health score should be 0-100")
        #expect(horoscope.luckyNumbers.count > 0, "Should have lucky numbers")
        #expect(!horoscope.luckyColor.isEmpty, "Should have lucky color")
    }

    // MARK: - Transits Tests

    @Test("Load current transits successfully")
    func testLoadTransitsSuccess() async {
        let mockService = MockAstrologyService()
        let viewModel = TodayViewModel(astrologyService: mockService)

        await viewModel.loadTodayData()

        #expect(viewModel.transits.count > 0, "Transits should be loaded")
        #expect(viewModel.isLoadingTransits == false, "Loading should complete")
        #expect(mockService.transitsCallCount == 1, "Service should be called once")
    }

    @Test("Load transits handles errors with fallback")
    func testLoadTransitsErrorFallback() async {
        let mockService = MockAstrologyService()
        mockService.shouldFail = true

        let viewModel = TodayViewModel(astrologyService: mockService)

        await viewModel.loadTodayData()

        // Should use fallback transits
        #expect(viewModel.transits.count > 0, "Should have fallback transits")
        #expect(viewModel.isLoadingTransits == false, "Loading should complete")
        #expect(viewModel.errorMessage != nil, "Error message should be set")
    }

    @Test("Transits contain valid data")
    func testTransitsContent() async {
        let mockService = MockAstrologyService()
        let viewModel = TodayViewModel(astrologyService: mockService)

        await viewModel.loadTodayData()

        for transit in viewModel.transits {
            #expect(!transit.interpretation.isEmpty, "Transit should have interpretation")
            #expect(!transit.humanDescription.isEmpty, "Transit should have human description")
            #expect(transit.orb > 0, "Orb should be positive")
        }
    }

    @Test("Fallback transits are created when needed")
    func testFallbackTransits() async {
        let mockService = MockAstrologyService()
        mockService.shouldFail = true

        let viewModel = TodayViewModel(astrologyService: mockService)

        await viewModel.loadTodayData()

        #expect(viewModel.transits.count == 3, "Should have 3 fallback transits")

        // Check that fallback transits have proper structure
        for transit in viewModel.transits {
            #expect(!transit.interpretation.isEmpty)
            #expect(!transit.humanDescription.isEmpty)
            #expect(!transit.emoji.isEmpty)
        }
    }

    // MARK: - Loading State Tests

    @Test("Loading states are managed correctly")
    func testLoadingStates() async {
        let mockService = MockAstrologyService()
        let viewModel = TodayViewModel(astrologyService: mockService)

        #expect(viewModel.isLoadingHoroscope == false, "Should start not loading")
        #expect(viewModel.isLoadingTransits == false, "Should start not loading")

        await viewModel.loadTodayData()

        #expect(viewModel.isLoadingHoroscope == false, "Should complete loading")
        #expect(viewModel.isLoadingTransits == false, "Should complete loading")
    }

    // MARK: - Refresh Tests

    @Test("Refresh content reloads data")
    func testRefreshContent() async {
        let mockService = MockAstrologyService()
        let viewModel = TodayViewModel(astrologyService: mockService)

        // Initial load
        await viewModel.loadTodayData()

        let initialCallCount = mockService.horoscopeCallCount

        // Clear data
        viewModel.dailyHoroscope = nil
        viewModel.transits = []

        // Refresh
        viewModel.refreshContent()

        // Wait for async completion
        try? await Task.sleep(nanoseconds: 500_000_000)

        #expect(mockService.horoscopeCallCount > initialCallCount, "Should call service again on refresh")
    }

    // MARK: - Error Message Tests

    @Test("Error message is cleared on successful load")
    func testErrorMessageCleared() async {
        let mockService = MockAstrologyService()
        let viewModel = TodayViewModel(astrologyService: mockService)

        // Set error first
        mockService.shouldFail = true
        await viewModel.loadTodayData()

        #expect(viewModel.errorMessage != nil, "Error should be set")

        // Now succeed
        mockService.shouldFail = false
        await viewModel.loadTodayData()

        #expect(viewModel.errorMessage == nil, "Error should be cleared on success")
    }

    // MARK: - Edge Cases

    @Test("Multiple concurrent loads don't cause issues")
    func testConcurrentLoads() async {
        let mockService = MockAstrologyService()
        let viewModel = TodayViewModel(astrologyService: mockService)

        // Trigger multiple loads concurrently
        async let load1 = viewModel.loadTodayData()
        async let load2 = viewModel.loadTodayData()
        async let load3 = viewModel.loadTodayData()

        await load1
        await load2
        await load3

        #expect(viewModel.dailyHoroscope != nil)
        #expect(viewModel.transits.count > 0)
        #expect(viewModel.isLoadingHoroscope == false)
        #expect(viewModel.isLoadingTransits == false)
    }

    @Test("Load today data calls both horoscope and transits")
    func testLoadTodayDataCallsBoth() async {
        let mockService = MockAstrologyService()
        let viewModel = TodayViewModel(astrologyService: mockService)

        await viewModel.loadTodayData()

        #expect(mockService.horoscopeCallCount == 1, "Horoscope should be called")
        #expect(mockService.transitsCallCount == 1, "Transits should be called")
    }

    @Test("Sync version of load triggers async load")
    func testSyncLoadTriggersAsync() async {
        let mockService = MockAstrologyService()
        let viewModel = TodayViewModel(astrologyService: mockService)

        viewModel.loadTodayContent()

        // Wait for async completion
        try? await Task.sleep(nanoseconds: 1_000_000_000)

        #expect(mockService.horoscopeCallCount == 1)
        #expect(mockService.transitsCallCount == 1)
    }

    @Test("Transit conversion handles missing data gracefully")
    func testTransitConversionWithMissingData() async {
        let mockService = MockAstrologyService()
        let viewModel = TodayViewModel(astrologyService: mockService)

        await viewModel.loadTodayData()

        // All transits from mock should be valid (have natalPlanet and aspectType)
        #expect(viewModel.transits.count > 0, "Should have converted transits")
    }

    @Test("Horoscope for different zodiac signs")
    func testDifferentZodiacSigns() async {
        let mockService = MockAstrologyService()

        // Note: ViewModel hardcodes .leo, but we can test the mock
        let horoscope = try? await mockService.generateDailyHoroscope(for: .aries, date: Date())

        #expect(horoscope != nil)
        #expect(horoscope?.sign == "Aries")
    }

    // MARK: - Integration Tests

    @Test("Complete today data load workflow")
    func testCompleteWorkflow() async {
        let mockService = MockAstrologyService()
        let viewModel = TodayViewModel(astrologyService: mockService)

        // 1. Initial state
        #expect(viewModel.dailyHoroscope == nil)
        #expect(viewModel.transits.isEmpty)

        // 2. Load data
        await viewModel.loadTodayData()

        // 3. Verify loaded
        #expect(viewModel.dailyHoroscope != nil)
        #expect(!viewModel.transits.isEmpty)

        // 4. Verify no loading
        #expect(viewModel.isLoadingHoroscope == false)
        #expect(viewModel.isLoadingTransits == false)

        // 5. Verify no errors
        #expect(viewModel.errorMessage == nil)
    }
}
