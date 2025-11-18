//
//  EnhancedHousesTabContent.swift
//  Astrolog
//
//  Created by Claude on 26.10.2025.
//

// Features/Chart/Views/EnhancedHousesTabContent.swift
import SwiftUI

/// Улучшенная вкладка "Сферы жизни" с персонализацией
struct EnhancedHousesTabContent: View {
    let birthChart: BirthChart
    let config: ChartTabConfig
    @ObservedObject var displayModeManager: ChartDisplayModeManager

    // Новые сервисы для персонализации
    @StateObject private var personalInsightsService = PersonalInsightsService()
    @StateObject private var emotionalService = EmotionalInterpretationService()
    @StateObject private var humanLanguageService = HumanLanguageService()

    @State private var personalInsights: PersonalInsights?
    @State private var lifeAreasAnalysis: LifeAreasAnalysis?
    @State private var isLoading = false
    @State private var selectedHouse: House?

    var body: some View {
        LazyVStack(spacing: CosmicSpacing.large) {
            // Заголовок секции
            housesHeaderSection

            // Персональный анализ сфер жизни (новое!)
            if let analysis = lifeAreasAnalysis {
                personalLifeAreasSection(analysis)
            }

            // Список домов с персональными инсайтами
            housesListSection
        }
        .onAppear {
            Task {
                await loadPersonalizationData()
            }
        }
        .sheet(item: $selectedHouse) { house in
            HouseDetailSheet(
                house: house,
                personalInsights: personalInsights,
                displayMode: displayModeManager.currentMode
            )
        }
    }

