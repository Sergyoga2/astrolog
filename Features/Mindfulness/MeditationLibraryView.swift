import SwiftUI

/// Main view for meditation library
struct MeditationLibraryView: View {
    @StateObject private var meditationService = MeditationService.shared
    @State private var selectedCategory: MeditationCategory?
    @State private var searchText = ""
    @State private var showingPlayer = false
    @State private var selectedMeditation: Meditation?

    var body: some View {
        ZStack {
            StarfieldBackground()
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: CosmicSpacing.large) {
                    CosmicSectionHeader(
                        "Медитации",
                        subtitle: "Практики осознанности и расслабления",
                        icon: "leaf.fill"
                    )

                    // Search Bar
                    SearchBar(text: $searchText)

                    // Statistics Card
                    if !meditationService.progress.isEmpty {
                        MeditationStatsCard(service: meditationService)
                    }

                    // Categories
                    if searchText.isEmpty {
                        CategoryScrollView(selectedCategory: $selectedCategory)
                    }

                    // Meditations Grid
                    if searchText.isEmpty {
                        if let category = selectedCategory {
                            CategoryMeditationsView(
                                category: category,
                                meditations: filteredMeditations,
                                onSelect: selectMeditation
                            )
                        } else {
                            AllMeditationsSections(
                                service: meditationService,
                                onSelect: selectMeditation
                            )
                        }
                    } else {
                        SearchResultsView(
                            meditations: filteredMeditations,
                            onSelect: selectMeditation
                        )
                    }
                }
                .padding(.horizontal, CosmicSpacing.medium)
            }

            if meditationService.isLoading {
                LoadingOverlay()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .sheet(item: $selectedMeditation) { meditation in
            MeditationPlayerView(meditation: meditation)
        }
        .task {
            await meditationService.loadMeditations()
            await meditationService.loadProgress()
        }
        .refreshable {
            await meditationService.loadMeditations()
            await meditationService.loadProgress()
        }
    }

    private var filteredMeditations: [Meditation] {
        if !searchText.isEmpty {
            return meditationService.searchMeditations(query: searchText)
        } else if let category = selectedCategory {
            return meditationService.meditations.filter { $0.category == category }
        } else {
            return meditationService.meditations
        }
    }

    private func selectMeditation(_ meditation: Meditation) {
        selectedMeditation = meditation
        CosmicFeedbackManager.shared.lightImpact()
    }
}

// MARK: - Search Bar

struct SearchBar: View {
    @Binding var text: String

    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.starWhite.opacity(0.6))

            TextField("Поиск медитаций...", text: $text)
                .foregroundColor(.starWhite)

            if !text.isEmpty {
                Button(action: { text = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.starWhite.opacity(0.6))
                }
            }
        }
        .padding()
        .background(Color.cosmicBlue.opacity(0.3))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.starWhite.opacity(0.2), lineWidth: 1)
        )
    }
}

// MARK: - Meditation Stats Card

struct MeditationStatsCard: View {
    @ObservedObject var service: MeditationService

    var body: some View {
        CosmicCard(glowColor: .cosmicTeal) {
            VStack(spacing: CosmicSpacing.medium) {
                HStack {
                    Image(systemName: "chart.bar.fill")
                        .foregroundColor(.cosmicTeal)

                    Text("Ваш прогресс")
                        .font(CosmicTypography.headline)
                        .foregroundColor(.starWhite)

                    Spacer()
                }

                HStack(spacing: CosmicSpacing.large) {
                    StatItem(
                        icon: "clock.fill",
                        value: formatDuration(service.getTotalMeditationTime()),
                        label: "Всего времени"
                    )

                    StatItem(
                        icon: "checkmark.circle.fill",
                        value: "\(service.getTotalSessions())",
                        label: "Сессий"
                    )

                    StatItem(
                        icon: "flame.fill",
                        value: "\(service.getCurrentStreak())",
                        label: "Дней подряд"
                    )
                }
            }
            .padding()
        }
    }

