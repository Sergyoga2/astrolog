import Foundation
import Security

/// Service for securely storing API keys and credentials in Keychain
final class KeychainService {
    static let shared = KeychainService()

    private init() {}

    // MARK: - API Keys Storage

    enum APIKey: String {
        case openStreetMap = "openstreetmap.api.key"
        case geoNames = "geonames.api.key"
        case firebaseWebAPI = "firebase.web.api.key"
        case astrologyAPI = "astrology.api.key"

        var service: String {
            "com.astrolog.apikeys"
        }
    }

    /// Stores an API key securely in Keychain
    func storeAPIKey(_ key: String, for apiKey: APIKey) throws {
        guard let keyData = key.data(using: .utf8) else {
            throw KeychainError.invalidData
        }

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: apiKey.rawValue,
            kSecAttrService as String: apiKey.service,
            kSecValueData as String: keyData,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        ]

        // Delete any existing key first
        SecItemDelete(query as CFDictionary)

        // Add new key
        let status = SecItemAdd(query as CFDictionary, nil)

        guard status == errSecSuccess else {
            throw KeychainError.keychainError(status)
        }
    }

    /// Retrieves an API key from Keychain
    func retrieveAPIKey(for apiKey: APIKey) throws -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: apiKey.rawValue,
            kSecAttrService as String: apiKey.service,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        guard status == errSecSuccess,
              let keyData = result as? Data,
              let key = String(data: keyData, encoding: .utf8) else {
            if status == errSecItemNotFound {
                return nil
            }
            throw KeychainError.keychainError(status)
        }

        return key
    }

    /// Deletes an API key from Keychain
    func deleteAPIKey(for apiKey: APIKey) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: apiKey.rawValue,
            kSecAttrService as String: apiKey.service
        ]

        let status = SecItemDelete(query as CFDictionary)

        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw KeychainError.keychainError(status)
        }
    }

    // MARK: - Generic Secure String Storage

    /// Stores any string securely in Keychain
    func store(_ value: String, forKey key: String, service: String = "com.astrolog.secure") throws {
        guard let valueData = value.data(using: .utf8) else {
            throw KeychainError.invalidData
        }

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecAttrService as String: service,
            kSecValueData as String: valueData,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        ]

        // Delete any existing value first
        SecItemDelete(query as CFDictionary)

        // Add new value
        let status = SecItemAdd(query as CFDictionary, nil)

        guard status == errSecSuccess else {
            throw KeychainError.keychainError(status)
        }
    }

    /// Retrieves a string from Keychain
    func retrieve(forKey key: String, service: String = "com.astrolog.secure") throws -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecAttrService as String: service,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        guard status == errSecSuccess,
              let valueData = result as? Data,
              let value = String(data: valueData, encoding: .utf8) else {
            if status == errSecItemNotFound {
                return nil
            }
            throw KeychainError.keychainError(status)
        }

        return value
    }

    /// Deletes a value from Keychain
    func delete(forKey key: String, service: String = "com.astrolog.secure") throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecAttrService as String: service
        ]

        let status = SecItemDelete(query as CFDictionary)

        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw KeychainError.keychainError(status)
        }
    }

    /// Deletes all items for a service
    func deleteAll(forService service: String = "com.astrolog.secure") throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service
        ]

        let status = SecItemDelete(query as CFDictionary)

        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw KeychainError.keychainError(status)
        }
    }
}

// MARK: - Errors

enum KeychainError: LocalizedError {
    case invalidData
    case keychainError(OSStatus)
    case notFound

    var errorDescription: String? {
        switch self {
        case .invalidData:
            return "Invalid data format"
        case .keychainError(let status):
            return "Keychain error: \(status) (\(keychainErrorMessage(status)))"
        case .notFound:
            return "Item not found in Keychain"
        }
    }

    private func keychainErrorMessage(_ status: OSStatus) -> String {
        switch status {
        case errSecSuccess:
            return "Success"
        case errSecItemNotFound:
            return "Item not found"
        case errSecDuplicateItem:
            return "Duplicate item"
        case errSecAuthFailed:
            return "Authentication failed"
        case errSecUnimplemented:
            return "Not implemented"
        case errSecParam:
            return "Invalid parameter"
        case errSecAllocate:
            return "Allocation failed"
        case errSecNotAvailable:
            return "Not available"
        case errSecReadOnly:
            return "Read only"
        case errSecInteractionNotAllowed:
            return "Interaction not allowed"
        case errSecDecode:
            return "Decode failed"
        default:
            return "Unknown error"
        }
    }
}

// MARK: - Environment Configuration

/// Helper for managing API keys from environment or Keychain
struct APIConfiguration {
    static let shared = APIConfiguration()

    private init() {}

    /// Gets API key, first checking Keychain, then falling back to environment
    func getAPIKey(for key: KeychainService.APIKey) -> String? {
        // Try Keychain first
        if let keychainValue = try? KeychainService.shared.retrieveAPIKey(for: key) {
            return keychainValue
        }

        // Fallback to environment variable (for development)
        // In production, keys should ONLY be in Keychain
        #if DEBUG
        return ProcessInfo.processInfo.environment[key.rawValue.uppercased()]
        #else
        return nil
        #endif
    }

    /// Migrates API keys from environment to Keychain (call once on first launch)
    func migrateAPIKeysToKeychain() {
        let keysToMigrate: [(KeychainService.APIKey, String)] = [
            (.openStreetMap, "OPENSTREETMAP_API_KEY"),
            (.geoNames, "GEONAMES_API_KEY"),
            (.firebaseWebAPI, "FIREBASE_WEB_API_KEY"),
            (.astrologyAPI, "ASTROLOGY_API_KEY")
        ]

        for (key, envVar) in keysToMigrate {
            if let envValue = ProcessInfo.processInfo.environment[envVar] {
                try? KeychainService.shared.storeAPIKey(envValue, for: key)
            }
        }
    }
}
