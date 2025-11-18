import Testing
import Foundation
@testable import Astrolog

struct KeychainServiceTests {
    let service = KeychainService.shared

    // MARK: - API Key Storage Tests

    @Test func testStoreAndRetrieveAPIKey() async throws {
        let testKey = "test_api_key_12345"
        let apiKey = KeychainService.APIKey.astrologyAPI

        // Store
        try service.storeAPIKey(testKey, for: apiKey)

        // Retrieve
        let retrieved = try service.retrieveAPIKey(for: apiKey)

        #expect(retrieved == testKey, "Retrieved API key should match stored key")

        // Clean up
        try service.deleteAPIKey(for: apiKey)
    }

    @Test func testUpdateAPIKey() async throws {
        let apiKey = KeychainService.APIKey.geoNames
        let originalKey = "original_key_123"
        let updatedKey = "updated_key_456"

        // Store original
        try service.storeAPIKey(originalKey, for: apiKey)

        // Update
        try service.storeAPIKey(updatedKey, for: apiKey)

        // Retrieve
        let retrieved = try service.retrieveAPIKey(for: apiKey)

        #expect(retrieved == updatedKey, "Retrieved key should be updated value")

        // Clean up
        try service.deleteAPIKey(for: apiKey)
    }

    @Test func testDeleteAPIKey() async throws {
        let testKey = "test_key_delete"
        let apiKey = KeychainService.APIKey.openStreetMap

        // Store
        try service.storeAPIKey(testKey, for: apiKey)

        // Verify stored
        var retrieved = try service.retrieveAPIKey(for: apiKey)
        #expect(retrieved == testKey, "Key should be stored")

        // Delete
        try service.deleteAPIKey(for: apiKey)

        // Verify deleted
        retrieved = try service.retrieveAPIKey(for: apiKey)
        #expect(retrieved == nil, "Key should be deleted")
    }

    @Test func testRetrieveNonExistentAPIKey() async throws {
        // First ensure the key doesn't exist
        try? service.deleteAPIKey(for: .firebaseWebAPI)

        let retrieved = try service.retrieveAPIKey(for: .firebaseWebAPI)
        #expect(retrieved == nil, "Non-existent key should return nil")
    }

    @Test func testMultipleAPIKeys() async throws {
        let key1 = "openstreetmap_key"
        let key2 = "geonames_key"

        // Store multiple keys
        try service.storeAPIKey(key1, for: .openStreetMap)
        try service.storeAPIKey(key2, for: .geoNames)

        // Retrieve both
        let retrieved1 = try service.retrieveAPIKey(for: .openStreetMap)
        let retrieved2 = try service.retrieveAPIKey(for: .geoNames)

        #expect(retrieved1 == key1, "First key should be correct")
        #expect(retrieved2 == key2, "Second key should be correct")

        // Clean up
        try service.deleteAPIKey(for: .openStreetMap)
        try service.deleteAPIKey(for: .geoNames)
    }

    // MARK: - Generic String Storage Tests

    @Test func testStoreAndRetrieveGenericString() async throws {
        let key = "test_key_\(UUID().uuidString)"
        let value = "test_value_sensitive_data"

        // Store
        try service.store(value, forKey: key)

        // Retrieve
        let retrieved = try service.retrieve(forKey: key)

        #expect(retrieved == value, "Retrieved value should match stored value")

        // Clean up
        try service.delete(forKey: key)
    }

    @Test func testStoreEmptyString() async throws {
        let key = "empty_key_\(UUID().uuidString)"
        let value = ""

        // Store empty string
        try service.store(value, forKey: key)

        // Retrieve
        let retrieved = try service.retrieve(forKey: key)

        #expect(retrieved == value, "Empty string should be stored and retrieved")

        // Clean up
        try service.delete(forKey: key)
    }

    @Test func testStoreUnicodeString() async throws {
        let key = "unicode_key_\(UUID().uuidString)"
        let value = "🔐 Секретный ключ 密钥 🗝️"

        // Store unicode string
        try service.store(value, forKey: key)

        // Retrieve
        let retrieved = try service.retrieve(forKey: key)

        #expect(retrieved == value, "Unicode string should be stored correctly")

        // Clean up
        try service.delete(forKey: key)
    }

    @Test func testStoreLongString() async throws {
        let key = "long_key_\(UUID().uuidString)"
        let value = String(repeating: "A", count: 10000) // 10KB string

        // Store long string
        try service.store(value, forKey: key)

        // Retrieve
        let retrieved = try service.retrieve(forKey: key)

        #expect(retrieved == value, "Long string should be stored correctly")

        // Clean up
        try service.delete(forKey: key)
    }

    @Test func testDeleteNonExistentKey() async throws {
        let key = "non_existent_key_\(UUID().uuidString)"

        // Delete non-existent key (should not throw)
        try service.delete(forKey: key)

        // Verify still doesn't exist
        let retrieved = try service.retrieve(forKey: key)
        #expect(retrieved == nil, "Key should not exist")
    }

    @Test func testOverwriteExistingKey() async throws {
        let key = "overwrite_key_\(UUID().uuidString)"
        let value1 = "original_value"
        let value2 = "new_value"

        // Store original
        try service.store(value1, forKey: key)

        // Overwrite
        try service.store(value2, forKey: key)

        // Retrieve
        let retrieved = try service.retrieve(forKey: key)

        #expect(retrieved == value2, "Value should be overwritten")

        // Clean up
        try service.delete(forKey: key)
    }

    // MARK: - Service Isolation Tests

    @Test func testServiceIsolation() async throws {
        let key = "same_key"
        let service1 = "com.astrolog.service1"
        let service2 = "com.astrolog.service2"
        let value1 = "value_for_service1"
        let value2 = "value_for_service2"

        // Store same key in different services
        try service.store(value1, forKey: key, service: service1)
        try service.store(value2, forKey: key, service: service2)

        // Retrieve from both services
        let retrieved1 = try service.retrieve(forKey: key, service: service1)
        let retrieved2 = try service.retrieve(forKey: key, service: service2)

        #expect(retrieved1 == value1, "Service 1 should have its value")
        #expect(retrieved2 == value2, "Service 2 should have its value")

        // Clean up
        try service.delete(forKey: key, service: service1)
        try service.delete(forKey: key, service: service2)
    }

    // MARK: - Edge Cases

    @Test func testStoreSpecialCharacters() async throws {
        let key = "special_key_\(UUID().uuidString)"
        let value = "!@#$%^&*()_+-=[]{}|;:'\",.<>?/~`"

        try service.store(value, forKey: key)
        let retrieved = try service.retrieve(forKey: key)

        #expect(retrieved == value, "Special characters should be preserved")

        try service.delete(forKey: key)
    }

    @Test func testStoreMultilineString() async throws {
        let key = "multiline_key_\(UUID().uuidString)"
        let value = """
        Line 1
        Line 2
        Line 3
        """

        try service.store(value, forKey: key)
        let retrieved = try service.retrieve(forKey: key)

        #expect(retrieved == value, "Multiline string should be preserved")

        try service.delete(forKey: key)
    }
}
