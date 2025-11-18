//
//  EssenceTabView.swift
//  Astrolog
//
//  Created by Claude on 26.10.2025.
//

// Features/Chart/Views/EssenceTabView.swift
import SwiftUI

/// Переработанная вкладка "Основное" - фокус на самом важном
/// Только Солнце, Луна, Асцендент + краткое описание личности
struct EssenceTabView: View {
    let birthChart: BirthChart
    @ObservedObject var displayModeManager: ChartDisplayModeManager
    @EnvironmentObject var interpretationEngine: InterpretationEngine

    // Новые сервисы для персонализации
    @StateObject private var personalInsightsService = PersonalInsightsService()
    @StateObject private var emotionalService = EmotionalInterpretationService()
    @StateObject private var humanLanguageService = HumanLanguageService()

    @State private var personalityEssence: PersonalityEssence?
    @State private var personalInsights: PersonalInsights?
    @State private var emotionalProfile: EmotionalProfile?
    @State private var isLoading = false
    @State private var selectedBigThreeElement: BigThreeElement?

    var body: some View {
        ScrollView {
            LazyVStack(spacing: CosmicSpacing.large) {
                // Заголовок секции
                essenceHeaderSection

                // Краткое описание личности одним абзацем
                if let insights = personalInsights {
                    enhancedPersonalityOverviewSection(insights)
                } else if let essence = personalityEssence {
                    personalityOverviewSection(essence)
                }

                // Эмоциональный профиль (новое!)
                if let emotionalProfile = emotionalProfile {
                    emotionalProfileSection(emotionalProfile)
                }

                // Основная троица - упрощенно с эмоциональными инсайтами
                enhancedBigThreeSection

                // 3-4 ключевые черты характера с персональными инсайтами
                if let insights = personalInsights {
                    enhancedKeyTraitsSection(insights)
                } else if let essence = personalityEssence {
                    keyTraitsSection(essence)
                }

                // Элементальный баланс (только для intermediate+)
                if displayModeManager.currentMode != .beginner {
                    elementalBalanceSection
                }

                Spacer(minLength: CosmicSpacing.medium)
            }
            .padding(.horizontal, CosmicSpacing.medium)
            .padding(.vertical, CosmicSpacing.small)
        }
        .refreshable {
            await loadAllPersonalizationData()
        }
        .task {
            await loadAllPersonalizationData()
        }
        .sheet(item: $selectedBigThreeElement) { element in
            BigThreeDetailSheet(element: element, birthChart: birthChart)
        }
    }

