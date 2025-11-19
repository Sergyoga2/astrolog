import Foundation
import UserNotifications
import Combine

/// Service for managing local and push notifications
@MainActor
class NotificationService: ObservableObject {
    static let shared = NotificationService()

    @Published var isAuthorized = false
    @Published var notificationSettings: [NotificationSetting] = []
    @Published var pendingNotifications: [UNNotificationRequest] = []

    private let center = UNUserNotificationCenter.current()
    private let firebaseService = FirebaseService.shared

    private init() {
        setupNotificationDelegate()
        Task {
            await checkAuthorizationStatus()
        }
    }

    // MARK: - Authorization

    /// Request notification permissions
    func requestAuthorization() async -> Bool {
        do {
            let granted = try await center.requestAuthorization(options: [.alert, .sound, .badge])
            isAuthorized = granted

            if granted {
                await registerForRemoteNotifications()
            }

            return granted
        } catch {
            print("Error requesting notification authorization: \(error)")
            return false
        }
    }

    /// Check current authorization status
    func checkAuthorizationStatus() async {
        let settings = await center.notificationSettings()
        isAuthorized = settings.authorizationStatus == .authorized
    }

    /// Register for remote notifications (APNs)
    private func registerForRemoteNotifications() async {
        await MainActor.run {
            #if !targetEnvironment(simulator)
            UIApplication.shared.registerForRemoteNotifications()
            #endif
        }
    }

    // MARK: - Daily Horoscope Notifications

    /// Schedule daily horoscope notification
    func scheduleDailyHoroscope(for zodiacSign: ZodiacSign, at time: DateComponents) async {
        // Cancel existing daily horoscope notifications
        center.removePendingNotificationRequests(withIdentifiers: ["daily_horoscope"])

        // Create notification content
        let content = UNMutableNotificationContent()
        content.title = "Ваш гороскоп на сегодня"
        content.body = "Узнайте, что день готовит для \(zodiacSign.rawValue) ✨"
        content.sound = .default
        content.badge = 1
        content.categoryIdentifier = "HOROSCOPE"
        content.userInfo = [
            "type": "daily_horoscope",
            "zodiacSign": zodiacSign.rawValue
        ]

        // Create trigger for daily notification
        let trigger = UNCalendarNotificationTrigger(
            dateMatching: time,
            repeats: true
        )

        // Create request
        let request = UNNotificationRequest(
            identifier: "daily_horoscope",
            content: content,
            trigger: trigger
        )

        do {
            try await center.add(request)
            print("Daily horoscope notification scheduled for \(time.hour ?? 9):\(time.minute ?? 0)")
        } catch {
            print("Error scheduling daily horoscope: \(error)")
        }
    }

    /// Cancel daily horoscope notifications
    func cancelDailyHoroscope() {
        center.removePendingNotificationRequests(withIdentifiers: ["daily_horoscope"])
    }

    // MARK: - Transit Notifications

    /// Schedule notification for important transit
    func scheduleTransitNotification(
        title: String,
        message: String,
        date: Date,
        transitId: String
    ) async {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = message
        content.sound = .default
        content.categoryIdentifier = "TRANSIT"
        content.userInfo = [
            "type": "transit",
            "transitId": transitId
        ]

        // Trigger at specific date
        let components = Calendar.current.dateComponents(
            [.year, .month, .day, .hour, .minute],
            from: date
        )
        let trigger = UNCalendarNotificationTrigger(
            dateMatching: components,
            repeats: false
        )

        let request = UNNotificationRequest(
            identifier: "transit_\(transitId)",
            content: content,
            trigger: trigger
        )

        do {
            try await center.add(request)
        } catch {
            print("Error scheduling transit notification: \(error)")
        }
    }

    // MARK: - Meditation Reminders

    /// Schedule meditation reminder
    func scheduleMeditationReminder(at time: DateComponents) async {
        center.removePendingNotificationRequests(withIdentifiers: ["meditation_reminder"])

        let content = UNMutableNotificationContent()
        content.title = "Время медитации"
        content.body = "Найдите несколько минут для осознанности 🧘‍♀️"
        content.sound = .default
        content.categoryIdentifier = "MEDITATION"
        content.userInfo = ["type": "meditation_reminder"]

        let trigger = UNCalendarNotificationTrigger(
            dateMatching: time,
            repeats: true
        )

        let request = UNNotificationRequest(
            identifier: "meditation_reminder",
            content: content,
            trigger: trigger
        )

        do {
            try await center.add(request)
        } catch {
            print("Error scheduling meditation reminder: \(error)")
        }
    }

    /// Cancel meditation reminders
    func cancelMeditationReminder() {
        center.removePendingNotificationRequests(withIdentifiers: ["meditation_reminder"])
    }

    // MARK: - Friend Request Notifications

    /// Send friend request notification (via server/Firebase Cloud Messaging)
    func sendFriendRequestNotification(to userId: String, from userName: String) async {
        // This would typically be handled by Firebase Cloud Functions
        // Triggering a push notification via FCM
        let notificationData: [String: Any] = [
            "type": "friend_request",
            "fromUserId": firebaseService.currentUser?.uid ?? "",
            "fromUserName": userName,
            "toUserId": userId
        ]

        // Save notification document in Firestore
        // Firebase Cloud Function will pick it up and send push notification
        do {
            try await firebaseService.sendPushNotification(data: notificationData)
        } catch {
            print("Error sending friend request notification: \(error)")
        }
    }

