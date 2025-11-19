import SwiftUI

/// Main view for friends list and social features
struct FriendsListView: View {
    @StateObject private var friendService = FriendService.shared
    @State private var showingAddFriend = false
    @State private var selectedFriend: Friend?
    @State private var showingCompatibility = false

    var body: some View {
        ZStack {
            StarfieldBackground()
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: CosmicSpacing.large) {
                    CosmicSectionHeader(
                        "Друзья",
                        subtitle: "Совместимость и социальные связи",
                        icon: "person.2.fill"
                    )

                    // Pending Requests Section
                    if !friendService.pendingRequests.isEmpty {
                        PendingRequestsSection(
                            requests: friendService.pendingRequests,
                            onAccept: { request in
                                Task {
                                    try? await friendService.acceptFriendRequest(request)
                                }
                            },
                            onDecline: { request in
                                Task {
                                    try? await friendService.declineFriendRequest(request)
                                }
                            }
                        )
                    }

                    // Add Friend Button
                    CosmicCard(glowColor: .neonPurple) {
                        Button(action: { showingAddFriend = true }) {
                            HStack {
                                Image(systemName: "person.badge.plus")
                                    .font(.title2)
                                    .foregroundColor(.neonPurple)

                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Добавить друга")
                                        .font(CosmicTypography.headline)
                                        .foregroundColor(.starWhite)

                                    Text("Найти друзей по email")
                                        .font(CosmicTypography.caption)
                                        .foregroundColor(.starWhite.opacity(0.7))
                                }

                                Spacer()

                                Image(systemName: "chevron.right")
                                    .foregroundColor(.starWhite.opacity(0.4))
                            }
                            .padding()
                        }
                    }

                    // Friends List
                    if friendService.friends.isEmpty {
                        EmptyFriendsView()
                    } else {
                        FriendsGridView(
                            friends: friendService.friends,
                            onFriendTap: { friend in
                                selectedFriend = friend
                                showingCompatibility = true
                            }
                        )
                    }

                    // Compatibility Rankings
                    if !friendService.friends.isEmpty {
                        CompatibilityRankingsView(
                            friends: friendService.getFriendsByCompatibility()
                        )
                    }
                }
                .padding(.horizontal, CosmicSpacing.medium)
            }

            if friendService.isLoading {
                LoadingOverlay()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingAddFriend) {
            AddFriendView()
        }
        .sheet(item: $selectedFriend) { friend in
            FriendDetailView(friend: friend)
        }
        .task {
            await friendService.loadFriends()
            await friendService.loadPendingRequests()
        }
        .refreshable {
            await friendService.loadFriends()
            await friendService.loadPendingRequests()
        }
    }
}

// MARK: - Pending Requests Section

struct PendingRequestsSection: View {
    let requests: [FriendRequest]
    let onAccept: (FriendRequest) -> Void
    let onDecline: (FriendRequest) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: CosmicSpacing.medium) {
            Text("Запросы в друзья")
                .font(CosmicTypography.headline)
                .foregroundColor(.starWhite)

            ForEach(requests) { request in
                CosmicCard(glowColor: .cosmicTeal) {
                    VStack(alignment: .leading, spacing: CosmicSpacing.small) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(request.fromUserName)
                                    .font(CosmicTypography.body)
                                    .foregroundColor(.starWhite)

                                if let email = request.fromUserEmail {
                                    Text(email)
                                        .font(CosmicTypography.caption)
                                        .foregroundColor(.starWhite.opacity(0.6))
                                }

                                if let message = request.message {
                                    Text(message)
                                        .font(CosmicTypography.caption)
                                        .foregroundColor(.starWhite.opacity(0.8))
                                        .italic()
                                        .padding(.top, 4)
                                }
                            }

                            Spacer()
                        }

                        HStack(spacing: CosmicSpacing.small) {
                            Button(action: { onAccept(request) }) {
                                Text("Принять")
                                    .font(CosmicTypography.caption)
                                    .foregroundColor(.cosmicBlue)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(Color.cosmicTeal)
                                    .cornerRadius(8)
                            }

                            Button(action: { onDecline(request) }) {
                                Text("Отклонить")
                                    .font(CosmicTypography.caption)
                                    .foregroundColor(.starWhite)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(Color.gray.opacity(0.3))
                                    .cornerRadius(8)
                            }
                        }
                    }
                    .padding()
                }
            }
        }
    }
}