    // MARK: - Essence Header
    private var essenceHeaderSection: some View {
        VStack(spacing: CosmicSpacing.medium) {
            // Космический символ
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                .starYellow.opacity(0.3),
                                .cosmicViolet.opacity(0.6),
                                .cosmicPurple.opacity(0.2)
                            ],
                            center: .center,
                            startRadius: 10,
                            endRadius: 50
                        )
                    )
                    .frame(width: 100, height: 100)
                    .modifier(PulsingGlow(color: .starYellow, intensity: 0.6))

                Text("⭐️")
                    .font(.system(size: 40))
            }

            VStack(spacing: CosmicSpacing.small) {
                Text("Ваша суть")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.starWhite)

                Text("Основа вашей личности")
                    .font(.body)
                    .foregroundColor(.starWhite.opacity(0.8))
                    .multilineTextAlignment(.center)
            }
        }
    }

    // MARK: - Enhanced Personality Overview
    private func enhancedPersonalityOverviewSection(_ insights: PersonalInsights) -> some View {
        CosmicCard(glowColor: .starYellow.opacity(0.5)) {
            VStack(spacing: CosmicSpacing.medium) {
                HStack {
                    Text("🌟")
                        .font(.title)

                    Text("Кто вы на самом деле")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.starWhite)

                    Spacer()
                }

                // Используем персонализированное описание
                Text(insights.corePersonalityDescription)
                    .font(.body)
                    .foregroundColor(.starWhite)
                    .lineSpacing(3)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)

                // Показываем жизненную тему для intermediate+
                if displayModeManager.currentMode != .human {
                    Divider()
                        .background(Color.starYellow.opacity(0.3))

                    HStack {
                        Text("🎯")
                            .font(.body)

                        VStack(alignment: .leading, spacing: CosmicSpacing.tiny) {
                            Text("Ваша жизненная тема")
                                .font(.caption)
                                .foregroundColor(.starWhite.opacity(0.8))

                            Text(insights.lifeTheme.title)
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(.neonCyan)
                        }

                        Spacer()
                    }
                }
            }
            .padding(CosmicSpacing.medium)
        }
    }

    // MARK: - Emotional Profile Section
    private func emotionalProfileSection(_ profile: EmotionalProfile) -> some View {
        CosmicCard(glowColor: .waterElement.opacity(0.5)) {
            VStack(spacing: CosmicSpacing.medium) {
                HStack {
                    Text("💖")
                        .font(.title)

                    Text("Ваш эмоциональный мир")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.starWhite)

                    Spacer()
                }

                // Эмоциональная природа
                HStack(spacing: CosmicSpacing.medium) {
                    Text("💧")
                        .font(.title2)

                    VStack(alignment: .leading, spacing: CosmicSpacing.tiny) {
                        Text("Ваша эмоциональная природа")
                            .font(.caption)
                            .foregroundColor(.starYellow.opacity(0.7))

                        Text(profile.coreEmotionalNature)
                            .font(.body)
                            .foregroundColor(.waterElement)
                            .fontWeight(.medium)
                    }

                    Spacer()
                }
                .padding(.horizontal)

                // Эмоциональные потребности
                VStack(alignment: .leading, spacing: CosmicSpacing.small) {
                    Text("Что вам нужно для гармонии:")
                        .font(.caption)
                        .foregroundColor(.starWhite.opacity(0.8))

                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: CosmicSpacing.tiny) {
                        ForEach(profile.emotionalStrengths.prefix(4), id: \.self) { need in
                            HStack(spacing: CosmicSpacing.tiny) {
                                Text("•")
                                    .foregroundColor(.waterElement)
                                Text(need)
                                    .font(.caption)
                                    .foregroundColor(.starWhite)
                                Spacer()
                            }
                        }
                    }
                }
            }
            .padding(CosmicSpacing.medium)
        }
    }

    // MARK: - Enhanced Big Three Section
    private var enhancedBigThreeSection: some View {
        VStack(spacing: CosmicSpacing.medium) {
            // Заголовок секции
            HStack {
                Text("👑")
                    .font(.title2)

                Text("Три кита вашей личности")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.starWhite)

                Spacer()
            }

            // Улучшенные карточки с эмоциональными инсайтами
            VStack(spacing: CosmicSpacing.small) {
                if let sun = birthChart.planets.first(where: { $0.type == .sun }) {
                    EnhancedBigThreeCard(
                        element: .sun(sun),
                        emotionalProfile: emotionalProfile,
                        displayMode: displayModeManager.currentMode,
                        onTap: { selectedBigThreeElement = .sun(sun) }
                    )
                }

                if let moon = birthChart.planets.first(where: { $0.type == .moon }) {
                    EnhancedBigThreeCard(
                        element: .moon(moon),
                        emotionalProfile: emotionalProfile,
                        displayMode: displayModeManager.currentMode,
                        onTap: { selectedBigThreeElement = .moon(moon) }
                    )
                }

                if let ascendant = birthChart.planets.first(where: { $0.type == .ascendant }) {
                    EnhancedBigThreeCard(
                        element: .ascendant(ascendant),
                        emotionalProfile: emotionalProfile,
                        displayMode: displayModeManager.currentMode,
                        onTap: { selectedBigThreeElement = .ascendant(ascendant) }
                    )
                }
            }
        }
    }

    // MARK: - Enhanced Key Traits Section
    private func enhancedKeyTraitsSection(_ insights: PersonalInsights) -> some View {
        VStack(spacing: CosmicSpacing.medium) {
            HStack {
                Text("✨")
                    .font(.title2)

                Text("Ваши уникальные качества")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.starWhite)

                Spacer()
            }

            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: CosmicSpacing.small) {
                ForEach(insights.uniqueTraits.prefix(4), id: \.id) { trait in
                    EnhancedTraitCard(trait: trait, displayMode: displayModeManager.currentMode)
                }
            }
        }
    }

    // MARK: - Personality Overview
    private func personalityOverviewSection(_ essence: PersonalityEssence) -> some View {
        CosmicCard(glowColor: .starYellow.opacity(0.5)) {
            VStack(spacing: CosmicSpacing.medium) {
                HStack {
                    Text("🌟")
                        .font(.title)

                    Text("Кто вы на самом деле")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.starWhite)

                    Spacer()
                }

                Text(essence.coreDescription)
                    .font(.body)
                    .foregroundColor(.starWhite)
                    .lineSpacing(3)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(CosmicSpacing.medium)
        }
    }

    // MARK: - Simplified Big Three
    private var simplifiedBigThreeSection: some View {
        VStack(spacing: CosmicSpacing.medium) {
            // Заголовок секции
            HStack {
                Text("👑")
                    .font(.title2)

                Text("Три кита вашей личности")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.starWhite)

                Spacer()
            }

            // Упрощенные карточки - только основная информация
            VStack(spacing: CosmicSpacing.small) {
                if let sun = birthChart.planets.first(where: { $0.type == .sun }) {
                    SimpleBigThreeCard(
                        element: .sun(sun),
                        displayMode: displayModeManager.currentMode,
                        onTap: { selectedBigThreeElement = .sun(sun) }
                    )
                }

                if let moon = birthChart.planets.first(where: { $0.type == .moon }) {
                    SimpleBigThreeCard(
                        element: .moon(moon),
                        displayMode: displayModeManager.currentMode,
                        onTap: { selectedBigThreeElement = .moon(moon) }
                    )
                }

                if let ascendant = birthChart.planets.first(where: { $0.type == .ascendant }) {
                    SimpleBigThreeCard(
                        element: .ascendant(ascendant),
                        displayMode: displayModeManager.currentMode,
                        onTap: { selectedBigThreeElement = .ascendant(ascendant) }
                    )
                }
            }
        }
    }

    // MARK: - Key Traits Section
    private func keyTraitsSection(_ essence: PersonalityEssence) -> some View {
        VStack(spacing: CosmicSpacing.medium) {
            HStack {
                Text("✨")
                    .font(.title2)

                Text("Ваши ключевые качества")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.starWhite)

                Spacer()
            }

            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: CosmicSpacing.small) {
                ForEach(essence.keyTraits.prefix(4), id: \.self) { trait in
                    TraitCard(trait: trait)
                }
            }
        }
    }

    // MARK: - Elemental Balance (для intermediate+)
    private var elementalBalanceSection: some View {
        VStack(spacing: CosmicSpacing.medium) {
            HStack {
                Text("🔥")
                    .font(.title2)

                Text("Баланс стихий")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.starWhite)

                Spacer()
            }

            ElementBalanceView(birthChart: birthChart, displayMode: displayModeManager.currentMode)
        }
    }

    // MARK: - Helper Methods
    @MainActor
    private func loadAllPersonalizationData() async {
        isLoading = true

        do {
            // Загружаем все данные персонализации параллельно
            async let personalInsightsTask = personalInsightsService.generatePersonalProfile(
                for: birthChart,
                displayMode: displayModeManager.currentMode
            )

            // Создаем эмоциональный профиль напрямую
            let emotionalProfile = EmotionalProfile.default

            // Ждем результатов
            await personalInsightsTask
            self.emotionalProfile = emotionalProfile

            // Создаем базовую суть личности как fallback
            personalityEssence = createPersonalityEssence()

        } catch {
            print("Ошибка загрузки персонализированных данных: \(error)")
            // Fallback на базовые данные
            personalityEssence = createPersonalityEssence()
        }

        isLoading = false
    }

    private func createPersonalityEssence() -> PersonalityEssence {
        let sun = birthChart.planets.first(where: { $0.type == .sun })
        let moon = birthChart.planets.first(where: { $0.type == .moon })
        let ascendant = birthChart.planets.first(where: { $0.type == .ascendant })

        // Генерируем краткое описание личности
        let coreDescription = generateCoreDescription(sun: sun, moon: moon, ascendant: ascendant)
        let keyTraits = generateKeyTraits(sun: sun, moon: moon, ascendant: ascendant)

        return PersonalityEssence(
            coreDescription: coreDescription,
            keyTraits: keyTraits,
            dominantElement: calculateDominantElement(),
            lifePurpose: generateLifePurpose(sun: sun)
        )
    }

    private func generateCoreDescription(sun: Planet?, moon: Planet?, ascendant: Planet?) -> String {
        guard let sun = sun else { return "Вы - уникальная личность с богатым внутренним миром." }

        let sunSign = sun.zodiacSign.displayName
        let moonDescription = moon?.zodiacSign.displayName ?? "глубоких эмоций"
        let ascendantDescription = ascendant?.zodiacSign.displayName ?? "интересной подачи себя"

        return "В основе вашей личности — энергия \(sunSign), которая определяет ваше творческое самовыражение и жизненную силу. Ваш эмоциональный мир окрашен качествами \(moonDescription), а окружающие воспринимают вас через призму \(ascendantDescription). Это создает уникальное сочетание внутренней силы, эмоциональной глубины и внешнего обаяния."
    }

    private func generateKeyTraits(sun: Planet?, moon: Planet?, ascendant: Planet?) -> [PersonalityTrait] {
        var traits: [PersonalityTrait] = []

        if let sun = sun {
            traits.append(PersonalityTrait(
                name: sun.zodiacSign.element.keyQuality,
                description: sun.zodiacSign.element.shortDescription,
                source: .sun,
                intensity: 0.9
            ))
        }

        if let moon = moon {
            traits.append(PersonalityTrait(
                name: moon.zodiacSign.emotionalKeyword,
                description: moon.zodiacSign.emotionalDescription,
                source: .moon,
                intensity: 0.8
            ))
        }

        if let ascendant = ascendant {
            traits.append(PersonalityTrait(
                name: ascendant.zodiacSign.socialKeyword,
                description: ascendant.zodiacSign.socialDescription,
                source: .ascendant,
                intensity: 0.7
            ))
        }

        // Добавляем четвертое качество на основе комбинации
        traits.append(PersonalityTrait(
            name: "Уникальность",
            description: "Ваше неповторимое сочетание качеств",
            source: .combination,
            intensity: 0.6
        ))

        return traits
    }

    private func calculateDominantElement() -> ZodiacSign.Element {
        // Упрощенный подсчет доминирующего элемента
        let elements = birthChart.planets.compactMap { $0.zodiacSign.element }
        let elementCounts = elements.reduce(into: [:]) { counts, element in
            counts[element, default: 0] += 1
        }

        return elementCounts.max(by: { $0.value < $1.value })?.key ?? .fire
    }

    private func generateLifePurpose(sun: Planet?) -> String {
        guard let sun = sun else { return "Найти свой уникальный путь в жизни" }

        switch sun.zodiacSign {
        case .aries: return "Быть первопроходцем и вдохновителем"
        case .taurus: return "Создавать красоту и стабильность"
        case .gemini: return "Соединять людей и идеи"
        case .cancer: return "Заботиться и создавать уют"
        case .leo: return "Вдохновлять и творить"
        case .virgo: return "Помогать и совершенствовать"
        case .libra: return "Создавать гармонию и красоту"
        case .scorpio: return "Трансформировать и исцелять"
        case .sagittarius: return "Исследовать и делиться мудростью"
        case .capricorn: return "Строить и достигать вершин"
        case .aquarius: return "Новаторствовать и объединять"
        case .pisces: return "Творить и сострадать"
        }
    }
}

