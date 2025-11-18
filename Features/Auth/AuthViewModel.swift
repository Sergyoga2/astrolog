import SwiftUI
import Combine
import AuthenticationServices

@MainActor
final class AuthViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var confirmPassword = ""
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var showError = false
    @Published var authMode: AuthMode = .login

    enum AuthMode {
        case login
        case signUp
    }

    private let firebaseService: FirebaseService
    private var cancellables = Set<AnyCancellable>()

    // Validation
    var isEmailValid: Bool {
        email.contains("@") && email.contains(".")
    }

    var isPasswordValid: Bool {
        password.count >= 6
    }

    var passwordsMatch: Bool {
        password == confirmPassword
    }

    var canSubmit: Bool {
        switch authMode {
        case .login:
            return isEmailValid && !password.isEmpty && !isLoading
        case .signUp:
            return isEmailValid && isPasswordValid && passwordsMatch && !isLoading
        }
    }

    init(firebaseService: FirebaseService = .shared) {
        self.firebaseService = firebaseService
    }

    func toggleAuthMode() {
        authMode = authMode == .login ? .signUp : .login
        clearFields()
    }

    func signIn() async {
        guard canSubmit else { return }

        isLoading = true
        errorMessage = nil

        do {
            try await firebaseService.signIn(email: email, password: password)
            // Success handled by FirebaseService state change
        } catch {
            errorMessage = handleAuthError(error)
            showError = true
        }

        isLoading = false
    }

    func signUp() async {
        guard canSubmit else { return }

        isLoading = true
        errorMessage = nil

        do {
            try await firebaseService.signUp(email: email, password: password)
            // Send email verification
            try? await firebaseService.sendEmailVerification()
            // Success handled by FirebaseService state change
        } catch {
            errorMessage = handleAuthError(error)
            showError = true
        }

        isLoading = false
    }

    func sendEmailVerification() async {
        isLoading = true
        errorMessage = nil

        do {
            try await firebaseService.sendEmailVerification()
            errorMessage = "Письмо с подтверждением отправлено"
            showError = true
        } catch {
            errorMessage = "Не удалось отправить письмо: \(error.localizedDescription)"
            showError = true
        }

        isLoading = false
    }

    func signInAnonymously() async {
        isLoading = true
        errorMessage = nil

        do {
            try await firebaseService.signInAnonymously()
        } catch {
            errorMessage = "Не удалось войти анонимно: \(error.localizedDescription)"
            showError = true
        }

        isLoading = false
    }

    func handleSignInWithApple(result: Result<ASAuthorization, Error>) async {
        isLoading = true
        errorMessage = nil

        switch result {
        case .success(let authorization):
            do {
                try await firebaseService.signInWithApple(authorization: authorization)
                // Success handled by FirebaseService state change
            } catch {
                errorMessage = "Не удалось войти через Apple: \(error.localizedDescription)"
                showError = true
            }
        case .failure(let error):
            errorMessage = "Ошибка Apple Sign In: \(error.localizedDescription)"
            showError = true
        }

        isLoading = false
    }

    func resetPassword() async {
        guard isEmailValid else {
            errorMessage = "Введите корректный email"
            showError = true
            return
        }

        isLoading = true
        errorMessage = nil

        do {
            try await firebaseService.resetPassword(email: email)
            errorMessage = "Инструкции отправлены на \(email)"
            showError = true
        } catch {
            errorMessage = handleAuthError(error)
            showError = true
        }

        isLoading = false
    }

    func clearFields() {
        email = ""
        password = ""
        confirmPassword = ""
        errorMessage = nil
        showError = false
    }

    private func handleAuthError(_ error: Error) -> String {
        let nsError = error as NSError

        switch nsError.code {
        case 17007: // Email already in use
            return "Этот email уже зарегистрирован"
        case 17008: // Invalid email
            return "Неверный формат email"
        case 17009: // Wrong password
            return "Неверный пароль"
        case 17011: // User not found
            return "Пользователь не найден"
        case 17026: // Weak password
            return "Слишком слабый пароль (минимум 6 символов)"
        default:
            return "Ошибка: \(error.localizedDescription)"
        }
    }
}
