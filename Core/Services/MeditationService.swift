import Foundation
import Combine

/// Service for managing meditations and progress
@MainActor
class MeditationService: ObservableObject {
    static let shared = MeditationService()

    @Published var meditations: [Meditation] = []
    @Published var favorites: [Meditation] = []
    @Published var recentlyPlayed: [Meditation] = []
    @Published var progress: [MeditationProgress] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let firebaseService = FirebaseService.shared
    private var cancellables = Set<AnyCancellable>()

    private init() {}

    // MARK: - Load Meditations

    /// Load all available meditations
    func loadMeditations() async {
        isLoading = true
        defer { isLoading = false }

        do {
            let meditationsData = try await firebaseService.loadMeditations()
            meditations = meditationsData.compactMap { Meditation.fromDictionary($0) }

            // Filter favorites
            favorites = meditations.filter { $0.isFavorite }

            // Sort recently played
            recentlyPlayed = meditations
                .filter { $0.lastPlayedAt != nil }
                .sorted { ($0.lastPlayedAt ?? Date.distantPast) > ($1.lastPlayedAt ?? Date.distantPast) }
                .prefix(10)
                .map { $0 }

            errorMessage = nil
        } catch {
            errorMessage = "Failed to load meditations: \(error.localizedDescription)"
        }
    }

    /// Load meditations by category
    func loadMeditations(category: MeditationCategory) async -> [Meditation] {
        await loadMeditations()
        return meditations.filter { $0.category == category }
    }

    /// Load user's meditation progress
    func loadProgress() async {
        guard let userId = firebaseService.currentUser?.uid else {
            errorMessage = "User not authenticated"
            return
        }

        isLoading = true
        defer { isLoading = false }

        do {
            let progressData = try await firebaseService.loadMeditationProgress(userId: userId)
            progress = progressData.compactMap { MeditationProgress.fromDictionary($0) }
            errorMessage = nil
        } catch {
            errorMessage = "Failed to load progress: \(error.localizedDescription)"
        }
    }

    // MARK: - Favorites

    /// Toggle favorite status
    func toggleFavorite(_ meditation: Meditation) async {
        var updated = meditation
        updated.isFavorite = !meditation.isFavorite

        do {
            try await firebaseService.updateMeditation(meditation.id, data: updated.toDictionary())

            // Update local state
            if let index = meditations.firstIndex(where: { $0.id == meditation.id }) {
                meditations[index] = updated
            }

            // Update favorites list
            if updated.isFavorite {
                if !favorites.contains(where: { $0.id == updated.id }) {
                    favorites.append(updated)
                }
            } else {
                favorites.removeAll { $0.id == updated.id }
            }
        } catch {
            errorMessage = "Failed to update favorite: \(error.localizedDescription)"
        }
    }

    // MARK: - Progress Tracking

    /// Track a meditation play (increment play count)
    func trackPlay(_ meditation: Meditation) async {
        var updated = meditation
        updated.playCount += 1
        updated.lastPlayedAt = Date()

        do {
            try await firebaseService.updateMeditation(meditation.id, data: updated.toDictionary())

            // Update local state
            if let index = meditations.firstIndex(where: { $0.id == meditation.id }) {
                meditations[index] = updated
            }

            // Update recently played
            await refreshRecentlyPlayed()
        } catch {
            print("Failed to track play: \(error)")
        }
    }

    /// Complete a meditation session
    func completeSession(_ meditation: Meditation, duration: TimeInterval) async {
        guard let userId = firebaseService.currentUser?.uid else { return }

        // Find or create progress entry
        var meditationProgress: MeditationProgress
        if let existing = progress.first(where: { $0.meditationId == meditation.id }) {
            meditationProgress = existing
        } else {
            meditationProgress = MeditationProgress(
                userId: userId,
                meditationId: meditation.id
            )
        }

        // Update progress
        meditationProgress.completedSessions += 1
        meditationProgress.totalDuration += duration
        meditationProgress.lastSessionDate = Date()

        // Update streak
        if let lastSession = meditationProgress.lastSessionDate {
            let calendar = Calendar.current
            if calendar.isDateInYesterday(lastSession) {
                meditationProgress.streak += 1
            } else if !calendar.isDateInToday(lastSession) {
                meditationProgress.streak = 1
            }
        } else {
            meditationProgress.streak = 1
        }

        do {
            try await firebaseService.saveMeditationProgress(
                userId: userId,
                progressId: meditationProgress.id,
                data: meditationProgress.toDictionary()
            )

            // Update local progress
            if let index = progress.firstIndex(where: { $0.id == meditationProgress.id }) {
                progress[index] = meditationProgress
            } else {
                progress.append(meditationProgress)
            }
        } catch {
            print("Failed to save progress: \(error)")
        }
    }

