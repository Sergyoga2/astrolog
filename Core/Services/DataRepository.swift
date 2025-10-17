import Foundation
import Combine

@MainActor
class DataRepository: ObservableObject {
    static let shared = DataRepository()

    @Published var syncStatus: SyncStatus = .synced
    @Published var isOnline = true

    private let firebaseService = FirebaseService.shared
    private let localCache = LocalCacheService.shared
    private let networkMonitor = NetworkMonitor.shared
    private var cancellables = Set<AnyCancellable>()

    private init() {
        setupNetworkMonitoring()
    }

    private func setupNetworkMonitoring() {
        // Monitor network connectivity changes
        networkMonitor.$isConnected
            .sink { [weak self] isConnected in
                self?.isOnline = isConnected
                if isConnected {
                    self?.syncIfNeeded()
                }
            }
            .store(in: &cancellables)

        // Periodic sync for authenticated users
        Timer.publish(every: 300, on: .main, in: .common) // every 5 minutes
            .autoconnect()
            .sink { [weak self] _ in
                self?.syncIfNeeded()
            }
            .store(in: &cancellables)
    }
}

// MARK: - Birth Chart Management
extension DataRepository {
    func saveBirthChart(_ chartData: BirthChart) async throws {
        // Always save to local cache first
        localCache.saveBirthChart(chartData)

        // Try to sync to Firebase if online
        if isOnline && firebaseService.isAuthenticated {
            do {
                let chartDict = chartData.toDictionary()
                try await firebaseService.saveBirthChart(chartDict)
                syncStatus = .synced
            } catch {
                syncStatus = .pendingSync
                // Queue for later sync
                localCache.queueForSync(.birthChart(chartData))
            }
        } else {
            syncStatus = .pendingSync
            localCache.queueForSync(.birthChart(chartData))
        }
    }

    func loadBirthChart() async -> BirthChart? {
        // Try to load from Firebase first if online
        if isOnline && firebaseService.isAuthenticated {
            do {
                if let chartData = try await firebaseService.loadBirthChart() {
                    let birthChart = BirthChart.fromDictionary(chartData)
                    // Update local cache
                    localCache.saveBirthChart(birthChart)
                    return birthChart
                }
            } catch {
                print("Failed to load from Firebase: \(error)")
            }
        }

        // Fallback to local cache
        return localCache.loadBirthChart()
    }
}

// MARK: - Horoscope Management
extension DataRepository {
    func saveHoroscope(date: String, sign: String, content: HoroscopeContent) async throws {
        // Save to local cache
        localCache.saveHoroscope(date: date, sign: sign, content: content)

        // Sync to Firebase if online
        if isOnline && firebaseService.isAuthenticated {
            do {
                try await firebaseService.saveHoroscope(
                    date: date,
                    sign: sign,
                    content: content.toDictionary()
                )
            } catch {
                localCache.queueForSync(.horoscope(date: date, sign: sign, content: content))
            }
        } else {
            localCache.queueForSync(.horoscope(date: date, sign: sign, content: content))
        }
    }

    func loadHoroscope(date: String, sign: String) async -> HoroscopeContent? {
        // Try Firebase first if online
        if isOnline && firebaseService.isAuthenticated {
            do {
                if let contentData = try await firebaseService.loadHoroscope(date: date, sign: sign) {
                    let content = HoroscopeContent.fromDictionary(contentData)
                    // Update local cache
                    localCache.saveHoroscope(date: date, sign: sign, content: content)
                    return content
                }
            } catch {
                print("Failed to load horoscope from Firebase: \(error)")
            }
        }

        // Fallback to local cache
        return localCache.loadHoroscope(date: date, sign: sign)
    }
}

// MARK: - Sync Management
extension DataRepository {
    func syncIfNeeded() {
        guard isOnline && firebaseService.isAuthenticated else { return }

        Task {
            await syncPendingChanges()
        }
    }

    private func syncPendingChanges() async {
        let pendingItems = localCache.getPendingSyncItems()

        for item in pendingItems {
            do {
                try await syncItem(item)
                localCache.markAsSynced(item)
            } catch {
                print("Failed to sync item: \(error)")
            }
        }

        if pendingItems.isEmpty {
            syncStatus = .synced
        }
    }

    private func syncItem(_ item: SyncItem) async throws {
        switch item {
        case .birthChart(let chart):
            try await firebaseService.saveBirthChart(chart.toDictionary())
        case .horoscope(let date, let sign, let content):
            try await firebaseService.saveHoroscope(
                date: date,
                sign: sign,
                content: content.toDictionary()
            )
        }
    }

    func forceSyncAll() async {
        guard isOnline && firebaseService.isAuthenticated else { return }

        syncStatus = .syncing
        await syncPendingChanges()
    }
}

// MARK: - Supporting Types
enum SyncStatus {
    case synced
    case syncing
    case pendingSync
    case error(String)
}

enum SyncItem {
    case birthChart(BirthChart)
    case horoscope(date: String, sign: String, content: HoroscopeContent)
}

// MARK: - Mock Data Extensions
extension BirthChart {
    func toDictionary() -> [String: Any] {
        return [
            "userId": userId,
            "name": name,
            "birthDate": ISO8601DateFormatter().string(from: birthDate),
            "birthTime": birthTime,
            "location": location,
            "latitude": latitude,
            "longitude": longitude,
            "planets": planets.map { ["name": $0.name, "sign": $0.sign, "degree": $0.degree] }
        ]
    }

    static func fromDictionary(_ dict: [String: Any]) -> BirthChart {
        let dateFormatter = ISO8601DateFormatter()
        return BirthChart(
            userId: dict["userId"] as? String ?? "",
            name: dict["name"] as? String ?? "",
            birthDate: dateFormatter.date(from: dict["birthDate"] as? String ?? "") ?? Date(),
            birthTime: dict["birthTime"] as? String ?? "",
            location: dict["location"] as? String ?? "",
            latitude: dict["latitude"] as? Double ?? 0.0,
            longitude: dict["longitude"] as? Double ?? 0.0,
            planets: [], // TODO: Parse planets from dict
            houses: [],  // TODO: Parse houses from dict
            aspects: []  // TODO: Parse aspects from dict
        )
    }
}

struct HoroscopeContent: Codable {
    let dailyText: String
    let luckyNumbers: [Int]
    let compatibility: String

    func toDictionary() -> [String: Any] {
        return [
            "dailyText": dailyText,
            "luckyNumbers": luckyNumbers,
            "compatibility": compatibility
        ]
    }

    static func fromDictionary(_ dict: [String: Any]) -> HoroscopeContent {
        return HoroscopeContent(
            dailyText: dict["dailyText"] as? String ?? "",
            luckyNumbers: dict["luckyNumbers"] as? [Int] ?? [],
            compatibility: dict["compatibility"] as? String ?? ""
        )
    }
}