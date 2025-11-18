//
//  EnhancedPlanetsTabContent.swift
//  Astrolog
//
//  Created by Claude on 26.10.2025.
//

// Features/Chart/Views/EnhancedPlanetsTabContent.swift
import SwiftUI

/// Улучшенная вкладка "Планеты" с персонализацией и эмоциональными инсайтами
struct EnhancedPlanetsTabContent: View {
    let birthChart: BirthChart
    let config: ChartTabConfig
    @ObservedObject var displayModeManager: ChartDisplayModeManager

    // Новые сервисы для персонализации
    @StateObject private var personalInsightsService = PersonalInsightsService()
    @StateObject private var emotionalService = EmotionalInterpretationService()
    @StateObject private var humanLanguageService = HumanLanguageService()

    @State private var personalInsights: PersonalInsights?
    @State private var isLoading = false
    @State private var selectedPlanet: Planet?

    var body: some View {
        LazyVStack(spacing: CosmicSpacing.large) {
            // Заголовок секции
            planetsHeaderSection

            // Персональный профиль планет (новое!)
            if let insights = personalInsights {
                personalPlanetProfileSection(insights)
            }

            // Список планет с эмоциональными инсайтами
            planetsListSection
        }
        .onAppear {
            Task {
                await loadPersonalizationData()
            }
        }
        .sheet(item: $selectedPlanet) { planet in
            PlanetDetailSheet(
                planet: planet,
                birthChart: birthChart,
                personalInsights: personalInsights,
                displayMode: displayModeManager.currentMode
            )
        }
    }