    // MARK: - Statistics

    /// Get total meditation time for user
    func getTotalMeditationTime() -> TimeInterval {
        return progress.reduce(0) { $0 + $1.totalDuration }
    }

    /// Get total completed sessions
    func getTotalSessions() -> Int {
        return progress.reduce(0) { $0 + $1.completedSessions }
    }

    /// Get current streak
    func getCurrentStreak() -> Int {
        return progress.map { $0.streak }.max() ?? 0
    }

    /// Get progress for specific meditation
    func getProgress(for meditation: Meditation) -> MeditationProgress? {
        return progress.first { $0.meditationId == meditation.id }
    }

    // MARK: - Search and Filter

    /// Search meditations by query
    func searchMeditations(query: String) -> [Meditation] {
        guard !query.isEmpty else { return meditations }

        let lowercasedQuery = query.lowercased()
        return meditations.filter {
            $0.title.lowercased().contains(lowercasedQuery) ||
            $0.description.lowercased().contains(lowercasedQuery) ||
            $0.category.rawValue.lowercased().contains(lowercasedQuery)
        }
    }

    /// Get meditations by level
    func getMeditations(level: MeditationLevel) -> [Meditation] {
        return meditations.filter { $0.level == level }
    }

    /// Get free meditations
    func getFreeMeditations() -> [Meditation] {
        return meditations.filter { !$0.isPremium }
    }

    /// Get premium meditations
    func getPremiumMeditations() -> [Meditation] {
        return meditations.filter { $0.isPremium }
    }

    // MARK: - Recommendations

    /// Get recommended meditations based on user's zodiac sign
    func getRecommendedMeditations(zodiacSign: String) -> [Meditation] {
        return meditations.filter { $0.zodiacSign == zodiacSign }
    }

    /// Get popular meditations (most played)
    func getPopularMeditations() -> [Meditation] {
        return meditations
            .sorted { $0.playCount > $1.playCount }
            .prefix(10)
            .map { $0 }
    }

    // MARK: - Helper Methods

    private func refreshRecentlyPlayed() async {
        recentlyPlayed = meditations
            .filter { $0.lastPlayedAt != nil }
            .sorted { ($0.lastPlayedAt ?? Date.distantPast) > ($1.lastPlayedAt ?? Date.distantPast) }
            .prefix(10)
            .map { $0 }
    }
}

// MARK: - Firebase Service Extension

extension FirebaseService {
    /// Load all meditations
    func loadMeditations() async throws -> [[String: Any]] {
        let snapshot = try await db.collection("meditations").getDocuments()
        return snapshot.documents.map { $0.data() }
    }

    /// Update meditation
    func updateMeditation(_ meditationId: String, data: [String: Any]) async throws {
        try await db.collection("meditations")
            .document(meditationId)
            .updateData(data)
    }

    /// Load meditation progress for user
    func loadMeditationProgress(userId: String) async throws -> [[String: Any]] {
        let snapshot = try await db.collection("users")
            .document(userId)
            .collection("meditationProgress")
            .getDocuments()

        return snapshot.documents.map { $0.data() }
    }

    /// Save meditation progress
    func saveMeditationProgress(userId: String, progressId: String, data: [String: Any]) async throws {
        try await db.collection("users")
            .document(userId)
            .collection("meditationProgress")
            .document(progressId)
            .setData(data, merge: true)
    }
}
