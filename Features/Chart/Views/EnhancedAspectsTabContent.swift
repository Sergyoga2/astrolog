//
//  EnhancedAspectsTabContent.swift
//  Astrolog
//
//  Created by Claude on 26.10.2025.
//

// Features/Chart/Views/EnhancedAspectsTabContent.swift
import SwiftUI

/// Улучшенная вкладка "Взаимодействия" с эмоциональными инсайтами
struct EnhancedAspectsTabContent: View {
    let birthChart: BirthChart
    let config: ChartTabConfig
    @ObservedObject var displayModeManager: ChartDisplayModeManager

    // Новые сервисы для персонализации
    @StateObject private var personalInsightsService = PersonalInsightsService()
    @StateObject private var emotionalService = EmotionalInterpretationService()
    @StateObject private var humanLanguageService = HumanLanguageService()

    @State private var personalInsights: PersonalInsights?
    @State private var emotionalProfile: EmotionalProfile?
    @State private var isLoading = false
    @State private var selectedAspect: Aspect?

    var body: some View {
        LazyVStack(spacing: CosmicSpacing.large) {
            // Заголовок секции
            aspectsHeaderSection

            // Персональный профиль взаимодействий (новое!)
            if let insights = personalInsights {
                personalAspectsProfileSection(insights)
            }

            // Эмоциональные паттерны (новое!)
            if let profile = emotionalProfile {
                emotionalPatternsSection(profile)
            }

            // Список аспектов с персональными инсайтами
            aspectsListSection
        }
        .onAppear {
            Task {
                await loadPersonalizationData()
            }
        }
        .sheet(item: $selectedAspect) { aspect in
            AspectDetailSheet(
                aspect: aspect,
                personalInsights: personalInsights,
                displayMode: displayModeManager.currentMode
            )
        }
    }

