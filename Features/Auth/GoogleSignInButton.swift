import SwiftUI

// MARK: - Google Sign In Button
// TODO: Requires Google Sign In SDK integration
// Installation steps:
// 1. Add GoogleSignIn package via SPM: https://github.com/google/GoogleSignIn-iOS
// 2. Add Google-Service-Info.plist to project
// 3. Configure URL schemes in Info.plist
// 4. Import GoogleSignIn and GoogleSignInSwift

struct GoogleSignInButton: View {
    let onCompletion: (Result<GoogleSignInResult, Error>) -> Void

    var body: some View {
        Button {
            // Placeholder action
            onCompletion(.failure(GoogleSignInError.notConfigured))
        } label: {
            HStack(spacing: 12) {
                // Google Logo
                Image(systemName: "g.circle.fill")
                    .font(.system(size: 20))
                    .foregroundColor(.white)

                Text("Войти через Google")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(
                LinearGradient(
                    colors: [Color(red: 0.26, green: 0.52, blue: 0.96), Color(red: 0.13, green: 0.59, blue: 0.95)],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(12)
        }
    }
}

// Placeholder types until Google SDK is integrated
struct GoogleSignInResult {
    let idToken: String
    let accessToken: String
    let email: String?
    let fullName: String?
}

enum GoogleSignInError: Error {
    case notConfigured
    case cancelled
    case failed(String)
}

/*
// PRODUCTION IMPLEMENTATION (uncomment when Google SDK is added):

import GoogleSignIn
import GoogleSignInSwift

struct GoogleSignInButton: View {
    let onCompletion: (Result<GIDSignInResult, Error>) -> Void

    var body: some View {
        Button {
            handleGoogleSignIn()
        } label: {
            HStack(spacing: 12) {
                Image("google_logo") // Add to Assets
                    .resizable()
                    .frame(width: 20, height: 20)

                Text("Войти через Google")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(
                LinearGradient(
                    colors: [Color(red: 0.26, green: 0.52, blue: 0.96), Color(red: 0.13, green: 0.59, blue: 0.95)],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(12)
        }
    }

    private func handleGoogleSignIn() {
        guard let presentingViewController = UIApplication.shared.windows.first?.rootViewController else {
            return
        }

        GIDSignIn.sharedInstance.signIn(
            withPresenting: presentingViewController
        ) { result, error in
            if let error = error {
                onCompletion(.failure(error))
                return
            }

            guard let result = result else {
                onCompletion(.failure(GoogleSignInError.failed("No result")))
                return
            }

            onCompletion(.success(result))
        }
    }
}
*/

#Preview {
    GoogleSignInButton { result in
        print(result)
    }
    .padding()
}
