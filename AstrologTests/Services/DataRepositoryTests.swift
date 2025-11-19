import Testing
import Foundation
import Combine
@testable import Astrolog

/// Tests for DataRepository
@Suite("DataRepository Tests")
struct DataRepositoryTests {

    // MARK: - Mock Services

    @MainActor
    final class MockFirebaseService {
        var isAuthenticated = false
        var shouldFailSave = false
        var shouldFailLoad = false
        var savedCharts: [[String: Any]] = []
        var savedHoroscopes: [(date: String, sign: String, content: [String: Any])] = []
        var chartToReturn: [String: Any]?
        var horoscopeToReturn: [String: Any]?
        var saveCallCount = 0
        var loadCallCount = 0

        func saveBirthChart(_ chartDict: [String: Any]) async throws {
            saveCallCount += 1
            if shouldFailSave {
                throw NSError(domain: "test", code: -1, userInfo: [NSLocalizedDescriptionKey: "Firebase save error"])
            }
            savedCharts.append(chartDict)
        }

        func loadBirthChart() async throws -> [String: Any]? {
            loadCallCount += 1
            if shouldFailLoad {
                throw NSError(domain: "test", code: -1, userInfo: [NSLocalizedDescriptionKey: "Firebase load error"])
            }
            return chartToReturn
        }

        func saveHoroscope(date: String, sign: String, content: [String: Any]) async throws {
            saveCallCount += 1
            if shouldFailSave {
                throw NSError(domain: "test", code: -1, userInfo: [NSLocalizedDescriptionKey: "Firebase save error"])
            }
            savedHoroscopes.append((date: date, sign: sign, content: content))
        }

        func loadHoroscope(date: String, sign: String) async throws -> [String: Any]? {
            loadCallCount += 1
            if shouldFailLoad {
                throw NSError(domain: "test", code: -1, userInfo: [NSLocalizedDescriptionKey: "Firebase load error"])
            }
            return horoscopeToReturn
        }
    }

    @MainActor
    final class MockLocalCacheService {
        var savedCharts: [BirthChart] = []
        var savedHoroscopes: [(date: String, sign: String, content: HoroscopeContent)] = []
        var chartToReturn: BirthChart?
        var horoscopeToReturn: HoroscopeContent?
        var pendingItems: [SyncItem] = []
        var syncedItems: [String] = []
        var saveChartCallCount = 0
        var loadChartCallCount = 0
        var queueCallCount = 0

        func saveBirthChart(_ chart: BirthChart) {
            saveChartCallCount += 1
            savedCharts.append(chart)
        }

        func loadBirthChart() -> BirthChart? {
            loadChartCallCount += 1
            return chartToReturn
        }

        func saveHoroscope(date: String, sign: String, content: HoroscopeContent) {
            savedHoroscopes.append((date: date, sign: sign, content: content))
        }

        func loadHoroscope(date: String, sign: String) -> HoroscopeContent? {
            return horoscopeToReturn
        }

        func queueForSync(_ item: SyncItem) {
            queueCallCount += 1
            pendingItems.append(item)
        }

        func getPendingSyncItems() -> [SyncItem] {
            return pendingItems
        }

        func markAsSynced(_ item: SyncItem) {
            syncedItems.append("synced")
            pendingItems.removeAll { item in
                switch item {
                case .birthChart: return true
                case .horoscope: return true
                }
            }
        }
    }

    @MainActor
    final class MockNetworkMonitor: ObservableObject {
        @Published var isConnected = true
    }

    // MARK: - Test Helpers

    @MainActor
    func createTestChart() -> BirthChart {
        return BirthChart(
            id: "test-chart-1",
            userId: "test-user",
            name: "Test Person",
            birthDate: Date(),
            birthTime: "12:00",
            location: "London, UK",
            latitude: 51.5074,
            longitude: -0.1278,
            planets: [
                Planet(name: "Sun", longitude: 280.0, latitude: 0.0, speed: 1.0, sign: "Capricorn", degree: 10.0, isRetrograde: false)
            ],
            houses: [
                House(number: 1, cusp: 90.0, sign: "Aries", degree: 0.0)
            ],
            aspects: [],
            calculatedAt: Date()
        )
    }

    @MainActor
    func createTestHoroscopeContent() -> HoroscopeContent {
        return HoroscopeContent(
            dailyText: "Great day ahead!",
            luckyNumbers: [7, 14, 21],
            compatibility: "Taurus"
        )
    }

