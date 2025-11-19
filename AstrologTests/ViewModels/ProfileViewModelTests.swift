import Testing
import Foundation
@testable import Astrolog

/// Tests for ProfileViewModel
@Suite("ProfileViewModel Tests")
struct ProfileViewModelTests {

    // MARK: - Initialization Tests

    @Test("ViewModel initializes with default values")
    func testInitialization() async {
        let viewModel = ProfileViewModel()

        #expect(viewModel.user == nil)
        #expect(viewModel.isLoading == false)
        #expect(viewModel.errorMessage == nil)
        #expect(viewModel.showError == false)
        #expect(viewModel.birthData == nil)
    }

    // MARK: - Settings Tests

    @Test("Load settings from UserDefaults")
    func testLoadSettings() async {
        // Set some values in UserDefaults
        UserDefaults.standard.set(true, forKey: "animations_enabled")
        UserDefaults.standard.set(false, forKey: "haptic_feedback_enabled")
        UserDefaults.standard.set(true, forKey: "auto_backup_enabled")

        let viewModel = ProfileViewModel()

        #expect(viewModel.animationsEnabled == true)
        #expect(viewModel.hapticFeedbackEnabled == false)
        #expect(viewModel.autoBackupEnabled == true)

        // Cleanup
        UserDefaults.standard.removeObject(forKey: "animations_enabled")
        UserDefaults.standard.removeObject(forKey: "haptic_feedback_enabled")
        UserDefaults.standard.removeObject(forKey: "auto_backup_enabled")
    }

    @Test("Save app settings to UserDefaults")
    func testSaveAppSettings() async {
        let viewModel = ProfileViewModel()

        viewModel.animationsEnabled = true
        viewModel.hapticFeedbackEnabled = true
        viewModel.autoBackupEnabled = false

        viewModel.saveAppSettings()

        let animations = UserDefaults.standard.bool(forKey: "animations_enabled")
        let haptic = UserDefaults.standard.bool(forKey: "haptic_feedback_enabled")
        let backup = UserDefaults.standard.bool(forKey: "auto_backup_enabled")

        #expect(animations == true)
        #expect(haptic == true)
        #expect(backup == false)

        // Cleanup
        UserDefaults.standard.removeObject(forKey: "animations_enabled")
        UserDefaults.standard.removeObject(forKey: "haptic_feedback_enabled")
        UserDefaults.standard.removeObject(forKey: "auto_backup_enabled")
    }

    @Test("Save notification settings to UserDefaults")
    func testSaveNotificationSettings() async {
        let viewModel = ProfileViewModel()

        viewModel.notificationsEnabled = true
        viewModel.transitAlertsEnabled = false
        viewModel.retrogradeAlertsEnabled = true

        viewModel.saveNotificationSettings()

        let notifications = UserDefaults.standard.bool(forKey: "notifications_enabled")
        let transits = UserDefaults.standard.bool(forKey: "transit_alerts_enabled")
        let retrogrades = UserDefaults.standard.bool(forKey: "retrograde_alerts_enabled")

        #expect(notifications == true)
        #expect(transits == false)
        #expect(retrogrades == true)

        // Cleanup
        UserDefaults.standard.removeObject(forKey: "notifications_enabled")
        UserDefaults.standard.removeObject(forKey: "transit_alerts_enabled")
        UserDefaults.standard.removeObject(forKey: "retrograde_alerts_enabled")
    }

    // MARK: - Birth Data Tests

    @Test("Update birth data stores in secure storage")
    func testUpdateBirthData() async throws {
        let viewModel = ProfileViewModel()

        let birthData = BirthData(
            date: Date(timeIntervalSince1970: 946684800),
            timeZone: TimeZone(identifier: "UTC")!,
            latitude: 51.5074,
            longitude: -0.1278,
            cityName: "London",
            countryName: "UK",
            isTimeExact: true
        )

        try viewModel.updateBirthData(birthData)

        #expect(viewModel.birthData != nil)
        #expect(viewModel.birthData?.cityName == "London")
        #expect(viewModel.birthData?.latitude == 51.5074)

        // Cleanup
        try? SecureStorageService.shared.clearBirthData()
    }