    // MARK: - Notification Management

    /// Get all pending notifications
    func loadPendingNotifications() async {
        pendingNotifications = await center.pendingNotificationRequests()
    }

    /// Cancel specific notification
    func cancelNotification(identifier: String) {
        center.removePendingNotificationRequests(withIdentifiers: [identifier])
    }

    /// Cancel all notifications
    func cancelAllNotifications() {
        center.removeAllPendingNotificationRequests()
    }

    /// Get delivered notifications
    func getDeliveredNotifications() async -> [UNNotification] {
        return await center.deliveredNotifications()
    }

    /// Clear delivered notifications
    func clearDeliveredNotifications() {
        center.removeAllDeliveredNotifications()
    }

    /// Reset badge count
    func resetBadgeCount() {
        Task { @MainActor in
            UIApplication.shared.applicationIconBadgeNumber = 0
        }
    }

    // MARK: - Notification Categories

    private func setupNotificationCategories() {
        // Horoscope category
        let horoscopeCategory = UNNotificationCategory(
            identifier: "HOROSCOPE",
            actions: [
                UNNotificationAction(
                    identifier: "VIEW_HOROSCOPE",
                    title: "Смотреть",
                    options: .foreground
                )
            ],
            intentIdentifiers: [],
            options: []
        )

        // Transit category
        let transitCategory = UNNotificationCategory(
            identifier: "TRANSIT",
            actions: [
                UNNotificationAction(
                    identifier: "VIEW_TRANSIT",
                    title: "Подробнее",
                    options: .foreground
                )
            ],
            intentIdentifiers: [],
            options: []
        )

        // Meditation category
        let meditationCategory = UNNotificationCategory(
            identifier: "MEDITATION",
            actions: [
                UNNotificationAction(
                    identifier: "START_MEDITATION",
                    title: "Начать",
                    options: .foreground
                ),
                UNNotificationAction(
                    identifier: "SKIP_MEDITATION",
                    title: "Напомнить позже",
                    options: []
                )
            ],
            intentIdentifiers: [],
            options: []
        )

        center.setNotificationCategories([
            horoscopeCategory,
            transitCategory,
            meditationCategory
        ])
    }

    // MARK: - Notification Delegate

    private func setupNotificationDelegate() {
        setupNotificationCategories()
        center.delegate = NotificationDelegate.shared
    }
}

// MARK: - Notification Delegate

class NotificationDelegate: NSObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationDelegate()

    // Handle notification when app is in foreground
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        // Show notification even when app is in foreground
        completionHandler([.banner, .sound, .badge])
    }

    // Handle notification tap
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let userInfo = response.notification.request.content.userInfo

        // Handle different notification types
        if let type = userInfo["type"] as? String {
            Task { @MainActor in
                handleNotificationResponse(type: type, userInfo: userInfo, actionIdentifier: response.actionIdentifier)
            }
        }

        completionHandler()
    }

    @MainActor
    private func handleNotificationResponse(
        type: String,
        userInfo: [AnyHashable: Any],
        actionIdentifier: String
    ) {
        switch type {
        case "daily_horoscope":
            // Navigate to today's horoscope
            NotificationCenter.default.post(
                name: .navigateToHoroscope,
                object: nil,
                userInfo: userInfo
            )

        case "transit":
            // Navigate to transit details
            NotificationCenter.default.post(
                name: .navigateToTransit,
                object: nil,
                userInfo: userInfo
            )

        case "meditation_reminder":
            if actionIdentifier == "START_MEDITATION" {
                // Navigate to meditation library
                NotificationCenter.default.post(
                    name: .navigateToMeditation,
                    object: nil
                )
            }

        case "friend_request":
            // Navigate to friends list
            NotificationCenter.default.post(
                name: .navigateToFriends,
                object: nil,
                userInfo: userInfo
            )

        default:
            break
        }
    }
}

// MARK: - Notification Settings Model

struct NotificationSetting: Identifiable {
    let id = UUID()
    let type: NotificationType
    var isEnabled: Bool
    var time: DateComponents?

    enum NotificationType: String, CaseIterable {
        case dailyHoroscope = "Ежедневный гороскоп"
        case transits = "Важные транзиты"
        case meditation = "Напоминания о медитации"
        case friendRequests = "Запросы в друзья"
        case compatibilityUpdates = "Обновления совместимости"

        var icon: String {
            switch self {
            case .dailyHoroscope:
                return "star.circle"
            case .transits:
                return "arrow.triangle.2.circlepath"
            case .meditation:
                return "leaf"
            case .friendRequests:
                return "person.2"
            case .compatibilityUpdates:
                return "heart"
            }
        }
    }
}

// MARK: - Firebase Service Extension

extension FirebaseService {
    /// Send push notification via Firebase Cloud Functions
    func sendPushNotification(data: [String: Any]) async throws {
        // This would trigger a Firebase Cloud Function
        // that sends a push notification via FCM
        try await db.collection("notifications")
            .document()
            .setData(data)
    }
}

// MARK: - Notification Names

extension Notification.Name {
    static let navigateToHoroscope = Notification.Name("navigateToHoroscope")
    static let navigateToTransit = Notification.Name("navigateToTransit")
    static let navigateToMeditation = Notification.Name("navigateToMeditation")
    static let navigateToFriends = Notification.Name("navigateToFriends")
}