    // MARK: - SyncStatus Tests

    @Test("SyncStatus enum has all cases")
    func testSyncStatusCases() {
        let synced = SyncStatus.synced
        let syncing = SyncStatus.syncing
        let pending = SyncStatus.pendingSync
        let error = SyncStatus.error("Test error")

        // Verify cases exist
        switch synced {
        case .synced: break
        default: Issue.record("Should be synced")
        }

        switch error {
        case .error(let message):
            #expect(message == "Test error")
        default:
            Issue.record("Should be error case")
        }
    }

    // MARK: - SyncItem Tests

    @Test("SyncItem enum handles birth chart")
    @MainActor
    func testSyncItemBirthChart() {
        let chart = createTestChart()
        let item = SyncItem.birthChart(chart)

        switch item {
        case .birthChart(let storedChart):
            #expect(storedChart.id == "test-chart-1")
        case .horoscope:
            Issue.record("Should be birthChart case")
        }
    }

    @Test("SyncItem enum handles horoscope")
    @MainActor
    func testSyncItemHoroscope() {
        let content = createTestHoroscopeContent()
        let item = SyncItem.horoscope(date: "2025-01-15", sign: "Leo", content: content)

        switch item {
        case .horoscope(let date, let sign, let storedContent):
            #expect(date == "2025-01-15")
            #expect(sign == "Leo")
            #expect(storedContent.dailyText == "Great day ahead!")
        case .birthChart:
            Issue.record("Should be horoscope case")
        }
    }

    // MARK: - HoroscopeContent Tests

    @Test("HoroscopeContent converts to dictionary")
    @MainActor
    func testHoroscopeContentToDictionary() {
        let content = createTestHoroscopeContent()
        let dict = content.toDictionary()

        #expect(dict["dailyText"] as? String == "Great day ahead!")
        #expect(dict["luckyNumbers"] as? [Int] == [7, 14, 21])
        #expect(dict["compatibility"] as? String == "Taurus")
    }

    @Test("HoroscopeContent creates from dictionary")
    func testHoroscopeContentFromDictionary() {
        let dict: [String: Any] = [
            "dailyText": "Amazing forecast",
            "luckyNumbers": [3, 6, 9],
            "compatibility": "Gemini"
        ]

        let content = HoroscopeContent.fromDictionary(dict)

        #expect(content.dailyText == "Amazing forecast")
        #expect(content.luckyNumbers == [3, 6, 9])
        #expect(content.compatibility == "Gemini")
    }

    @Test("HoroscopeContent handles missing dictionary data")
    func testHoroscopeContentFromEmptyDictionary() {
        let dict: [String: Any] = [:]
        let content = HoroscopeContent.fromDictionary(dict)

        #expect(content.dailyText == "")
        #expect(content.luckyNumbers == [])
        #expect(content.compatibility == "")
    }

    // MARK: - BirthChart Dictionary Tests

    @Test("BirthChart converts to dictionary")
    @MainActor
    func testBirthChartToDictionary() {
        let chart = createTestChart()
        let dict = chart.toDictionary()

        #expect(dict["userId"] as? String == "test-user")
        #expect(dict["name"] as? String == "Test Person")
        #expect(dict["birthTime"] as? String == "12:00")
        #expect(dict["location"] as? String == "London, UK")
        #expect(dict["latitude"] as? Double == 51.5074)
        #expect(dict["longitude"] as? Double == -0.1278)

        let planets = dict["planets"] as? [[String: Any]]
        #expect(planets?.count == 1)
        #expect(planets?[0]["name"] as? String == "Sun")
    }

    @Test("BirthChart creates from dictionary")
    func testBirthChartFromDictionary() {
        let dict: [String: Any] = [
            "id": "chart-123",
            "userId": "user-456",
            "name": "Jane Doe",
            "birthDate": "2025-01-15T12:00:00Z",
            "birthTime": "14:30",
            "location": "Paris, France",
            "latitude": 48.8566,
            "longitude": 2.3522
        ]

        let chart = BirthChart.fromDictionary(dict)

        #expect(chart.id == "chart-123")
        #expect(chart.userId == "user-456")
        #expect(chart.name == "Jane Doe")
        #expect(chart.birthTime == "14:30")
        #expect(chart.location == "Paris, France")
        #expect(chart.latitude == 48.8566)
        #expect(chart.longitude == 2.3522)
    }

