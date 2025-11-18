import Testing
import Foundation
@testable import Astrolog

/// Integration Tests for Firebase Service
/// These tests verify actual Firebase integration (requires Firebase emulator or test project)
///
/// SETUP REQUIRED:
/// 1. Firebase emulator suite running, OR
/// 2. Test Firebase project configured
///
/// Run emulator: firebase emulators:start --only auth,firestore,storage
@Suite("Firebase Integration Tests", .tags(.integration))
struct FirebaseIntegrationTests {

    // MARK: - Test Configuration

    static let testEmail = "test-\(UUID().uuidString)@example.com"
    static let testPassword = "TestPassword123!"
    static var testUserId: String?

    // MARK: - Authentication Tests

    @Test("Sign up creates user account")
    func testSignUp() async throws {
        let service = FirebaseService.shared
        let email = "signup-\(UUID().uuidString)@example.com"
        let password = "SignUpTest123!"

        // Sign up
        try await service.signUp(email: email, password: password)

        // Verify authenticated
        #expect(service.isAuthenticated == true, "User should be authenticated after signup")
        #expect(service.currentUser != nil, "Current user should exist")
        #expect(service.currentUser?.email == email, "Email should match")

        // Cleanup
        try await service.signOut()
    }

    @Test("Sign in with valid credentials succeeds")
    func testSignIn() async throws {
        let service = FirebaseService.shared
        let email = "signin-\(UUID().uuidString)@example.com"
        let password = "SignInTest123!"

        // Create account first
        try await service.signUp(email: email, password: password)
        try await service.signOut()

        // Sign in
        try await service.signIn(email: email, password: password)

        // Verify authenticated
        #expect(service.isAuthenticated == true)
        #expect(service.currentUser?.email == email)

        // Cleanup
        try await service.signOut()
    }

    @Test("Sign in with invalid credentials fails")
    func testSignInInvalidCredentials() async throws {
        let service = FirebaseService.shared

        // Attempt sign in with non-existent account
        do {
            try await service.signIn(
                email: "nonexistent-\(UUID().uuidString)@example.com",
                password: "WrongPassword123!"
            )
            Issue.record("Sign in should have failed with invalid credentials")
        } catch {
            // Expected to fail
            #expect(error is FirebaseError, "Should throw FirebaseError")
        }
    }

    @Test("Sign out clears authentication state")
    func testSignOut() async throws {
        let service = FirebaseService.shared
        let email = "signout-\(UUID().uuidString)@example.com"
        let password = "SignOutTest123!"

        // Sign up
        try await service.signUp(email: email, password: password)
        #expect(service.isAuthenticated == true)

        // Sign out
        try await service.signOut()

        // Verify not authenticated
        #expect(service.isAuthenticated == false)
        #expect(service.currentUser == nil)
    }

    @Test("Anonymous sign in creates anonymous user")
    func testAnonymousSignIn() async throws {
        let service = FirebaseService.shared

        // Sign in anonymously
        try await service.signInAnonymously()

        // Verify authenticated
        #expect(service.isAuthenticated == true)
        #expect(service.currentUser != nil)
        #expect(service.currentUser?.isAnonymous == true)

        // Cleanup
        try await service.signOut()
    }

    @Test("Password reset sends email")
    func testPasswordReset() async throws {
        let service = FirebaseService.shared
        let email = "reset-\(UUID().uuidString)@example.com"
        let password = "ResetTest123!"

        // Create account
        try await service.signUp(email: email, password: password)
        try await service.signOut()

        // Request password reset
        try await service.resetPassword(email: email)

        // No error means email was sent
        // In emulator, check logs for reset link
    }

    @Test("Email verification can be sent")
    func testEmailVerification() async throws {
        let service = FirebaseService.shared
        let email = "verify-\(UUID().uuidString)@example.com"
        let password = "VerifyTest123!"

        // Sign up
        try await service.signUp(email: email, password: password)

        // Send verification email
        try await service.sendEmailVerification()

        // No error means email was sent
        // In emulator, check logs for verification link

        // Cleanup
        try await service.signOut()
    }

    // MARK: - Firestore Tests

    @Test("Create user document after signup")
    func testCreateUserDocument() async throws {
        let service = FirebaseService.shared
        let email = "userdoc-\(UUID().uuidString)@example.com"
        let password = "UserDocTest123!"

        // Sign up (should create user document)
        try await service.signUp(email: email, password: password)

        // Wait a moment for async creation
        try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second

        // Fetch user from Firestore
        let userId = service.currentUser?.uid ?? ""
        let user = try await service.getUser(userId: userId)

        #expect(user != nil, "User document should exist")
        #expect(user?.email == email, "Email should match")

        // Cleanup
        try await service.signOut()
    }

    @Test("Update user profile")
    func testUpdateUserProfile() async throws {
        let service = FirebaseService.shared
        let email = "update-\(UUID().uuidString)@example.com"
        let password = "UpdateTest123!"

        // Sign up
        try await service.signUp(email: email, password: password)
        let userId = service.currentUser?.uid ?? ""

        // Update profile
        let updates: [String: Any] = [
            "name": "Test User",
            "isPro": true
        ]
        try await service.updateUser(userId: userId, updates: updates)

        // Fetch updated user
        let user = try await service.getUser(userId: userId)

        #expect(user?.name == "Test User")
        #expect(user?.isPro == true)

        // Cleanup
        try await service.signOut()
    }

