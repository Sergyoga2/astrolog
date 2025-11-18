import Foundation
import CryptoKit
import Security

/// Service for encrypting and securely storing sensitive user data
@MainActor
final class SecureStorageService {
    static let shared = SecureStorageService()

    private init() {}

    // MARK: - Encryption/Decryption

    /// Encrypts data using AES-GCM with a key from Keychain
    func encrypt<T: Codable>(_ data: T) throws -> Data {
        // Encode to JSON
        let jsonData = try JSONEncoder().encode(data)

        // Get or create encryption key
        let key = try getOrCreateEncryptionKey()

        // Generate a nonce
        let nonce = AES.GCM.Nonce()

        // Encrypt
        let sealedBox = try AES.GCM.seal(jsonData, using: key, nonce: nonce)

        // Combine nonce + ciphertext + tag
        guard let combined = sealedBox.combined else {
            throw SecureStorageError.encryptionFailed
        }

        return combined
    }

    /// Decrypts data using AES-GCM
    func decrypt<T: Codable>(_ encryptedData: Data, as type: T.Type) throws -> T {
        // Get encryption key
        let key = try getOrCreateEncryptionKey()

        // Create sealed box from combined data
        let sealedBox = try AES.GCM.SealedBox(combined: encryptedData)

        // Decrypt
        let decryptedData = try AES.GCM.open(sealedBox, using: key)

        // Decode from JSON
        let decodedData = try JSONDecoder().decode(T.self, from: decryptedData)

        return decodedData
    }

    // MARK: - Birth Data Specific Methods

    /// Securely stores birth data
    func storeBirthData(_ birthData: BirthData, forUserId userId: String) throws {
        let encryptedData = try encrypt(birthData)
        let key = "birth_data_\(userId)"

        // Store in UserDefaults with encrypted data
        UserDefaults.standard.set(encryptedData, forKey: key)
    }

    /// Retrieves and decrypts birth data
    func retrieveBirthData(forUserId userId: String) throws -> BirthData? {
        let key = "birth_data_\(userId)"

        guard let encryptedData = UserDefaults.standard.data(forKey: key) else {
            return nil
        }

        return try decrypt(encryptedData, as: BirthData.self)
    }

    /// Deletes stored birth data
    func deleteBirthData(forUserId userId: String) {
        let key = "birth_data_\(userId)"
        UserDefaults.standard.removeObject(forKey: key)
    }

    // MARK: - Encryption Key Management

    private func getOrCreateEncryptionKey() throws -> SymmetricKey {
        // Try to load existing key from Keychain
        if let existingKey = try? loadKeyFromKeychain() {
            return existingKey
        }

        // Generate new key
        let newKey = SymmetricKey(size: .bits256)

        // Store in Keychain
        try saveKeyToKeychain(newKey)

        return newKey
    }

    private func saveKeyToKeychain(_ key: SymmetricKey) throws {
        let keyData = key.withUnsafeBytes { Data($0) }

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: "astrolog.encryption.key",
            kSecAttrService as String: "com.astrolog.encryption",
            kSecValueData as String: keyData,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        ]

        // Delete any existing key first
        SecItemDelete(query as CFDictionary)

        // Add new key
        let status = SecItemAdd(query as CFDictionary, nil)

        guard status == errSecSuccess else {
            throw SecureStorageError.keychainError(status)
        }
    }

    private func loadKeyFromKeychain() throws -> SymmetricKey {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: "astrolog.encryption.key",
            kSecAttrService as String: "com.astrolog.encryption",
            kSecReturnData as String: true
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        guard status == errSecSuccess,
              let keyData = result as? Data else {
            throw SecureStorageError.keychainError(status)
        }

        return SymmetricKey(data: keyData)
    }

    /// Deletes encryption key from Keychain (use with caution!)
    func deleteEncryptionKey() throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: "astrolog.encryption.key",
            kSecAttrService as String: "com.astrolog.encryption"
        ]

        let status = SecItemDelete(query as CFDictionary)

        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw SecureStorageError.keychainError(status)
        }
    }
}

// MARK: - Errors

enum SecureStorageError: LocalizedError {
    case encryptionFailed
    case decryptionFailed
    case keychainError(OSStatus)
    case invalidData

    var errorDescription: String? {
        switch self {
        case .encryptionFailed:
            return "Failed to encrypt data"
        case .decryptionFailed:
            return "Failed to decrypt data"
        case .keychainError(let status):
            return "Keychain error: \(status)"
        case .invalidData:
            return "Invalid data format"
        }
    }
}