    // MARK: - Header Section
    private var housesHeaderSection: some View {
        VStack(spacing: CosmicSpacing.medium) {
            // Символ сфер жизни
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color.earthElement.opacity(0.3),
                                .cosmicViolet.opacity(0.4),
                                .airElement.opacity(0.2)
                            ],
                            center: .center,
                            startRadius: 25,
                            endRadius: 80
                        )
                    )
                    .frame(width: 160, height: 160)

                Text("🏠")
                    .font(.system(size: 70))
            }

            VStack(spacing: CosmicSpacing.small) {
                Text(getHeaderTitle())
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.starWhite)

                Text("Основные области вашей жизни")
                    .font(.body)
                    .foregroundColor(.starWhite.opacity(0.8))
                    .multilineTextAlignment(.center)
            }
        }
    }

    // MARK: - Personal Life Areas Section
    private func personalLifeAreasSection(_ analysis: LifeAreasAnalysis) -> some View {
        CosmicCard(glowColor: Color.earthElement.opacity(0.4)) {
            VStack(spacing: CosmicSpacing.medium) {
                HStack {
                    Text("🌟")
                        .font(.title)

                    Text("Ваши жизненные приоритеты")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.starWhite)

                    Spacer()
                }

                // Самые акцентированные сферы
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: CosmicSpacing.small) {
                    ForEach(analysis.topPriorityAreas.prefix(4), id: \.id) { area in
                        LifeAreaPriorityCard(area: area, displayMode: displayModeManager.currentMode)
                    }
                }

                // Общий жизненный фокус
                if let focus = analysis.overallLifeFocus {
                    Divider()
                        .background(Color.starWhite.opacity(0.3))

                    VStack(alignment: .leading, spacing: CosmicSpacing.small) {
                        Text("Ваш главный жизненный фокус:")
                            .font(.subheadline)
                            .foregroundColor(.starWhite.opacity(0.9))

                        Text(focus.description)
                            .font(.body)
                            .fontWeight(.medium)
                            .foregroundColor(Color.earthElement)
                    }
                }
            }
            .padding(CosmicSpacing.medium)
        }
    }

    // MARK: - Houses List
    private var housesListSection: some View {
        LazyVStack(spacing: CosmicSpacing.medium) {
            // Личностные дома (1-3)
            personalityHousesSection

            // Материальные дома (2, 6, 10)
            if displayModeManager.currentMode != .human {
                materialHousesSection
            }

            // Отношения (5, 7, 11)
            relationshipHousesSection

            // Духовные дома (4, 8, 9, 12)
            if displayModeManager.currentMode == .intermediate {
                spiritualHousesSection
            }
        }
    }

    private var personalityHousesSection: some View {
        VStack(spacing: CosmicSpacing.medium) {
            HStack {
                Text("🎭")
                    .font(.title2)

                Text("Личность и самовыражение")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.starWhite)

                Spacer()
            }

            LazyVStack(spacing: CosmicSpacing.small) {
                ForEach([1, 3, 5], id: \.self) { houseNumber in
                    if let house = birthChart.houses.first(where: { $0.number == houseNumber }) {
                        EnhancedHouseCard(
                            house: house,
                            personalInsights: personalInsights,
                            displayMode: displayModeManager.currentMode,
                            onTap: { selectedHouse = house }
                        )
                    }
                }
            }
        }
    }

    private var materialHousesSection: some View {
        VStack(spacing: CosmicSpacing.medium) {
            HStack {
                Text("💰")
                    .font(.title2)

                Text("Материальный мир")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.starWhite)

                Spacer()
            }

            LazyVStack(spacing: CosmicSpacing.small) {
                ForEach([2, 6, 10], id: \.self) { houseNumber in
                    if let house = birthChart.houses.first(where: { $0.number == houseNumber }) {
                        EnhancedHouseCard(
                            house: house,
                            personalInsights: personalInsights,
                            displayMode: displayModeManager.currentMode,
                            onTap: { selectedHouse = house }
                        )
                    }
                }
            }
        }
    }

    private var relationshipHousesSection: some View {
        VStack(spacing: CosmicSpacing.medium) {
            HStack {
                Text("💖")
                    .font(.title2)

                Text("Отношения и общение")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.starWhite)

                Spacer()
            }

            LazyVStack(spacing: CosmicSpacing.small) {
                ForEach([7, 11], id: \.self) { houseNumber in
                    if let house = birthChart.houses.first(where: { $0.number == houseNumber }) {
                        EnhancedHouseCard(
                            house: house,
                            personalInsights: personalInsights,
                            displayMode: displayModeManager.currentMode,
                            onTap: { selectedHouse = house }
                        )
                    }
                }
            }
        }
    }

    private var spiritualHousesSection: some View {
        VStack(spacing: CosmicSpacing.medium) {
            HStack {
                Text("🔮")
                    .font(.title2)

                Text("Духовность и трансформация")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.starWhite)

                Spacer()
            }

            LazyVStack(spacing: CosmicSpacing.small) {
                ForEach([4, 8, 9, 12], id: \.self) { houseNumber in
                    if let house = birthChart.houses.first(where: { $0.number == houseNumber }) {
                        EnhancedHouseCard(
                            house: house,
                            personalInsights: personalInsights,
                            displayMode: displayModeManager.currentMode,
                            onTap: { selectedHouse = house }
                        )
                    }
                }
            }
        }
    }

    private func getHeaderTitle() -> String {
        switch displayModeManager.currentMode {
        case .human:
            return "Сферы вашей жизни"
        case .beginner:
            return "Дома в астрологии"
        default:
            return "Астрологические дома"
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

            // Создаем анализ сфер жизни
            lifeAreasAnalysis = await createLifeAreasAnalysis()

            // Convert PersonalInsight array to PersonalInsights struct
            personalInsights = PersonalInsights(
                id: UUID(),
                userId: "user",
                chartId: "chart",
                generatedAt: Date(),
                corePersonalityDescription: "Анализ домов в натальной карте",
                lifeTheme: LifeTheme(
                    id: UUID(),
                    title: "Сферы жизни",
                    description: "Основные жизненные области согласно домам",
                    keywords: ["дома", "сферы жизни", "активность"],
                    color: Color.earthElement,
                    importance: 0.8
                ),
                uniqueTraits: [],
                emotionalBalance: "Анализ эмоционального баланса через дома",
                dominantPlanetaryInfluences: [],
                planetaryInsights: personalInsightsService.personalInsights.compactMap { insight in
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
            print("Ошибка загрузки персонализированных данных домов: \(error)")
        }

        isLoading = false
    }

    private func createLifeAreasAnalysis() async -> LifeAreasAnalysis {
        // Анализируем акцентированные дома на основе планет
        let housesWithPlanets = birthChart.houses.filter { house in
            !house.planets.isEmpty
        }

        let priorityAreas = housesWithPlanets.map { house in
            LifeAreaPriority(
                id: UUID(),
                house: house,
                priority: calculateHousePriority(house),
                description: getHousePersonalDescription(house)
            )
        }.sorted { $0.priority > $1.priority }

        let overallFocus = determineOverallLifeFocus(from: priorityAreas)

        return LifeAreasAnalysis(
            topPriorityAreas: priorityAreas,
            overallLifeFocus: overallFocus,
            balanceScore: calculateLifeBalance(priorityAreas)
        )
    }

    private func calculateHousePriority(_ house: House) -> Double {
        // Учитываем количество и важность планет в доме
        let planetWeights: [PlanetType: Double] = [
            .sun: 1.0, .moon: 1.0, .ascendant: 1.0,
            .mercury: 0.7, .venus: 0.7, .mars: 0.7,
            .jupiter: 0.5, .saturn: 0.5
        ]

        return house.planets.reduce(0) { total, planet in
            total + (planetWeights[planet.type] ?? 0.3)
        }
    }

    private func getHousePersonalDescription(_ house: House) -> String {
        switch house.number {
        case 1: return "Самовыражение и личность"
        case 2: return "Материальные ценности и ресурсы"
        case 3: return "Общение и близкое окружение"
        case 4: return "Дом и семья"
        case 5: return "Творчество и романтика"
        case 6: return "Работа и здоровье"
        case 7: return "Партнерство и брак"
        case 8: return "Трансформация и общие ресурсы"
        case 9: return "Философия и дальние путешествия"
        case 10: return "Карьера и репутация"
        case 11: return "Дружба и мечты"
        case 12: return "Подсознание и духовность"
        default: return "Важная сфера жизни"
        }
    }

    private func determineOverallLifeFocus(from areas: [LifeAreaPriority]) -> LifeFocus? {
        guard let topArea = areas.first else { return nil }

        switch topArea.house.number {
        case 1, 5: return LifeFocus.selfExpression
        case 2, 6, 10: return LifeFocus.materialSuccess
        case 3, 7, 11: return LifeFocus.relationships
        case 4, 8, 9, 12: return LifeFocus.spirituality
        default: return LifeFocus.balanced
        }
    }

    private func calculateLifeBalance(_ areas: [LifeAreaPriority]) -> Double {
        // Простой расчет баланса между разными сферами
        let categories = [1, 2, 3, 4] // личность, материальное, отношения, духовность
        let categoryScores = categories.map { category in
            areas.filter { getCategoryForHouse($0.house.number) == category }
                  .reduce(0) { $0 + $1.priority }
        }

        let maxScore = categoryScores.max() ?? 0
        let minScore = categoryScores.min() ?? 0

        return maxScore > 0 ? (1.0 - (maxScore - minScore) / maxScore) : 1.0
    }

    private func getCategoryForHouse(_ houseNumber: Int) -> Int {
        switch houseNumber {
        case 1, 3, 5: return 1  // личность
        case 2, 6, 10: return 2 // материальное
        case 7, 11: return 3    // отношения
        case 4, 8, 9, 12: return 4 // духовность
        default: return 1
        }
    }
}

// MARK: - Supporting Models

struct LifeAreasAnalysis {
    let topPriorityAreas: [LifeAreaPriority]
    let overallLifeFocus: LifeFocus?
    let balanceScore: Double
}

struct LifeAreaPriority {
    let id: UUID
    let house: House
    let priority: Double
    let description: String
}

enum LifeFocus {
    case selfExpression
    case materialSuccess
    case relationships
    case spirituality
    case balanced

    var description: String {
        switch self {
        case .selfExpression: return "Творческое самовыражение и личностный рост"
        case .materialSuccess: return "Материальные достижения и карьера"
        case .relationships: return "Отношения и социальные связи"
        case .spirituality: return "Духовное развитие и внутренняя трансформация"
        case .balanced: return "Гармоничное развитие всех сфер жизни"
        }
    }
}

// MARK: - Supporting Components

/// Карточка приоритетной сферы жизни
struct LifeAreaPriorityCard: View {
    let area: LifeAreaPriority
    let displayMode: DisplayMode

    var body: some View {
        VStack(spacing: CosmicSpacing.small) {
            HStack {
                Text(getHouseEmoji())
                    .font(.title2)

                Text(getHouseName())
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.starWhite)
                    .lineLimit(1)

                Spacer()
            }

            Text(area.description)
                .font(.caption2)
                .foregroundColor(.starWhite.opacity(0.8))
                .lineLimit(2)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)

            // Индикатор приоритета
            HStack {
                Text("Важность:")
                    .font(.caption2)
                    .foregroundColor(.starWhite.opacity(0.6))

                ForEach(0..<5, id: \.self) { index in
                    Circle()
                        .fill(index < Int(area.priority * 2) ? Color.earthElement : Color.earthElement.opacity(0.2))
                        .frame(width: 4, height: 4)
                }

                Spacer()
            }
        }
        .padding(CosmicSpacing.small)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.earthElement.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.earthElement.opacity(0.3), lineWidth: 1)
                )
        )
    }

    private func getHouseEmoji() -> String {
        switch area.house.number {
        case 1: return "🎭"
        case 2: return "💰"
        case 3: return "💬"
        case 4: return "🏠"
        case 5: return "🎨"
        case 6: return "⚕️"
        case 7: return "💍"
        case 8: return "🔮"
        case 9: return "🌍"
        case 10: return "🏆"
        case 11: return "👥"
        case 12: return "🧘"
        default: return "⭐"
        }
    }

    private func getHouseName() -> String {
        switch displayMode {
        case .human:
            return getHumanHouseName()
        default:
            return "\(area.house.number) дом"
        }
    }

    private func getHumanHouseName() -> String {
        switch area.house.number {
        case 1: return "Я сам"
        case 2: return "Мои деньги"
        case 3: return "Общение"
        case 4: return "Семья"
        case 5: return "Творчество"
        case 6: return "Работа"
        case 7: return "Партнер"
        case 8: return "Тайны"
        case 9: return "Знания"
        case 10: return "Карьера"
        case 11: return "Друзья"
        case 12: return "Духовность"
        default: return "Жизнь"
        }
    }
}

