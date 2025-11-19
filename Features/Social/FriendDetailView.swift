import SwiftUI

/// Detailed view for a friend showing compatibility analysis
struct FriendDetailView: View {
    let friend: Friend

    @Environment(\.dismiss) private var dismiss
    @StateObject private var friendService = FriendService.shared

    @State private var isCalculating = false
    @State private var compatibilityScore: Int?
    @State private var showingRemoveAlert = false

    var body: some View {
        NavigationStack {
            ZStack {
                StarfieldBackground()
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: CosmicSpacing.large) {
                        // Friend Header
                        FriendHeaderView(friend: friend)

                        // Compatibility Section
                        CompatibilitySection(
                            friend: friend,
                            compatibilityScore: compatibilityScore ?? friend.compatibilityScore,
                            isCalculating: isCalculating,
                            onCalculate: calculateCompatibility
                        )

                        // Birth Data Info (if available)
                        if friend.friendBirthData != nil {
                            BirthDataInfoView(birthData: friend.friendBirthData!)
                        }

                        // Actions
                        ActionsSection(
                            onRemove: { showingRemoveAlert = true }
                        )
                    }
                    .padding(.horizontal, CosmicSpacing.medium)
                }

                if isCalculating {
                    LoadingOverlay(message: "Расчет совместимости...")
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Закрыть") {
                        dismiss()
                    }
                    .foregroundColor(.starWhite)
                }
            }
            .alert("Удалить друга?", isPresented: $showingRemoveAlert) {
                Button("Отмена", role: .cancel) {}
                Button("Удалить", role: .destructive) {
                    removeFriend()
                }
            } message: {
                Text("Вы уверены, что хотите удалить \(friend.friendName) из друзей?")
            }
            .onAppear {
                compatibilityScore = friend.compatibilityScore
            }
        }
    }

    private func calculateCompatibility() {
        isCalculating = true

        Task {
            do {
                let score = try await friendService.calculateCompatibility(for: friend)
                compatibilityScore = score
            } catch {
                // Show error
                print("Error calculating compatibility: \(error)")
            }

            isCalculating = false
        }
    }

    private func removeFriend() {
        Task {
            try? await friendService.removeFriend(friend)
            dismiss()
        }
    }
}

// MARK: - Friend Header View

struct FriendHeaderView: View {
    let friend: Friend

    var body: some View {
        CosmicCard(glowColor: .cosmicTeal) {
            VStack(spacing: CosmicSpacing.medium) {
                // Avatar
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [.cosmicTeal, .neonPurple],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 100, height: 100)

                    Text(friend.friendName.prefix(1).uppercased())
                        .font(.system(size: 40))
                        .fontWeight(.bold)
                        .foregroundColor(.cosmicBlue)
                }

                // Name
                Text(friend.friendName)
                    .font(CosmicTypography.title)
                    .foregroundColor(.starWhite)

                // Email
                if let email = friend.friendEmail {
                    Text(email)
                        .font(CosmicTypography.caption)
                        .foregroundColor(.starWhite.opacity(0.7))
                }

                // Friend Since
                if let acceptedDate = friend.acceptedAt {
                    HStack(spacing: 4) {
                        Image(systemName: "calendar")
                            .font(.caption)
                        Text("Друзья с \(acceptedDate.formatted(date: .abbreviated, time: .omitted))")
                    }
                    .font(CosmicTypography.caption)
                    .foregroundColor(.starWhite.opacity(0.6))
                }
            }
            .padding()
        }
    }
}

// MARK: - Compatibility Section

struct CompatibilitySection: View {
    let friend: Friend
    let compatibilityScore: Int?
    let isCalculating: Bool
    let onCalculate: () -> Void