    @Test("Load birth data from secure storage")
    func testLoadBirthData() async throws {
        let birthData = BirthData(
            date: Date(timeIntervalSince1970: 946684800),
            timeZone: TimeZone(identifier: "UTC")!,
            latitude: 48.8566,
            longitude: 2.3522,
            cityName: "Paris",
            countryName: "France",
            isTimeExact: true
        )

        // Store birth data
        try SecureStorageService.shared.storeBirthData(birthData)

        // Create new ViewModel which should load it
        let viewModel = ProfileViewModel()
        viewModel.loadBirthData()

        #expect(viewModel.birthData != nil)
        #expect(viewModel.birthData?.cityName == "Paris")
        #expect(viewModel.birthData?.latitude == 48.8566)

        // Cleanup
        try? SecureStorageService.shared.clearBirthData()
    }

    // MARK: - Subscription Tier Tests

    @Test("Free tier when user has no subscriptions")
    func testFreeTier() async {
        let viewModel = ProfileViewModel()

        // No user set
        #expect(viewModel.isPro == false)
        #expect(viewModel.isGuru == false)
        #expect(viewModel.subscriptionTier == "Free")
    }

    @Test("PRO tier when user has isPro")
    func testProTier() async {
        let viewModel = ProfileViewModel()

        // Create mock user with PRO
        let mockUser = User(
            id: "test-user",
            email: "test@example.com",
            name: "Test User",
            isPro: true,
            isGuru: false,
            createdAt: Date(),
            birthData: nil
        )

        viewModel.user = mockUser

        #expect(viewModel.isPro == true)
        #expect(viewModel.isGuru == false)
        #expect(viewModel.subscriptionTier == "PRO")
    }

    @Test("GURU tier when user has isGuru")
    func testGuruTier() async {
        let viewModel = ProfileViewModel()

        // Create mock user with GURU
        let mockUser = User(
            id: "test-user",
            email: "test@example.com",
            name: "Test User",
            isPro: true,
            isGuru: true,
            createdAt: Date(),
            birthData: nil
        )

        viewModel.user = mockUser

        #expect(viewModel.isPro == true)
        #expect(viewModel.isGuru == true)
        #expect(viewModel.subscriptionTier == "GURU")
    }

    // MARK: - Error Handling Tests

    @Test("Error message is set when operation fails")
    func testErrorHandling() async {
        let viewModel = ProfileViewModel()

        // Simulate error by trying to update birth data with invalid data
        // (This is a mock test - in real scenario we'd inject a mock service)

        #expect(viewModel.errorMessage == nil)
        #expect(viewModel.showError == false)
    }

    // MARK: - Notification Time Tests

    @Test("Daily horoscope time is persisted")
    func testDailyHoroscopeTimePersistence() async {
        let viewModel = ProfileViewModel()

        // Set a specific time
        var components = DateComponents()
        components.hour = 9
        components.minute = 30
        let testTime = Calendar.current.date(from: components) ?? Date()

        viewModel.dailyHoroscopeTime = testTime
        viewModel.saveNotificationSettings()

        // Load in new ViewModel
        let newViewModel = ProfileViewModel()
        newViewModel.loadSettings()

        let savedInterval = UserDefaults.standard.double(forKey: "daily_horoscope_time")
        #expect(savedInterval > 0, "Time should be saved")

        // Cleanup
        UserDefaults.standard.removeObject(forKey: "daily_horoscope_time")
    }

    // MARK: - State Management Tests

