import Testing
import Foundation
@testable import Astrolog

/// Tests for Localization Manager
@Suite("Localization Tests")
struct LocalizationTests {

    // MARK: - Language Switching Tests

    @Test("Default language is selected based on system locale")
    func testDefaultLanguage() {
        let manager = LocalizationManager.shared

        // Should be either English or Russian depending on system
        #expect([AppLanguage.english, AppLanguage.russian].contains(manager.currentLanguage))
    }

    @Test("Language can be switched to English")
    func testSwitchToEnglish() {
        let manager = LocalizationManager.shared

        manager.setLanguage(.english)

        #expect(manager.currentLanguage == .english)
    }

    @Test("Language can be switched to Russian")
    func testSwitchToRussian() {
        let manager = LocalizationManager.shared

        manager.setLanguage(.russian)

        #expect(manager.currentLanguage == .russian)
    }

    @Test("Language preference is persisted")
    func testLanguagePersistence() {
        let manager = LocalizationManager.shared

        // Set to Russian
        manager.setLanguage(.russian)

        // Check UserDefaults
        let savedLanguage = UserDefaults.standard.string(forKey: "app_language")
        #expect(savedLanguage == "ru")

        // Set to English
        manager.setLanguage(.english)

        let newSavedLanguage = UserDefaults.standard.string(forKey: "app_language")
        #expect(newSavedLanguage == "en")
    }

    // MARK: - English Localization Tests

    @Test("English auth strings are localized correctly")
    func testEnglishAuthStrings() {
        let manager = LocalizationManager.shared
        manager.setLanguage(.english)

        #expect(manager.string(for: .authLoginTitle) == "Sign In")
        #expect(manager.string(for: .authSignupTitle) == "Sign Up")
        #expect(manager.string(for: .authEmailPlaceholder) == "Email")
        #expect(manager.string(for: .authPasswordPlaceholder) == "Password")
        #expect(manager.string(for: .authLoginButton) == "Sign In")
        #expect(manager.string(for: .authSignupButton) == "Sign Up")
    }

    @Test("English common strings are localized correctly")
    func testEnglishCommonStrings() {
        let manager = LocalizationManager.shared
        manager.setLanguage(.english)

        #expect(manager.string(for: .commonOk) == "OK")
        #expect(manager.string(for: .commonCancel) == "Cancel")
        #expect(manager.string(for: .commonSave) == "Save")
        #expect(manager.string(for: .commonDelete) == "Delete")
        #expect(manager.string(for: .commonEdit) == "Edit")
        #expect(manager.string(for: .commonDone) == "Done")
    }

    @Test("English tab bar strings are localized correctly")
    func testEnglishTabBarStrings() {
        let manager = LocalizationManager.shared
        manager.setLanguage(.english)

        #expect(manager.string(for: .tabToday) == "Today")
        #expect(manager.string(for: .tabChart) == "Chart")
        #expect(manager.string(for: .tabSocial) == "Social")
        #expect(manager.string(for: .tabMindfulness) == "Mindfulness")
        #expect(manager.string(for: .tabProfile) == "Profile")
    }

    // MARK: - Russian Localization Tests

    @Test("Russian auth strings are localized correctly")
    func testRussianAuthStrings() {
        let manager = LocalizationManager.shared
        manager.setLanguage(.russian)

        #expect(manager.string(for: .authLoginTitle) == "Вход")
        #expect(manager.string(for: .authSignupTitle) == "Регистрация")
        #expect(manager.string(for: .authEmailPlaceholder) == "Email")
        #expect(manager.string(for: .authPasswordPlaceholder) == "Пароль")
        #expect(manager.string(for: .authLoginButton) == "Войти")
        #expect(manager.string(for: .authSignupButton) == "Зарегистрироваться")
    }

    @Test("Russian common strings are localized correctly")
    func testRussianCommonStrings() {
        let manager = LocalizationManager.shared
        manager.setLanguage(.russian)

        #expect(manager.string(for: .commonOk) == "OK")
        #expect(manager.string(for: .commonCancel) == "Отмена")
        #expect(manager.string(for: .commonSave) == "Сохранить")
        #expect(manager.string(for: .commonDelete) == "Удалить")
        #expect(manager.string(for: .commonEdit) == "Редактировать")
        #expect(manager.string(for: .commonDone) == "Готово")
    }

    @Test("Russian tab bar strings are localized correctly")
    func testRussianTabBarStrings() {
        let manager = LocalizationManager.shared
        manager.setLanguage(.russian)

        #expect(manager.string(for: .tabToday) == "Сегодня")
        #expect(manager.string(for: .tabChart) == "Карта")
        #expect(manager.string(for: .tabSocial) == "Соцсети")
        #expect(manager.string(for: .tabMindfulness) == "Медитация")
        #expect(manager.string(for: .tabProfile) == "Профиль")
    }

