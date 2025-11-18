//
//  TodayTabView.swift
//  Astrolog
//
//  Created by Claude on 26.10.2025.
//

// Features/Chart/Views/TodayTabView.swift
import SwiftUI

/// Вкладка "Сегодня" с текущими транзитами, энергией дня и персональными рекомендациями
struct TodayTabView: View {
    let birthChart: BirthChart
    @ObservedObject var displayModeManager: ChartDisplayModeManager

    @StateObject private var transitService = TransitService()
    @State private var selectedTransit: Transit?
    @State private var selectedRecommendation: DailyRecommendation?

    var body: some View {
        ScrollView {
            LazyVStack(spacing: CosmicSpacing.large) {
                // Заголовок дня
                todayHeaderSection

                // Энергия дня
                if let insight = transitService.todayInsights {
                    dailyEnergySection(insight)
                }

                // Лунная фаза
                if let insight = transitService.todayInsights {
                    lunarPhaseSection(insight)
                }

                // Ключевые транзиты
                if let insight = transitService.todayInsights {
                    keyTransitsSection(insight)
                } else if !transitService.currentTransits.isEmpty {
                    // Показываем транзиты без дневных инсайтов
                    basicTransitsSection
                }

                // Персональные рекомендации
                if let insight = transitService.todayInsights {
                    personalRecommendationsSection(insight)
                }

                // Аффирмация дня
                if let insight = transitService.todayInsights {
                    affirmationSection(insight)
                }
            }
            .padding(.horizontal, CosmicSpacing.medium)
            .padding(.vertical, CosmicSpacing.small)
        }
        .refreshable {
            await loadTransits()
        }
        .task {
            await loadTransits()
        }
        .sheet(item: $selectedTransit) { transit in
            TransitDetailSheet(transit: transit, birthChart: birthChart)
        }
        .sheet(item: $selectedRecommendation) { recommendation in
            RecommendationDetailSheet(recommendation: recommendation)
        }
    }