    // MARK: - Header Section
    private var planetsHeaderSection: some View {
        VStack(spacing: CosmicSpacing.medium) {
            // Космический символ
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                .starYellow.opacity(0.2),
                                .cosmicViolet.opacity(0.4),
                                .neonCyan.opacity(0.3)
                            ],
                            center: .center,
                            startRadius: 15,
                            endRadius: 60
                        )
                    )
                    .frame(width: 120, height: 120)

                Text("🪐")
                    .font(.system(size: 50))
            }

            VStack(spacing: CosmicSpacing.small) {
                Text("Планеты в вашей карте")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.starWhite)

                Text("Космические влияния на вашу личность")
                    .font(.body)
                    .foregroundColor(.starWhite.opacity(0.8))
                    .multilineTextAlignment(.center)
            }
        }
    }

    // MARK: - Personal Planet Profile
    private func personalPlanetProfileSection(_ insights: PersonalInsights) -> some View {
        CosmicCard(glowColor: .neonCyan.opacity(0.4)) {
            VStack(spacing: CosmicSpacing.medium) {
                HStack {
                    Text("🌟")
                        .font(.title)

                    Text("Ваш планетарный профиль")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.starWhite)

                    Spacer()
                }

                // Доминирующие планетарные влияния
                if !insights.dominantPlanetaryInfluences.isEmpty {
                    VStack(alignment: .leading, spacing: CosmicSpacing.small) {
                        Text("Самые сильные влияния:")
                            .font(.subheadline)
                            .foregroundColor(.starWhite.opacity(0.9))

                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: CosmicSpacing.tiny) {
                            ForEach(insights.dominantPlanetaryInfluences.prefix(4), id: \.planet) { influence in
                                PlanetaryInfluenceCard(influence: influence)
                            }
                        }
                    }
                }

                // Эмоциональный баланс планет
                Divider()
                    .background(Color.starWhite.opacity(0.3))

                VStack(alignment: .leading, spacing: CosmicSpacing.small) {
                    Text("Эмоциональный баланс:")
                        .font(.subheadline)
                        .foregroundColor(.starWhite.opacity(0.9))

                    Text(insights.emotionalBalance)
                        .font(.caption)
                        .foregroundColor(.waterElement)
                        .lineLimit(3)
                }
            }
            .padding(CosmicSpacing.medium)
        }
    }

    // MARK: - Planets List
    private var planetsListSection: some View {
        LazyVStack(spacing: CosmicSpacing.medium) {
            // Большая тройка выделенно
            bigThreeSection

            // Остальные планеты
            otherPlanetsSection
        }
    }

    private var bigThreeSection: some View {
        VStack(spacing: CosmicSpacing.medium) {
            HStack {
                Text("👑")
                    .font(.title2)

                Text("Основа личности")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.starWhite)

                Spacer()
            }

            LazyVStack(spacing: CosmicSpacing.small) {
                ForEach([PlanetType.sun, .moon, .ascendant], id: \.self) { planetType in
                    if let planet = birthChart.planets.first(where: { $0.type == planetType }) {
                        EnhancedPlanetCard(
                            planet: planet,
                            personalInsights: personalInsights,
                            displayMode: displayModeManager.currentMode,
                            isHighlighted: true,
                            onTap: { selectedPlanet = planet }
                        )
                    }
                }
            }
        }
    }

    private var otherPlanetsSection: some View {
        VStack(spacing: CosmicSpacing.medium) {
            HStack {
                Text("🪐")
                    .font(.title2)

                Text("Другие планеты")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.starWhite)

                Spacer()
            }

            LazyVStack(spacing: CosmicSpacing.small) {
                ForEach(otherPlanets, id: \.id) { planet in
                    EnhancedPlanetCard(
                        planet: planet,
                        personalInsights: personalInsights,
                        displayMode: displayModeManager.currentMode,
                        isHighlighted: false,
                        onTap: { selectedPlanet = planet }
                    )
                }
            }
        }
    }

    private var otherPlanets: [Planet] {
        birthChart.planets.filter { planet in
            ![.sun, .moon, .ascendant].contains(planet.type)
        }
    }

    // MARK: - Data Loading
    @MainActor
    private func loadPersonalizationData() async {
        isLoading = true

        do {
            await personalInsightsService.generatePersonalProfile(
                for: birthChart,
                displayMode: displayModeManager.currentMode
            )
            personalInsights = PersonalInsights(
                id: UUID(),
                userId: "user",
                chartId: "chart",
                generatedAt: Date(),
                corePersonalityDescription: "Анализ планетарных влияний в натальной карте",
                lifeTheme: LifeTheme(
                    id: UUID(),
                    title: "Планетарные влияния",
                    description: "Основные планетарные темы в вашей карте",
                    keywords: ["планеты", "влияние", "характер"],
                    color: Color.cosmicViolet,
                    importance: 0.8
                ),
                uniqueTraits: [],
                emotionalBalance: "Анализ эмоционального баланса через планеты",
                dominantPlanetaryInfluences: [],
                planetaryInsights: personalInsightsService.personalInsights.compactMap { insight in
                    // Convert PersonalInsight to PlanetaryInsight if needed
                    PlanetaryInsight(
                        id: UUID(),
                        planet: .sun, // Default value, should be properly mapped
                        personalizedDescription: insight.description,
                        emotionalImpact: insight.title,
                        practicalAdvice: insight.practicalAdvice ?? "Рекомендации в разработке",
                        keywords: []
                    )
                },
                aspectPatterns: [],
                aspectInsights: [],
                overallHarmony: .moderate,
                houseInsights: []
            )
        } catch {
            print("Ошибка загрузки персонализированных данных планет: \(error)")
        }

        isLoading = false
    }
}

// MARK: - Supporting Components

/// Карточка планетарного влияния
struct PlanetaryInfluenceCard: View {
    let influence: PlanetaryInfluence

    var body: some View {
        HStack(spacing: CosmicSpacing.small) {
            Text(influence.planet.symbol)
                .font(.caption)
                .foregroundColor(influence.planet.color)

            VStack(alignment: .leading, spacing: 2) {
                Text(influence.planet.displayName)
                    .font(.caption2)
                    .fontWeight(.medium)
                    .foregroundColor(.starWhite)

                Text(influence.description)
                    .font(.caption2)
                    .foregroundColor(.starWhite.opacity(0.7))
                    .lineLimit(1)
            }

            Spacer()

            // Индикатор силы
            Circle()
                .fill(influence.planet.color.opacity(influence.strength))
                .frame(width: 8, height: 8)
        }
        .padding(.horizontal, CosmicSpacing.small)
        .padding(.vertical, CosmicSpacing.tiny)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(influence.planet.color.opacity(0.1))
        )
    }
}