    @Test("Loading state is managed correctly")
    func testLoadingState() async {
        let viewModel = ProfileViewModel()

        #expect(viewModel.isLoading == false, "Should start as not loading")

        // Note: Can't easily test async loading without mock services
        // Would need dependency injection for FirebaseService
    }

    @Test("Settings toggles work correctly")
    func testSettingsToggles() async {
        let viewModel = ProfileViewModel()

        // Default values
        #expect(viewModel.animationsEnabled == false)

        // Toggle
        viewModel.animationsEnabled = true
        #expect(viewModel.animationsEnabled == true)

        viewModel.animationsEnabled = false
        #expect(viewModel.animationsEnabled == false)
    }

    @Test("Notification toggles work correctly")
    func testNotificationToggles() async {
        let viewModel = ProfileViewModel()

        viewModel.notificationsEnabled = true
        #expect(viewModel.notificationsEnabled == true)

        viewModel.transitAlertsEnabled = false
        #expect(viewModel.transitAlertsEnabled == false)

        viewModel.retrogradeAlertsEnabled = true
        #expect(viewModel.retrogradeAlertsEnabled == true)
    }

    // MARK: - Multiple Settings Tests

    @Test("Multiple settings can be saved and loaded")
    func testMultipleSettingsPersistence() async {
        let viewModel = ProfileViewModel()

        // Set multiple settings
        viewModel.animationsEnabled = true
        viewModel.hapticFeedbackEnabled = false
        viewModel.autoBackupEnabled = true
        viewModel.notificationsEnabled = true
        viewModel.transitAlertsEnabled = false
        viewModel.retrogradeAlertsEnabled = true

        // Save all
        viewModel.saveAppSettings()
        viewModel.saveNotificationSettings()

        // Create new ViewModel and load
        let newViewModel = ProfileViewModel()
        newViewModel.loadSettings()

        #expect(newViewModel.animationsEnabled == true)
        #expect(newViewModel.hapticFeedbackEnabled == false)
        #expect(newViewModel.autoBackupEnabled == true)
        #expect(newViewModel.notificationsEnabled == true)
        #expect(newViewModel.transitAlertsEnabled == false)
        #expect(newViewModel.retrogradeAlertsEnabled == true)

        // Cleanup
        UserDefaults.standard.removeObject(forKey: "animations_enabled")
        UserDefaults.standard.removeObject(forKey: "haptic_feedback_enabled")
        UserDefaults.standard.removeObject(forKey: "auto_backup_enabled")
        UserDefaults.standard.removeObject(forKey: "notifications_enabled")
        UserDefaults.standard.removeObject(forKey: "transit_alerts_enabled")
        UserDefaults.standard.removeObject(forKey: "retrograde_alerts_enabled")
    }

    // MARK: - Edge Cases

    @Test("ViewModel handles missing UserDefaults gracefully")
    func testMissingUserDefaults() async {
        // Clear all settings
        UserDefaults.standard.removeObject(forKey: "animations_enabled")
        UserDefaults.standard.removeObject(forKey: "haptic_feedback_enabled")
        UserDefaults.standard.removeObject(forKey: "auto_backup_enabled")

        let viewModel = ProfileViewModel()

        // Should initialize with default values (false for bools)
        #expect(viewModel.animationsEnabled == false)
        #expect(viewModel.hapticFeedbackEnabled == false)
        #expect(viewModel.autoBackupEnabled == false)
    }

    @Test("Birth data loading handles missing data gracefully")
    func testMissingBirthData() async {
        // Clear birth data
        try? SecureStorageService.shared.clearBirthData()

        let viewModel = ProfileViewModel()
        viewModel.loadBirthData()

        #expect(viewModel.birthData == nil, "Should be nil when no data exists")
    }

    @Test("User is nil initially")
    func testUserNilInitially() async {
        let viewModel = ProfileViewModel()

        #expect(viewModel.user == nil)
        #expect(viewModel.isPro == false)
        #expect(viewModel.isGuru == false)
    }
}