// MARK: - Empty Friends View

struct EmptyFriendsView: View {
    var body: some View {
        CosmicCard(glowColor: .cosmicBlue.opacity(0.5)) {
            VStack(spacing: CosmicSpacing.medium) {
                Image(systemName: "person.2.slash")
                    .font(.system(size: 60))
                    .foregroundColor(.starWhite.opacity(0.4))

                Text("Нет друзей")
                    .font(CosmicTypography.title)
                    .foregroundColor(.starWhite)

                Text("Добавьте друзей, чтобы увидеть совместимость ваших натальных карт")
                    .font(CosmicTypography.body)
                    .foregroundColor(.starWhite.opacity(0.7))
                    .multilineTextAlignment(.center)
            }
            .padding(CosmicSpacing.large)
        }
    }
}

// MARK: - Friends Grid View

struct FriendsGridView: View {
    let friends: [Friend]
    let onFriendTap: (Friend) -> Void

    let columns = [
        GridItem(.flexible(), spacing: CosmicSpacing.medium),
        GridItem(.flexible(), spacing: CosmicSpacing.medium)
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: CosmicSpacing.medium) {
            Text("Мои друзья (\(friends.count))")
                .font(CosmicTypography.headline)
                .foregroundColor(.starWhite)

            LazyVGrid(columns: columns, spacing: CosmicSpacing.medium) {
                ForEach(friends) { friend in
                    FriendCardView(friend: friend)
                        .onTapGesture {
                            onFriendTap(friend)
                            CosmicFeedbackManager.shared.lightImpact()
                        }
                }
            }
        }
    }
}

// MARK: - Friend Card View

struct FriendCardView: View {
    let friend: Friend

    var body: some View {
        CosmicCard(glowColor: compatibilityColor) {
            VStack(spacing: CosmicSpacing.small) {
                // Avatar
                ZStack {
                    Circle()
                        .fill(Color.cosmicBlue.opacity(0.3))
                        .frame(width: 60, height: 60)

                    Text(friend.friendName.prefix(1).uppercased())
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.starWhite)
                }

                // Name
                Text(friend.friendName)
                    .font(CosmicTypography.body)
                    .foregroundColor(.starWhite)
                    .lineLimit(1)

                // Compatibility Score
                if let score = friend.compatibilityScore {
                    HStack(spacing: 4) {
                        Image(systemName: "heart.fill")
                            .font(.caption)
                            .foregroundColor(compatibilityColor)

                        Text("\(score)%")
                            .font(CosmicTypography.caption)
                            .foregroundColor(compatibilityColor)
                    }
                } else {
                    Text("Не рассчитано")
                        .font(CosmicTypography.caption)
                        .foregroundColor(.starWhite.opacity(0.5))
                }
            }
            .padding(CosmicSpacing.medium)
        }
    }

    private var compatibilityColor: Color {
        guard let score = friend.compatibilityScore else {
            return .cosmicBlue.opacity(0.3)
        }

        switch score {
        case 80...100:
            return .cosmicTeal
        case 60..<80:
            return .neonPurple
        case 40..<60:
            return .cosmicBlue
        default:
            return .starWhite.opacity(0.5)
        }
    }
}

// MARK: - Compatibility Rankings View

struct CompatibilityRankingsView: View {
    let friends: [Friend]

    var body: some View {
        if !friends.isEmpty {
            CosmicCard(glowColor: .cosmicTeal) {
                VStack(alignment: .leading, spacing: CosmicSpacing.medium) {
                    HStack {
                        Image(systemName: "star.fill")
                            .foregroundColor(.cosmicTeal)

                        Text("Лучшая совместимость")
                            .font(CosmicTypography.headline)
                            .foregroundColor(.starWhite)

                        Spacer()
                    }

                    ForEach(friends.prefix(3)) { friend in
                        HStack {
                            Text(friend.friendName)
                                .font(CosmicTypography.body)
                                .foregroundColor(.starWhite)

                            Spacer()

                            if let score = friend.compatibilityScore {
                                Text("\(score)%")
                                    .font(CosmicTypography.headline)
                                    .foregroundColor(.cosmicTeal)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
                .padding()
            }
        }
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        FriendsListView()
    }
}