    // MARK: - String Formatting Tests

    @Test("String formatting works with arguments in English")
    func testEnglishStringFormatting() {
        let manager = LocalizationManager.shared
        manager.setLanguage(.english)

        let email = "test@example.com"
        let result = manager.string(for: .authSuccessReset, email)

        #expect(result.contains(email), "Formatted string should contain email")
        #expect(result == "Instructions sent to \(email)")
    }

    @Test("String formatting works with arguments in Russian")
    func testRussianStringFormatting() {
        let manager = LocalizationManager.shared
        manager.setLanguage(.russian)

        let email = "test@example.com"
        let result = manager.string(for: .authSuccessReset, email)

        #expect(result.contains(email), "Formatted string should contain email")
        #expect(result == "Инструкции отправлены на \(email)")
    }

    // MARK: - AppLanguage Enum Tests

    @Test("AppLanguage has correct codes")
    func testAppLanguageCodes() {
        #expect(AppLanguage.english.code == "en")
        #expect(AppLanguage.russian.code == "ru")
    }

    @Test("AppLanguage has flags")
    func testAppLanguageFlags() {
        #expect(AppLanguage.english.flag == "🇺🇸")
        #expect(AppLanguage.russian.flag == "🇷🇺")
    }

    @Test("AppLanguage has display names")
    func testAppLanguageDisplayNames() {
        #expect(AppLanguage.english.displayName == "English")
        #expect(AppLanguage.russian.displayName == "Русский")
    }

    @Test("All app languages are available in CaseIterable")
    func testAppLanguageCaseIterable() {
        let allLanguages = AppLanguage.allCases

        #expect(allLanguages.count == 2)
        #expect(allLanguages.contains(.english))
        #expect(allLanguages.contains(.russian))
    }

    // MARK: - Coverage Tests

    @Test("All auth keys have translations in both languages")
    func testAuthKeysCompleteness() {
        let manager = LocalizationManager.shared
        let authKeys: [LocalizationKey] = [
            .authLoginTitle, .authSignupTitle, .authEmailPlaceholder,
            .authPasswordPlaceholder, .authPasswordConfirm, .authLoginButton,
            .authSignupButton, .authForgotPassword
        ]

        // Test English
        manager.setLanguage(.english)
        for key in authKeys {
            let value = manager.string(for: key)
            #expect(!value.isEmpty, "English translation missing for \(key)")
            #expect(value != key.rawValue, "Translation not found for \(key)")
        }

        // Test Russian
        manager.setLanguage(.russian)
        for key in authKeys {
            let value = manager.string(for: key)
            #expect(!value.isEmpty, "Russian translation missing for \(key)")
            #expect(value != key.rawValue, "Translation not found for \(key)")
        }
    }

    @Test("All common keys have translations in both languages")
    func testCommonKeysCompleteness() {
        let manager = LocalizationManager.shared
        let commonKeys: [LocalizationKey] = [
            .commonOk, .commonCancel, .commonSave, .commonDelete,
            .commonEdit, .commonDone, .commonLoading, .commonError
        ]

        // Test English
        manager.setLanguage(.english)
        for key in commonKeys {
            let value = manager.string(for: key)
            #expect(!value.isEmpty, "English translation missing for \(key)")
        }

        // Test Russian
        manager.setLanguage(.russian)
        for key in commonKeys {
            let value = manager.string(for: key)
            #expect(!value.isEmpty, "Russian translation missing for \(key)")
        }
    }

    // MARK: - String Extension Tests

    @Test("String extension works with LocalizationKey")
    func testStringExtension() {
        let manager = LocalizationManager.shared
        manager.setLanguage(.english)

        let loginTitle = String(.authLoginTitle)
        #expect(loginTitle == "Sign In")

        manager.setLanguage(.russian)
        let loginTitleRu = String(.authLoginTitle)
        #expect(loginTitleRu == "Вход")
    }

    // MARK: - Thread Safety Tests

    @Test("Concurrent language switching is safe")
    func testConcurrentLanguageSwitching() async {
        let manager = LocalizationManager.shared

        await withTaskGroup(of: Void.self) { group in
            // Switch between languages concurrently
            for i in 0..<10 {
                group.addTask {
                    let language = i % 2 == 0 ? AppLanguage.english : AppLanguage.russian
                    manager.setLanguage(language)
                }
            }
        }

        // Should end up in a valid state
        #expect([AppLanguage.english, AppLanguage.russian].contains(manager.currentLanguage))
    }
}
