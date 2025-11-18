import XCTest

/// UI Tests for Onboarding flow
/// Tests the complete user onboarding experience
final class OnboardingUITests: XCTestCase {

    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()

        // Reset onboarding state for clean test
        app.launchArguments = ["--uitesting", "--reset-onboarding"]
        app.launch()
    }

    override func tearDownWithError() throws {
        app = nil
    }

    // MARK: - Onboarding Flow Tests

    func testOnboardingScreensNavigation() throws {
        // Should start at first onboarding screen
        XCTAssertTrue(app.staticTexts["Добро пожаловать в Astrolog"].exists)

        // Tap "Далее" to go to second screen
        app.buttons["Далее"].tap()

        // Wait for second screen
        let secondScreenTitle = app.staticTexts["Персональный гороскоп"]
        XCTAssertTrue(secondScreenTitle.waitForExistence(timeout: 2))

        // Tap "Далее" again
        app.buttons["Далее"].tap()

        // Wait for third screen
        let thirdScreenTitle = app.staticTexts["Начните свое путешествие"]
        XCTAssertTrue(thirdScreenTitle.waitForExistence(timeout: 2))

        // Final screen should have "Начать" button
        XCTAssertTrue(app.buttons["Начать"].exists)
    }

    func testOnboardingCompletion() throws {
        // Navigate through all screens
        app.buttons["Далее"].tap()
        sleep(1)
        app.buttons["Далее"].tap()
        sleep(1)

        // Tap "Начать" to complete onboarding
        app.buttons["Начать"].tap()

        // Should navigate to auth screen
        let authTitle = app.staticTexts["Вход"]
        XCTAssertTrue(authTitle.waitForExistence(timeout: 3))
    }

    func testOnboardingSkip() throws {
        // Some onboarding implementations have skip button
        if app.buttons["Пропустить"].exists {
            app.buttons["Пропустить"].tap()

            // Should navigate to auth screen
            let authTitle = app.staticTexts["Вход"]
            XCTAssertTrue(authTitle.waitForExistence(timeout: 3))
        }
    }

    func testOnboardingPageIndicator() throws {
        // Check if page indicators exist
        let pageIndicator = app.otherElements["PageIndicator"]
        if pageIndicator.exists {
            // Should start at first page
            XCTAssertEqual(pageIndicator.value as? String, "Страница 1 из 3")

            // Navigate to second page
            app.buttons["Далее"].tap()
            XCTAssertTrue(pageIndicator.waitForExistence(timeout: 2))
            XCTAssertEqual(pageIndicator.value as? String, "Страница 2 из 3")
        }
    }

    // MARK: - Animation Tests

    func testOnboardingAnimations() throws {
        // Check if animated elements exist (Lottie or similar)
        let animationView = app.otherElements["OnboardingAnimation"]

        if animationView.exists {
            XCTAssertTrue(animationView.isHittable)
        }
    }

    // MARK: - Accessibility Tests

    func testOnboardingAccessibility() throws {
        // Verify accessibility labels exist
        XCTAssertTrue(app.buttons["Далее"].isAccessibilityElement)

        // Navigate through screens and check accessibility
        for _ in 0..<3 {
            let nextButton = app.buttons["Далее"]
            if nextButton.exists {
                XCTAssertNotNil(nextButton.label)
                nextButton.tap()
                sleep(1)
            }
        }
    }

    // MARK: - Persistence Tests

    func testOnboardingNotShownAfterCompletion() throws {
        // Complete onboarding
        app.buttons["Далее"].tap()
        sleep(1)
        app.buttons["Далее"].tap()
        sleep(1)
        app.buttons["Начать"].tap()

        // Terminate and relaunch without reset flag
        app.terminate()

        let freshApp = XCUIApplication()
        freshApp.launchArguments = ["--uitesting"]
        freshApp.launch()

        // Should go directly to auth, not onboarding
        let authTitle = freshApp.staticTexts["Вход"]
        XCTAssertTrue(authTitle.waitForExistence(timeout: 3))

        // Onboarding title should not exist
        XCTAssertFalse(freshApp.staticTexts["Добро пожаловать в Astrolog"].exists)
    }
}
