import Testing
import Foundation
@testable import Astrolog

@MainActor
struct AuthViewModelTests {

    // MARK: - Validation Tests

    @Test func testEmailValidation() {
        let viewModel = AuthViewModel()

        // Invalid emails
        viewModel.email = ""
        #expect(viewModel.isEmailValid == false, "Empty email should be invalid")

        viewModel.email = "invalid"
        #expect(viewModel.isEmailValid == false, "Email without @ should be invalid")

        viewModel.email = "invalid@"
        #expect(viewModel.isEmailValid == false, "Email without domain should be invalid")

        viewModel.email = "@invalid.com"
        #expect(viewModel.isEmailValid == false, "Email without local part should be invalid")

        // Valid emails
        viewModel.email = "test@example.com"
        #expect(viewModel.isEmailValid == true, "Valid email should be accepted")

        viewModel.email = "user.name@domain.co.uk"
        #expect(viewModel.isEmailValid == true, "Email with dots should be valid")
    }

    @Test func testPasswordValidation() {
        let viewModel = AuthViewModel()

        // Invalid passwords
        viewModel.password = ""
        #expect(viewModel.isPasswordValid == false, "Empty password should be invalid")

        viewModel.password = "12345"
        #expect(viewModel.isPasswordValid == false, "Password < 6 chars should be invalid")

        // Valid passwords
        viewModel.password = "123456"
        #expect(viewModel.isPasswordValid == true, "6 char password should be valid")

        viewModel.password = "longerpassword123"
        #expect(viewModel.isPasswordValid == true, "Long password should be valid")
    }

    @Test func testPasswordMatch() {
        let viewModel = AuthViewModel()

        viewModel.password = "password123"
        viewModel.confirmPassword = "password123"
        #expect(viewModel.passwordsMatch == true, "Matching passwords should be valid")

        viewModel.confirmPassword = "different"
        #expect(viewModel.passwordsMatch == false, "Different passwords should not match")

        viewModel.password = ""
        viewModel.confirmPassword = ""
        #expect(viewModel.passwordsMatch == true, "Empty passwords should match")
    }

    @Test func testCanSubmitLogin() {
        let viewModel = AuthViewModel()
        viewModel.authMode = .login

        // Invalid state
        viewModel.email = ""
        viewModel.password = ""
        #expect(viewModel.canSubmit == false, "Cannot submit with empty fields")

        viewModel.email = "invalid"
        viewModel.password = "password"
        #expect(viewModel.canSubmit == false, "Cannot submit with invalid email")

        viewModel.email = "test@example.com"
        viewModel.password = ""
        #expect(viewModel.canSubmit == false, "Cannot submit with empty password")

        // Valid state
        viewModel.email = "test@example.com"
        viewModel.password = "password123"
        #expect(viewModel.canSubmit == true, "Should be able to submit with valid fields")

        // Loading state
        viewModel.isLoading = true
        #expect(viewModel.canSubmit == false, "Cannot submit while loading")
    }

    @Test func testCanSubmitSignUp() {
        let viewModel = AuthViewModel()
        viewModel.authMode = .signUp

        // Invalid state - short password
        viewModel.email = "test@example.com"
        viewModel.password = "12345"
        viewModel.confirmPassword = "12345"
        #expect(viewModel.canSubmit == false, "Cannot submit with short password")

        // Invalid state - passwords don't match
        viewModel.password = "password123"
        viewModel.confirmPassword = "different"
        #expect(viewModel.canSubmit == false, "Cannot submit with non-matching passwords")

        // Valid state
        viewModel.email = "test@example.com"
        viewModel.password = "password123"
        viewModel.confirmPassword = "password123"
        #expect(viewModel.canSubmit == true, "Should be able to submit with valid fields")
    }

    // MARK: - Auth Mode Tests

    @Test func testToggleAuthMode() {
        let viewModel = AuthViewModel()

        #expect(viewModel.authMode == .login, "Should start in login mode")

        viewModel.toggleAuthMode()
        #expect(viewModel.authMode == .signUp, "Should toggle to sign up mode")

        viewModel.toggleAuthMode()
        #expect(viewModel.authMode == .login, "Should toggle back to login mode")
    }

    @Test func testToggleAuthModeClearsFields() {
        let viewModel = AuthViewModel()

        viewModel.email = "test@example.com"
        viewModel.password = "password123"
        viewModel.confirmPassword = "password123"
        viewModel.errorMessage = "Some error"

        viewModel.toggleAuthMode()

        #expect(viewModel.email == "", "Email should be cleared")
        #expect(viewModel.password == "", "Password should be cleared")
        #expect(viewModel.confirmPassword == "", "Confirm password should be cleared")
        #expect(viewModel.errorMessage == nil, "Error message should be cleared")
    }

    // MARK: - Clear Fields Tests

    @Test func testClearFields() {
        let viewModel = AuthViewModel()

        viewModel.email = "test@example.com"
        viewModel.password = "password123"
        viewModel.confirmPassword = "password123"
        viewModel.errorMessage = "Error"
        viewModel.showError = true

        viewModel.clearFields()

        #expect(viewModel.email == "", "Email should be cleared")
        #expect(viewModel.password == "", "Password should be cleared")
        #expect(viewModel.confirmPassword == "", "Confirm password should be cleared")
        #expect(viewModel.errorMessage == nil, "Error message should be cleared")
        #expect(viewModel.showError == false, "Show error should be false")
    }

    // MARK: - State Tests

    @Test func testInitialState() {
        let viewModel = AuthViewModel()

        #expect(viewModel.email == "", "Email should be empty initially")
        #expect(viewModel.password == "", "Password should be empty initially")
        #expect(viewModel.confirmPassword == "", "Confirm password should be empty initially")
        #expect(viewModel.isLoading == false, "Should not be loading initially")
        #expect(viewModel.errorMessage == nil, "Should have no error initially")
        #expect(viewModel.showError == false, "Should not show error initially")
        #expect(viewModel.authMode == .login, "Should start in login mode")
    }

    // MARK: - Edge Cases

    @Test func testEmailWithSpaces() {
        let viewModel = AuthViewModel()

        viewModel.email = " test@example.com "
        // In real implementation, should trim spaces
        #expect(viewModel.isEmailValid == true, "Email with spaces should be valid")
    }

    @Test func testVeryLongPassword() {
        let viewModel = AuthViewModel()

        viewModel.password = String(repeating: "a", count: 1000)
        #expect(viewModel.isPasswordValid == true, "Very long password should be valid")
    }

    @Test func testSpecialCharactersInPassword() {
        let viewModel = AuthViewModel()

        viewModel.password = "!@#$%^&*()"
        #expect(viewModel.isPasswordValid == true, "Password with special chars should be valid")
    }

    @Test func testUnicodeInEmail() {
        let viewModel = AuthViewModel()

        viewModel.email = "тест@пример.рф"
        // Basic validation might not support unicode, but should not crash
        let _ = viewModel.isEmailValid
        #expect(true, "Should handle unicode without crashing")
    }
}
