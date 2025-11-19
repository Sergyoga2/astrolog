import Foundation
import Combine

/// Service for managing friends and compatibility
@MainActor
class FriendService: ObservableObject {
    static let shared = FriendService()

    @Published var friends: [Friend] = []
    @Published var pendingRequests: [FriendRequest] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let firebaseService = FirebaseService.shared
    private let astrologyService: AstrologyServiceProtocol
    private var cancellables = Set<AnyCancellable>()

    init(astrologyService: AstrologyServiceProtocol = SwissEphemerisService()) {
        self.astrologyService = astrologyService
    }

    // MARK: - Friend Requests

    /// Send a friend request to another user
    func sendFriendRequest(
        toUserId: String,
        toUserName: String,
        toUserEmail: String?,
        message: String? = nil
    ) async throws {
        guard let currentUserId = firebaseService.currentUser?.uid else {
            throw FriendError.notAuthenticated
        }

        guard let currentUserName = firebaseService.currentUser?.displayName else {
            throw FriendError.missingUserInfo
        }

        isLoading = true
        defer { isLoading = false }

        // Check if already friends or request exists
        if friends.contains(where: { $0.friendUserId == toUserId }) {
            throw FriendError.alreadyFriends
        }

        let request = FriendRequest(
            fromUserId: currentUserId,
            fromUserName: currentUserName,
            fromUserEmail: firebaseService.currentUser?.email,
            toUserId: toUserId,
            message: message
        )

        // Save request to Firebase
        try await firebaseService.sendFriendRequest(request.toDictionary())

        // Create pending friend entry for current user
        let friend = Friend(
            userId: currentUserId,
            friendUserId: toUserId,
            friendName: toUserName,
            friendEmail: toUserEmail,
            status: .pending,
            requestedBy: currentUserId
        )

        try await firebaseService.saveFriend(friend.toDictionary())

        // Refresh friends list
        await loadFriends()
    }

    /// Accept a friend request
    func acceptFriendRequest(_ request: FriendRequest) async throws {
        guard let currentUserId = firebaseService.currentUser?.uid else {
            throw FriendError.notAuthenticated
        }

        guard request.toUserId == currentUserId else {
            throw FriendError.unauthorized
        }

        isLoading = true
        defer { isLoading = false }

        // Update request status
        var updatedRequest = request
        updatedRequest.status = .accepted

        try await firebaseService.updateFriendRequest(
            requestId: request.id,
            data: updatedRequest.toDictionary()
        )

        // Create friend entry for both users
        let currentUserName = firebaseService.currentUser?.displayName ?? "User"

        // Friend entry for current user
        let friendForCurrentUser = Friend(
            userId: currentUserId,
            friendUserId: request.fromUserId,
            friendName: request.fromUserName,
            friendEmail: request.fromUserEmail,
            status: .accepted,
            requestedAt: request.createdAt,
            acceptedAt: Date(),
            requestedBy: request.fromUserId
        )

        // Friend entry for requesting user
        let friendForRequestingUser = Friend(
            userId: request.fromUserId,
            friendUserId: currentUserId,
            friendName: currentUserName,
            friendEmail: firebaseService.currentUser?.email,
            status: .accepted,
            requestedAt: request.createdAt,
            acceptedAt: Date(),
            requestedBy: request.fromUserId
        )

        try await firebaseService.saveFriend(friendForCurrentUser.toDictionary())
        try await firebaseService.saveFriend(friendForRequestingUser.toDictionary())

        // Remove from pending requests
        pendingRequests.removeAll { $0.id == request.id }

        // Refresh friends list
        await loadFriends()
    }

    /// Decline a friend request
    func declineFriendRequest(_ request: FriendRequest) async throws {
        guard let currentUserId = firebaseService.currentUser?.uid else {
            throw FriendError.notAuthenticated
        }

        guard request.toUserId == currentUserId else {
            throw FriendError.unauthorized
        }

        isLoading = true
        defer { isLoading = false }

        var updatedRequest = request
        updatedRequest.status = .declined

        try await firebaseService.updateFriendRequest(
            requestId: request.id,
            data: updatedRequest.toDictionary()
        )

        pendingRequests.removeAll { $0.id == request.id }
    }

    // MARK: - Friend Management

    /// Load friends for current user
    func loadFriends() async {
        guard let currentUserId = firebaseService.currentUser?.uid else {
            errorMessage = "Not authenticated"
            return
        }

        isLoading = true
        defer { isLoading = false }

        do {
            let friendsData = try await firebaseService.loadFriends(userId: currentUserId)
            friends = friendsData.compactMap { Friend.fromDictionary($0) }
                .filter { $0.status == .accepted }

            errorMessage = nil
        } catch {
            errorMessage = "Failed to load friends: \(error.localizedDescription)"
        }
    }