/// Улучшенная карточка планеты с персональными инсайтами
struct EnhancedPlanetCard: View {
    let planet: Planet
    let personalInsights: PersonalInsights?
    let displayMode: DisplayMode
    let isHighlighted: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: CosmicSpacing.medium) {
                // Символ планеты
                planetSymbol

                // Информация о планете
                VStack(alignment: .leading, spacing: CosmicSpacing.tiny) {
                    HStack {
                        Text(getPlanetName())
                            .font(isHighlighted ? .body : .subheadline)
                            .fontWeight(isHighlighted ? .semibold : .medium)
                            .foregroundColor(.starWhite)

                        Spacer()

                        signBadge
                    }

                    Text("в \(planet.zodiacSign.displayName)")
                        .font(.caption)
                        .foregroundColor(planet.zodiacSign.color)

                    // Персональный инсайт
                    if let insight = getPersonalInsight() {
                        Text(insight)
                            .font(.caption2)
                            .foregroundColor(.neonCyan)
                            .lineLimit(2)
                    }

                    // Эмоциональное влияние
                    if displayMode != .human, let emotionalImpact = getEmotionalImpact() {
                        Text(emotionalImpact)
                            .font(.caption2)
                            .foregroundColor(.waterElement.opacity(0.8))
                            .lineLimit(1)
                    }
                }

                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.neonCyan.opacity(0.6))
            }
            .padding(CosmicSpacing.medium)
            .background(cardBackground)
        }
        .buttonStyle(PlainButtonStyle())
    }

    private var planetSymbol: some View {
        ZStack {
            Circle()
                .fill(planet.type.color.opacity(0.3))
                .frame(width: isHighlighted ? 50 : 40, height: isHighlighted ? 50 : 40)

            if isHighlighted {
                Circle()
                    .stroke(planet.type.color, lineWidth: 2)
                    .frame(width: 52, height: 52)
            }

            Text(planet.type.symbol)
                .font(isHighlighted ? .title2 : .title3)
                .foregroundColor(.starWhite)
        }
    }

    private var signBadge: some View {
        Text(planet.zodiacSign.symbol)
            .font(.caption)
            .fontWeight(.medium)
            .foregroundColor(.starWhite)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(planet.zodiacSign.color.opacity(0.3))
            )
    }

    private var cardBackground: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(
                LinearGradient(
                    colors: [
                        planet.zodiacSign.elementColor.opacity(0.1),
                        .cosmicPurple.opacity(isHighlighted ? 0.2 : 0.15),
                        planet.type.color.opacity(0.05)
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(
                        planet.type.color.opacity(isHighlighted ? 0.4 : 0.2),
                        lineWidth: isHighlighted ? 2 : 1
                    )
            )
    }

    private func getPlanetName() -> String {
        switch displayMode {
        case .human:
            return HumanLanguageService().translatePlanet(planet.type).humanName
        default:
            return planet.type.displayName
        }
    }

    private func getPersonalInsight() -> String? {
        guard let insights = personalInsights else { return nil }

        // Ищем персональный инсайт для этой планеты
        return insights.planetaryInsights.first { $0.planet == planet.type }?.personalizedDescription
    }

    private func getEmotionalImpact() -> String? {
        // Заглушка для эмоционального влияния
        switch planet.type {
        case .sun: return "Основа эмоций"
        case .moon: return "Глубина чувств"
        case .mercury: return "Выражение эмоций"
        case .venus: return "Любовь и привязанность"
        case .mars: return "Страсть и гнев"
        default: return nil
        }
    }
}