/// Улучшенная карточка дома
struct EnhancedHouseCard: View {
    let house: House
    let personalInsights: PersonalInsights?
    let displayMode: DisplayMode
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: CosmicSpacing.medium) {
                // Номер дома и символ
                houseSymbol

                // Информация о доме
                VStack(alignment: .leading, spacing: CosmicSpacing.tiny) {
                    HStack {
                        Text(getHouseName())
                            .font(.body)
                            .fontWeight(.medium)
                            .foregroundColor(.starWhite)

                        Spacer()

                        signBadge
                    }

                    Text("Управитель: \(house.zodiacSign.displayName)")
                        .font(.caption)
                        .foregroundColor(house.zodiacSign.color)

                    // Планеты в доме
                    if !house.planets.isEmpty {
                        planetsInHouse
                    }

                    // Персональный инсайт
                    if let insight = getPersonalInsight() {
                        Text(insight)
                            .font(.caption2)
                            .foregroundColor(Color.earthElement)
                            .lineLimit(2)
                    }
                }

                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.neonCyan.opacity(0.6))
            }
            .padding(CosmicSpacing.medium)
            .background(houseCardBackground)
        }
        .buttonStyle(PlainButtonStyle())
    }

    private var houseSymbol: some View {
        ZStack {
            Circle()
                .fill(Color.earthElement.opacity(0.3))
                .frame(width: 40, height: 40)

            Text("\(house.number)")
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.starWhite)
        }
    }

    private var signBadge: some View {
        Text(house.zodiacSign.symbol)
            .font(.caption)
            .fontWeight(.medium)
            .foregroundColor(.starWhite)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(house.zodiacSign.color.opacity(0.3))
            )
    }

    private var planetsInHouse: some View {
        HStack(spacing: CosmicSpacing.tiny) {
            Text("Планеты:")
                .font(.caption2)
                .foregroundColor(.starWhite.opacity(0.7))

            ForEach(house.planets.prefix(3), id: \.id) { planet in
                Text(planet.type.symbol)
                    .font(.caption2)
                    .foregroundColor(planet.type.color)
            }

            if house.planets.count > 3 {
                Text("+\(house.planets.count - 3)")
                    .font(.caption2)
                    .foregroundColor(.starWhite.opacity(0.7))
            }

            Spacer()
        }
    }

    private var houseCardBackground: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(
                LinearGradient(
                    colors: [
                        house.zodiacSign.elementColor.opacity(0.1),
                        .cosmicPurple.opacity(0.15),
                        Color.earthElement.opacity(0.05)
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.earthElement.opacity(0.3), lineWidth: 1)
            )
    }

    private func getHouseName() -> String {
        switch displayMode {
        case .human:
            return getHumanHouseName()
        case .beginner:
            return "\(house.number) дом - \(getBasicHouseDescription())"
        default:
            return "\(house.number) дом"
        }
    }

    private func getHumanHouseName() -> String {
        switch house.number {
        case 1: return "Ваша личность"
        case 2: return "Ваши ресурсы"
        case 3: return "Ваше общение"
        case 4: return "Ваш дом"
        case 5: return "Ваше творчество"
        case 6: return "Ваша работа"
        case 7: return "Ваши отношения"
        case 8: return "Ваши трансформации"
        case 9: return "Ваши убеждения"
        case 10: return "Ваша карьера"
        case 11: return "Ваши мечты"
        case 12: return "Ваша духовность"
        default: return "Сфера жизни"
        }
    }

    private func getBasicHouseDescription() -> String {
        switch house.number {
        case 1: return "Личность"
        case 2: return "Деньги"
        case 3: return "Общение"
        case 4: return "Семья"
        case 5: return "Творчество"
        case 6: return "Здоровье"
        case 7: return "Партнерство"
        case 8: return "Трансформация"
        case 9: return "Философия"
        case 10: return "Карьера"
        case 11: return "Дружба"
        case 12: return "Подсознание"
        default: return "Неизвестно"
        }
    }

    private func getPersonalInsight() -> String? {
        guard let insights = personalInsights else { return nil }

        // Ищем персональный инсайт для этого дома
        return insights.houseInsights.first { $0.house == house.number }?.personalizedDescription
    }
}