    private func formatDuration(_ duration: TimeInterval) -> String {
        let hours = Int(duration) / 3600
        let minutes = (Int(duration) % 3600) / 60
        if hours > 0 {
            return "\(hours)ч \(minutes)м"
        } else {
            return "\(minutes)м"
        }
    }
}

struct StatItem: View {
    let icon: String
    let value: String
    let label: String

    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.cosmicTeal)

            Text(value)
                .font(CosmicTypography.headline)
                .foregroundColor(.starWhite)

            Text(label)
                .font(CosmicTypography.caption)
                .foregroundColor(.starWhite.opacity(0.7))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Category Scroll View

struct CategoryScrollView: View {
    @Binding var selectedCategory: MeditationCategory?

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: CosmicSpacing.small) {
                // All categories button
                CategoryButton(
                    category: nil,
                    isSelected: selectedCategory == nil,
                    action: { selectedCategory = nil }
                )

                ForEach(MeditationCategory.allCases, id: \.self) { category in
                    CategoryButton(
                        category: category,
                        isSelected: selectedCategory == category,
                        action: { selectedCategory = category }
                    )
                }
            }
            .padding(.horizontal, CosmicSpacing.medium)
        }
    }
}

struct CategoryButton: View {
    let category: MeditationCategory?
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if let category = category {
                    Image(systemName: category.icon)
                    Text(category.rawValue)
                } else {
                    Image(systemName: "square.grid.2x2")
                    Text("Все")
                }
            }
            .font(CosmicTypography.caption)
            .foregroundColor(isSelected ? .cosmicBlue : .starWhite)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(isSelected ? Color.cosmicTeal : Color.cosmicBlue.opacity(0.3))
            .cornerRadius(20)
        }
    }
}

// MARK: - All Meditations Sections

struct AllMeditationsSections: View {
    @ObservedObject var service: MeditationService
    let onSelect: (Meditation) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: CosmicSpacing.large) {
            // Recently Played
            if !service.recentlyPlayed.isEmpty {
                MeditationSection(
                    title: "Недавно прослушанные",
                    icon: "clock.arrow.circlepath",
                    meditations: service.recentlyPlayed,
                    onSelect: onSelect
                )
            }

            // Favorites
            if !service.favorites.isEmpty {
                MeditationSection(
                    title: "Избранное",
                    icon: "heart.fill",
                    meditations: service.favorites,
                    onSelect: onSelect
                )
            }

            // Popular
            let popular = service.getPopularMeditations()
            if !popular.isEmpty {
                MeditationSection(
                    title: "Популярные",
                    icon: "star.fill",
                    meditations: popular,
                    onSelect: onSelect
                )
            }

            // All Meditations
            MeditationSection(
                title: "Все медитации",
                icon: "list.bullet",
                meditations: service.meditations,
                onSelect: onSelect,
                showAll: true
            )
        }
    }
}

// MARK: - Meditation Section