// MARK: - Supporting Models

/// Суть личности
struct PersonalityEssence {
    let coreDescription: String
    let keyTraits: [PersonalityTrait]
    let dominantElement: ZodiacSign.Element
    let lifePurpose: String
}

/// Черта личности
struct PersonalityTrait: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let description: String
    let source: TraitSource
    let intensity: Double

    var color: Color {
        source.color
    }

    var emoji: String {
        source.emoji
    }
}

/// Источник черты личности
enum TraitSource {
    case sun, moon, ascendant, combination

    var color: Color {
        switch self {
        case .sun: return .starYellow
        case .moon: return .waterElement
        case .ascendant: return .airElement
        case .combination: return .cosmicViolet
        }
    }

    var emoji: String {
        switch self {
        case .sun: return "☀️"
        case .moon: return "🌙"
        case .ascendant: return "🎭"
        case .combination: return "✨"
        }
    }
}

/// Элементы большой тройки для детального просмотра
enum BigThreeElement: Identifiable, Equatable {
    case sun(Planet)
    case moon(Planet)
    case ascendant(Planet)

    var id: String {
        switch self {
        case .sun(let planet): return "sun-\(planet.id)"
        case .moon(let planet): return "moon-\(planet.id)"
        case .ascendant(let planet): return "ascendant-\(planet.id)"
        }
    }

