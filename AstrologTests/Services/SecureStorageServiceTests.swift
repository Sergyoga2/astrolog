import Testing
import Foundation
@testable import Astrolog

@MainActor
struct SecureStorageServiceTests {
    let service = SecureStorageService.shared

    // MARK: - Encryption/Decryption Tests

    @Test func testEncryptDecryptBirthData() async throws {
        let birthData = BirthData(
            birthDate: Date(),
            birthTime: "14:30",
            location: "Moscow, Russia",
            latitude: 55.7558,
            longitude: 37.6176,
            timezone: "Europe/Moscow",
            timeUnknown: false
        )

        // Encrypt
        let encrypted = try service.encrypt(birthData)
        #expect(encrypted.count > 0, "Encrypted data should not be empty")

        // Decrypt
        let decrypted: BirthData = try service.decrypt(encrypted, as: BirthData.self)

        // Verify
        #expect(decrypted.location == birthData.location, "Location should match")
        #expect(decrypted.latitude == birthData.latitude, "Latitude should match")
        #expect(decrypted.longitude == birthData.longitude, "Longitude should match")
        #expect(decrypted.birthTime == birthData.birthTime, "Birth time should match")
        #expect(decrypted.timezone == birthData.timezone, "Timezone should match")
        #expect(decrypted.timeUnknown == birthData.timeUnknown, "Time unknown flag should match")
    }

    @Test func testEncryptedDataIsDifferent() async throws {
        let birthData = BirthData(
            birthDate: Date(),
            birthTime: "12:00",
            location: "London, UK",
            latitude: 51.5074,
            longitude: -0.1278,
            timezone: "Europe/London",
            timeUnknown: false
        )

        // Encrypt same data twice
        let encrypted1 = try service.encrypt(birthData)
        let encrypted2 = try service.encrypt(birthData)

        // Encrypted data should be different due to different nonces
        #expect(encrypted1 != encrypted2, "Encrypted data should differ due to random nonce")

        // But both should decrypt to same data
        let decrypted1: BirthData = try service.decrypt(encrypted1, as: BirthData.self)
        let decrypted2: BirthData = try service.decrypt(encrypted2, as: BirthData.self)

        #expect(decrypted1.location == decrypted2.location, "Decrypted data should be identical")
    }

    @Test func testDecryptInvalidDataFails() async throws {
        let invalidData = Data("invalid encrypted data".utf8)

        #expect(throws: Error.self) {
            let _: BirthData = try service.decrypt(invalidData, as: BirthData.self)
        }
    }

    // MARK: - Birth Data Storage Tests

    @Test func testStoreSaveAndRetrieveBirthData() async throws {
        let userId = "test_user_\(UUID().uuidString)"
        let birthData = BirthData(
            birthDate: Date(timeIntervalSince1970: 946684800),
            birthTime: "10:30",
            location: "New York, USA",
            latitude: 40.7128,
            longitude: -74.0060,
            timezone: "America/New_York",
            timeUnknown: false
        )

        // Store
        try service.storeBirthData(birthData, forUserId: userId)

        // Retrieve
        let retrieved = try service.retrieveBirthData(forUserId: userId)

        #expect(retrieved != nil, "Birth data should be retrieved")

        if let retrieved = retrieved {
            #expect(retrieved.location == birthData.location, "Location should match")
            #expect(retrieved.latitude == birthData.latitude, "Latitude should match")
            #expect(retrieved.longitude == birthData.longitude, "Longitude should match")
        }

        // Clean up
        service.deleteBirthData(forUserId: userId)
    }

    @Test func testDeleteBirthData() async throws {
        let userId = "test_user_\(UUID().uuidString)"
        let birthData = BirthData(
            birthDate: Date(),
            birthTime: "15:00",
            location: "Paris, France",
            latitude: 48.8566,
            longitude: 2.3522,
            timezone: "Europe/Paris",
            timeUnknown: false
        )

        // Store
        try service.storeBirthData(birthData, forUserId: userId)

        // Verify stored
        var retrieved = try service.retrieveBirthData(forUserId: userId)
        #expect(retrieved != nil, "Birth data should be stored")

        // Delete
        service.deleteBirthData(forUserId: userId)

        // Verify deleted
        retrieved = try service.retrieveBirthData(forUserId: userId)
        #expect(retrieved == nil, "Birth data should be deleted")
    }

    @Test func testRetrieveNonExistentBirthData() async throws {
        let userId = "non_existent_user"

        let retrieved = try service.retrieveBirthData(forUserId: userId)
        #expect(retrieved == nil, "Non-existent birth data should return nil")
    }

    // MARK: - Generic Encryption Tests

    @Test func testEncryptDecryptString() async throws {
        let testString = "This is a secret message 🔐"

        let encrypted = try service.encrypt(testString)
        let decrypted: String = try service.decrypt(encrypted, as: String.self)

        #expect(decrypted == testString, "Decrypted string should match original")
    }

    @Test func testEncryptDecryptCodableStruct() async throws {
        struct TestData: Codable, Equatable {
            let name: String
            let age: Int
            let email: String
        }

        let testData = TestData(name: "John Doe", age: 30, email: "john@example.com")

        let encrypted = try service.encrypt(testData)
        let decrypted: TestData = try service.decrypt(encrypted, as: TestData.self)

        #expect(decrypted == testData, "Decrypted struct should match original")
    }

    // MARK: - Key Management Tests

    @Test func testEncryptionKeyPersistence() async throws {
        // First encryption
        let data1 = "Test data 1"
        let encrypted1 = try service.encrypt(data1)

        // Second encryption (should use same key from Keychain)
        let data2 = "Test data 2"
        let encrypted2 = try service.encrypt(data2)

        // Both should decrypt successfully with same key
        let decrypted1: String = try service.decrypt(encrypted1, as: String.self)
        let decrypted2: String = try service.decrypt(encrypted2, as: String.self)

        #expect(decrypted1 == data1, "First decryption should work")
        #expect(decrypted2 == data2, "Second decryption should work")
    }
}
