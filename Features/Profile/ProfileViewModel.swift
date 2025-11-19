import Foundation
import SwiftUI
import Combine

/// ViewModel for Profile screen
/// Manages user profile data, settings, and authentication state
@MainActor
final class ProfileViewModel: ObservableObject {

    // MARK: - Published Properties

    @Published var user: User?
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var showError = false
    @Published var birthData: BirthData?

    // Notifications
    @Published var notificationsEnabled = false
    @Published var dailyHoroscopeTime = Date()
    @Published var transitAlertsEnabled = true
    @Published var retrogradeAlertsEnabled = true

    // Settings
    @Published var animationsEnabled = true
    @Published var hapticFeedbackEnabled = true
    @Published var autoBackupEnabled = true

    // MARK: - Services

    private let firebaseService: FirebaseService
    private let secureStorage: SecureStorageService
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Initialization

    init(
        firebaseService: FirebaseService = .shared,
        secureStorage: SecureStorageService = .shared
    ) {
        self.firebaseService = firebaseService
        self.secureStorage = secureStorage

        loadUserData()
        loadSettings()
        loadBirthData()
    }

    // MARK: - Data Loading

    /// Load user data from Firebase
    func loadUserData() {
        guard let userId = firebaseService.currentUser?.uid else { return }

        isLoading = true

        Task {
            do {
                user = try await firebaseService.getUser(userId: userId)
                isLoading = false
            } catch {
                handleError(error)
            }
        }
    }

    /// Load birth data from secure storage
    func loadBirthData() {
        do {
            birthData = try secureStorage.retrieveBirthData()
        } catch {
            print("⚠️ Failed to load birth data: \(error)")
        }
    }

    /// Load settings from UserDefaults
    func loadSettings() {
        animationsEnabled = UserDefaults.standard.bool(forKey: "animations_enabled")
        hapticFeedbackEnabled = UserDefaults.standard.bool(forKey: "haptic_feedback_enabled")
        autoBackupEnabled = UserDefaults.standard.bool(forKey: "auto_backup_enabled")

        // Notifications
        notificationsEnabled = UserDefaults.standard.bool(forKey: "notifications_enabled")
        transitAlertsEnabled = UserDefaults.standard.bool(forKey: "transit_alerts_enabled")
        retrogradeAlertsEnabled = UserDefaults.standard.bool(forKey: "retrograde_alerts_enabled")

        if let timeInterval = UserDefaults.standard.object(forKey: "daily_horoscope_time") as? TimeInterval {
            dailyHoroscopeTime = Date(timeIntervalSince1970: timeInterval)
        }
    }

    // MARK: - Profile Updates

    /// Update user profile
    func updateProfile(name: String) async throws {
        guard let userId = firebaseService.currentUser?.uid else { return }

        isLoading = true

        do {
            let updates: [String: Any] = ["name": name]
            try await firebaseService.updateUser(userId: userId, updates: updates)

            // Reload user data
            user = try await firebaseService.getUser(userId: userId)
            isLoading = false
        } catch {
            handleError(error)
            throw error
        }
    }

    /// Update birth data
    func updateBirthData(_ newBirthData: BirthData) throws {
        try secureStorage.storeBirthData(newBirthData)
        birthData = newBirthData
    }

    // MARK: - Settings Updates

    /// Save notification settings
    func saveNotificationSettings() {
        UserDefaults.standard.set(notificationsEnabled, forKey: "notifications_enabled")
        UserDefaults.standard.set(transitAlertsEnabled, forKey: "transit_alerts_enabled")
        UserDefaults.standard.set(retrogradeAlertsEnabled, forKey: "retrograde_alerts_enabled")
        UserDefaults.standard.set(dailyHoroscopeTime.timeIntervalSince1970, forKey: "daily_horoscope_time")

        // Request notification permissions if enabled
        if notificationsEnabled {
            requestNotificationPermissions()
        }
    }

    /// Save app settings
    func saveAppSettings() {
        UserDefaults.standard.set(animationsEnabled, forKey: "animations_enabled")
        UserDefaults.standard.set(hapticFeedbackEnabled, forKey: "haptic_feedback_enabled")
        UserDefaults.standard.set(autoBackupEnabled, forKey: "auto_backup_enabled")
    }

    // MARK: - Notifications

    /// Request notification permissions
    private func requestNotificationPermissions() {
        Task {
            do {
                let center = UNUserNotificationCenter.current()
                let granted = try await center.requestAuthorization(options: [.alert, .sound, .badge])

                if granted {
                    print("✅ Notification permissions granted")
                    scheduleNotifications()
                } else {
                    print("⚠️ Notification permissions denied")
                    notificationsEnabled = false
                }
            } catch {
                print("❌ Failed to request notification permissions: \(error)")
            }
        }
    }

    /// Schedule daily horoscope notifications
    private func scheduleNotifications() {
        guard notificationsEnabled else { return }

        let center = UNUserNotificationCenter.current()

        // Remove existing notifications
        center.removeAllPendingNotificationRequests()

        // Schedule daily horoscope
        let content = UNMutableNotificationContent()
        content.title = String(.todayHoroscope)
        content.body = "Узнайте, что звезды приготовили для вас сегодня"
        content.sound = .default

        var dateComponents = Calendar.current.dateComponents([.hour, .minute], from: dailyHoroscopeTime)
        dateComponents.second = 0

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: "daily_horoscope", content: content, trigger: trigger)

        center.add(request) { error in
            if let error = error {
                print("❌ Failed to schedule notification: \(error)")
            }
        }
    }

    // MARK: - Authentication

    /// Sign out user
    func signOut() async throws {
        isLoading = true

        do {
            try await firebaseService.signOut()

            // Clear local data
            user = nil
            birthData = nil

            isLoading = false
        } catch {
            handleError(error)
            throw error
        }
    }

    /// Delete user account
    func deleteAccount() async throws {
        isLoading = true

        do {
            try await firebaseService.deleteAccount()

            // Clear local data
            user = nil
            birthData = nil
            try? secureStorage.clearBirthData()

            isLoading = false
        } catch {
            handleError(error)
            throw error
        }
    }

    // MARK: - Subscription

    var isPro: Bool {
        user?.isPro ?? false
    }

    var isGuru: Bool {
        user?.isGuru ?? false
    }

    var subscriptionTier: String {
        if isGuru {
            return "GURU"
        } else if isPro {
            return "PRO"
        } else {
            return "Free"
        }
    }

    // MARK: - Error Handling

    private func handleError(_ error: Error) {
        isLoading = false
        errorMessage = error.localizedDescription
        showError = true
    }
}

// MARK: - UserNotifications Import

import UserNotifications