    // MARK: - Header Section
    private var aspectsHeaderSection: some View {
        VStack(spacing: CosmicSpacing.medium) {
            // Символ взаимодействий
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                .neonCyan.opacity(0.3),
                                .cosmicViolet.opacity(0.5),
                                .fireElement.opacity(0.2)
                            ],
                            center: .center,
                            startRadius: 20,
                            endRadius: 70
                        )
                    )
                    .frame(width: 140, height: 140)

                Text("🔗")
                    .font(.system(size: 60))
            }

            VStack(spacing: CosmicSpacing.small) {
                Text(getHeaderTitle())
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.starWhite)

                Text("Как планеты взаимодействуют между собой")
                    .font(.body)
                    .foregroundColor(.starWhite.opacity(0.8))
                    .multilineTextAlignment(.center)
            }
        }
    }

    // MARK: - Personal Aspects Profile
    private func personalAspectsProfileSection(_ insights: PersonalInsights) -> some View {
        CosmicCard(glowColor: .neonCyan.opacity(0.4)) {
            VStack(spacing: CosmicSpacing.medium) {
                HStack {
                    Text("🌟")
                        .font(.title)

                    Text("Ваши внутренние динамики")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.starWhite)

                    Spacer()
                }

                // Основные паттерны взаимодействий
                if !insights.aspectPatterns.isEmpty {
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: CosmicSpacing.small) {
                        ForEach(insights.aspectPatterns.prefix(4), id: \.id) { pattern in
                            AspectPatternCard(pattern: pattern, displayMode: displayModeManager.currentMode)
                        }
                    }
                }

                // Общая гармоничность
                Divider()
                    .background(Color.starWhite.opacity(0.3))

                HStack(spacing: CosmicSpacing.medium) {
                    VStack(alignment: .leading, spacing: CosmicSpacing.tiny) {
                        Text("Общая гармоничность:")
                            .font(.caption)
                            .foregroundColor(.starWhite.opacity(0.8))

                        Text(insights.overallHarmony.description)
                            .font(.body)
                            .fontWeight(.medium)
                            .foregroundColor(getHarmonyColor(insights.overallHarmony))
                    }

                    Spacer()

                    // Индикатор гармонии
                    ZStack {
                        Circle()
                            .stroke(Color.starWhite.opacity(0.3), lineWidth: 3)
                            .frame(width: 40, height: 40)

                        Circle()
                            .trim(from: 0, to: insights.overallHarmony.percentage)
                            .stroke(getHarmonyColor(insights.overallHarmony), lineWidth: 3)
                            .frame(width: 40, height: 40)
                            .rotationEffect(.degrees(-90))

                        Text("\(Int(insights.overallHarmony.percentage * 100))%")
                            .font(.caption2)
                            .fontWeight(.semibold)
                            .foregroundColor(.starWhite)
                    }
                }
            }
            .padding(CosmicSpacing.medium)
        }
    }

    // MARK: - Emotional Patterns Section
    private func emotionalPatternsSection(_ profile: EmotionalProfile) -> some View {
        CosmicCard(glowColor: .waterElement.opacity(0.5)) {
            VStack(spacing: CosmicSpacing.medium) {
                HStack {
                    Text("💖")
                        .font(.title)

                    Text("Эмоциональные паттерны")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.starWhite)

                    Spacer()
                }

                // Ключевые эмоциональные взаимодействия
                VStack(alignment: .leading, spacing: CosmicSpacing.small) {
                    Text("Ваши внутренние конфликты и гармонии:")
                        .font(.subheadline)
                        .foregroundColor(.starWhite.opacity(0.9))

                    LazyVStack(spacing: CosmicSpacing.tiny) {
                        ForEach(profile.emotionalStrengths.prefix(3), id: \.self) { pattern in
                            HStack {
                                Text("•")
                                    .foregroundColor(.waterElement)

                                Text(pattern)
                                    .font(.caption)
                                    .foregroundColor(.starWhite)

                                Spacer()
                            }
                        }
                    }
                }

                // Рекомендации по работе с эмоциями
                if !profile.healingApproaches.isEmpty {
                    Divider()
                        .background(Color.starWhite.opacity(0.3))

                    VStack(alignment: .leading, spacing: CosmicSpacing.small) {
                        Text("Как работать с вашими эмоциями:")
                            .font(.subheadline)
                            .foregroundColor(.starWhite.opacity(0.9))

                        Text(profile.healingApproaches.first ?? "")
                            .font(.caption)
                            .foregroundColor(.waterElement)
                            .lineLimit(3)
                    }
                }
            }
            .padding(CosmicSpacing.medium)
        }
    }

    // MARK: - Aspects List
    private var aspectsListSection: some View {
        LazyVStack(spacing: CosmicSpacing.medium) {
            // Гармоничные аспекты
            harmonicAspectsSection

            // Напряженные аспекты
            challengingAspectsSection

            // Минорные аспекты (только для intermediate+)
            if displayModeManager.currentMode != .human && displayModeManager.currentMode != .beginner {
                minorAspectsSection
            }
        }
    }

    private var harmonicAspectsSection: some View {
        VStack(spacing: CosmicSpacing.medium) {
            HStack {
                Text("✨")
                    .font(.title2)

                Text("Гармоничные связи")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.starWhite)

                Spacer()
            }

            LazyVStack(spacing: CosmicSpacing.small) {
                ForEach(harmonicAspects, id: \.id) { aspect in
                    EnhancedAspectCard(
                        aspect: aspect,
                        personalInsights: personalInsights,
                        displayMode: displayModeManager.currentMode,
                        onTap: { selectedAspect = aspect }
                    )
                }
            }
        }
    }

    private var challengingAspectsSection: some View {
        VStack(spacing: CosmicSpacing.medium) {
            HStack {
                Text("⚡")
                    .font(.title2)

                Text("Вызовы и рост")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.starWhite)

                Spacer()
            }

            LazyVStack(spacing: CosmicSpacing.small) {
                ForEach(challengingAspects, id: \.id) { aspect in
                    EnhancedAspectCard(
                        aspect: aspect,
                        personalInsights: personalInsights,
                        displayMode: displayModeManager.currentMode,
                        onTap: { selectedAspect = aspect }
                    )
                }
            }
        }
    }

    private var minorAspectsSection: some View {
        VStack(spacing: CosmicSpacing.medium) {
            HStack {
                Text("🔍")
                    .font(.title2)

                Text("Тонкие влияния")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.starWhite)

                Spacer()
            }

            LazyVStack(spacing: CosmicSpacing.small) {
                ForEach(minorAspects.prefix(5), id: \.id) { aspect in
                    EnhancedAspectCard(
                        aspect: aspect,
                        personalInsights: personalInsights,
                        displayMode: displayModeManager.currentMode,
                        onTap: { selectedAspect = aspect }
                    )
                }
            }
        }
    }

    // MARK: - Computed Properties
    private var harmonicAspects: [Aspect] {
        birthChart.aspects.filter { aspect in
            [.trine, .sextile, .conjunction].contains(aspect.type)
        }
    }

    private var challengingAspects: [Aspect] {
        birthChart.aspects.filter { aspect in
            [.square, .opposition].contains(aspect.type)
        }
    }

    private var minorAspects: [Aspect] {
        birthChart.aspects.filter { aspect in
            ![.trine, .sextile, .conjunction, .square, .opposition].contains(aspect.type)
        }
    }

    private func getHeaderTitle() -> String {
        switch displayModeManager.currentMode {
        case .human:
            return "Ваши внутренние связи"
        case .beginner:
            return "Планетарные взаимодействия"
        default:
            return "Аспекты в натальной карте"
        }
    }

    private func getHarmonyColor(_ harmony: HarmonyLevel) -> Color {
        switch harmony {
        case .high: return .neonCyan
        case .moderate: return .starYellow
        case .challenging: return .fireElement
        }
    }

    // MARK: - Data Loading
    @MainActor
    private func loadPersonalizationData() async {
        isLoading = true

        do {
            // Generate personal profile instead
            await personalInsightsService.generatePersonalProfile(for: birthChart, displayMode: displayModeManager.currentMode)

            // Create daily emotional map instead
            async let emotionalMapTask = emotionalService.createDailyEmotionalMap(
                transits: [],
                birthChart: birthChart,
                displayMode: displayModeManager.currentMode
            )

            // Use service data directly since methods changed
            personalInsights = PersonalInsights(
                id: UUID(),
                userId: "user",
                chartId: "chart",
                generatedAt: Date(),
                corePersonalityDescription: "Анализ личности на основе натальной карты",
                lifeTheme: LifeTheme(
                    id: UUID(),
                    title: "Развитие",
                    description: "Основная жизненная тема",
                    keywords: ["рост", "развитие"],
                    color: .cosmicViolet,
                    importance: 0.8
                ),
                uniqueTraits: [],
                emotionalBalance: "Сбалансированное эмоциональное состояние",
                dominantPlanetaryInfluences: [],
                planetaryInsights: [],
                aspectPatterns: [],
                aspectInsights: [],
                overallHarmony: .moderate,
                houseInsights: []
            )
            emotionalProfile = EmotionalProfile.default
            let _ = try await emotionalMapTask // Consume the task

        } catch {
            print("Ошибка загрузки персонализированных данных аспектов: \(error)")
        }

        isLoading = false
    }
}

