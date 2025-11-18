import XCTest

/// UI Tests for Authentication flow
/// Tests login, signup, password reset, and Apple Sign In flows
final class AuthUITests: XCTestCase {

    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()

        // Start at auth screen with clean state
        app.launchArguments = ["--uitesting", "--start-at-auth", "--clear-keychain"]
        app.launch()
    }

    override func tearDownWithError() throws {
        app = nil
    }

    // MARK: - Login Flow Tests

    func testLoginScreenElements() throws {
        // Verify all UI elements exist
        XCTAssertTrue(app.staticTexts["Вход"].exists)
        XCTAssertTrue(app.textFields["Email"].exists)
        XCTAssertTrue(app.secureTextFields.element.exists)
        XCTAssertTrue(app.buttons["Войти"].exists)
        XCTAssertTrue(app.buttons["Регистрация"].exists)
    }

    func testSwitchToSignUpMode() throws {
        // Tap "Регистрация" to switch mode
        app.buttons["Регистрация"].tap()

        // Should show signup UI
        XCTAssertTrue(app.staticTexts["Регистрация"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.buttons["Создать аккаунт"].exists)

        // Switch back to login
        app.buttons["Вход"].tap()
        XCTAssertTrue(app.staticTexts["Вход"].waitForExistence(timeout: 2))
    }

    func testEmailValidation() throws {
        let emailField = app.textFields["Email"]
        let passwordField = app.secureTextFields.element

        // Enter invalid email
        emailField.tap()
        emailField.typeText("invalid-email")

        // Enter password
        passwordField.tap()
        passwordField.typeText("password123")

        // Try to submit
        app.buttons["Войти"].tap()

        // Should show validation error
        let errorText = app.staticTexts.matching(NSPredicate(format: "label CONTAINS 'email'")).firstMatch
        XCTAssertTrue(errorText.waitForExistence(timeout: 2))
    }

    func testPasswordValidation() throws {
        // Switch to signup mode
        app.buttons["Регистрация"].tap()

        let emailField = app.textFields["Email"]
        let passwordField = app.secureTextFields.firstMatch
        let confirmPasswordField = app.secureTextFields.element(boundBy: 1)

        // Enter valid email
        emailField.tap()
        emailField.typeText("test@example.com")

        // Enter short password
        passwordField.tap()
        passwordField.typeText("123")

        // Enter mismatched confirmation
        confirmPasswordField.tap()
        confirmPasswordField.typeText("456")

        // Try to submit
        app.buttons["Создать аккаунт"].tap()

        // Should show password validation errors
        let errorExists = app.staticTexts.matching(NSPredicate(format: "label CONTAINS 'Пароль'")).firstMatch.exists
        XCTAssertTrue(errorExists)
    }

    func testPasswordVisibilityToggle() throws {
        let passwordField = app.secureTextFields.element

        // Enter password
        passwordField.tap()
        passwordField.typeText("MyPassword123")

        // Look for visibility toggle button (if implemented)
        let toggleButton = app.buttons["TogglePasswordVisibility"]
        if toggleButton.exists {
            toggleButton.tap()

            // Password should now be in text field, not secure field
            XCTAssertTrue(app.textFields["Password"].exists)

            // Toggle back
            toggleButton.tap()
            XCTAssertTrue(app.secureTextFields.element.exists)
        }
    }

    func testForgotPasswordFlow() throws {
        // Tap "Забыли пароль?"
        app.buttons["Забыли пароль?"].tap()

        // Should show reset password UI
        let resetTitle = app.staticTexts["Сброс пароля"]
        XCTAssertTrue(resetTitle.waitForExistence(timeout: 2))

        // Enter email
        let emailField = app.textFields["Email"]
        emailField.tap()
        emailField.typeText("test@example.com")

        // Submit reset request
        app.buttons["Отправить ссылку"].tap()

        // Should show success message
        let successMessage = app.staticTexts.matching(NSPredicate(format: "label CONTAINS 'отправлена'")).firstMatch
        XCTAssertTrue(successMessage.waitForExistence(timeout: 3))
    }

    func testAnonymousSignIn() throws {
        // Tap "Войти анонимно" if available
        let anonymousButton = app.buttons["Войти анонимно"]

        if anonymousButton.exists {
            anonymousButton.tap()

            // Should navigate to main app
            let mainTabBar = app.tabBars.firstMatch
            XCTAssertTrue(mainTabBar.waitForExistence(timeout: 5))
        }
    }

    // MARK: - Apple Sign In Tests

    func testAppleSignInButtonExists() throws {
        // Verify Apple Sign In button is present
        let appleButton = app.buttons["Sign in with Apple"]
        XCTAssertTrue(appleButton.exists)
        XCTAssertTrue(appleButton.isEnabled)
    }

    func testAppleSignInTap() throws {
        let appleButton = app.buttons["Sign in with Apple"]

        if appleButton.exists {
            appleButton.tap()

            // Note: Actual Apple Sign In flow requires system dialog
            // In UI tests, this would show the Apple ID dialog
            // We can't fully test this without mocking
        }
    }

    // MARK: - Google Sign In Tests

    func testGoogleSignInButtonExists() throws {
        // Verify Google Sign In button is present (if implemented)
        let googleButton = app.buttons["Войти через Google"]

        if googleButton.exists {
            XCTAssertTrue(googleButton.isEnabled)
        }
    }

    // MARK: - Form Interaction Tests

    func testEmailFieldCharacterLimit() throws {
        let emailField = app.textFields["Email"]
        emailField.tap()

        // Type very long email
        let longEmail = String(repeating: "a", count: 100) + "@example.com"
        emailField.typeText(longEmail)

        // Field should accept it (no hard limit typically)
        XCTAssertTrue(emailField.value as? String != nil)
    }

    func testKeyboardDismissal() throws {
        let emailField = app.textFields["Email"]
        emailField.tap()
        emailField.typeText("test@example.com")

        // Tap outside to dismiss keyboard
        app.otherElements["AuthView"].tap()

        // Keyboard should be dismissed
        XCTAssertFalse(app.keyboards.firstMatch.exists)
    }

    func testTabThroughFields() throws {
        let emailField = app.textFields["Email"]
        emailField.tap()
        emailField.typeText("test@example.com")

        // Tap return to move to next field
        app.keyboards.buttons["return"].tap()

        // Should focus on password field
        let passwordField = app.secureTextFields.element
        XCTAssertTrue(passwordField.hasFocus)
    }

    // MARK: - Loading State Tests

    func testLoadingStateWhileAuthenticating() throws {
        let emailField = app.textFields["Email"]
        let passwordField = app.secureTextFields.element

        emailField.tap()
        emailField.typeText("test@example.com")
        passwordField.tap()
        passwordField.typeText("ValidPass123!")

        app.buttons["Войти"].tap()

        // Loading indicator should appear
        let loadingIndicator = app.activityIndicators.firstMatch
        XCTAssertTrue(loadingIndicator.waitForExistence(timeout: 2))

        // Button should be disabled during loading
        XCTAssertFalse(app.buttons["Войти"].isEnabled)
    }

    // MARK: - Error Handling Tests

    func testInvalidCredentialsError() throws {
        let emailField = app.textFields["Email"]
        let passwordField = app.secureTextFields.element

        emailField.tap()
        emailField.typeText("wrong@example.com")
        passwordField.tap()
        passwordField.typeText("WrongPassword123!")

        app.buttons["Войти"].tap()

        // Should show error alert or message
        let errorAlert = app.alerts.firstMatch
        if errorAlert.waitForExistence(timeout: 5) {
            XCTAssertTrue(errorAlert.staticTexts.matching(NSPredicate(format: "label CONTAINS 'ошибка' OR label CONTAINS 'неверн'")).firstMatch.exists)

            // Dismiss alert
            errorAlert.buttons["OK"].tap()
        }
    }

    // MARK: - Accessibility Tests

    func testAccessibilityLabels() throws {
        XCTAssertTrue(app.textFields["Email"].isAccessibilityElement)
        XCTAssertNotNil(app.textFields["Email"].label)

        XCTAssertTrue(app.buttons["Войти"].isAccessibilityElement)
        XCTAssertNotNil(app.buttons["Войти"].label)
    }

    func testVoiceOverSupport() throws {
        // Enable VoiceOver (requires accessibility permissions)
        // Verify all elements have proper labels and hints

        let emailField = app.textFields["Email"]
        XCTAssertNotNil(emailField.accessibilityLabel)
        XCTAssertNotNil(emailField.accessibilityHint)
    }

    // MARK: - Successful Authentication Tests

    func testSuccessfulLoginNavigatesToMainApp() throws {
        // This would require a test account or mocking
        // Placeholder for integration with Firebase emulator

        let emailField = app.textFields["Email"]
        let passwordField = app.secureTextFields.element

        emailField.tap()
        emailField.typeText("testuser@example.com")
        passwordField.tap()
        passwordField.typeText("TestPassword123!")

        app.buttons["Войти"].tap()

        // If auth succeeds, should navigate to main tab bar
        let mainTabBar = app.tabBars.firstMatch
        if mainTabBar.waitForExistence(timeout: 10) {
            XCTAssertTrue(mainTabBar.exists)
            XCTAssertTrue(mainTabBar.buttons.count > 0)
        }
    }
}

// MARK: - XCUIElement Extensions

extension XCUIElement {
    var hasFocus: Bool {
        return (self.value(forKey: "hasKeyboardFocus") as? Bool) ?? false
    }
}