    var planet: Planet {
        switch self {
        case .sun(let planet), .moon(let planet), .ascendant(let planet):
            return planet
        }
    }

    var title: String {
        switch self {
        case .sun: return "Солнце"
        case .moon: return "Луна"
        case .ascendant: return "Асцендент"
        }
    }

    var subtitle: String {
        switch self {
        case .sun: return "Ваша суть"
        case .moon: return "Ваши эмоции"
        case .ascendant: return "Ваша маска"
        }
    }

    var description: String {
        switch self {
        case .sun: return "Основа личности и творческое самовыражение"
        case .moon: return "Внутренний мир и эмоциональные потребности"
        case .ascendant: return "Как вас воспринимают окружающие"
        }
    }

    static func == (lhs: BigThreeElement, rhs: BigThreeElement) -> Bool {
        switch (lhs, rhs) {
        case (.sun(let planet1), .sun(let planet2)):
            return planet1.id == planet2.id
        case (.moon(let planet1), .moon(let planet2)):
            return planet1.id == planet2.id
        case (.ascendant(let planet1), .ascendant(let planet2)):
            return planet1.id == planet2.id
        default:
            return false
        }
    }
}

// MARK: - Supporting Views

/// Упрощенная карточка большой тройки
struct SimpleBigThreeCard: View {
    let element: BigThreeElement
    let displayMode: DisplayMode
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: CosmicSpacing.medium) {
                // Символ
                planetSymbol

                // Информация
                VStack(alignment: .leading, spacing: CosmicSpacing.tiny) {
                    HStack {
                        Text(element.title)
                            .font(.body)
                            .fontWeight(.semibold)
                            .foregroundColor(.starWhite)

                        Spacer()

                        signBadge
                    }

                    Text("в \(element.planet.zodiacSign.displayName)")
                        .font(.caption)
                        .foregroundColor(element.planet.zodiacSign.color)

                    if displayMode != .beginner {
                        Text(element.description)
                            .font(.caption2)
                            .foregroundColor(.starWhite.opacity(0.7))
                            .lineLimit(2)
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
                .fill(element.planet.type.color.opacity(0.3))
                .frame(width: 40, height: 40)

            Text(element.planet.type.symbol)
                .font(.title3)
                .foregroundColor(.starWhite)
        }
    }

    private var signBadge: some View {
        Text(element.planet.zodiacSign.symbol)
            .font(.caption)
            .fontWeight(.medium)
            .foregroundColor(.starWhite)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(element.planet.zodiacSign.color.opacity(0.3))
            )
    }

    private var cardBackground: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(
                LinearGradient(
                    colors: [
                        element.planet.zodiacSign.elementColor.opacity(0.1),
                        .cosmicPurple.opacity(0.15)
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(element.planet.type.color.opacity(0.3), lineWidth: 1)
            )
    }
}

