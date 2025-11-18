//
//  ChartTabBar.swift
//  Astrolog
//
//  Created by Claude on 21.10.2025.
//

// Features/Chart/Components/ChartTabBar.swift
import SwiftUI

/// Панель вкладок для навигации по разделам карты
struct ChartTabBar: View {
    @ObservedObject var tabState: ChartTabState
    let birthChart: BirthChart
    let displayMode: DisplayMode

    @Namespace private var tabIndicator
    @State private var indicatorOffset: CGFloat = 0

    var body: some View {
        VStack(spacing: 0) {
            // Основные вкладки
            tabButtons

            // Индикатор выбранной вкладки
            tabIndicatorView
        }
        .padding(.horizontal, CosmicSpacing.medium)
        .padding(.vertical, CosmicSpacing.small)
        .background(tabBarBackground)
        .onAppear {
            setupTabIndicator()
        }
    }

    // MARK: - Tab Buttons
    private var tabButtons: some View {
        HStack(spacing: 0) {
            ForEach(tabState.availableTabs) { tab in
                tabButton(for: tab)
                    .frame(maxWidth: .infinity)
            }
        }
    }

    private func tabButton(for tab: ChartTab) -> some View {
        Button(action: {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                tabState.selectTab(tab)
            }
        }) {
            VStack(spacing: CosmicSpacing.tiny) {
                // Иконка с бейджем
                ZStack {
                    tabIcon(for: tab)

                    // Бейдж с количеством элементов
                    if tab.shouldShowBadge(for: displayMode),
                       let badgeCount = tab.getBadgeCount(for: birthChart, displayMode: displayMode),
                       badgeCount > 0 {
                        badge(count: badgeCount)
                    }
                }

                // Название вкладки
                Text(tab.rawValue)
                    .font(.caption)
                    .fontWeight(tabState.selectedTab == tab ? .semibold : .medium)
                    .foregroundColor(tabColor(for: tab))
                    .lineLimit(1)
            }
            .padding(.horizontal, CosmicSpacing.small)
            .padding(.vertical, CosmicSpacing.small)
            .scaleEffect(tabState.selectedTab == tab ? 1.05 : 1.0)
            .opacity(tabState.selectedTab == tab ? 1.0 : 0.7)
        }
        .buttonStyle(PlainButtonStyle())
        .matchedGeometryEffect(
            id: tab.id,
            in: tabIndicator,
            properties: .frame,
            isSource: tabState.selectedTab == tab
        )
    }

    private func tabIcon(for tab: ChartTab) -> some View {
        ZStack {
            // Фоновый круг для активной вкладки
            if tabState.selectedTab == tab {
                Circle()
                    .fill(tab.color.opacity(0.2))
                    .frame(width: 32, height: 32)
                    .overlay(
                        Circle()
                            .stroke(tab.color.opacity(0.5), lineWidth: 1)
                    )
                    .shadow(
                        color: tab.color.opacity(0.3),
                        radius: 4, x: 0, y: 2
                    )
            }

            // Иконка
            Image(systemName: tabState.selectedTab == tab ? tab.selectedIcon : tab.icon)
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(tabColor(for: tab))
                .animation(.easeInOut(duration: 0.2), value: tabState.selectedTab)
        }
    }

    private func badge(count: Int) -> some View {
        Text("\(count)")
            .font(.caption2)
            .fontWeight(.bold)
            .foregroundColor(.starWhite)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(
                Capsule()
                    .fill(Color.neonPink)
                    .shadow(color: .neonPink.opacity(0.5), radius: 2)
            )
            .offset(x: 12, y: -8)
            .scaleEffect(0.9)
    }

    private func tabColor(for tab: ChartTab) -> Color {
        if tabState.selectedTab == tab {
            return tab.color
        } else {
            return .starWhite.opacity(0.7)
        }
    }

    // MARK: - Tab Indicator
    private var tabIndicatorView: some View {
        HStack {
            ForEach(tabState.availableTabs) { tab in
                Rectangle()
                    .fill(tabState.selectedTab == tab ? tab.color : Color.clear)
                    .frame(height: 2)
                    .animation(.spring(response: 0.5, dampingFraction: 0.8), value: tabState.selectedTab)
            }
        }
        .padding(.top, CosmicSpacing.tiny)
    }

    // MARK: - Background
    private var tabBarBackground: some View {
        Rectangle()
            .fill(
                LinearGradient(
                    colors: [
                        Color.cosmicPurple.opacity(0.3),
                        Color.cosmicDarkPurple.opacity(0.5)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .background(.ultraThinMaterial)
            .overlay(alignment: .top) {
                Color.starWhite.opacity(0.2)
                    .frame(height: 1)
            }
    }

    // MARK: - Helper Methods
    private func setupTabIndicator() {
        // Настройка индикатора при первом появлении
    }
}

/// Контейнер для содержимого вкладок
struct ChartContentView: View {
    @ObservedObject var tabState: ChartTabState
    let birthChart: BirthChart
    @ObservedObject var displayModeManager: ChartDisplayModeManager

    @EnvironmentObject var tooltipService: TooltipService
    @EnvironmentObject var interpretationEngine: InterpretationEngine

    var body: some View {
        TabView(selection: $tabState.selectedTab) {
            ForEach(tabState.availableTabs) { tab in
                tabContent(for: tab)
                    .tag(tab)
                    .transition(.asymmetric(
                        insertion: .opacity.combined(with: .scale(scale: 0.95)),
                        removal: .opacity.combined(with: .scale(scale: 1.05))
                    ))
            }
        }
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
        .animation(.easeInOut(duration: 0.3), value: tabState.selectedTab)
    }

    // MARK: - Tab Content
    @ViewBuilder
    private func tabContent(for tab: ChartTab) -> some View {
        let config = ChartTabConfig(
            tab: tab,
            displayMode: displayModeManager.currentMode,
            birthChart: birthChart
        )

        ScrollView {
            LazyVStack(spacing: config.contentSize.spacing) {
                switch tab {
                case .today:
                    TodayTabView(
                        birthChart: birthChart,
                        displayModeManager: displayModeManager
                    )

                case .overview:
                    EssenceTabView(
                        birthChart: birthChart,
                        displayModeManager: displayModeManager
                    )

                case .planets:
                    EnhancedPlanetsTabContent(
                        birthChart: birthChart,
                        config: config,
                        displayModeManager: displayModeManager
                    )

                case .houses:
                    EnhancedHousesTabContent(
                        birthChart: birthChart,
                        config: config,
                        displayModeManager: displayModeManager
                    )

                case .aspects:
                    EnhancedAspectsTabContent(
                        birthChart: birthChart,
                        config: config,
                        displayModeManager: displayModeManager
                    )

                case .education:
                    EnhancedEducationTabContent(
                        config: config,
                        displayModeManager: displayModeManager
                    )
                }
            }
            .padding(.horizontal, CosmicSpacing.medium)
            .padding(.vertical, CosmicSpacing.small)
        }
        .refreshable {
            // Возможность обновления контента
            await refreshContent(for: tab)
        }
    }

    private func refreshContent(for tab: ChartTab) async {
        // Имитация обновления данных
        try? await Task.sleep(nanoseconds: 1_000_000_000)
    }
}

// MARK: - Tab Content Views

/// Содержимое вкладки "Обзор"
struct OverviewTabContent: View {
    let birthChart: BirthChart
    let config: ChartTabConfig
    @ObservedObject var displayModeManager: ChartDisplayModeManager

    var body: some View {
        VStack(spacing: config.contentSize.spacing) {
            // Заголовок секции
            sectionHeader("Ключевые элементы", icon: "star.fill")

            // Основная троица (Солнце, Луна, Асцендент)
            bigThreeSection

            if config.showDetailedInfo {
                // Самые важные аспекты
                significantAspectsSection

                // Доминирующие элементы
                if displayModeManager.currentMode == .intermediate {
                    dominantElementsSection
                }
            }
        }
    }

    private var bigThreeSection: some View {
        VStack(spacing: CosmicSpacing.medium) {
            ForEach([
                (birthChart.planets.first { $0.type == .sun }, "Солнце", "Личность"),
                (birthChart.planets.first { $0.type == .moon }, "Луна", "Эмоции"),
                (birthChart.planets.first { $0.type == .ascendant }, "Асцендент", "Внешность")
            ], id: \.0?.id) { planetInfo in
                if let planet = planetInfo.0 {
                    OverviewPlanetCard(
                        planet: planet,
                        title: planetInfo.1,
                        subtitle: planetInfo.2,
                        displayMode: displayModeManager.currentMode
                    )
                }
            }
        }
    }

    private var significantAspectsSection: some View {
        VStack(alignment: .leading, spacing: CosmicSpacing.medium) {
            sectionHeader("Важные аспекты", icon: "arrow.triangle.2.circlepath")

            let significantAspects = displayModeManager.getSignificantAspects(from: birthChart)
                .prefix(config.maxElements / 2)

            ForEach(Array(significantAspects), id: \.id) { aspect in
                OverviewAspectCard(
                    aspect: aspect,
                    displayMode: displayModeManager.currentMode
                )
            }
        }
    }

    private var dominantElementsSection: some View {
        VStack(alignment: .leading, spacing: CosmicSpacing.medium) {
            sectionHeader("Доминирующие элементы", icon: "flame.fill")

            DominantElementsView(
                birthChart: birthChart,
                displayMode: displayModeManager.currentMode
            )
        }
    }

    private func sectionHeader(_ title: String, icon: String) -> some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.neonCyan)
                .font(.headline)

            Text(title)
                .font(CosmicTypography.headline)
                .fontWeight(.semibold)
                .foregroundColor(.starWhite)

            Spacer()
        }
        .padding(.horizontal, CosmicSpacing.small)
    }
}