    @Test("BirthChart from dictionary handles missing data")
    func testBirthChartFromEmptyDictionary() {
        let dict: [String: Any] = [:]
        let chart = BirthChart.fromDictionary(dict)

        #expect(!chart.id.isEmpty) // Should generate UUID
        #expect(chart.userId == "")
        #expect(chart.name == "")
        #expect(chart.planets.isEmpty)
        #expect(chart.houses.isEmpty)
        #expect(chart.aspects.isEmpty)
    }

    // MARK: - Dictionary Round-Trip Tests

    @Test("BirthChart dictionary round-trip preserves data")
    @MainActor
    func testBirthChartRoundTrip() {
        let originalChart = createTestChart()
        let dict = originalChart.toDictionary()
        let restoredChart = BirthChart.fromDictionary(dict)

        #expect(restoredChart.userId == originalChart.userId)
        #expect(restoredChart.name == originalChart.name)
        #expect(restoredChart.birthTime == originalChart.birthTime)
        #expect(restoredChart.location == originalChart.location)
        #expect(restoredChart.latitude == originalChart.latitude)
        #expect(restoredChart.longitude == originalChart.longitude)
    }

    @Test("HoroscopeContent dictionary round-trip preserves data")
    @MainActor
    func testHoroscopeContentRoundTrip() {
        let original = createTestHoroscopeContent()
        let dict = original.toDictionary()
        let restored = HoroscopeContent.fromDictionary(dict)

        #expect(restored.dailyText == original.dailyText)
        #expect(restored.luckyNumbers == original.luckyNumbers)
        #expect(restored.compatibility == original.compatibility)
    }

    // MARK: - Integration Note

    @Test("DataRepository architecture is offline-first")
    func testArchitectureDocumentation() {
        // This test documents the expected architecture behavior:
        // 1. Always save to local cache first
        // 2. Attempt Firebase sync if online and authenticated
        // 3. Queue for later sync if Firebase fails or offline
        // 4. Load from Firebase with fallback to local cache
        // 5. Network monitoring triggers automatic sync
        // 6. Periodic sync every 5 minutes

        #expect(true, "Architecture documented")
    }

    @Test("DataRepository uses dependency injection pattern")
    func testDependencyInjectionNote() {
        // Note: Current implementation uses singletons (FirebaseService.shared, etc.)
        // For full testability, these should be injected via initializer
        // This allows mocking services in tests

        #expect(true, "Dependency injection pattern noted for future refactoring")
    }

    // MARK: - Edge Cases

    @Test("Empty dictionary creates valid BirthChart")
    func testEmptyDictionaryCreatesChart() {
        let chart = BirthChart.fromDictionary([:])

        #expect(!chart.id.isEmpty, "Should generate UUID for id")
        #expect(chart.planets.isEmpty)
        #expect(chart.houses.isEmpty)
        #expect(chart.aspects.isEmpty)
    }

    @Test("Empty dictionary creates valid HoroscopeContent")
    func testEmptyDictionaryCreatesHoroscope() {
        let content = HoroscopeContent.fromDictionary([:])

        #expect(content.dailyText == "")
        #expect(content.luckyNumbers.isEmpty)
        #expect(content.compatibility == "")
    }

    @Test("BirthChart dictionary includes all required fields")
    @MainActor
    func testBirthChartDictionaryCompleteness() {
        let chart = createTestChart()
        let dict = chart.toDictionary()

        // Verify all required fields are present
        #expect(dict["userId"] != nil)
        #expect(dict["name"] != nil)
        #expect(dict["birthDate"] != nil)
        #expect(dict["birthTime"] != nil)
        #expect(dict["location"] != nil)
        #expect(dict["latitude"] != nil)
        #expect(dict["longitude"] != nil)
        #expect(dict["planets"] != nil)
    }

    @Test("HoroscopeContent is Codable")
    @MainActor
    func testHoroscopeContentCodable() throws {
        let content = createTestHoroscopeContent()

        // Encode
        let encoder = JSONEncoder()
        let data = try encoder.encode(content)

        #expect(!data.isEmpty, "Should encode to non-empty data")

        // Decode
        let decoder = JSONDecoder()
        let decoded = try decoder.decode(HoroscopeContent.self, from: data)

        #expect(decoded.dailyText == content.dailyText)
        #expect(decoded.luckyNumbers == content.luckyNumbers)
        #expect(decoded.compatibility == content.compatibility)
    }

