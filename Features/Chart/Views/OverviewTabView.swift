//
//  OverviewTabView.swift
//  Astrolog
//
//  Created by Claude on 21.10.2025.
//

// Features/Chart/Views/OverviewTabView.swift
import SwiftUI

/// Вкладка обзора с ключевыми карточками натальной карты
struct OverviewTabView: View {
    let birthChart: BirthChart
    @ObservedObject var displayModeManager: ChartDisplayModeManager
    @EnvironmentObject var interpretationEngine: InterpretationEngine
    @EnvironmentObject var tooltipService: TooltipService

    @State private var keyInterpretations: [Interpretation] = []
    @State private var isLoading = false
    @State private var selectedInterpretation: Interpretation?

    var body: some View {
        ScrollView {
            LazyVStack(spacing: CosmicSpacing.large) {
                // Мини-визуализация карты
                miniChartSection

                // Основная троица
                bigThreeSection

                // Ключевые интерпретации
                keyInterpretationsSection

                // Доминирующие элементы
                if displayModeManager.currentMode != .beginner {
                    dominantElementsSection
                }

                // Краткий астрологический портрет
                if displayModeManager.currentMode == .intermediate {
                    astrologicalPortraitSection
                }
            }
            .padding(.horizontal, CosmicSpacing.medium)
            .padding(.vertical, CosmicSpacing.small)
        }
        .refreshable {
            await loadKeyInterpretations()
        }
        .task {
            await loadKeyInterpretations()
        }
        .sheet(item: $selectedInterpretation) { interpretation in
            InterpretationDetailSheet(interpretation: interpretation)
        }
    }

