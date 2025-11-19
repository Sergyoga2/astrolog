import SwiftUI

/// View for playing meditation audio
struct MeditationPlayerView: View {
    let meditation: Meditation

    @Environment(\.dismiss) private var dismiss
    @StateObject private var audioPlayer = AudioPlayerService.shared
    @StateObject private var meditationService = MeditationService.shared

    @State private var showingInfo = false

    var body: some View {
        NavigationStack {
            ZStack {
                StarfieldBackground()
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: CosmicSpacing.xlarge) {
                        // Cover Art
                        CoverArtView(meditation: meditation)
                            .padding(.top, CosmicSpacing.xlarge)

                        // Title and Info
                        VStack(spacing: CosmicSpacing.small) {
                            Text(meditation.title)
                                .font(CosmicTypography.title)
                                .foregroundColor(.starWhite)
                                .multilineTextAlignment(.center)

                            HStack(spacing: CosmicSpacing.small) {
                                Label(meditation.category.rawValue, systemImage: meditation.category.icon)
                                Text("•")
                                Label(meditation.durationFormatted, systemImage: "clock")
                            }
                            .font(CosmicTypography.caption)
                            .foregroundColor(.starWhite.opacity(0.7))
                        }

                        // Progress Slider
                        ProgressSlider(
                            currentTime: audioPlayer.currentTime,
                            duration: audioPlayer.duration,
                            onSeek: { time in
                                audioPlayer.seek(to: time)
                            }
                        )

                        // Time Labels
                        HStack {
                            Text(audioPlayer.currentTimeFormatted)
                            Spacer()
                            Text("-\(audioPlayer.remainingTimeFormatted)")
                        }
                        .font(CosmicTypography.caption)
                        .foregroundColor(.starWhite.opacity(0.6))

                        // Playback Controls
                        PlaybackControls(
                            isPlaying: audioPlayer.isPlaying,
                            onSkipBackward: { audioPlayer.skipBackward() },
                            onTogglePlay: { audioPlayer.togglePlayPause() },
                            onSkipForward: { audioPlayer.skipForward() }
                        )

                        // Additional Controls
                        AdditionalControls(
                            isFavorite: meditation.isFavorite,
                            playbackRate: audioPlayer.playbackRate,
                            onToggleFavorite: {
                                Task {
                                    await meditationService.toggleFavorite(meditation)
                                }
                            },
                            onChangePlaybackRate: { rate in
                                audioPlayer.setPlaybackRate(rate)
                            }
                        )

                        // Benefits
                        if !meditation.benefits.isEmpty {
                            BenefitsView(benefits: meditation.benefits)
                        }
                    }
                    .padding(.horizontal, CosmicSpacing.medium)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        audioPlayer.stop()
                        dismiss()
                    }) {
                        Image(systemName: "chevron.down")
                            .foregroundColor(.starWhite)
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingInfo = true }) {
                        Image(systemName: "info.circle")
                            .foregroundColor(.starWhite)
                    }
                }
            }
            .task {
                await audioPlayer.loadMeditation(meditation)
            }
            .sheet(isPresented: $showingInfo) {
                MeditationInfoView(meditation: meditation)
            }
        }
    }
}

// MARK: - Cover Art View

struct CoverArtView: View {
    let meditation: Meditation

    var body: some View {
        ZStack {
            Circle()
                .fill(
                    LinearGradient(
                        colors: [.cosmicTeal, .neonPurple, .cosmicBlue],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 280, height: 280)

            Image(systemName: meditation.category.icon)
                .font(.system(size: 100))
                .foregroundColor(.starWhite.opacity(0.9))
        }
        .shadow(color: .cosmicTeal.opacity(0.5), radius: 30)
    }
}

// MARK: - Progress Slider

struct ProgressSlider: View {
    let currentTime: TimeInterval
    let duration: TimeInterval
    let onSeek: (TimeInterval) -> Void

    @State private var isDragging = false
    @State private var dragValue: Double = 0

    var body: some View {
        VStack(spacing: 8) {
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background track
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color.starWhite.opacity(0.2))
                        .frame(height: 4)

                    // Progress track
                    RoundedRectangle(cornerRadius: 2)
                        .fill(
                            LinearGradient(
                                colors: [.cosmicTeal, .neonPurple],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: progressWidth(in: geometry.size.width), height: 4)

                    // Thumb
                    Circle()
                        .fill(Color.starWhite)
                        .frame(width: 16, height: 16)
                        .shadow(color: .cosmicTeal.opacity(0.5), radius: 4)
                        .offset(x: progressWidth(in: geometry.size.width) - 8)
                }
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { value in
                            isDragging = true
                            let progress = min(max(0, value.location.x / geometry.size.width), 1)
                            dragValue = progress * duration
                        }
                        .onEnded { value in
                            isDragging = false
                            onSeek(dragValue)
                        }
                )
            }
            .frame(height: 16)
        }
    }

    private func progressWidth(in totalWidth: CGFloat) -> CGFloat {
        guard duration > 0 else { return 0 }
        let progress = isDragging ? (dragValue / duration) : (currentTime / duration)
        return totalWidth * CGFloat(progress)
    }
}

// MARK: - Playback Controls

struct PlaybackControls: View {
    let isPlaying: Bool
    let onSkipBackward: () -> Void
    let onTogglePlay: () -> Void
    let onSkipForward: () -> Void

