import Firebase
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage
import Combine
import AuthenticationServices
import CryptoKit

@MainActor
class FirebaseService: ObservableObject {
    static let shared = FirebaseService()

    @Published var isAuthenticated = false
    @Published var currentUser: FirebaseAuth.User?

    private let auth = Auth.auth()
    private let db = Firestore.firestore()
    private let storage = Storage.storage()

    private init() {
        setupAuthListener()
    }

    // Firebase configuration is now handled in AstrologApp.swift

    private func setupAuthListener() {
        _ = auth.addStateDidChangeListener { [weak self] _, user in
            Task { @MainActor in
                self?.currentUser = user
                self?.isAuthenticated = user != nil
            }
        }
    }
}

// MARK: - Authentication
extension FirebaseService {
    func signInAnonymously() async throws {
        _ = try await auth.signInAnonymously()
    }

    func signUp(email: String, password: String) async throws {
        let result = try await auth.createUser(withEmail: email, password: password)
        await createUserDocument(uid: result.user.uid, email: email)
    }

    func signIn(email: String, password: String) async throws {
        _ = try await auth.signIn(withEmail: email, password: password)
    }

    func signOut() throws {
        try auth.signOut()
    }

    func deleteAccount() async throws {
        guard let user = currentUser else { return }
        try await user.delete()
    }

    // Sign in with Apple
    func signInWithApple(authorization: ASAuthorization) async throws {
        guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential else {
            throw FirebaseError.invalidData
        }

        guard let appleIDToken = appleIDCredential.identityToken,
              let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
            throw FirebaseError.invalidData
        }

        // Create nonce for security
        let nonce = randomNonceString()
        let hashedNonce = sha256(nonce)

        // Create Firebase credential
        let credential = OAuthProvider.appleCredential(
            withIDToken: idTokenString,
            rawNonce: nonce,
            fullName: appleIDCredential.fullName
        )

        // Sign in with Firebase
        let result = try await auth.signIn(with: credential)

        // Create user document if this is a new user
        if let email = result.user.email {
            await createUserDocument(uid: result.user.uid, email: email)
        }
    }

    func resetPassword(email: String) async throws {
        try await auth.sendPasswordReset(withEmail: email)
    }

    func sendEmailVerification() async throws {
        guard let user = currentUser else {
            throw FirebaseError.notAuthenticated
        }
        try await user.sendEmailVerification()
    }

    // Google Sign In
    // TODO: Uncomment when GoogleSignIn SDK is integrated
    /*
    func signInWithGoogle(result: GIDSignInResult) async throws {
        guard let idToken = result.user.idToken?.tokenString else {
            throw FirebaseError.invalidData
        }

        let credential = GoogleAuthProvider.credential(
            withIDToken: idToken,
            accessToken: result.user.accessToken.tokenString
        )

        let authResult = try await auth.signIn(with: credential)

        // Create user document if this is a new user
        if let email = authResult.user.email {
            await createUserDocument(uid: authResult.user.uid, email: email)
        }
    }
    */

    // MARK: - Helpers for Sign in with Apple

    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        var randomBytes = [UInt8](repeating: 0, count: length)
        let errorCode = SecRandomCopyBytes(kSecRandomDefault, randomBytes.count, &randomBytes)
        if errorCode != errSecSuccess {
            fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
        }

        let charset: [Character] = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")

        let nonce = randomBytes.map { byte in
            charset[Int(byte) % charset.count]
        }

        return String(nonce)
    }

    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            String(format: "%02x", $0)
        }.joined()

        return hashString
    }
}

// MARK: - User Document Management
extension FirebaseService {
    private func createUserDocument(uid: String, email: String) async {
        let userData: [String: Any] = [
            "email": email,
            "createdAt": Timestamp(),
            "subscriptionTier": "free"
        ]

        do {
            try await db.collection("users").document(uid).setData(userData)
        } catch {
            print("Error creating user document: \(error)")
        }
    }

    func updateUserSubscription(tier: String) async throws {
        guard let uid = currentUser?.uid else { return }

        try await db.collection("users").document(uid).updateData([
            "subscriptionTier": tier,
            "updatedAt": Timestamp()
        ])
    }
}

// MARK: - Birth Chart Data
extension FirebaseService {
    func saveBirthChart(_ chartData: [String: Any]) async throws {
        guard let uid = currentUser?.uid else {
            throw FirebaseError.notAuthenticated
        }

        let chartDocument: [String: Any] = [
            "chartData": chartData,
            "calculatedAt": Timestamp(),
            "userId": uid
        ]

        try await db.collection("birthCharts")
            .document(uid)
            .setData(chartDocument, merge: true)
    }

    func loadBirthChart() async throws -> [String: Any]? {
        guard let uid = currentUser?.uid else {
            throw FirebaseError.notAuthenticated
        }

        let document = try await db.collection("birthCharts").document(uid).getDocument()
        return document.data()?["chartData"] as? [String: Any]
    }
}

// MARK: - Horoscope Data
extension FirebaseService {
    func saveHoroscope(date: String, sign: String, content: [String: Any]) async throws {
        let horoscopeData: [String: Any] = [
            "content": content,
            "createdAt": Timestamp()
        ]

        try await db.collection("horoscopes")
            .document(date)
            .collection("signs")
            .document(sign)
            .setData(horoscopeData)
    }

    func loadHoroscope(date: String, sign: String) async throws -> [String: Any]? {
        let document = try await db.collection("horoscopes")
            .document(date)
            .collection("signs")
            .document(sign)
            .getDocument()

        return document.data()?["content"] as? [String: Any]
    }
}

// MARK: - Error Types
enum FirebaseError: Error, LocalizedError {
    case notAuthenticated
    case documentNotFound
    case invalidData

    var errorDescription: String? {
        switch self {
        case .notAuthenticated:
            return "User is not authenticated"
        case .documentNotFound:
            return "Document not found"
        case .invalidData:
            return "Invalid data format"
        }
    }
}