/// Карточка черты характера
struct TraitCard: View {
    let trait: PersonalityTrait

    var body: some View {
        VStack(spacing: CosmicSpacing.small) {
            HStack {
                Text(trait.emoji)
                    .font(.title2)

                Text(trait.name)
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundColor(.starWhite)
                    .lineLimit(1)

                Spacer()
            }

            Text(trait.description)
                .font(.caption)
                .foregroundColor(.starWhite.opacity(0.8))
                .lineLimit(3)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)

            // Индикатор интенсивности
            HStack {
                ForEach(0..<5, id: \.self) { index in
                    Circle()
                        .fill(index < Int(trait.intensity * 5) ? trait.color : trait.color.opacity(0.2))
                        .frame(width: 4, height: 4)
                }
                Spacer()
            }
        }
        .padding(CosmicSpacing.medium)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(trait.color.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(trait.color.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

/// Упрощенный баланс элементов
struct ElementBalanceView: View {
    let birthChart: BirthChart
    let displayMode: DisplayMode

    var body: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: CosmicSpacing.small) {
            ForEach(ZodiacSign.Element.allCases, id: \.self) { element in
                ElementIndicator(
                    element: element,
                    strength: calculateElementStrength(element),
                    displayMode: displayMode
                )
            }
        }
    }

    private func calculateElementStrength(_ element: ZodiacSign.Element) -> Double {
        let planetElements = birthChart.planets.compactMap { $0.zodiacSign.element }
        let elementCount = planetElements.filter { $0 == element }.count
        let totalPlanets = max(1, planetElements.count)
        return Double(elementCount) / Double(totalPlanets)
    }
}

/// Индикатор элемента
struct ElementIndicator: View {
    let element: ZodiacSign.Element
    let strength: Double
    let displayMode: DisplayMode

