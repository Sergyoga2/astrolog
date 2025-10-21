import SwiftUI
import Firebase
import FirebaseAuth

struct AuthTestView: View {
    @EnvironmentObject var firebaseService: FirebaseService
    @EnvironmentObject var dataRepository: DataRepository
    @State private var testStatus = "Готов к тестированию"
    @State private var isLoading = false

    var body: some View {
        VStack(spacing: 20) {
            Text("🔥 Firebase Integration Test")
                .font(.title)
                .padding()

            Text(testStatus)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding()

            if firebaseService.isAuthenticated {
                VStack(spacing: 15) {
                    Text("✅ Authenticated")
                        .foregroundColor(.green)
                        .font(.headline)

                    if let user = firebaseService.currentUser {
                        Text("User ID: \(user.uid)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.horizontal)
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(8)
                    }

                    VStack(spacing: 10) {
                        Button("Test Data Save") {
                            Task {
                                await testDataPersistence()
                            }
                        }
                        .buttonStyle(.bordered)
                        .disabled(isLoading)

                        Button("Sign Out") {
                            try? firebaseService.signOut()
                            testStatus = "Logged out successfully"
                        }
                        .buttonStyle(.bordered)
                        .disabled(isLoading)
                    }
                }
            } else {
                VStack(spacing: 15) {
                    Text("❌ Not Authenticated")
                        .foregroundColor(.red)
                        .font(.headline)

                    Button("Sign In Anonymously") {
                        Task {
                            await testAuthentication()
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(isLoading)
                }
            }

            if isLoading {
                ProgressView("Testing...")
                    .padding()
            }

            Spacer()
        }
        .padding()
    }

    @MainActor
    private func testAuthentication() async {
        isLoading = true
        testStatus = "Signing in anonymously..."

        do {
            try await firebaseService.signInAnonymously()
            testStatus = "✅ Authentication successful!"
        } catch {
            testStatus = "❌ Authentication failed: \(error.localizedDescription)"
        }

        isLoading = false
    }

    @MainActor
    private func testDataPersistence() async {
        isLoading = true
        testStatus = "Testing data persistence..."

        do {
            // Create test birth chart
            let testChart = BirthChart(
                id: UUID().uuidString,
                userId: firebaseService.currentUser?.uid ?? "test_user",
                name: "Firebase Test Chart",
                birthDate: Date(),
                birthTime: "12:00",
                location: "Moscow, Russia",
                latitude: 55.7558,
                longitude: 37.6176,
                planets: [],
                houses: [],
                aspects: [],
                calculatedAt: Date()
            )

            testStatus = "Saving test chart..."
            try await dataRepository.saveBirthChart(testChart)

            testStatus = "Loading saved chart..."
            let loadedChart = await dataRepository.loadBirthChart()

            if loadedChart != nil {
                testStatus = "✅ Data persistence test successful! Chart saved and loaded."
            } else {
                testStatus = "❌ Failed to load saved chart"
            }

        } catch {
            testStatus = "❌ Data test failed: \(error.localizedDescription)"
        }

        isLoading = false
    }
}

#Preview {
    AuthTestView()
        .environmentObject(FirebaseService.shared)
}