/// Содержимое вкладки "Планеты"
struct PlanetsTabContent: View {
    let birthChart: BirthChart
    let config: ChartTabConfig
    @ObservedObject var displayModeManager: ChartDisplayModeManager

    var body: some View {
        VStack(spacing: config.contentSize.spacing) {
            let priorityPlanets = displayModeManager.getPriorityPlanets(from: birthChart)
                .prefix(config.maxElements)

            ForEach(Array(priorityPlanets), id: \.id) { planet in
                PlanetCard(
                    planet: planet,
                    interpretation: getInterpretation(for: planet),
                    displayMode: displayModeManager.currentMode,
                    isHighlighted: displayModeManager.isElementHighlighted(.planet(planet))
                )
            }

            if config.showAdvancedControls {
                advancedPlanetControls
            }
        }
    }

    private var advancedPlanetControls: some View {
        VStack(spacing: CosmicSpacing.small) {
            Text("Дополнительные настройки")
                .font(.caption)
                .foregroundColor(.starWhite.opacity(0.7))

            // Здесь могут быть фильтры, сортировка и т.д.
        }
        .padding(CosmicSpacing.medium)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.cosmicPurple.opacity(0.1))
        )
    }

    private func getInterpretation(for planet: Planet) -> Interpretation? {
        // Заглушка для получения интерпретации
        return Interpretation.brief(
            title: "\(planet.type.displayName) в \(planet.zodiacSign.displayName)",
            emoji: "\(planet.type.symbol)\(planet.zodiacSign.symbol)",
            summary: "Интерпретация для \(planet.type.displayName) в \(planet.zodiacSign.displayName)",
            elementType: .planetInSign,
            keywords: ["влияние", "энергия"]
        )
    }
}