    var body: some View {
        HStack(spacing: CosmicSpacing.xlarge) {
            // Skip Backward
            Button(action: onSkipBackward) {
                Image(systemName: "gobackward.15")
                    .font(.title)
                    .foregroundColor(.starWhite)
            }

            // Play/Pause
            Button(action: onTogglePlay) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [.cosmicTeal, .neonPurple],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 80, height: 80)

                    Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                        .font(.system(size: 32))
                        .foregroundColor(.cosmicBlue)
                }
                .shadow(color: .cosmicTeal.opacity(0.5), radius: 10)
            }

            // Skip Forward
            Button(action: onSkipForward) {
                Image(systemName: "goforward.15")
                    .font(.title)
                    .foregroundColor(.starWhite)
            }
        }
        .padding(.vertical, CosmicSpacing.medium)
    }
}

// MARK: - Additional Controls

struct AdditionalControls: View {
    let isFavorite: Bool
    let playbackRate: Float
    let onToggleFavorite: () -> Void
    let onChangePlaybackRate: (Float) -> Void

    @State private var showingSpeedPicker = false

    var body: some View {
        HStack(spacing: CosmicSpacing.xlarge) {
            // Favorite
            Button(action: onToggleFavorite) {
                Image(systemName: isFavorite ? "heart.fill" : "heart")
                    .font(.title2)
                    .foregroundColor(isFavorite ? .cosmicTeal : .starWhite.opacity(0.6))
            }

            Spacer()

            // Playback Speed
            Menu {
                ForEach([0.75, 1.0, 1.25, 1.5], id: \.self) { speed in
                    Button(action: {
                        onChangePlaybackRate(Float(speed))
                    }) {
                        HStack {
                            Text("\(speed, specifier: "%.2f")x")
                            if playbackRate == Float(speed) {
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                }
            } label: {
                HStack(spacing: 4) {
                    Image(systemName: "gauge")
                    Text("\(playbackRate, specifier: "%.2f")x")
                }
                .font(CosmicTypography.caption)
                .foregroundColor(.starWhite.opacity(0.6))
            }
        }
        .padding(.horizontal, CosmicSpacing.large)
    }
}

// MARK: - Benefits View

struct BenefitsView: View {
    let benefits: [String]

    var body: some View {
        CosmicCard(glowColor: .neonPurple.opacity(0.5)) {
            VStack(alignment: .leading, spacing: CosmicSpacing.small) {
                HStack {
                    Image(systemName: "star.fill")
                        .foregroundColor(.neonPurple)

                    Text("Польза медитации")
                        .font(CosmicTypography.headline)
                        .foregroundColor(.starWhite)

                    Spacer()
                }

                ForEach(benefits, id: \.self) { benefit in
                    HStack(alignment: .top, spacing: 8) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.caption)
                            .foregroundColor(.cosmicTeal)

                        Text(benefit)
                            .font(CosmicTypography.caption)
                            .foregroundColor(.starWhite.opacity(0.8))
                    }
                }
            }
            .padding()
        }
    }
}

// MARK: - Meditation Info View

struct MeditationInfoView: View {
    let meditation: Meditation

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                StarfieldBackground()
                    .ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: CosmicSpacing.large) {
                        CosmicCard(glowColor: .cosmicTeal) {
                            VStack(alignment: .leading, spacing: CosmicSpacing.medium) {
                                Text("Описание")
                                    .font(CosmicTypography.headline)
                                    .foregroundColor(.starWhite)

                                Text(meditation.description)
                                    .font(CosmicTypography.body)
                                    .foregroundColor(.starWhite.opacity(0.8))
                            }
                            .padding()
                        }

                        CosmicCard(glowColor: .neonPurple.opacity(0.5)) {
                            VStack(alignment: .leading, spacing: CosmicSpacing.small) {
                                Text("Детали")
                                    .font(CosmicTypography.headline)
                                    .foregroundColor(.starWhite)

                                InfoRow(icon: "folder", title: "Категория", value: meditation.category.rawValue)
                                InfoRow(icon: "clock", title: "Длительность", value: meditation.durationFormatted)
                                InfoRow(icon: "chart.bar", title: "Уровень", value: meditation.level.rawValue)

                                if let zodiacSign = meditation.zodiacSign {
                                    InfoRow(icon: "star", title: "Знак зодиака", value: zodiacSign)
                                }

                                if meditation.isPremium {
                                    InfoRow(icon: "star.fill", title: "Премиум", value: "Да")
                                }
                            }
                            .padding()
                        }
                    }
                    .padding(.horizontal, CosmicSpacing.medium)
                }
            }
            .navigationTitle("О медитации")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Закрыть") {
                        dismiss()
                    }
                    .foregroundColor(.starWhite)
                }
            }
        }
    }
}

// MARK: - Preview

#Preview {
    MeditationPlayerView(
        meditation: Meditation(
            title: "Утренняя медитация",
            description: "Начните день с осознанности и внутреннего спокойствия",
            duration: 600,
            category: .chakra,
            audioURL: "https://example.com/meditation.mp3",
            benefits: [
                "Снижение стресса",
                "Улучшение концентрации",
                "Гармонизация чакр"
            ],
            level: .beginner
        )
    )
}