    var body: some View {
        VStack(spacing: CosmicSpacing.small) {
            Text(element.emoji)
                .font(.title2)

            Text(element.displayName)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.starWhite)

            // Полоска силы
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(element.color.opacity(0.2))
                        .frame(height: 4)

                    RoundedRectangle(cornerRadius: 2)
                        .fill(element.color)
                        .frame(width: geometry.size.width * strength, height: 4)
                        .animation(.easeInOut(duration: 0.8), value: strength)
                }
            }
            .frame(height: 4)

            if displayMode != .beginner {
                Text("\(Int(strength * 100))%")
                    .font(.caption2)
                    .foregroundColor(.starWhite.opacity(0.7))
            }
        }
        .padding(CosmicSpacing.small)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(element.color.opacity(0.05))
        )
    }
}

/// Детальная информация об элементе большой тройки
struct BigThreeDetailSheet: View {
    let element: BigThreeElement
    let birthChart: BirthChart
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: CosmicSpacing.large) {
                    // Заголовок
                    VStack(alignment: .leading, spacing: CosmicSpacing.medium) {
                        Text(element.planet.type.symbol)
                            .font(.system(size: 60))
                            .foregroundColor(element.planet.type.color)

                        VStack(alignment: .leading, spacing: CosmicSpacing.small) {
                            Text(element.title)
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(.starWhite)

                            Text("в \(element.planet.zodiacSign.displayName)")
                                .font(.title2)
                                .foregroundColor(element.planet.zodiacSign.color)

                            Text(element.description)
                                .font(.body)
                                .foregroundColor(.starWhite.opacity(0.8))
                        }
                    }

                    // Детальная интерпретация - заглушка
                    CosmicCard(glowColor: element.planet.type.color) {
                        VStack(alignment: .leading, spacing: CosmicSpacing.medium) {
                            Text("Детальная интерпретация")
                                .font(.headline)
                                .foregroundColor(.starWhite)

                            Text("Здесь будет подробное описание влияния \(element.title.lowercased()) в \(element.planet.zodiacSign.displayName.lowercased()) на вашу личность.")
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

/// Анимация пульсирующего свечения
struct PulsingGlow: ViewModifier {
    let color: Color
    let intensity: Double
    @State private var isAnimating = false

    func body(content: Content) -> some View {
        content
            .overlay(
                content
                    .blur(radius: isAnimating ? 8 : 4)
                    .opacity(isAnimating ? intensity * 0.8 : intensity * 0.4)
                    .scaleEffect(isAnimating ? 1.1 : 1.0)
                    .animation(
                        Animation.easeInOut(duration: 2.0)
                            .repeatForever(autoreverses: true),
                        value: isAnimating
                    )
            )
            .onAppear {
                isAnimating = true
            }
    }

    // MARK: - Helper Methods для персонализации
    private func translateEmotionalState(_ state: EmotionalState) -> String {
        // Упрощенная версия для совместимости
        return "Сбалансированное эмоциональное состояние"
    }
}

// MARK: - Enhanced Components

/// Улучшенная карточка большой тройки с эмоциональными инсайтами
struct EnhancedBigThreeCard: View {
    let element: BigThreeElement
    let emotionalProfile: EmotionalProfile?
    let displayMode: DisplayMode
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: CosmicSpacing.medium) {
                // Символ с эмоциональной подсветкой
                planetSymbol

                // Информация
                VStack(alignment: .leading, spacing: CosmicSpacing.tiny) {
                    HStack {
                        Text(element.title)
                            .font(.body)
                            .fontWeight(.semibold)
                            .foregroundColor(.starWhite)

                        Spacer()

                        signBadge
                    }

                    Text("в \(element.planet.zodiacSign.displayName)")
                        .font(.caption)
                        .foregroundColor(element.planet.zodiacSign.color)

                    // Эмоциональный инсайт для этого элемента
                    if let emotionalInsight = getEmotionalInsight() {
                        Text(emotionalInsight)
                            .font(.caption2)
                            .foregroundColor(.waterElement)
                            .lineLimit(2)
                    } else if displayMode != .beginner {
                        Text(element.description)
                            .font(.caption2)
                            .foregroundColor(.starWhite.opacity(0.7))
                            .lineLimit(2)
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
                .fill(element.planet.type.color.opacity(0.3))
                .frame(width: 40, height: 40)

            // Добавляем эмоциональное свечение если есть профиль
            if emotionalProfile != nil {
                Circle()
                    .stroke(Color.waterElement.opacity(0.4), lineWidth: 1)
                    .frame(width: 42, height: 42)
            }

            Text(element.planet.type.symbol)
                .font(.title3)
                .foregroundColor(.starWhite)
        }
    }

    private var signBadge: some View {
        Text(element.planet.zodiacSign.symbol)
            .font(.caption)
            .fontWeight(.medium)
            .foregroundColor(.starWhite)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(element.planet.zodiacSign.color.opacity(0.3))
            )
    }

    private var cardBackground: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(
                LinearGradient(
                    colors: [
                        element.planet.zodiacSign.elementColor.opacity(0.1),
                        .cosmicPurple.opacity(0.15),
                        // Добавляем эмоциональный оттенок
                        emotionalProfile != nil ? .waterElement.opacity(0.05) : .clear
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(element.planet.type.color.opacity(0.3), lineWidth: 1)
            )
    }

    private func getEmotionalInsight() -> String? {
        guard let profile = emotionalProfile else { return nil }

        switch element {
        case .sun:
            return "Источник \(profile.coreEmotionalNature.lowercased())"
        case .moon:
            return profile.emotionalStrengths.first ?? "Глубокие эмоции"
        case .ascendant:
            return "Эмоциональная маска"
        }
    }
}

/// Улучшенная карточка черты с персональными инсайтами
struct EnhancedTraitCard: View {
    let trait: PersonalTrait
    let displayMode: DisplayMode

    var body: some View {
        VStack(spacing: CosmicSpacing.small) {
            HStack {
                Text(trait.category.emoji)
                    .font(.title2)

                Text(trait.displayName)
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundColor(.starWhite)
                    .lineLimit(1)

                Spacer()
            }

            Text(getTraitDescription())
                .font(.caption)
                .foregroundColor(.starWhite.opacity(0.8))
                .lineLimit(3)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)

            // Персональная значимость
            HStack {
                Text("Важность для вас:")
                    .font(.caption2)
                    .foregroundColor(.starWhite.opacity(0.6))

                ForEach(0..<5, id: \.self) { index in
                    Circle()
                        .fill(index < Int(trait.personalRelevance * 5) ? trait.category.color : trait.category.color.opacity(0.2))
                        .frame(width: 4, height: 4)
                }

                Spacer()
            }
        }
        .padding(CosmicSpacing.medium)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(trait.category.color.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(trait.category.color.opacity(0.3), lineWidth: 1)
                )
        )
    }

    private func getTraitDescription() -> String {
        switch displayMode {
        case .human:
            return trait.humanDescription
        case .beginner:
            return trait.basicDescription
        default:
            return trait.detailedDescription
        }
    }
}

// MARK: - Extensions для зодиакальных знаков

extension ZodiacSign {
    var emotionalKeyword: String {
        switch self {
        case .aries: return "Импульсивность"
        case .taurus: return "Стабильность"
        case .gemini: return "Любознательность"
        case .cancer: return "Чувствительность"
        case .leo: return "Эмоциональность"
        case .virgo: return "Аналитичность"
        case .libra: return "Гармоничность"
        case .scorpio: return "Интенсивность"
        case .sagittarius: return "Оптимизм"
        case .capricorn: return "Сдержанность"
        case .aquarius: return "Независимость"
        case .pisces: return "Интуитивность"
        }
    }

    var emotionalDescription: String {
        "\(emotionalKeyword) в эмоциональных реакциях"
    }

    var socialKeyword: String {
        switch self {
        case .aries: return "Энергичность"
        case .taurus: return "Надежность"
        case .gemini: return "Общительность"
        case .cancer: return "Заботливость"
        case .leo: return "Харизматичность"
        case .virgo: return "Практичность"
        case .libra: return "Дипломатичность"
        case .scorpio: return "Магнетизм"
        case .sagittarius: return "Открытость"
        case .capricorn: return "Авторитетность"
        case .aquarius: return "Оригинальность"
        case .pisces: return "Мягкость"
        }
    }

    var socialDescription: String {
        "\(socialKeyword) в общении с людьми"
    }
}

extension ZodiacSign.Element {
    var keyQuality: String {
        switch self {
        case .fire: return "Энергичность"
        case .earth: return "Практичность"
        case .air: return "Коммуникабельность"
        case .water: return "Эмпатия"
        }
    }

    var shortDescription: String {
        switch self {
        case .fire: return "Активность и инициативность"
        case .earth: return "Стабильность и надежность"
        case .air: return "Гибкость и адаптивность"
        case .water: return "Чувствительность и интуиция"
        }
    }

    var emoji: String {
        switch self {
        case .fire: return "🔥"
        case .earth: return "🌱"
        case .air: return "💨"
        case .water: return "💧"
        }
    }


    var color: Color {
        switch self {
        case .fire: return .fireElement
        case .earth: return .earthElement
        case .air: return .airElement
        case .water: return .waterElement
        }
    }
}