/// Содержимое вкладки "Дома"
struct HousesTabContent: View {
    let birthChart: BirthChart
    let config: ChartTabConfig
    @ObservedObject var displayModeManager: ChartDisplayModeManager

    var body: some View {
        VStack(spacing: config.contentSize.spacing) {
            let relevantHouses = displayModeManager.getRelevantHouses(from: birthChart)

            ForEach(relevantHouses, id: \.id) { house in
                HouseCard(
                    house: house,
                    displayMode: displayModeManager.currentMode
                )
            }
        }
    }
}

/// Содержимое вкладки "Аспекты"
struct AspectsTabContent: View {
    let birthChart: BirthChart
    let config: ChartTabConfig
    @ObservedObject var displayModeManager: ChartDisplayModeManager

    var body: some View {
        VStack(spacing: config.contentSize.spacing) {
            let significantAspects = displayModeManager.getSignificantAspects(from: birthChart)
                .prefix(config.maxElements)

            ForEach(Array(significantAspects), id: \.id) { aspect in
                AspectCard(
                    aspect: aspect,
                    displayMode: displayModeManager.currentMode
                )
            }
        }
    }
}

// MARK: - Supporting Card Views (Заглушки для будущей реализации)

struct OverviewPlanetCard: View {
    let planet: Planet
    let title: String
    let subtitle: String
    let displayMode: DisplayMode