    // MARK: - Today Header Section
    private var todayHeaderSection: some View {
        VStack(spacing: CosmicSpacing.small) {
            // Дата и приветствие
            VStack(spacing: CosmicSpacing.tiny) {
                Text(Date(), format: .dateTime.weekday(.wide).day().month(.wide))
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.starWhite)

                Text("Что готовят вам звёзды сегодня")
                    .font(.body)
                    .foregroundColor(.starWhite.opacity(0.8))
                    .multilineTextAlignment(.center)
            }

            // Индикатор загрузки
            if transitService.isLoading {
                ProgressView()
                    .tint(.neonCyan)
                    .scaleEffect(1.2)
                    .padding(.top, CosmicSpacing.small)
            }
        }
        .padding(.bottom, CosmicSpacing.medium)
    }

    // MARK: - Daily Energy Section
    private func dailyEnergySection(_ insight: DailyInsight) -> some View {
        CosmicCard(glowColor: insight.emotionalTone.color) {
            VStack(spacing: CosmicSpacing.medium) {
                // Заголовок секции
                sectionHeader(
                    title: "Энергия дня",
                    emoji: insight.emoji,
                    subtitle: insight.emotionalTone.rawValue
                )

                // Общая энергетика
                VStack(spacing: CosmicSpacing.small) {
                    Text(insight.overallEnergy)
                        .font(.body)
                        .foregroundColor(.starWhite)
                        .multilineTextAlignment(.center)
                        .lineSpacing(2)

                    // Индикатор энергии
                    energyIndicator(level: insight.energyLevel, tone: insight.emotionalTone)
                }
            }
        }
    }

    private func energyIndicator(level: Double, tone: EmotionalTone) -> some View {
        VStack(spacing: CosmicSpacing.small) {
            HStack(spacing: 4) {
                ForEach(0..<5, id: \.self) { index in
                    Circle()
                        .fill(index < Int(level * 5) ? tone.color : tone.color.opacity(0.2))
                        .frame(width: 8, height: 8)
                }
            }

            Text(energyLevelText(level))
                .font(.caption)
                .foregroundColor(.starWhite.opacity(0.7))
        }
    }

    private func energyLevelText(_ level: Double) -> String {
        switch level {
        case 0.8...1.0: return "Очень гармоничный день"
        case 0.6...0.8: return "Благоприятный день"
        case 0.4...0.6: return "Сбалансированный день"
        case 0.2...0.4: return "Интенсивный день"
        default: return "Испытывающий день"
        }
    }

    // MARK: - Lunar Phase Section
    private func lunarPhaseSection(_ insight: DailyInsight) -> some View {
        CosmicCard(glowColor: .waterElement.opacity(0.5)) {
            HStack(spacing: CosmicSpacing.medium) {
                // Эмодзи фазы
                Text(insight.lunarPhase.emoji)
                    .font(.system(size: 40))

                VStack(alignment: .leading, spacing: CosmicSpacing.small) {
                    Text(insight.lunarPhase.rawValue)
                        .font(.headline)
                        .foregroundColor(.starWhite)

                    Text(insight.lunarPhase.influence)
                        .font(.body)
                        .foregroundColor(.starWhite.opacity(0.8))
                        .lineLimit(nil)
                }

                Spacer()
            }
        }
    }

    // MARK: - Key Transits Section
    private func keyTransitsSection(_ insight: DailyInsight) -> some View {
        VStack(spacing: CosmicSpacing.medium) {
            sectionHeader(
                title: "Ключевые влияния",
                emoji: "⭐️",
                subtitle: "Важные астрологические аспекты дня"
            )

            let topTransits = insight.getTopTransits(limit: getMaxTransits())

            if topTransits.isEmpty {
                emptyTransitsView
            } else {
                LazyVStack(spacing: CosmicSpacing.small) {
                    ForEach(topTransits) { transit in
                        TransitCard(
                            transit: transit,
                            displayMode: displayModeManager.currentMode,
                            onTap: {
                                selectedTransit = transit
                            }
                        )
                    }
                }
            }
        }
    }

    private var emptyTransitsView: some View {
        VStack(spacing: CosmicSpacing.medium) {
            Image(systemName: "moon.stars.fill")
                .font(.system(size: 40))
                .foregroundColor(.starWhite.opacity(0.3))

            Text("Спокойный астрологический день")
                .font(.body)
                .foregroundColor(.starWhite.opacity(0.7))
                .multilineTextAlignment(.center)

            Text("Сегодня нет значимых транзитов. Время для отдыха и восстановления.")
                .font(.caption)
                .foregroundColor(.starWhite.opacity(0.5))
                .multilineTextAlignment(.center)
        }
        .padding(CosmicSpacing.large)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.cosmicPurple.opacity(0.1))
        )
    }

    // MARK: - Personal Recommendations Section
    private func personalRecommendationsSection(_ insight: DailyInsight) -> some View {
        VStack(spacing: CosmicSpacing.medium) {
            sectionHeader(
                title: "Персональные советы",
                emoji: "💡",
                subtitle: "На основе вашей натальной карты"
            )

            let topRecommendations = insight.getTopRecommendations(limit: getMaxRecommendations())

            LazyVStack(spacing: CosmicSpacing.small) {
                ForEach(topRecommendations) { recommendation in
                    RecommendationCard(
                        recommendation: recommendation,
                        displayMode: displayModeManager.currentMode,
                        onTap: {
                            selectedRecommendation = recommendation
                        }
                    )
                }
            }
        }
    }

    // MARK: - Affirmation Section
    private func affirmationSection(_ insight: DailyInsight) -> some View {
        CosmicCard(glowColor: .starYellow.opacity(0.5)) {
            VStack(spacing: CosmicSpacing.medium) {
                Image(systemName: "quote.bubble.fill")
                    .font(.title)
                    .foregroundColor(.starYellow)

                Text("Аффирмация дня")
                    .font(.headline)
                    .foregroundColor(.starWhite)

                Text(insight.affirmation)
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundColor(.starWhite)
                    .multilineTextAlignment(.center)
                    .lineSpacing(3)
                    .padding(.horizontal, CosmicSpacing.small)
            }
            .padding(CosmicSpacing.medium)
        }
    }

    // MARK: - Helper Views
    private func sectionHeader(title: String, emoji: String, subtitle: String) -> some View {
        VStack(alignment: .leading, spacing: CosmicSpacing.tiny) {
            HStack(spacing: CosmicSpacing.small) {
                Text(emoji)
                    .font(.title2)

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.starWhite)

                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.starWhite.opacity(0.7))
                        .lineLimit(2)
                }

                Spacer()
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Basic Transits Section (когда нет полных дневных инсайтов)
    private var basicTransitsSection: some View {
        VStack(spacing: CosmicSpacing.medium) {
            sectionHeader(
                title: "Текущие транзиты",
                emoji: "⭐️",
                subtitle: "Астрологические влияния сегодня"
            )

            let topTransits = transitService.getTopTransits(count: getMaxTransits())

            if topTransits.isEmpty {
                emptyTransitsView
            } else {
                LazyVStack(spacing: CosmicSpacing.small) {
                    ForEach(topTransits) { transit in
                        TransitCard(
                            transit: transit,
                            displayMode: displayModeManager.currentMode,
                            onTap: {
                                selectedTransit = transit
                            }
                        )
                    }
                }
            }
        }
    }

    // MARK: - Helper Methods
    private func getMaxTransits() -> Int {
        switch displayModeManager.currentMode {
        case .human: return 2
        case .beginner: return 3
        case .intermediate: return 8
        }
    }

    private func getMaxRecommendations() -> Int {
        switch displayModeManager.currentMode {
        case .human: return 1
        case .beginner: return 2
        case .intermediate: return 4
        }
    }

    @MainActor
    private func loadTransits() async {
        // Запускаем расчет транзитов через сервис
        await transitService.calculateCurrentTransits(for: birthChart)
    }

}