    // MARK: - Mini Chart Section
    private var miniChartSection: some View {
        VStack(spacing: CosmicSpacing.medium) {
            // Заголовок
            sectionHeader(
                title: "Ваша натальная карта",
                icon: "star.circle.fill",
                description: "Космический отпечаток момента вашего рождения"
            )

            // Мини-визуализация
            ZStack {
                // Упрощенная карта
                SimplifiedChartView(
                    birthChart: birthChart,
                    displayMode: displayModeManager.currentMode
                )
                .frame(height: 200)
                .clipped()

                // Кнопка для полной визуализации
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        expandChartButton
                    }
                }
                .padding(CosmicSpacing.medium)
            }
            .background(miniChartBackground)
            .cornerRadius(16)
        }
    }

    private var expandChartButton: some View {
        Button(action: {
            // Переход к полной визуализации
        }) {
            HStack(spacing: CosmicSpacing.tiny) {
                Image(systemName: "arrow.up.left.and.arrow.down.right")
                    .font(.caption)
                Text("Развернуть")
                    .font(.caption)
                    .fontWeight(.medium)
            }
            .foregroundColor(Color.starWhite)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.cosmicPurple.opacity(0.8))
                    .background(.ultraThinMaterial)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }

    // MARK: - Big Three Section
    private var bigThreeSection: some View {
        VStack(spacing: CosmicSpacing.medium) {
            sectionHeader(
                title: "Основная троица",
                icon: "crown.fill",
                description: "Солнце, Луна и Асцендент — ваши главные энергии"
            )

            VStack(spacing: CosmicSpacing.small) {
                // Солнце
                if let sunPlanet = birthChart.planets.first(where: { $0.type == .sun }) {
                    BigThreeCard(
                        planet: sunPlanet,
                        title: "Солнце",
                        subtitle: "Ваша суть",
                        description: "Основа личности и творческое самовыражение",
                        interpretation: getInterpretation(for: sunPlanet),
                        displayMode: displayModeManager.currentMode
                    )
                }

                // Луна
                if let moonPlanet = birthChart.planets.first(where: { $0.type == .moon }) {
                    BigThreeCard(
                        planet: moonPlanet,
                        title: "Луна",
                        subtitle: "Ваши эмоции",
                        description: "Внутренний мир и эмоциональные потребности",
                        interpretation: getInterpretation(for: moonPlanet),
                        displayMode: displayModeManager.currentMode
                    )
                }

                // Асцендент
                if let ascendantPlanet = birthChart.planets.first(where: { $0.type == .ascendant }) {
                    BigThreeCard(
                        planet: ascendantPlanet,
                        title: "Асцендент",
                        subtitle: "Ваша маска",
                        description: "Как вас воспринимают окружающие",
                        interpretation: getInterpretation(for: ascendantPlanet),
                        displayMode: displayModeManager.currentMode
                    )
                }
            }
        }
    }

    // MARK: - Key Interpretations Section
    private var keyInterpretationsSection: some View {
        VStack(spacing: CosmicSpacing.medium) {
            sectionHeader(
                title: "Ключевые особенности",
                icon: "sparkles",
                description: "Самые важные аспекты вашей карты"
            )

            if isLoading {
                loadingView
            } else {
                LazyVStack(spacing: CosmicSpacing.small) {
                    ForEach(keyInterpretations.prefix(getMaxInterpretations())) { interpretation in
                        KeyInterpretationCard(
                            interpretation: interpretation,
                            displayMode: displayModeManager.currentMode,
                            onTap: {
                                selectedInterpretation = interpretation
                            }
                        )
                    }

                    if keyInterpretations.count > getMaxInterpretations() {
                        showMoreButton
                    }
                }
            }
        }
    }

    private var loadingView: some View {
        VStack(spacing: CosmicSpacing.medium) {
            ForEach(0..<3) { _ in
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.cosmicPurple.opacity(0.1))
                    .frame(height: 80)
                    .redacted(reason: .placeholder)
            }
        }
    }

    private var showMoreButton: some View {
        Button("Показать больше интерпретаций") {
            // Показать все интерпретации
        }
        .font(.caption)
        .foregroundColor(.neonCyan)
        .padding(.top, CosmicSpacing.small)
    }

    // MARK: - Dominant Elements Section
    private var dominantElementsSection: some View {
        VStack(spacing: CosmicSpacing.medium) {
            sectionHeader(
                title: "Доминирующие элементы",
                icon: "flame.fill",
                description: "Преобладающие стихии и модальности в карте"
            )

            ElementAnalysisView(
                birthChart: birthChart,
                displayMode: displayModeManager.currentMode
            )
        }
    }

    // MARK: - Astrological Portrait Section
    private var astrologicalPortraitSection: some View {
        VStack(spacing: CosmicSpacing.medium) {
            sectionHeader(
                title: "Астрологический портрет",
                icon: "person.crop.circle.fill",
                description: "Комплексный анализ личности"
            )

            AstrologicalPortraitView(
                birthChart: birthChart,
                keyInterpretations: keyInterpretations,
                displayMode: displayModeManager.currentMode
            )
        }
    }

    // MARK: - Helper Views
    private func sectionHeader(title: String, icon: String, description: String) -> some View {
        VStack(alignment: .leading, spacing: CosmicSpacing.tiny) {
            HStack(spacing: CosmicSpacing.small) {
                Image(systemName: icon)
                    .foregroundColor(.neonCyan)
                    .font(.title2)

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(CosmicTypography.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(Color.starWhite)

                    Text(description)
                        .font(.caption)
                        .foregroundColor(Color.starWhite.opacity(0.7))
                        .lineLimit(2)
                }

                Spacer()
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var miniChartBackground: some View {
        RoundedRectangle(cornerRadius: 16)
            .fill(
                LinearGradient(
                    colors: [
                        .cosmicViolet.opacity(0.2),
                        Color.cosmicPurple.opacity(0.3),
                        .cosmicDarkPurple.opacity(0.4)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.starWhite.opacity(0.2), lineWidth: 1)
            )
    }

    // MARK: - Helper Methods
    private func getInterpretation(for planet: Planet) -> Interpretation? {
        let context = InterpretationContext(
            birthChart: birthChart,
            userPreferences: UserPreferences(
                interpretationStyle: displayModeManager.preferredInterpretationStyle,
                detailLevel: displayModeManager.currentMode.recommendedDepth
            ),
            displayMode: displayModeManager.currentMode
        )

        return interpretationEngine.getInterpretation(
            for: planet.type,
            in: planet.zodiacSign,
            context: context
        )
    }

    private func getMaxInterpretations() -> Int {
        switch displayModeManager.currentMode {
        case .human: return 2
        case .beginner: return 3
        case .intermediate: return 8
        }
    }

    @MainActor
    private func loadKeyInterpretations() async {
        isLoading = true

        // Имитация загрузки
        try? await Task.sleep(nanoseconds: 1_000_000_000)

        let context = InterpretationContext(
            birthChart: birthChart,
            userPreferences: UserPreferences(
                interpretationStyle: displayModeManager.preferredInterpretationStyle,
                detailLevel: displayModeManager.currentMode.recommendedDepth
            ),
            displayMode: displayModeManager.currentMode
        )

        keyInterpretations = interpretationEngine.getKeyInterpretations(
            for: birthChart,
            limit: 10,
            context: context
        )

        isLoading = false
    }
}

// MARK: - Supporting Views

/// Карточка для основной троицы
struct BigThreeCard: View {
    let planet: Planet
    let title: String
    let subtitle: String
    let description: String
    let interpretation: Interpretation?
    let displayMode: DisplayMode

    @State private var isExpanded = false

    var body: some View {
        VStack(spacing: 0) {
            // Основной контент
            HStack(spacing: CosmicSpacing.medium) {
                // Символ планеты и знака
                planetSymbolView

                // Информация
                VStack(alignment: .leading, spacing: CosmicSpacing.tiny) {
                    HStack {
                        Text(title)
                            .font(CosmicTypography.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(Color.starWhite)

                        Text(subtitle)
                            .font(.caption)
                            .foregroundColor(Color.starWhite.opacity(0.7))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(planet.zodiacSign.color.opacity(0.2))
                            )
                    }

                    Text("в \(planet.zodiacSign.displayName)")
                        .font(.body)
                        .foregroundColor(planet.zodiacSign.color)

                    if displayMode != .beginner {
                        Text(description)
                            .font(.caption)
                            .foregroundColor(Color.starWhite.opacity(0.8))
                            .lineLimit(2)
                    }
                }

                Spacer()

                // Кнопка развернуть
                Button(action: {
                    withAnimation(.spring()) {
                        isExpanded.toggle()
                    }
                }) {
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.caption)
                        .foregroundColor(.neonCyan)
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding(CosmicSpacing.medium)
            .background(cardBackground)
            .onTapGesture {
                withAnimation(.spring()) {
                    isExpanded.toggle()
                }
            }

            // Расширенная информация
            if isExpanded, let interpretation = interpretation {
                expandedContent(interpretation)
            }
        }
        .cornerRadius(12)
    }

    private var planetSymbolView: some View {
        ZStack {
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            planet.type.color.opacity(0.8),
                            planet.type.color.opacity(0.3)
                        ],
                        center: .center,
                        startRadius: 5,
                        endRadius: 25
                    )
                )
                .frame(width: 50, height: 50)

            VStack(spacing: 2) {
                Text(planet.type.symbol)
                    .font(.title2)
                    .foregroundColor(Color.starWhite)

                Text(planet.zodiacSign.symbol)
                    .font(.caption)
                    .foregroundColor(planet.zodiacSign.color)
            }
        }
    }

    private func expandedContent(_ interpretation: Interpretation) -> some View {
        VStack(alignment: .leading, spacing: CosmicSpacing.small) {
            Divider()
                .background(Color.starWhite.opacity(0.3))

            VStack(alignment: .leading, spacing: CosmicSpacing.small) {
                Text(interpretation.getText(for: displayMode.recommendedDepth))
                    .font(.body)
                    .foregroundColor(Color.starWhite.opacity(0.9))

                if !interpretation.keywords.isEmpty && displayMode != .beginner {
                    keywordsView(interpretation.keywords)
                }
            }
            .padding(CosmicSpacing.medium)
        }
        .background(Color.cosmicPurple.opacity(0.1))
        .transition(.asymmetric(
            insertion: .opacity.combined(with: .scale(scale: 0.95, anchor: .top)),
            removal: .opacity.combined(with: .scale(scale: 0.95, anchor: .top))
        ))
    }

    private func keywordsView(_ keywords: [String]) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Ключевые качества:")
                .font(.caption)
                .foregroundColor(Color.starWhite.opacity(0.7))

            WrappingHStack(keywords.prefix(4).map { String($0) }) { keyword in
                keywordChip(keyword)
            }
        }
    }

    private func keywordChip(_ keyword: String) -> some View {
        Text(keyword)
            .font(.caption2)
            .fontWeight(.medium)
            .foregroundColor(.cosmicDarkPurple)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(planet.zodiacSign.color.opacity(0.8))
            )
    }

    private var cardBackground: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(
                LinearGradient(
                    colors: [
                        planet.zodiacSign.elementColor.opacity(0.1),
                        Color.cosmicPurple.opacity(0.2)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(planet.type.color.opacity(0.3), lineWidth: 1)
            )
    }
}