    var body: some View {
        HStack(spacing: CosmicSpacing.medium) {
            Text(planet.type.symbol)
                .font(.title2)
                .foregroundColor(planet.type.color)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.starWhite)

                Text("в \(planet.zodiacSign.displayName)")
                    .font(.caption)
                    .foregroundColor(planet.zodiacSign.color)

                Text(subtitle)
                    .font(.caption2)
                    .foregroundColor(.starWhite.opacity(0.7))
            }

            Spacer()
        }
        .padding(CosmicSpacing.medium)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.cosmicPurple.opacity(0.2))
        )
    }
}

struct OverviewAspectCard: View {
    let aspect: Aspect
    let displayMode: DisplayMode

    var body: some View {
        HStack(spacing: CosmicSpacing.medium) {
            Text(aspect.type.symbol)
                .font(.title2)
                .foregroundColor(aspect.type.color)

            VStack(alignment: .leading, spacing: 2) {
                Text("\(aspect.planet1.type.displayName) \(aspect.type.rawValue) \(aspect.planet2.type.displayName)")
                    .font(.body)
                    .foregroundColor(.starWhite)

                if displayMode != .beginner {
                    Text("Орб: \(String(format: "%.1f", aspect.orb))°")
                        .font(.caption)
                        .foregroundColor(.starWhite.opacity(0.7))
                }
            }

            Spacer()
        }
        .padding(CosmicSpacing.medium)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(aspect.type.color.opacity(0.1))
        )
    }
}

struct HouseCard: View {
    let house: House
    let displayMode: DisplayMode

    var body: some View {
        Text("Дом \(house.number) - заглушка")
            .padding()
            .background(Color.cosmicBlue.opacity(0.2))
            .cornerRadius(8)
    }
}

struct AspectCard: View {
    let aspect: Aspect
    let displayMode: DisplayMode

    var body: some View {
        Text("Аспект \(aspect.type.rawValue) - заглушка")
            .padding()
            .background(aspect.type.color.opacity(0.2))
            .cornerRadius(8)
    }
}

struct DominantElementsView: View {
    let birthChart: BirthChart
    let displayMode: DisplayMode

    var body: some View {
        Text("Доминирующие элементы - заглушка")
            .padding()
            .background(Color.starYellow.opacity(0.2))
            .cornerRadius(8)
    }
}

/// Содержимое вкладки "Обучение"
struct EducationTabContent: View {
    let config: ChartTabConfig
    @ObservedObject var displayModeManager: ChartDisplayModeManager
    @StateObject private var glossaryService = AstrologyGlossaryService()
    @State private var showFullGlossary = false
    @State private var showAllLessons = false

    var body: some View {
        VStack(spacing: config.contentSize.spacing) {
            // Заголовок секции
            educationHeader

            // Быстрый доступ к глоссарию
            quickGlossaryAccess

            // Поиск в глоссарии
            glossarySearchSection

            // Категории терминов
            glossaryCategoriesSection

            // Избранные термины
            if !glossaryService.getFavoriteTerms().isEmpty {
                favoriteTermsSection
            }

            // Предложения для изучения
            suggestedLearningSection

            // Мини-уроки
            miniLessonsSection
        }
        .sheet(isPresented: $showFullGlossary) {
            GlossaryView()
        }
        .sheet(isPresented: $showAllLessons) {
            MiniLessonListView(displayMode: displayModeManager.currentMode)
        }
    }