// MARK: - Supporting Cards

/// Карточка транзита
struct TransitCard: View {
    let transit: Transit
    let displayMode: DisplayMode
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: CosmicSpacing.medium) {
                // Влияние транзита
                VStack {
                    Text(transit.emoji)
                        .font(.title)

                    impactIndicator
                }
                .frame(width: 50)

                // Информация о транзите
                VStack(alignment: .leading, spacing: CosmicSpacing.tiny) {
                    Text(displayMode == .human || displayMode == .beginner ? transit.humanDescription : transit.shortDescription)
                        .font(.body)
                        .fontWeight(.medium)
                        .foregroundColor(.starWhite)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)

                    Text(displayMode == .human || displayMode == .beginner ? transit.humanDescription : transit.interpretation)
                        .font(.caption)
                        .foregroundColor(.starWhite.opacity(0.8))
                        .lineLimit(displayMode == .human ? 2 : 3)
                        .multilineTextAlignment(.leading)

                    HStack {
                        influenceLabel

                        Spacer()

                        Text(transit.timeToFromPeak)
                            .font(.caption2)
                            .foregroundColor(.starWhite.opacity(0.6))
                    }
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.neonCyan)
            }
            .padding(CosmicSpacing.medium)
            .background(cardBackground)
        }
        .buttonStyle(PlainButtonStyle())
    }

    private var impactIndicator: some View {
        Circle()
            .fill(transit.influence.color)
            .frame(width: 8, height: 8)
            .overlay(
                Circle()
                    .stroke(transit.influence.color, lineWidth: 2)
                    .scaleEffect(1 + transit.intensity * 0.5)
                    .opacity(0.5)
            )
    }

    private var influenceLabel: some View {
        HStack(spacing: 4) {
            Image(systemName: transit.influence.icon)
                .font(.caption2)
            Text(transit.influence.rawValue)
                .font(.caption2)
        }
        .foregroundColor(transit.influence.color)
        .padding(.horizontal, 6)
        .padding(.vertical, 2)
        .background(
            Capsule()
                .fill(transit.influence.color.opacity(0.2))
        )
    }

    private var cardBackground: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(
                LinearGradient(
                    colors: [
                        transit.influence.color.opacity(0.1),
                        .cosmicPurple.opacity(0.2)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(transit.influence.color.opacity(0.3), lineWidth: 1)
            )
    }
}

