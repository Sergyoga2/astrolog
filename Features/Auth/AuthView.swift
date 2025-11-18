import SwiftUI

struct AuthView: View {
    @StateObject private var viewModel = AuthViewModel()
    @EnvironmentObject private var firebaseService: FirebaseService
    @EnvironmentObject private var appCoordinator: AppCoordinator
    @State private var showForgotPasswordAlert = false

    var body: some View {
        ZStack {
            // Cosmic Background
            StarfieldBackground()
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 32) {
                    // Header
                    authHeader

                    // Auth Form
                    authForm

                    // Toggle Auth Mode
                    toggleButton

                    // Social Sign In
                    VStack(spacing: 12) {
                        // Sign in with Apple
                        SignInWithAppleButton { result in
                            Task {
                                await viewModel.handleSignInWithApple(result: result)
                            }
                        }
                        .padding(.horizontal, 24)

                        // Google Sign In (requires Google SDK setup)
                        // TODO: Uncomment when GoogleSignIn SDK is configured
                        /*
                        GoogleSignInButton { result in
                            Task {
                                await viewModel.handleSignInWithGoogle(result: result)
                            }
                        }
                        .padding(.horizontal, 24)
                        */
                    }

                    // Divider
                    orDivider

                    // Anonymous Sign In
                    anonymousButton

                    Spacer()
                }
                .padding(.horizontal, 24)
                .padding(.top, 60)
            }

            // Loading Overlay
            if viewModel.isLoading {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                CosmicLoadingView()
            }
        }
        .alert("Ошибка", isPresented: $viewModel.showError) {
            Button("OK", role: .cancel) { }
        } message: {
            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
            }
        }
        .onChange(of: firebaseService.isAuthenticated) { isAuthenticated in
            if isAuthenticated {
                appCoordinator.completeAuth()
            }
        }
        .alert("Сброс пароля", isPresented: $showForgotPasswordAlert) {
            Button("Отправить") {
                Task {
                    await viewModel.resetPassword()
                }
            }
            Button("Отмена", role: .cancel) { }
        } message: {
            Text("Инструкции будут отправлены на: \(viewModel.email)")
        }
    }

    private var authHeader: some View {
        VStack(spacing: 12) {
            // Logo or Icon
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [.neonPurple, .neonBlue],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 80, height: 80)
                    .modifier(NeonGlow(color: .neonPurple, intensity: 0.8))

                Image(systemName: "sparkles")
                    .font(.system(size: 36))
                    .foregroundColor(.white)
            }

            Text(viewModel.authMode == .login ? "Вход" : "Регистрация")
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundColor(.white)

            Text(viewModel.authMode == .login ?
                 "Добро пожаловать в Astrolog" :
                 "Создайте свой астрологический профиль")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
        }
    }

    private var authForm: some View {
        VStack(spacing: 20) {
            CosmicCard(glowColor: .neonPurple) {
                VStack(spacing: 16) {
                    // Email Field
                    CosmicTextField(
                        "Email",
                        text: $viewModel.email,
                        icon: "envelope.fill"
                    )
                    .textInputAutocapitalization(.never)
                    .keyboardType(.emailAddress)
                    .autocorrectionDisabled()

                    // Password Field
                    SecureField("", text: $viewModel.password)
                        .placeholder(when: viewModel.password.isEmpty) {
                            Text("Пароль")
                                .foregroundColor(.gray.opacity(0.6))
                        }
                        .padding()
                        .background(Color.white.opacity(0.05))
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.neonPurple.opacity(0.3), lineWidth: 1)
                        )

                    // Confirm Password (Sign Up only)
                    if viewModel.authMode == .signUp {
                        SecureField("", text: $viewModel.confirmPassword)
                            .placeholder(when: viewModel.confirmPassword.isEmpty) {
                                Text("Подтвердите пароль")
                                    .foregroundColor(.gray.opacity(0.6))
                            }
                            .padding()
                            .background(Color.white.opacity(0.05))
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.neonPurple.opacity(0.3), lineWidth: 1)
                            )

                        // Password validation hints
                        if viewModel.authMode == .signUp {
                            VStack(alignment: .leading, spacing: 4) {
                                ValidationHint(
                                    text: "Минимум 6 символов",
                                    isValid: viewModel.password.count >= 6
                                )
                                ValidationHint(
                                    text: "Пароли совпадают",
                                    isValid: viewModel.passwordsMatch && !viewModel.confirmPassword.isEmpty
                                )
                            }
                            .padding(.top, 4)
                        }
                    }

                    // Submit Button
                    CosmicButton(
                        title: viewModel.authMode == .login ? "Войти" : "Зарегистрироваться",
                        icon: viewModel.authMode == .login ? "arrow.right.circle.fill" : "person.badge.plus.fill",
                        color: .neonPurple
                    ) {
                        Task {
                            if viewModel.authMode == .login {
                                await viewModel.signIn()
                            } else {
                                await viewModel.signUp()
                            }
                        }
                    }
                    .disabled(!viewModel.canSubmit)
                    .opacity(viewModel.canSubmit ? 1.0 : 0.5)

                    // Forgot Password (Login only)
                    if viewModel.authMode == .login {
                        Button("Забыли пароль?") {
                            showForgotPasswordAlert = true
                        }
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.neonBlue)
                        .padding(.top, 4)
                    }
                }
            }
        }
    }

    private var toggleButton: some View {
        Button {
            viewModel.toggleAuthMode()
        } label: {
            HStack(spacing: 4) {
                Text(viewModel.authMode == .login ?
                     "Нет аккаунта?" :
                     "Уже есть аккаунт?")
                    .foregroundColor(.gray)
                Text(viewModel.authMode == .login ?
                     "Зарегистрируйтесь" :
                     "Войдите")
                    .foregroundColor(.neonPurple)
                    .fontWeight(.semibold)
            }
            .font(.system(size: 15))
        }
    }

    private var orDivider: some View {
        HStack {
            Rectangle()
                .fill(Color.gray.opacity(0.3))
                .frame(height: 1)
            Text("или")
                .font(.system(size: 14))
                .foregroundColor(.gray)
                .padding(.horizontal, 12)
            Rectangle()
                .fill(Color.gray.opacity(0.3))
                .frame(height: 1)
        }
        .padding(.horizontal, 24)
    }

    private var anonymousButton: some View {
        Button {
            Task {
                await viewModel.signInAnonymously()
            }
        } label: {
            HStack {
                Image(systemName: "person.crop.circle.dashed")
                    .font(.system(size: 18))
                Text("Продолжить без регистрации")
                    .font(.system(size: 16, weight: .medium))
            }
            .foregroundColor(.white.opacity(0.8))
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.white.opacity(0.1))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
            )
        }
        .padding(.horizontal, 24)
    }
}

// MARK: - Helper Views

struct ValidationHint: View {
    let text: String
    let isValid: Bool

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: isValid ? "checkmark.circle.fill" : "circle")
                .font(.system(size: 12))
                .foregroundColor(isValid ? .green : .gray.opacity(0.5))
            Text(text)
                .font(.system(size: 12))
                .foregroundColor(isValid ? .green : .gray.opacity(0.7))
        }
    }
}

// Placeholder modifier for SecureField
extension View {
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content
    ) -> some View {
        ZStack(alignment: alignment) {
            placeholder().opacity(shouldShow ? 1 : 0)
            self
        }
    }
}

#Preview {
    AuthView()
        .environmentObject(FirebaseService.shared)
        .environmentObject(AppCoordinator())
}