    private var educationHeader: some View {
        HStack {
            Image(systemName: "graduationcap.fill")
                .foregroundColor(.neonPink)
                .font(.title2)

            Text("Изучение астрологии")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.starWhite)

            Spacer()
        }
        .padding(.horizontal, CosmicSpacing.medium)
    }

    private var quickGlossaryAccess: some View {
        CosmicCard(glowColor: .neonPink) {
            VStack(spacing: CosmicSpacing.medium) {
                HStack {
                    Image(systemName: "book.fill")
                        .foregroundColor(.neonPink)
                        .font(.title3)

                    Text("Глоссарий терминов")
                        .font(CosmicTypography.headline)
                        .foregroundColor(.starWhite)

                    Spacer()

                    Text("\(glossaryService.allTerms.count)")
                        .font(.caption2)
                        .fontWeight(.bold)
                        .foregroundColor(.neonPink)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            Capsule()
                                .fill(Color.neonPink.opacity(0.3))
                        )
                }

                Text("Изучите значения астрологических терминов с примерами и объяснениями")
                    .font(CosmicTypography.body)
                    .foregroundColor(.starWhite.opacity(0.8))
                    .multilineTextAlignment(.leading)

                CosmicButton(
                    title: "Открыть полный глоссарий",
                    icon: "arrow.right.circle",
                    color: .neonPink
                ) {
                    // Показываем полный глоссарий
                    showFullGlossary = true
                }
            }
        }
    }

    private var glossarySearchSection: some View {
        VStack(spacing: CosmicSpacing.medium) {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.neonCyan)

                Text("Поиск термина")
                    .font(CosmicTypography.headline)
                    .foregroundColor(.starWhite)

                Spacer()
            }

            // Поисковая строка - изолирована от навигации
            SearchFieldIsolated(searchText: $glossaryService.searchQuery)

            // Результаты поиска (первые 3)
            if !glossaryService.searchQuery.isEmpty && !glossaryService.filteredTerms.isEmpty {
                VStack(spacing: CosmicSpacing.small) {
                    ForEach(glossaryService.filteredTerms.prefix(3)) { term in
                        QuickTermCard(term: term)
                    }

                    if glossaryService.filteredTerms.count > 3 {
                        Text("+ еще \(glossaryService.filteredTerms.count - 3) терминов")
                            .font(.caption)
                            .foregroundColor(.starWhite.opacity(0.7))
                    }
                }
            }
        }
        .padding(.horizontal, CosmicSpacing.medium)
    }

    private var glossaryCategoriesSection: some View {
        VStack(alignment: .leading, spacing: CosmicSpacing.medium) {
            HStack {
                Image(systemName: "square.grid.3x3")
                    .foregroundColor(.cosmicViolet)

                Text("Категории")
                    .font(CosmicTypography.headline)
                    .foregroundColor(.starWhite)

                Spacer()
            }
            .padding(.horizontal, CosmicSpacing.medium)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: CosmicSpacing.small) {
                    ForEach(GlossaryCategory.allCases, id: \.self) { category in
                        CategoryQuickCard(
                            category: category,
                            termCount: glossaryService.allTerms.filter { $0.category == category }.count
                        )
                    }
                }
                .padding(.horizontal, CosmicSpacing.medium)
            }
        }
    }

    private var favoriteTermsSection: some View {
        VStack(alignment: .leading, spacing: CosmicSpacing.medium) {
            HStack {
                Image(systemName: "heart.fill")
                    .foregroundColor(.neonPink)

                Text("Избранные термины")
                    .font(CosmicTypography.headline)
                    .foregroundColor(.starWhite)

                Spacer()
            }
            .padding(.horizontal, CosmicSpacing.medium)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: CosmicSpacing.small) {
                    ForEach(glossaryService.getFavoriteTerms().prefix(5)) { term in
                        FavoriteTermCard(term: term)
                    }
                }
                .padding(.horizontal, CosmicSpacing.medium)
            }
        }
    }

    private var suggestedLearningSection: some View {
        VStack(alignment: .leading, spacing: CosmicSpacing.medium) {
            HStack {
                Image(systemName: "lightbulb.fill")
                    .foregroundColor(.starYellow)

                Text("Рекомендуем изучить")
                    .font(CosmicTypography.headline)
                    .foregroundColor(.starWhite)

                Spacer()
            }
            .padding(.horizontal, CosmicSpacing.medium)

            VStack(spacing: CosmicSpacing.small) {
                let suggestedTerms = getSuggestedTerms()

                ForEach(suggestedTerms) { term in
                    SuggestedTermCard(term: term, displayMode: displayModeManager.currentMode)
                }
            }
        }
    }

    private var miniLessonsSection: some View {
        VStack(alignment: .leading, spacing: CosmicSpacing.medium) {
            HStack {
                Image(systemName: "graduationcap.fill")
                    .foregroundColor(.cosmicViolet)

                Text("Мини-уроки")
                    .font(CosmicTypography.headline)
                    .foregroundColor(.starWhite)

                Spacer()

                Button(action: {
                    showAllLessons = true
                }) {
                    HStack(spacing: 4) {
                        Text("Все уроки")
                            .font(.caption)
                        Image(systemName: "arrow.right")
                            .font(.caption)
                    }
                    .foregroundColor(.cosmicViolet)
                }
            }
            .padding(.horizontal, CosmicSpacing.medium)

            CosmicCard(glowColor: .cosmicViolet) {
                VStack(spacing: CosmicSpacing.medium) {
                    HStack {
                        Image(systemName: "book.fill")
                            .foregroundColor(.cosmicViolet)
                            .font(.title3)

                        Text("Изучайте астрологию пошагово")
                            .font(CosmicTypography.headline)
                            .foregroundColor(.starWhite)

                        Spacer()
                    }

                    Text("Структурированные уроки помогут вам освоить основы астрологии от простого к сложному")
                        .font(CosmicTypography.body)
                        .foregroundColor(.starWhite.opacity(0.8))
                        .multilineTextAlignment(.leading)

                    HStack(spacing: CosmicSpacing.medium) {
                        LessonFeatureItem(
                            icon: "clock.fill",
                            text: "3-7 минут",
                            color: .starYellow
                        )

                        LessonFeatureItem(
                            icon: "questionmark.circle.fill",
                            text: "С квизами",
                            color: .neonPink
                        )

                        LessonFeatureItem(
                            icon: "star.fill",
                            text: "Примеры",
                            color: .neonCyan
                        )
                    }

                    CosmicButton(
                        title: "Начать обучение",
                        icon: "play.circle.fill",
                        color: .cosmicViolet
                    ) {
                        showAllLessons = true
                    }
                }
            }
        }
    }

    private func getSuggestedTerms() -> [GlossaryTerm] {
        // Возвращаем термины, подходящие для текущего уровня пользователя
        return glossaryService.allTerms
            .filter { $0.level == displayModeManager.currentMode }
            .shuffled()
            .prefix(3)
            .map { $0 }
    }
}