/// Детальная информация о планете
struct PlanetDetailSheet: View {
    let planet: Planet
    let birthChart: BirthChart
    let personalInsights: PersonalInsights?
    let displayMode: DisplayMode

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: CosmicSpacing.large) {
                    // Заголовок с символом планеты
                    planetHeaderSection

                    // Персональная интерпретация
                    if let insights = personalInsights {
                        personalInterpretationSection(insights)
                    }

                    // Основная информация
                    basicInformationSection

                    // Эмоциональное влияние
                    emotionalInfluenceSection

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

    private var planetHeaderSection: some View {
        VStack(alignment: .leading, spacing: CosmicSpacing.medium) {
            HStack {
                Text(planet.type.symbol)
                    .font(.system(size: 80))
                    .foregroundColor(planet.type.color)

                Spacer()

                VStack(alignment: .trailing, spacing: CosmicSpacing.small) {
                    Text(planet.zodiacSign.symbol)
                        .font(.system(size: 40))
                        .foregroundColor(planet.zodiacSign.color)

                    Text(planet.zodiacSign.displayName)
                        .font(.caption)
                        .foregroundColor(planet.zodiacSign.color)
                }
            }

            VStack(alignment: .leading, spacing: CosmicSpacing.small) {
                Text(planet.type.displayName)
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.starWhite)

                Text("в знаке \(planet.zodiacSign.displayName)")
                    .font(.title2)
                    .foregroundColor(planet.zodiacSign.color)
            }
        }
    }

    private func personalInterpretationSection(_ insights: PersonalInsights) -> some View {
        CosmicCard(glowColor: planet.type.color) {
            VStack(alignment: .leading, spacing: CosmicSpacing.medium) {
                Text("Что это значит для вас")
                    .font(.headline)
                    .foregroundColor(.starWhite)

                if let personalDescription = getPersonalDescription(insights) {
                    Text(personalDescription)
                        .font(.body)
                        .foregroundColor(.starWhite)
                        .lineSpacing(3)
                }
            }
            .padding(CosmicSpacing.medium)
        }
    }

    private var basicInformationSection: some View {
        CosmicCard(glowColor: planet.zodiacSign.color) {
            VStack(alignment: .leading, spacing: CosmicSpacing.medium) {
                Text("Основная информация")
                    .font(.headline)
                    .foregroundColor(.starWhite)

                VStack(alignment: .leading, spacing: CosmicSpacing.small) {
                    InfoRow(title: "Планета", value: planet.type.displayName)
                    InfoRow(title: "Знак", value: planet.zodiacSign.displayName)
                    InfoRow(title: "Элемент", value: planet.zodiacSign.element.displayName)
                    InfoRow(title: "Качество", value: planet.zodiacSign.modality.displayName)
                }
            }
            .padding(CosmicSpacing.medium)
        }
    }

    private var emotionalInfluenceSection: some View {
        CosmicCard(glowColor: .waterElement.opacity(0.6)) {
            VStack(alignment: .leading, spacing: CosmicSpacing.medium) {
                HStack {
                    Text("💖")
                        .font(.title2)

                    Text("Эмоциональное влияние")
                        .font(.headline)
                        .foregroundColor(.starWhite)
                }

                Text("Как \(planet.type.displayName.lowercased()) в \(planet.zodiacSign.displayName.lowercased()) влияет на ваши эмоции и внутренний мир.")
                    .font(.body)
                    .foregroundColor(.starWhite)
                    .lineSpacing(3)
            }
            .padding(CosmicSpacing.medium)
        }
    }

    private func getPersonalDescription(_ insights: PersonalInsights) -> String? {
        return insights.planetaryInsights.first { $0.planet == planet.type }?.personalizedDescription
    }
}

/// Информационная строка
struct InfoRow: View {
    let title: String
    let value: String

    var body: some View {
        HStack {
            Text(title)
                .font(.body)
                .foregroundColor(.starWhite.opacity(0.8))

            Spacer()

            Text(value)
                .font(.body)
                .fontWeight(.medium)
                .foregroundColor(.starWhite)
        }
    }
}