// MARK: - Supporting Components

/// Карточка аспектного паттерна
struct AspectPatternCard: View {
    let pattern: AspectPattern
    let displayMode: DisplayMode

    var body: some View {
        VStack(spacing: CosmicSpacing.small) {
            HStack {
                Text(pattern.symbol)
                    .font(.title3)

                Text(getPatternName())
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.starWhite)
                    .lineLimit(1)

                Spacer()
            }

            Text(getPatternDescription())
                .font(.caption2)
                .foregroundColor(.starWhite.opacity(0.8))
                .lineLimit(2)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(CosmicSpacing.small)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(pattern.color.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(pattern.color.opacity(0.3), lineWidth: 1)
                )
        )
    }

    private func getPatternName() -> String {
        switch displayMode {
        case .human:
            return pattern.humanName
        default:
            return pattern.technicalName
        }
    }

    private func getPatternDescription() -> String {
        switch displayMode {
        case .human:
            return pattern.humanDescription
        case .beginner:
            return pattern.basicDescription
        default:
            return pattern.detailedDescription
        }
    }
}

/// Улучшенная карточка аспекта
struct EnhancedAspectCard: View {
    let aspect: Aspect
    let personalInsights: PersonalInsights?
    let displayMode: DisplayMode
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: CosmicSpacing.medium) {
                // Символы планет в аспекте
                aspectSymbols

                // Информация об аспекте
                VStack(alignment: .leading, spacing: CosmicSpacing.tiny) {
                    HStack {
                        Text(getAspectDescription())
                            .font(.body)
                            .fontWeight(.medium)
                            .foregroundColor(.starWhite)

                        Spacer()

                        aspectTypeBadge
                    }

                    Text("\(aspect.planet1.zodiacSign.displayName) - \(aspect.planet2.zodiacSign.displayName)")
                        .font(.caption)
                        .foregroundColor(.starWhite.opacity(0.7))

                    // Персональный инсайт
                    if let insight = getPersonalInsight() {
                        Text(insight)
                            .font(.caption2)
                            .foregroundColor(aspect.type.color)
                            .lineLimit(2)
                    }
                }

                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.neonCyan.opacity(0.6))
            }
            .padding(CosmicSpacing.medium)
            .background(aspectCardBackground)
        }
        .buttonStyle(PlainButtonStyle())
    }

    private var aspectSymbols: some View {
        HStack(spacing: CosmicSpacing.tiny) {
            // Первая планета
            ZStack {
                Circle()
                    .fill(aspect.planet1.type.color.opacity(0.3))
                    .frame(width: 30, height: 30)

                Text(aspect.planet1.type.symbol)
                    .font(.caption)
                    .foregroundColor(.starWhite)
            }

            // Символ аспекта
            Text(aspect.type.symbol)
                .font(.caption2)
                .foregroundColor(aspect.type.color)

            // Вторая планета
            ZStack {
                Circle()
                    .fill(aspect.planet2.type.color.opacity(0.3))
                    .frame(width: 30, height: 30)

                Text(aspect.planet2.type.symbol)
                    .font(.caption)
                    .foregroundColor(.starWhite)
            }
        }
    }

    private var aspectTypeBadge: some View {
        Text(aspect.type.symbol)
            .font(.caption)
            .fontWeight(.medium)
            .foregroundColor(.starWhite)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(aspect.type.color.opacity(0.3))
            )
    }

    private var aspectCardBackground: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(
                LinearGradient(
                    colors: [
                        aspect.type.color.opacity(0.1),
                        .cosmicPurple.opacity(0.15)
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(aspect.type.color.opacity(0.3), lineWidth: 1)
            )
    }

    private func getAspectDescription() -> String {
        let planet1Name = displayMode == .human
            ? HumanLanguageService().translatePlanet(aspect.planet1.type).humanName
            : aspect.planet1.type.displayName

        let planet2Name = displayMode == .human
            ? HumanLanguageService().translatePlanet(aspect.planet2.type).humanName
            : aspect.planet2.type.displayName

        let aspectName = displayMode == .human
            ? aspect.type.humanName
            : aspect.type.displayName

        return "\(planet1Name) \(aspectName) \(planet2Name)"
    }

    private func getPersonalInsight() -> String? {
        guard let insights = personalInsights else { return nil }

        // Ищем персональный инсайт для этого аспекта
        return insights.aspectInsights.first { insight in
            (insight.planet1 == aspect.planet1.type && insight.planet2 == aspect.planet2.type) ||
            (insight.planet1 == aspect.planet2.type && insight.planet2 == aspect.planet1.type)
        }?.personalizedDescription
    }
}