/// Карточка рекомендации
struct RecommendationCard: View {
    let recommendation: DailyRecommendation
    let displayMode: DisplayMode
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: CosmicSpacing.medium) {
                // Иконка категории
                VStack {
                    Text(recommendation.emoji)
                        .font(.title2)

                    priorityIndicator
                }
                .frame(width: 40)

                // Контент рекомендации
                VStack(alignment: .leading, spacing: CosmicSpacing.tiny) {
                    HStack {
                        Text(recommendation.title)
                            .font(.body)
                            .fontWeight(.medium)
                            .foregroundColor(.starWhite)

                        Spacer()

                        Text(recommendation.category.rawValue)
                            .font(.caption2)
                            .foregroundColor(recommendation.category.color)
                    }

                    Text(recommendation.description)
                        .font(.caption)
                        .foregroundColor(.starWhite.opacity(0.8))
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)

                    if let action = recommendation.action, displayMode != .human && displayMode != .beginner {
                        Text("💡 \(action)")
                            .font(.caption2)
                            .foregroundColor(.neonCyan)
                            .lineLimit(2)
                    }
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.neonCyan.opacity(0.6))
            }
            .padding(CosmicSpacing.medium)
            .background(recommendationBackground)
        }
        .buttonStyle(PlainButtonStyle())
    }

    private var priorityIndicator: some View {
        HStack(spacing: 2) {
            ForEach(0..<recommendation.priority, id: \.self) { _ in
                Circle()
                    .fill(recommendation.category.color)
                    .frame(width: 4, height: 4)
            }
        }
    }

    private var recommendationBackground: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(recommendation.category.color.opacity(0.05))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(recommendation.category.color.opacity(0.2), lineWidth: 1)
            )
    }
}

// MARK: - Detail Sheets

/// Детальная информация о транзите
struct TransitDetailSheet: View {
    let transit: Transit
    let birthChart: BirthChart
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: CosmicSpacing.large) {
                    // Заголовок
                    VStack(alignment: .leading, spacing: CosmicSpacing.small) {
                        Text(transit.emoji)
                            .font(.system(size: 50))

                        Text(transit.fullDescription)
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.starWhite)
                    }

                    // Интерпретация
                    CosmicCard(glowColor: transit.influence.color) {
                        VStack(alignment: .leading, spacing: CosmicSpacing.medium) {
                            Text("Интерпретация")
                                .font(.headline)
                                .foregroundColor(.starWhite)

                            Text(transit.interpretation)
                                .font(.body)
                                .foregroundColor(.starWhite)
                                .lineSpacing(3)
                        }
                    }

                    Spacer()
                }
                .padding(CosmicSpacing.large)
            }
            .background(StarfieldBackground().ignoresSafeArea())
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Закрыть") {
                        dismiss()
                    }
                    .foregroundColor(.neonCyan)
                }
            }
        }
    }
}

/// Детальная информация о рекомендации
struct RecommendationDetailSheet: View {
    let recommendation: DailyRecommendation
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: CosmicSpacing.large) {
                    // Заголовок
                    VStack(alignment: .leading, spacing: CosmicSpacing.small) {
                        Text(recommendation.emoji)
                            .font(.system(size: 50))

                        Text(recommendation.title)
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.starWhite)
                    }

                    // Описание
                    CosmicCard(glowColor: recommendation.category.color) {
                        VStack(alignment: .leading, spacing: CosmicSpacing.medium) {
                            Text(recommendation.description)
                                .font(.body)
                                .foregroundColor(.starWhite)
                                .lineSpacing(3)

                            if let action = recommendation.action {
                                Text("Рекомендуемое действие:")
                                    .font(.headline)
                                    .foregroundColor(.starWhite)

                                Text(action)
                                    .font(.body)
                                    .foregroundColor(.neonCyan)
                                    .lineSpacing(3)
                            }
                        }
                    }

                    Spacer()
                }
                .padding(CosmicSpacing.large)
            }
            .background(StarfieldBackground().ignoresSafeArea())
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Закрыть") {
                        dismiss()
                    }
                    .foregroundColor(.neonCyan)
                }
            }
        }
    }
}