    var body: some View {
        CosmicCard(glowColor: compatibilityColor) {
            VStack(spacing: CosmicSpacing.medium) {
                HStack {
                    Image(systemName: "heart.fill")
                        .foregroundColor(compatibilityColor)

                    Text("Совместимость")
                        .font(CosmicTypography.headline)
                        .foregroundColor(.starWhite)

                    Spacer()
                }

                if let score = compatibilityScore {
                    // Score Display
                    VStack(spacing: CosmicSpacing.small) {
                        Text("\(score)%")
                            .font(.system(size: 60, weight: .bold))
                            .foregroundColor(compatibilityColor)

                        Text(compatibilityDescription(for: score))
                            .font(CosmicTypography.body)
                            .foregroundColor(.starWhite.opacity(0.8))
                            .multilineTextAlignment(.center)

                        if let description = friend.compatibilityDescription {
                            Text(description)
                                .font(CosmicTypography.caption)
                                .foregroundColor(.starWhite.opacity(0.7))
                                .multilineTextAlignment(.center)
                                .padding(.top, 8)
                        }
                    }
                    .padding(.vertical, CosmicSpacing.medium)

                    // Recalculate Button
                    Button(action: onCalculate) {
                        HStack {
                            Image(systemName: "arrow.clockwise")
                            Text("Пересчитать")
                        }
                        .font(CosmicTypography.caption)
                        .foregroundColor(.starWhite.opacity(0.7))
                    }
                    .disabled(isCalculating)

                } else {
                    // Calculate Button
                    VStack(spacing: CosmicSpacing.medium) {
                        Image(systemName: "star.circle")
                            .font(.system(size: 50))
                            .foregroundColor(.starWhite.opacity(0.4))

                        Text("Совместимость не рассчитана")
                            .font(CosmicTypography.body)
                            .foregroundColor(.starWhite.opacity(0.7))

                        if friend.friendBirthData != nil {
                            Button(action: onCalculate) {
                                HStack {
                                    Image(systemName: "sparkles")
                                    Text("Рассчитать совместимость")
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(compatibilityColor)
                                .foregroundColor(.cosmicBlue)
                                .cornerRadius(12)
                            }
                        } else {
                            Text("У друга нет натальной карты")
                                .font(CosmicTypography.caption)
                                .foregroundColor(.starWhite.opacity(0.5))
                        }
                    }
                    .padding(.vertical, CosmicSpacing.medium)
                }
            }
            .padding()
        }
    }

    private var compatibilityColor: Color {
        guard let score = compatibilityScore else {
            return .cosmicBlue.opacity(0.5)
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

    private func compatibilityDescription(for score: Int) -> String {
        switch score {
        case 90...100:
            return "Идеальная совместимость! Звезды благосклонны к вашему союзу."
        case 80..<90:
            return "Отличная совместимость. У вас прекрасное взаимопонимание."
        case 70..<80:
            return "Хорошая совместимость. Вы дополняете друг друга."
        case 60..<70:
            return "Умеренная совместимость. Есть общие точки соприкосновения."
        case 40..<60:
            return "Средняя совместимость. Потребуются усилия для гармонии."
        default:
            return "Низкая совместимость. Различия могут создавать сложности."
        }
    }
}

// MARK: - Birth Data Info View

struct BirthDataInfoView: View {
    let birthData: BirthData

    var body: some View {
        CosmicCard(glowColor: .neonPurple.opacity(0.5)) {
            VStack(alignment: .leading, spacing: CosmicSpacing.medium) {
                HStack {
                    Image(systemName: "mappin.circle.fill")
                        .foregroundColor(.neonPurple)

                    Text("Данные о рождении")
                        .font(CosmicTypography.headline)
                        .foregroundColor(.starWhite)

                    Spacer()
                }

                VStack(alignment: .leading, spacing: CosmicSpacing.small) {
                    InfoRow(
                        icon: "calendar",
                        title: "Дата",
                        value: birthData.date.formatted(date: .long, time: .omitted)
                    )

                    InfoRow(
                        icon: "location.fill",
                        title: "Место",
                        value: "\(birthData.cityName), \(birthData.countryName)"
                    )

                    InfoRow(
                        icon: "clock",
                        title: "Время",
                        value: birthData.isTimeExact ? "Точное" : "Приблизительное"
                    )
                }
            }
            .padding()
        }
    }
}

// MARK: - Info Row

struct InfoRow: View {
    let icon: String
    let title: String
    let value: String

    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.caption)
                .foregroundColor(.starWhite.opacity(0.6))
                .frame(width: 20)

            Text(title)
                .font(CosmicTypography.caption)
                .foregroundColor(.starWhite.opacity(0.7))

            Spacer()

            Text(value)
                .font(CosmicTypography.caption)
                .foregroundColor(.starWhite)
        }
    }
}

// MARK: - Actions Section

struct ActionsSection: View {
    let onRemove: () -> Void

    var body: some View {
        CosmicCard(glowColor: .red.opacity(0.3)) {
            VStack(spacing: CosmicSpacing.small) {
                Button(action: onRemove) {
                    HStack {
                        Image(systemName: "person.fill.xmark")
                        Text("Удалить из друзей")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .foregroundColor(.red)
                }
            }
            .padding()
        }
    }
}

// MARK: - Loading Overlay

struct LoadingOverlay: View {
    var message: String = "Загрузка..."

    var body: some View {
        ZStack {
            Color.cosmicBlue.opacity(0.8)
                .ignoresSafeArea()

            VStack(spacing: CosmicSpacing.medium) {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .cosmicTeal))
                    .scaleEffect(1.5)

                Text(message)
                    .font(CosmicTypography.body)
                    .foregroundColor(.starWhite)
            }
            .padding(CosmicSpacing.large)
            .background(Color.cosmicBlue)
            .cornerRadius(16)
        }
    }
}

// MARK: - Preview

#Preview {
    FriendDetailView(
        friend: Friend(
            userId: "user1",
            friendUserId: "user2",
            friendName: "Анна Иванова",
            friendEmail: "anna@example.com",
            friendBirthData: BirthData(
                date: Date(),
                timeZone: TimeZone.current,
                latitude: 55.7558,
                longitude: 37.6173,
                cityName: "Москва",
                countryName: "Россия",
                isTimeExact: true
            ),
            status: .accepted,
            compatibilityScore: 85,
            compatibilityDescription: "Отличная совместимость",
            requestedBy: "user1"
        )
    )
}