struct MeditationSection: View {
    let title: String
    let icon: String
    let meditations: [Meditation]
    let onSelect: (Meditation) -> Void
    var showAll: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: CosmicSpacing.medium) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(.cosmicTeal)

                Text(title)
                    .font(CosmicTypography.headline)
                    .foregroundColor(.starWhite)

                Spacer()

                Text("\(meditations.count)")
                    .font(CosmicTypography.caption)
                    .foregroundColor(.starWhite.opacity(0.6))
            }

            if showAll {
                LazyVStack(spacing: CosmicSpacing.small) {
                    ForEach(meditations) { meditation in
                        MeditationRow(meditation: meditation, onSelect: onSelect)
                    }
                }
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: CosmicSpacing.medium) {
                        ForEach(meditations.prefix(5)) { meditation in
                            MeditationCard(meditation: meditation, onSelect: onSelect)
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Meditation Card

struct MeditationCard: View {
    let meditation: Meditation
    let onSelect: (Meditation) -> Void

    var body: some View {
        Button(action: { onSelect(meditation) }) {
            VStack(alignment: .leading, spacing: CosmicSpacing.small) {
                // Image/Category Icon
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(
                            LinearGradient(
                                colors: [.cosmicTeal.opacity(0.6), .neonPurple.opacity(0.6)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 150, height: 100)

                    Image(systemName: meditation.category.icon)
                        .font(.system(size: 40))
                        .foregroundColor(.starWhite)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(meditation.title)
                        .font(CosmicTypography.body)
                        .foregroundColor(.starWhite)
                        .lineLimit(2)

                    HStack(spacing: 4) {
                        Image(systemName: "clock")
                            .font(.caption2)

                        Text(meditation.durationFormatted)
                            .font(CosmicTypography.caption)
                    }
                    .foregroundColor(.starWhite.opacity(0.6))

                    if meditation.isPremium {
                        HStack(spacing: 4) {
                            Image(systemName: "star.fill")
                                .font(.caption2)
                            Text("Premium")
                                .font(CosmicTypography.caption)
                        }
                        .foregroundColor(.cosmicTeal)
                    }
                }
            }
            .frame(width: 150)
        }
    }
}

// MARK: - Meditation Row

struct MeditationRow: View {
    let meditation: Meditation
    let onSelect: (Meditation) -> Void

    var body: some View {
        Button(action: { onSelect(meditation) }) {
            CosmicCard(glowColor: .cosmicBlue.opacity(0.3)) {
                HStack(spacing: CosmicSpacing.medium) {
                    // Icon
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [.cosmicTeal, .neonPurple],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 60, height: 60)

                        Image(systemName: meditation.category.icon)
                            .font(.title2)
                            .foregroundColor(.starWhite)
                    }

                    // Info
                    VStack(alignment: .leading, spacing: 4) {
                        Text(meditation.title)
                            .font(CosmicTypography.body)
                            .foregroundColor(.starWhite)

                        Text(meditation.description)
                            .font(CosmicTypography.caption)
                            .foregroundColor(.starWhite.opacity(0.7))
                            .lineLimit(2)

                        HStack(spacing: CosmicSpacing.small) {
                            Label(meditation.durationFormatted, systemImage: "clock")

                            if meditation.isPremium {
                                Label("Premium", systemImage: "star.fill")
                                    .foregroundColor(.cosmicTeal)
                            }
                        }
                        .font(CosmicTypography.caption)
                        .foregroundColor(.starWhite.opacity(0.6))
                    }

                    Spacer()

                    Image(systemName: "play.circle.fill")
                        .font(.title)
                        .foregroundColor(.cosmicTeal)
                }
                .padding()
            }
        }
    }
}

// MARK: - Category Meditations View

struct CategoryMeditationsView: View {
    let category: MeditationCategory
    let meditations: [Meditation]
    let onSelect: (Meditation) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: CosmicSpacing.medium) {
            Text(category.rawValue)
                .font(CosmicTypography.title)
                .foregroundColor(.starWhite)

            LazyVStack(spacing: CosmicSpacing.small) {
                ForEach(meditations) { meditation in
                    MeditationRow(meditation: meditation, onSelect: onSelect)
                }
            }
        }
    }
}

// MARK: - Search Results View

struct SearchResultsView: View {
    let meditations: [Meditation]
    let onSelect: (Meditation) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: CosmicSpacing.medium) {
            Text("Результаты поиска (\(meditations.count))")
                .font(CosmicTypography.headline)
                .foregroundColor(.starWhite)

            if meditations.isEmpty {
                Text("Ничего не найдено")
                    .font(CosmicTypography.body)
                    .foregroundColor(.starWhite.opacity(0.6))
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(CosmicSpacing.xlarge)
            } else {
                LazyVStack(spacing: CosmicSpacing.small) {
                    ForEach(meditations) { meditation in
                        MeditationRow(meditation: meditation, onSelect: onSelect)
                    }
                }
            }
        }
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        MeditationLibraryView()
    }
}