struct LessonFeatureItem: View {
    let icon: String
    let text: String
    let color: Color

    var body: some View {
        HStack(spacing: CosmicSpacing.tiny) {
            Image(systemName: icon)
                .font(.caption2)
                .foregroundColor(color)

            Text(text)
                .font(.caption)
                .foregroundColor(.starWhite.opacity(0.8))
        }
        .padding(.horizontal, CosmicSpacing.small)
        .padding(.vertical, 4)
        .background(
            RoundedRectangle(cornerRadius: 6)
                .fill(color.opacity(0.1))
        )
    }
}

// MARK: - Supporting Education Views

struct QuickTermCard: View {
    let term: GlossaryTerm

    var body: some View {
        Button(action: {
            // Здесь можно показать подробную информацию о термине
            print("Нажат термин: \(term.term)")
        }) {
            HStack(spacing: CosmicSpacing.small) {
                Image(systemName: term.category.icon)
                    .foregroundColor(term.category.color)
                    .frame(width: 20)

                VStack(alignment: .leading, spacing: 2) {
                    Text(term.term)
                        .font(CosmicTypography.body)
                        .foregroundColor(.starWhite)

                    Text(term.definition)
                        .font(.caption)
                        .foregroundColor(.starWhite.opacity(0.7))
                        .lineLimit(1)
                }

                Spacer()

                Image(systemName: "arrow.right")
                    .font(.caption)
                    .foregroundColor(.starWhite.opacity(0.5))
            }
            .padding(.horizontal, CosmicSpacing.medium)
            .padding(.vertical, CosmicSpacing.small)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(.ultraThinMaterial)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct CategoryQuickCard: View {
    let category: GlossaryCategory
    let termCount: Int

    var body: some View {
        Button(action: {
            // Здесь можно показать термины из категории
            print("Нажата категория: \(category.rawValue)")
        }) {
            VStack(spacing: CosmicSpacing.small) {
                Image(systemName: category.icon)
                    .font(.title2)
                    .foregroundColor(category.color)
                    .frame(width: 32, height: 32)

                Text(category.rawValue)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.starWhite)
                    .multilineTextAlignment(.center)

                Text("\(termCount)")
                    .font(.caption2)
                    .foregroundColor(category.color)
            }
            .padding(CosmicSpacing.small)
            .frame(width: 80, height: 80)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(category.color.opacity(0.2))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(category.color.opacity(0.5), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct FavoriteTermCard: View {
    let term: GlossaryTerm

    var body: some View {
        Button(action: {
            // Здесь можно убрать из избранного или показать подробности
            print("Нажат избранный термин: \(term.term)")
        }) {
            VStack(alignment: .leading, spacing: CosmicSpacing.small) {
                HStack {
                    Image(systemName: term.category.icon)
                        .foregroundColor(term.category.color)
                        .font(.caption)

                    Text(term.term)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.starWhite)
                        .lineLimit(1)

                    Spacer()
                }

                Text(term.definition)
                    .font(.caption2)
                    .foregroundColor(.starWhite.opacity(0.7))
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
            }
            .padding(CosmicSpacing.small)
            .frame(width: 140, height: 70)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.neonPink.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.neonPink.opacity(0.3), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct SuggestedTermCard: View {
    let term: GlossaryTerm
    let displayMode: DisplayMode

    var body: some View {
        Button(action: {
            // Здесь можно показать урок или подробности термина
            print("Нажат рекомендуемый термин: \(term.term)")
        }) {
            CosmicCard(glowColor: term.category.color.opacity(0.7)) {
                HStack(spacing: CosmicSpacing.medium) {
                    Image(systemName: term.category.icon)
                        .font(.title3)
                        .foregroundColor(term.category.color)

                    VStack(alignment: .leading, spacing: CosmicSpacing.tiny) {
                        HStack {
                            Text(term.term)
                                .font(CosmicTypography.headline)
                                .foregroundColor(.starWhite)

                            Spacer()

                            Text(term.level.shortName)
                                .font(.caption2)
                                .fontWeight(.semibold)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(
                                    Capsule()
                                        .fill(term.level.color.opacity(0.3))
                                )
                                .foregroundColor(term.level.color)
                        }

                        Text(term.definition)
                            .font(CosmicTypography.caption)
                            .foregroundColor(.starWhite.opacity(0.8))
                            .lineLimit(2)

                        if !term.keywords.isEmpty {
                            Text("#" + term.keywords.prefix(2).joined(separator: " #"))
                                .font(.caption2)
                                .foregroundColor(term.category.color.opacity(0.8))
                        }
                    }
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

/// Изолированное поисковое поле, которое не конфликтует с навигацией табов
private struct SearchFieldIsolated: View {
    @Binding var searchText: String

    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.starWhite.opacity(0.6))

            TextField("Введите термин...", text: $searchText)
                .textFieldStyle(PlainTextFieldStyle())
                .foregroundColor(.starWhite)

            if !searchText.isEmpty {
                Button {
                    searchText = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.starWhite.opacity(0.6))
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.neonCyan.opacity(0.3), lineWidth: 1)
                )
        )
        .contentShape(Rectangle()) // Определяем область для взаимодействия
        .onTapGesture {
            // Пустое действие чтобы перехватить tap и не дать ему пропагировать наверх
        }
    }
}

// MARK: - Preview
struct ChartTabBar_Previews: PreviewProvider {
    static var previews: some View {
        let sampleChart = BirthChart(
            id: "sample",
            userId: "user1",
            name: "Тестовая карта",
            birthDate: Date(),
            birthTime: "14:30",
            location: "Москва",
            latitude: 55.7558,
            longitude: 37.6176,
            planets: [],
            houses: [],
            aspects: [],
            calculatedAt: Date()
        )

        let displayModeManager = ChartDisplayModeManager()
        let tabState = ChartTabState(displayModeManager: displayModeManager)

        VStack {
            ChartTabBar(
                tabState: tabState,
                birthChart: sampleChart,
                displayMode: displayModeManager.currentMode
            )

            Spacer()
        }
        .background(CosmicGradients.mainCosmic)
        .environmentObject(TooltipService())
    }
}