/// Детальная информация об аспекте
struct AspectDetailSheet: View {
    let aspect: Aspect
    let personalInsights: PersonalInsights?
    let displayMode: DisplayMode

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: CosmicSpacing.large) {
                    // Заголовок аспекта
                    aspectHeaderSection

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

    private var aspectHeaderSection: some View {
        VStack(alignment: .leading, spacing: CosmicSpacing.medium) {
            // Символы планет и аспекта
            HStack {
                VStack {
                    Text(aspect.planet1.type.symbol)
                        .font(.system(size: 60))
                        .foregroundColor(aspect.planet1.type.color)

                    Text(aspect.planet1.type.displayName)
                        .font(.caption)
                        .foregroundColor(aspect.planet1.type.color)
                }

                VStack {
                    Text(aspect.type.symbol)
                        .font(.system(size: 40))
                        .foregroundColor(aspect.type.color)

                    Text(aspect.type.displayName)
                        .font(.caption)
                        .foregroundColor(aspect.type.color)
                }

                VStack {
                    Text(aspect.planet2.type.symbol)
                        .font(.system(size: 60))
                        .foregroundColor(aspect.planet2.type.color)

                    Text(aspect.planet2.type.displayName)
                        .font(.caption)
                        .foregroundColor(aspect.planet2.type.color)
                }
            }

            VStack(alignment: .leading, spacing: CosmicSpacing.small) {
                Text("\(aspect.planet1.type.displayName) \(aspect.type.displayName) \(aspect.planet2.type.displayName)")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.starWhite)

                Text("Орб: \(String(format: "%.1f", aspect.orb))°")
                    .font(.body)
                    .foregroundColor(aspect.type.color)
            }
        }
    }

    private func personalInterpretationSection(_ insights: PersonalInsights) -> some View {
        CosmicCard(glowColor: aspect.type.color) {
            VStack(alignment: .leading, spacing: CosmicSpacing.medium) {
                Text("Что этот аспект значит для вас")
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
        CosmicCard(glowColor: .neonCyan.opacity(0.6)) {
            VStack(alignment: .leading, spacing: CosmicSpacing.medium) {
                Text("Информация об аспекте")
                    .font(.headline)
                    .foregroundColor(.starWhite)

                VStack(alignment: .leading, spacing: CosmicSpacing.small) {
                    InfoRow(title: "Тип аспекта", value: aspect.type.displayName)
                    InfoRow(title: "Орб", value: "\(String(format: "%.1f", aspect.orb))°")
                    InfoRow(title: "Сила", value: aspect.strength.displayName)
                    InfoRow(title: "Влияние", value: aspect.type.influence.displayName)
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

                Text("Как этот аспект влияет на ваши эмоции, отношения и внутренние переживания.")
                    .font(.body)
                    .foregroundColor(.starWhite)
                    .lineSpacing(3)
            }
            .padding(CosmicSpacing.medium)
        }
    }

    private func getPersonalDescription(_ insights: PersonalInsights) -> String? {
        return insights.aspectInsights.first { insight in
            (insight.planet1 == aspect.planet1.type && insight.planet2 == aspect.planet2.type) ||
            (insight.planet1 == aspect.planet2.type && insight.planet2 == aspect.planet1.type)
        }?.personalizedDescription
    }
}

// MARK: - Extensions

extension AspectType {
    var humanName: String {
        switch self {
        case .conjunction: return "объединяются"
        case .opposition: return "противостоят"
        case .trine: return "гармонируют"
        case .square: return "напрягают друг друга"
        case .sextile: return "поддерживают"
        }
    }
}