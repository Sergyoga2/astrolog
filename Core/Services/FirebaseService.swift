import Firebase
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage
import Combine

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
        auth.addStateDidChangeListener { [weak self] _, user in
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