    @Test("Save and fetch birth chart")
    func testSaveBirthChart() async throws {
        let service = FirebaseService.shared
        let email = "chart-\(UUID().uuidString)@example.com"
        let password = "ChartTest123!"

        // Sign up
        try await service.signUp(email: email, password: password)
        let userId = service.currentUser?.uid ?? ""

        // Create test birth chart
        let chart = BirthChart(
            id: UUID().uuidString,
            userId: userId,
            name: "Test Chart",
            birthDate: Date(),
            birthTime: "12:00",
            location: "London, UK",
            latitude: 51.5074,
            longitude: -0.1278,
            planets: [],
            houses: [],
            aspects: [],
            calculatedAt: Date()
        )

        // Save chart
        try await service.saveBirthChart(chart)

        // Wait a moment
        try await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds

        // Fetch charts
        let charts = try await service.getUserBirthCharts(userId: userId)

        #expect(charts.count > 0, "Should have at least one chart")
        #expect(charts.contains { $0.id == chart.id }, "Chart should be saved")

        // Cleanup
        try await service.signOut()
    }

    @Test("Delete birth chart")
    func testDeleteBirthChart() async throws {
        let service = FirebaseService.shared
        let email = "delete-\(UUID().uuidString)@example.com"
        let password = "DeleteTest123!"

        // Sign up
        try await service.signUp(email: email, password: password)
        let userId = service.currentUser?.uid ?? ""

        // Create and save chart
        let chartId = UUID().uuidString
        let chart = BirthChart(
            id: chartId,
            userId: userId,
            name: "Chart to Delete",
            birthDate: Date(),
            birthTime: "12:00",
            location: "Paris, France",
            latitude: 48.8566,
            longitude: 2.3522,
            planets: [],
            houses: [],
            aspects: [],
            calculatedAt: Date()
        )

        try await service.saveBirthChart(chart)
        try await Task.sleep(nanoseconds: 500_000_000)

        // Delete chart
        try await service.deleteBirthChart(chartId: chartId)
        try await Task.sleep(nanoseconds: 500_000_000)

        // Verify deleted
        let charts = try await service.getUserBirthCharts(userId: userId)
        #expect(!charts.contains { $0.id == chartId }, "Chart should be deleted")

        // Cleanup
        try await service.signOut()
    }

    // MARK: - Storage Tests (if implemented)

    @Test("Upload user profile image", .disabled("Requires Storage implementation"))
    func testUploadProfileImage() async throws {
        let service = FirebaseService.shared
        let email = "upload-\(UUID().uuidString)@example.com"
        let password = "UploadTest123!"

        // Sign up
        try await service.signUp(email: email, password: password)
        let userId = service.currentUser?.uid ?? ""

        // Create test image data
        let testImageData = Data(repeating: 0xFF, count: 1024) // 1KB of data

        // Upload image
        let imageUrl = try await service.uploadProfileImage(userId: userId, imageData: testImageData)

        #expect(imageUrl != nil, "Image URL should be returned")
        #expect(imageUrl?.absoluteString.contains("storage") == true, "URL should be from storage")

        // Cleanup
        try await service.signOut()
    }

    // MARK: - Concurrent Access Tests

    @Test("Concurrent sign-ups should all succeed")
    func testConcurrentSignUps() async throws {
        let service = FirebaseService.shared

        // Create 5 concurrent sign-up tasks
        await withTaskGroup(of: Result<Void, Error>.self) { group in
            for i in 0..<5 {
                group.addTask {
                    let email = "concurrent-\(i)-\(UUID().uuidString)@example.com"
                    let password = "Concurrent\(i)Test123!"

                    do {
                        try await service.signUp(email: email, password: password)
                        try await service.signOut()
                        return .success(())
                    } catch {
                        return .failure(error)
                    }
                }
            }

            // Collect results
            var successCount = 0
            for await result in group {
                if case .success = result {
                    successCount += 1
                }
            }

            #expect(successCount == 5, "All concurrent signups should succeed")
        }
    }

    // MARK: - Edge Cases

    @Test("Sign up with duplicate email fails")
    func testDuplicateEmailSignUp() async throws {
        let service = FirebaseService.shared
        let email = "duplicate-\(UUID().uuidString)@example.com"
        let password = "DuplicateTest123!"

        // First signup
        try await service.signUp(email: email, password: password)
        try await service.signOut()

        // Second signup with same email should fail
        do {
            try await service.signUp(email: email, password: password)
            Issue.record("Duplicate signup should have failed")
        } catch {
            // Expected to fail
            #expect(error is FirebaseError)
        }
    }

    @Test("Sign in after account deletion fails")
    func testSignInAfterDeletion() async throws {
        let service = FirebaseService.shared
        let email = "deleteaccount-\(UUID().uuidString)@example.com"
        let password = "DeleteAccountTest123!"

        // Sign up
        try await service.signUp(email: email, password: password)

        // Delete account
        try await service.deleteAccount()

        // Try to sign in with deleted account
        do {
            try await service.signIn(email: email, password: password)
            Issue.record("Sign in should have failed after account deletion")
        } catch {
            // Expected to fail
            #expect(error is FirebaseError)
        }
    }
}

// MARK: - Test Tags

extension Tag {
    @Tag static var integration: Self
    @Tag static var firebase: Self
    @Tag static var auth: Self
    @Tag static var firestore: Self
}
