import Foundation

class LocalCacheService {
    static let shared = LocalCacheService()

    private let userDefaults = UserDefaults.standard
    private let fileManager = FileManager.default

    private var documentsDirectory: URL {
        fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
    }

    private var cacheDirectory: URL {
        documentsDirectory.appendingPathComponent("AstroCache")
    }

    private init() {
        createCacheDirectoryIfNeeded()
    }

    private func createCacheDirectoryIfNeeded() {
        if !fileManager.fileExists(atPath: cacheDirectory.path) {
            try? fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
        }
    }
}

// MARK: - Birth Chart Caching
extension LocalCacheService {
    func saveBirthChart(_ chart: BirthChart) {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601

        do {
            let data = try encoder.encode(chart)
            let url = cacheDirectory.appendingPathComponent("birth_chart.json")
            try data.write(to: url)
        } catch {
            print("Failed to save birth chart: \(error)")
        }
    }

    func loadBirthChart() -> BirthChart? {
        let url = cacheDirectory.appendingPathComponent("birth_chart.json")

        guard fileManager.fileExists(atPath: url.path) else { return nil }

        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            return try decoder.decode(BirthChart.self, from: data)
        } catch {
            print("Failed to load birth chart: \(error)")
            return nil
        }
    }
}

// MARK: - Horoscope Caching
extension LocalCacheService {
    func saveHoroscope(date: String, sign: String, content: HoroscopeContent) {
        let encoder = JSONEncoder()

        do {
            let data = try encoder.encode(content)
            let url = horoscopeURL(date: date, sign: sign)
            try data.write(to: url)
        } catch {
            print("Failed to save horoscope: \(error)")
        }
    }

    func loadHoroscope(date: String, sign: String) -> HoroscopeContent? {
        let url = horoscopeURL(date: date, sign: sign)

        guard fileManager.fileExists(atPath: url.path) else { return nil }

        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            return try decoder.decode(HoroscopeContent.self, from: data)
        } catch {
            print("Failed to load horoscope: \(error)")
            return nil
        }
    }

    private func horoscopeURL(date: String, sign: String) -> URL {
        let horoscopeDir = cacheDirectory.appendingPathComponent("horoscopes")

        // Create horoscope directory if needed
        if !fileManager.fileExists(atPath: horoscopeDir.path) {
            try? fileManager.createDirectory(at: horoscopeDir, withIntermediateDirectories: true)
        }

        return horoscopeDir.appendingPathComponent("\(date)_\(sign).json")
    }
}

// MARK: - Sync Queue Management
extension LocalCacheService {
    private var syncQueueKey: String { "pending_sync_items" }

    func queueForSync(_ item: SyncItem) {
        var queue = getPendingSyncItems()
        queue.append(item)

        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(queue.map { $0.toData() })
            userDefaults.set(data, forKey: syncQueueKey)
        } catch {
            print("Failed to queue item for sync: \(error)")
        }
    }

    func getPendingSyncItems() -> [SyncItem] {
        guard let data = userDefaults.data(forKey: syncQueueKey) else { return [] }

        do {
            let decoder = JSONDecoder()
            let itemData = try decoder.decode([SyncItemData].self, from: data)
            return itemData.compactMap { SyncItem.fromData($0) }
        } catch {
            print("Failed to load pending sync items: \(error)")
            return []
        }
    }

    func markAsSynced(_ item: SyncItem) {
        var queue = getPendingSyncItems()
        queue.removeAll { $0.id == item.id }

        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(queue.map { $0.toData() })
            userDefaults.set(data, forKey: syncQueueKey)
        } catch {
            print("Failed to update sync queue: \(error)")
        }
    }

    func clearSyncQueue() {
        userDefaults.removeObject(forKey: syncQueueKey)
    }
}

// MARK: - Cache Management
extension LocalCacheService {
    func clearCache() {
        do {
            let contents = try fileManager.contentsOfDirectory(at: cacheDirectory, includingPropertiesForKeys: nil)
            for url in contents {
                try fileManager.removeItem(at: url)
            }
        } catch {
            print("Failed to clear cache: \(error)")
        }
    }

    func getCacheSize() -> Int64 {
        do {
            let contents = try fileManager.contentsOfDirectory(at: cacheDirectory, includingPropertiesForKeys: [.fileSizeKey])
            var totalSize: Int64 = 0

            for url in contents {
                let resourceValues = try url.resourceValues(forKeys: [.fileSizeKey])
                totalSize += Int64(resourceValues.fileSize ?? 0)
            }

            return totalSize
        } catch {
            print("Failed to calculate cache size: \(error)")
            return 0
        }
    }
}

// MARK: - Supporting Types
struct SyncItemData: Codable {
    let id: String
    let type: String
    let data: Data
}

extension SyncItem {
    var id: String {
        switch self {
        case .birthChart:
            return "birth_chart"
        case .horoscope(let date, let sign, _):
            return "horoscope_\(date)_\(sign)"
        }
    }

    func toData() -> SyncItemData {
        let encoder = JSONEncoder()

        switch self {
        case .birthChart(let chart):
            let data = (try? encoder.encode(chart)) ?? Data()
            return SyncItemData(id: id, type: "birth_chart", data: data)

        case .horoscope(let date, let sign, let content):
            let horoscopeData = HoroscopeItemData(date: date, sign: sign, content: content)
            let data = (try? encoder.encode(horoscopeData)) ?? Data()
            return SyncItemData(id: id, type: "horoscope", data: data)
        }
    }

    static func fromData(_ data: SyncItemData) -> SyncItem? {
        let decoder = JSONDecoder()

        switch data.type {
        case "birth_chart":
            guard let chart = try? decoder.decode(BirthChart.self, from: data.data) else { return nil }
            return .birthChart(chart)

        case "horoscope":
            guard let horoscopeData = try? decoder.decode(HoroscopeItemData.self, from: data.data) else { return nil }
            return .horoscope(date: horoscopeData.date, sign: horoscopeData.sign, content: horoscopeData.content)

        default:
            return nil
        }
    }
}

struct HoroscopeItemData: Codable {
    let date: String
    let sign: String
    let content: HoroscopeContent
}

// HoroscopeContent is now defined as Codable in DataRepository