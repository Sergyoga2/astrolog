import Foundation
import SwiftUI

/// Manager for app localization
final class LocalizationManager {
    static let shared = LocalizationManager()

    private init() {}

    /// Returns localized string for key
    func string(for key: LocalizationKey) -> String {
        NSLocalizedString(key.rawValue, comment: key.comment)
    }

    /// Returns localized string with arguments
    func string(for key: LocalizationKey, _ arguments: CVarArg...) -> String {
        String(format: NSLocalizedString(key.rawValue, comment: key.comment), arguments: arguments)
    }
}

// MARK: - Localization Keys

enum LocalizationKey: String {
    // MARK: - Authentication
    case authLoginTitle = "auth.login.title"
    case authSignupTitle = "auth.signup.title"
    case authEmailPlaceholder = "auth.email.placeholder"
    case authPasswordPlaceholder = "auth.password.placeholder"
    case authPasswordConfirm = "auth.password.confirm"
    case authLoginButton = "auth.login.button"
    case authSignupButton = "auth.signup.button"
    case authForgotPassword = "auth.forgot.password"
    case authResetPasswordTitle = "auth.reset.password.title"
    case authResetPasswordMessage = "auth.reset.password.message"
    case authSend = "auth.send"
    case authCancel = "auth.cancel"
    case authAnonymousButton = "auth.anonymous.button"
    case authWelcomeMessage = "auth.welcome.message"
    case authCreateProfile = "auth.create.profile"
    case authSignInApple = "auth.sign.in.apple"
    case authSignInGoogle = "auth.sign.in.google"
    case authOr = "auth.or"
    case authNoAccount = "auth.no.account"
    case authHaveAccount = "auth.have.account"
    case authSignupLink = "auth.signup.link"
    case authLoginLink = "auth.login.link"

    // Validation
    case authValidationPasswordMin = "auth.validation.password.min"
    case authValidationPasswordMatch = "auth.validation.password.match"
    case authValidationEmailInvalid = "auth.validation.email.invalid"

    // Errors
    case authErrorTitle = "auth.error.title"
    case authErrorOk = "auth.error.ok"
    case authErrorEmailUsed = "auth.error.email.used"
    case authErrorEmailInvalid = "auth.error.email.invalid"
    case authErrorPasswordWrong = "auth.error.password.wrong"
    case authErrorUserNotFound = "auth.error.user.not.found"
    case authErrorPasswordWeak = "auth.error.password.weak"
    case authErrorAnonymousFailed = "auth.error.anonymous.failed"
    case authErrorAppleFailed = "auth.error.apple.failed"
    case authErrorGoogleFailed = "auth.error.google.failed"
    case authErrorResetFailed = "auth.error.reset.failed"
    case authSuccessReset = "auth.success.reset"
    case authSuccessVerification = "auth.success.verification"

    // MARK: - Common
    case commonOk = "common.ok"
    case commonCancel = "common.cancel"
    case commonSave = "common.save"
    case commonDelete = "common.delete"
    case commonEdit = "common.edit"
    case commonDone = "common.done"
    case commonLoading = "common.loading"
    case commonError = "common.error"
    case commonRetry = "common.retry"
    case commonClose = "common.close"
    case commonNext = "common.next"
    case commonBack = "common.back"
    case commonSkip = "common.skip"
    case commonYes = "common.yes"
    case commonNo = "common.no"

    // MARK: - Tab Bar
    case tabToday = "tab.today"
    case tabChart = "tab.chart"
    case tabSocial = "tab.social"
    case tabMindfulness = "tab.mindfulness"
    case tabProfile = "tab.profile"

    var comment: String {
        switch self {
        case .authLoginTitle:
            return "Login screen title"
        case .authSignupTitle:
            return "Sign up screen title"
        case .authEmailPlaceholder:
            return "Email input placeholder"
        case .authPasswordPlaceholder:
            return "Password input placeholder"
        case .authPasswordConfirm:
            return "Confirm password input placeholder"
        case .authLoginButton:
            return "Login button text"
        case .authSignupButton:
            return "Sign up button text"
        case .authForgotPassword:
            return "Forgot password link text"
        case .authResetPasswordTitle:
            return "Reset password alert title"
        case .authResetPasswordMessage:
            return "Reset password alert message"
        case .authSend:
            return "Send button text"
        case .authCancel:
            return "Cancel button text"
        case .authAnonymousButton:
            return "Continue anonymously button text"
        case .authWelcomeMessage:
            return "Welcome message"
        case .authCreateProfile:
            return "Create profile message"
        case .authSignInApple:
            return "Sign in with Apple button"
        case .authSignInGoogle:
            return "Sign in with Google button"
        case .authOr:
            return "Or divider text"
        case .authNoAccount:
            return "No account prompt"
        case .authHaveAccount:
            return "Have account prompt"
        case .authSignupLink:
            return "Sign up link text"
        case .authLoginLink:
            return "Login link text"
        case .authValidationPasswordMin:
            return "Password minimum length validation"
        case .authValidationPasswordMatch:
            return "Passwords match validation"
        case .authValidationEmailInvalid:
            return "Invalid email validation"
        case .authErrorTitle:
            return "Error alert title"
        case .authErrorOk:
            return "OK button text"
        case .authErrorEmailUsed:
            return "Email already used error"
        case .authErrorEmailInvalid:
            return "Invalid email error"
        case .authErrorPasswordWrong:
            return "Wrong password error"
        case .authErrorUserNotFound:
            return "User not found error"
        case .authErrorPasswordWeak:
            return "Weak password error"
        case .authErrorAnonymousFailed:
            return "Anonymous sign in failed error"
        case .authErrorAppleFailed:
            return "Apple sign in failed error"
        case .authErrorGoogleFailed:
            return "Google sign in failed error"
        case .authErrorResetFailed:
            return "Password reset failed error"
        case .authSuccessReset:
            return "Password reset success message"
        case .authSuccessVerification:
            return "Email verification sent message"
        case .commonOk:
            return "OK button"
        case .commonCancel:
            return "Cancel button"
        case .commonSave:
            return "Save button"
        case .commonDelete:
            return "Delete button"
        case .commonEdit:
            return "Edit button"
        case .commonDone:
            return "Done button"
        case .commonLoading:
            return "Loading text"
        case .commonError:
            return "Error text"
        case .commonRetry:
            return "Retry button"
        case .commonClose:
            return "Close button"
        case .commonNext:
            return "Next button"
        case .commonBack:
            return "Back button"
        case .commonSkip:
            return "Skip button"
        case .commonYes:
            return "Yes button"
        case .commonNo:
            return "No button"
        case .tabToday:
            return "Today tab"
        case .tabChart:
            return "Chart tab"
        case .tabSocial:
            return "Social tab"
        case .tabMindfulness:
            return "Mindfulness tab"
        case .tabProfile:
            return "Profile tab"
        }
    }
}

// MARK: - SwiftUI Extension

extension String {
    /// Initialize String with LocalizationKey
    init(_ key: LocalizationKey) {
        self = LocalizationManager.shared.string(for: key)
    }

    /// Initialize String with LocalizationKey and arguments
    init(_ key: LocalizationKey, _ arguments: CVarArg...) {
        self = String(format: LocalizationManager.shared.string(for: key), arguments: arguments)
    }
}

// MARK: - Text Extension for SwiftUI

extension Text {
    /// Initialize Text with LocalizationKey
    init(_ key: LocalizationKey) {
        self = Text(LocalizationManager.shared.string(for: key))
    }
}