/// Карточка для ключевой интерпретации
struct KeyInterpretationCard: View {
    let interpretation: Interpretation
    let displayMode: DisplayMode
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: CosmicSpacing.medium) {
                // Эмодзи
                Text(interpretation.emoji)
                    .font(.title)
                    .frame(width: 40, height: 40)

                // Контент
                VStack(alignment: .leading, spacing: CosmicSpacing.tiny) {
                    Text(interpretation.title)
                        .font(.body)
                        .fontWeight(.medium)
                        .foregroundColor(Color.starWhite)
                        .multilineTextAlignment(.leading)

                    Text(interpretation.getText(for: displayMode.recommendedDepth))
                        .font(.caption)
                        .foregroundColor(Color.starWhite.opacity(0.8))
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.neonCyan)
            }
            .padding(CosmicSpacing.medium)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(interpretation.themeColor.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(interpretation.themeColor.opacity(0.2), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

/// Оберточный HStack для ключевых слов
struct WrappingHStack<Data: RandomAccessCollection, Content: View>: View where Data.Element: Hashable {
    let data: Data
    let content: (Data.Element) -> Content
    let spacing: CGFloat

    init(_ data: Data, spacing: CGFloat = 8, @ViewBuilder content: @escaping (Data.Element) -> Content) {
        self.data = data
        self.content = content
        self.spacing = spacing
    }

    var body: some View {
        LazyVGrid(
            columns: [GridItem(.adaptive(minimum: 80))],
            spacing: spacing
        ) {
            ForEach(Array(data), id: \.self) { item in
                content(item)
            }
        }
    }
}

/// Заглушки для сложных компонентов
struct SimplifiedChartView: View {
    let birthChart: BirthChart
    let displayMode: DisplayMode

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.starWhite.opacity(0.3), lineWidth: 2)

            Text("🌟")
                .font(.largeTitle)

            Text("Упрощенная визуализация карты")
                .font(.caption)
                .foregroundColor(Color.starWhite.opacity(0.7))
                .offset(y: 50)
        }
    }
}

struct ElementAnalysisView: View {
    let birthChart: BirthChart
    let displayMode: DisplayMode

    var body: some View {
        Text("Анализ элементов - заглушка")
            .padding()
            .background(Color.fireElement.opacity(0.1))
            .cornerRadius(12)
    }
}

struct AstrologicalPortraitView: View {
    let birthChart: BirthChart
    let keyInterpretations: [Interpretation]
    let displayMode: DisplayMode

    var body: some View {
        Text("Астрологический портрет - заглушка")
            .padding()
            .background(Color.cosmicViolet.opacity(0.1))
            .cornerRadius(12)
    }
}

struct InterpretationDetailSheet: View {
    let interpretation: Interpretation

    var body: some View {
        Text("Детальная интерпретация - заглушка")
            .padding()
    }
}