    /// Load pending friend requests
    func loadPendingRequests() async {
        guard let currentUserId = firebaseService.currentUser?.uid else {
            errorMessage = "Not authenticated"
            return
        }

        isLoading = true
        defer { isLoading = false }

        do {
            let requestsData = try await firebaseService.loadFriendRequests(userId: currentUserId)
            pendingRequests = requestsData.compactMap { FriendRequest.fromDictionary($0) }
                .filter { $0.status == .pending }

            errorMessage = nil
        } catch {
            errorMessage = "Failed to load requests: \(error.localizedDescription)"
        }
    }

    /// Remove a friend
    func removeFriend(_ friend: Friend) async throws {
        guard let currentUserId = firebaseService.currentUser?.uid else {
            throw FriendError.notAuthenticated
        }

        isLoading = true
        defer { isLoading = false }

        // Remove friendship from both users
        try await firebaseService.removeFriend(friendId: friend.id, userId: currentUserId)

        // Remove from local list
        friends.removeAll { $0.id == friend.id }
    }

    /// Block a user
    func blockUser(_ friend: Friend) async throws {
        guard let currentUserId = firebaseService.currentUser?.uid else {
            throw FriendError.notAuthenticated
        }

        isLoading = true
        defer { isLoading = false }

        var blockedFriend = friend
        blockedFriend.status = .blocked

        try await firebaseService.updateFriend(
            friendId: friend.id,
            data: blockedFriend.toDictionary()
        )

        friends.removeAll { $0.id == friend.id }
    }

    // MARK: - Compatibility Calculations

    /// Calculate compatibility between current user and friend
    func calculateCompatibility(for friend: Friend) async throws -> Int {
        guard let currentUserId = firebaseService.currentUser?.uid else {
            throw FriendError.notAuthenticated
        }

        // Load current user's birth chart
        guard let currentUserChartData = try await firebaseService.loadBirthChart(),
              let currentUserChart = BirthChart.fromDictionary(currentUserChartData) else {
            throw FriendError.missingBirthChart
        }

        // Load friend's birth chart
        guard let friendChartData = try await firebaseService.loadBirthChart(userId: friend.friendUserId),
              let friendChart = BirthChart.fromDictionary(friendChartData) else {
            throw FriendError.missingBirthChart
        }

        // Calculate compatibility using astrology service
        let compatibility = try await astrologyService.calculateCompatibility(
            chart1: currentUserChart,
            chart2: friendChart
        )

        // Update friend with compatibility score
        var updatedFriend = friend
        updatedFriend.compatibilityScore = compatibility.overallScore
        updatedFriend.compatibilityDescription = compatibility.summary

        try await firebaseService.updateFriend(
            friendId: friend.id,
            data: updatedFriend.toDictionary()
        )

        // Update local friend object
        if let index = friends.firstIndex(where: { $0.id == friend.id }) {
            friends[index] = updatedFriend
        }

        return compatibility.overallScore
    }

    /// Get friends sorted by compatibility score
    func getFriendsByCompatibility() -> [Friend] {
        return friends
            .filter { $0.compatibilityScore != nil }
            .sorted { ($0.compatibilityScore ?? 0) > ($1.compatibilityScore ?? 0) }
    }

    // MARK: - Search

    /// Search for users by email
    func searchUserByEmail(_ email: String) async throws -> UserSearchResult? {
        guard firebaseService.currentUser != nil else {
            throw FriendError.notAuthenticated
        }

        isLoading = true
        defer { isLoading = false }

        do {
            if let userData = try await firebaseService.searchUserByEmail(email) {
                return UserSearchResult.fromDictionary(userData)
            }
            return nil
        } catch {
            throw FriendError.userNotFound
        }
    }
}

// MARK: - Friend Errors

enum FriendError: LocalizedError {
    case notAuthenticated
    case missingUserInfo
    case alreadyFriends
    case unauthorized
    case userNotFound
    case missingBirthChart

    var errorDescription: String? {
        switch self {
        case .notAuthenticated:
            return "User not authenticated"
        case .missingUserInfo:
            return "User information is incomplete"
        case .alreadyFriends:
            return "Already friends with this user"
        case .unauthorized:
            return "Unauthorized action"
        case .userNotFound:
            return "User not found"
        case .missingBirthChart:
            return "Birth chart not available for compatibility calculation"
        }
    }
}

// MARK: - User Search Result

struct UserSearchResult: Identifiable, Codable {
    let id: String
    let name: String
    let email: String
    let hasBirthChart: Bool

    static func fromDictionary(_ dict: [String: Any]) -> UserSearchResult? {
        guard let id = dict["id"] as? String ?? dict["uid"] as? String,
              let name = dict["name"] as? String ?? dict["displayName"] as? String,
              let email = dict["email"] as? String else {
            return nil
        }

        let hasBirthChart = dict["hasBirthChart"] as? Bool ?? false

        return UserSearchResult(
            id: id,
            name: name,
            email: email,
            hasBirthChart: hasBirthChart
        )
    }
}