/// Детальная информация о доме
struct HouseDetailSheet: View {
    let house: House
    let personalInsights: PersonalInsights?
    let displayMode: DisplayMode

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: CosmicSpacing.large) {
                    // Заголовок дома
                    houseHeaderSection

                    // Персональная интерпретация
                    if let insights = personalInsights {
                        personalInterpretationSection(insights)
                    }

                    // Планеты в доме
                    if !house.planets.isEmpty {
                        planetsInHouseSection
                    }

                    // Основная информация
                    basicInformationSection

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

    private var houseHeaderSection: some View {
        VStack(alignment: .leading, spacing: CosmicSpacing.medium) {
            HStack {
                ZStack {
                    Circle()
                        .fill(Color.earthElement.opacity(0.3))
                        .frame(width: 80, height: 80)

                    Text("\(house.number)")
                        .font(.system(size: 40))
                        .fontWeight(.bold)
                        .foregroundColor(.starWhite)
                }

                Spacer()

                VStack(alignment: .trailing) {
                    Text(house.zodiacSign.symbol)
                        .font(.system(size: 50))
                        .foregroundColor(house.zodiacSign.color)

                    Text(house.zodiacSign.displayName)
                        .font(.caption)
                        .foregroundColor(house.zodiacSign.color)
                }
            }

            VStack(alignment: .leading, spacing: CosmicSpacing.small) {
                Text("\(house.number) дом")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.starWhite)

                Text("Управитель: \(house.zodiacSign.displayName)")
                    .font(.title2)
                    .foregroundColor(house.zodiacSign.color)
            }
        }
    }

    private func personalInterpretationSection(_ insights: PersonalInsights) -> some View {
        CosmicCard(glowColor: Color.earthElement) {
            VStack(alignment: .leading, spacing: CosmicSpacing.medium) {
                Text("Что этот дом значит для вас")
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

    private var planetsInHouseSection: some View {
        CosmicCard(glowColor: .neonCyan.opacity(0.6)) {
            VStack(alignment: .leading, spacing: CosmicSpacing.medium) {
                Text("Планеты в доме")
                    .font(.headline)
                    .foregroundColor(.starWhite)

                LazyVStack(spacing: CosmicSpacing.small) {
                    ForEach(house.planets, id: \.id) { planet in
                        HStack {
                            Text(planet.type.symbol)
                                .font(.title3)
                                .foregroundColor(planet.type.color)

                            VStack(alignment: .leading) {
                                Text(planet.type.displayName)
                                    .font(.body)
                                    .fontWeight(.medium)
                                    .foregroundColor(.starWhite)

                                Text("в \(planet.zodiacSign.displayName)")
                                    .font(.caption)
                                    .foregroundColor(planet.zodiacSign.color)
                            }

                            Spacer()
                        }
                    }
                }
            }
            .padding(CosmicSpacing.medium)
        }
    }

    private var basicInformationSection: some View {
        CosmicCard(glowColor: house.zodiacSign.color) {
            VStack(alignment: .leading, spacing: CosmicSpacing.medium) {
                Text("Информация о доме")
                    .font(.headline)
                    .foregroundColor(.starWhite)

                VStack(alignment: .leading, spacing: CosmicSpacing.small) {
                    InfoRow(title: "Номер дома", value: "\(house.number)")
                    InfoRow(title: "Знак на куспиде", value: house.zodiacSign.displayName)
                    InfoRow(title: "Элемент", value: house.zodiacSign.element.displayName)
                    InfoRow(title: "Качество", value: house.zodiacSign.modality.displayName)
                    InfoRow(title: "Планет в доме", value: "\(house.planets.count)")
                }
            }
            .padding(CosmicSpacing.medium)
        }
    }

    private func getPersonalDescription(_ insights: PersonalInsights) -> String? {
        return insights.houseInsights.first { $0.house == house.number }?.personalizedDescription
    }
}