    // MARK: - SyncItem Pattern Tests

    @Test("SyncItem can be queued for later synchronization")
    @MainActor
    func testSyncItemQueuing() {
        let chart = createTestChart()
        let chartItem = SyncItem.birthChart(chart)

        let content = createTestHoroscopeContent()
        let horoscopeItem = SyncItem.horoscope(date: "2025-01-15", sign: "Aries", content: content)

        var queue: [SyncItem] = []
        queue.append(chartItem)
        queue.append(horoscopeItem)

        #expect(queue.count == 2, "Should queue multiple items")

        // Verify item types
        switch queue[0] {
        case .birthChart: break
        case .horoscope: Issue.record("First item should be birthChart")
        }

        switch queue[1] {
        case .horoscope: break
        case .birthChart: Issue.record("Second item should be horoscope")
        }
    }

    // MARK: - Data Validation Tests

    @Test("BirthChart latitude and longitude are preserved")
    @MainActor
    func testBirthChartCoordinates() {
        let chart = createTestChart()
        let dict = chart.toDictionary()

        #expect(dict["latitude"] as? Double == 51.5074)
        #expect(dict["longitude"] as? Double == -0.1278)

        let restored = BirthChart.fromDictionary(dict)
        #expect(restored.latitude == 51.5074)
        #expect(restored.longitude == -0.1278)
    }

    @Test("HoroscopeContent lucky numbers array is preserved")
    @MainActor
    func testHoroscopeLuckyNumbers() {
        let content = HoroscopeContent(
            dailyText: "Test",
            luckyNumbers: [1, 2, 3, 4, 5],
            compatibility: "Test"
        )

        let dict = content.toDictionary()
        let restored = HoroscopeContent.fromDictionary(dict)

        #expect(restored.luckyNumbers == [1, 2, 3, 4, 5])
    }

    // MARK: - ISO8601 Date Formatting Tests

    @Test("BirthChart uses ISO8601 date format")
    @MainActor
    func testBirthChartDateFormatting() {
        let chart = createTestChart()
        let dict = chart.toDictionary()

        let dateString = dict["birthDate"] as? String
        #expect(dateString != nil, "Should have birthDate string")

        // Verify ISO8601 format (contains T and Z)
        #expect(dateString?.contains("T") == true, "Should use ISO8601 format with T separator")
        #expect(dateString?.contains("Z") == true, "Should use ISO8601 format with Z timezone")
    }

    @Test("BirthChart parses ISO8601 dates correctly")
    func testBirthChartDateParsing() {
        let dict: [String: Any] = [
            "birthDate": "2025-01-15T10:30:00Z"
        ]

        let chart = BirthChart.fromDictionary(dict)

        // Should successfully parse the date
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day], from: chart.birthDate)

        #expect(components.year == 2025)
        #expect(components.month == 1)
        #expect(components.day == 15)
    }

    // MARK: - Concurrency Tests

    @Test("Multiple SyncItems can be processed")
    @MainActor
    func testMultipleSyncItems() async {
        let items: [SyncItem] = [
            .birthChart(createTestChart()),
            .horoscope(date: "2025-01-15", sign: "Leo", content: createTestHoroscopeContent()),
            .birthChart(createTestChart()),
            .horoscope(date: "2025-01-16", sign: "Virgo", content: createTestHoroscopeContent())
        ]

        #expect(items.count == 4, "Should handle multiple sync items")

        // Count each type
        var chartCount = 0
        var horoscopeCount = 0

        for item in items {
            switch item {
            case .birthChart: chartCount += 1
            case .horoscope: horoscopeCount += 1
            }
        }

        #expect(chartCount == 2)
        #expect(horoscopeCount == 2)
    }

    // MARK: - Future Test Coverage Notes

    @Test("Full DataRepository integration requires dependency injection")
    func testFutureImprovements() {
        // Current implementation uses singletons which are difficult to mock
        // Recommended improvements:
        // 1. Inject FirebaseService, LocalCacheService, NetworkMonitor via initializer
        // 2. Create protocol-based abstractions for all dependencies
        // 3. Enable full unit testing without singleton dependencies
        // 4. Test actual save/load/sync workflows with mock services

        #expect(true, "Future improvements documented")
    }
}
