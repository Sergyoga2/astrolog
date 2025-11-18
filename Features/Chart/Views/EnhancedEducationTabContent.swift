//
//  EnhancedEducationTabContent.swift
//  Astrolog
//
//  Created by Claude on 26.10.2025.
//

// Features/Chart/Views/EnhancedEducationTabContent.swift
import SwiftUI

/// Улучшенная образовательная вкладка с персонализированными советами
struct EnhancedEducationTabContent: View {
    let config: ChartTabConfig
    @ObservedObject var displayModeManager: ChartDisplayModeManager

    // Новые сервисы для персонализации
    @StateObject private var personalInsightsService = PersonalInsightsService()
    @StateObject private var emotionalService = EmotionalInterpretationService()
    @StateObject private var humanLanguageService = HumanLanguageService()

    @State private var personalizedAdvice: PersonalizedAdvice?
    @State private var learningPath: AstrologyLearningPath?
    @State private var isLoading = false

    var body: some View {
        LazyVStack(spacing: CosmicSpacing.large) {
            // Заголовок секции
            educationHeaderSection

            // Персонализированные советы (новое!)
            if let advice = personalizedAdvice {
                personalizedAdviceSection(advice)
            }

            // Путь обучения (новое!)
            if let path = learningPath {
                learningPathSection(path)
            }

            // Базовые образовательные секции
            educationalSections
        }
        .onAppear {
            Task {
                await loadPersonalizedEducation()
            }
        }
    }

    // MARK: - Header Section
    private var educationHeaderSection: some View {
        VStack(spacing: CosmicSpacing.medium) {
            // Символ обучения
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                .starYellow.opacity(0.3),
                                .neonCyan.opacity(0.4),
                                .cosmicViolet.opacity(0.3)
                            ],
                            center: .center,
                            startRadius: 30,
                            endRadius: 90
                        )
                    )
                    .frame(width: 180, height: 180)

                Text("🎓")
                    .font(.system(size: 80))
            }

            VStack(spacing: CosmicSpacing.small) {
                Text(getHeaderTitle())
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.starWhite)

                Text("Персональные советы для роста")
                    .font(.body)
                    .foregroundColor(.starWhite.opacity(0.8))
                    .multilineTextAlignment(.center)
            }
        }
    }

    // MARK: - Personalized Advice Section
    private func personalizedAdviceSection(_ advice: PersonalizedAdvice) -> some View {
        CosmicCard(glowColor: .starYellow.opacity(0.5)) {
            VStack(spacing: CosmicSpacing.medium) {
                HStack {
                    Text("💡")
                        .font(.title)

                    Text("Персональные рекомендации")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.starWhite)

                    Spacer()
                }

                // Главный совет дня
                if let dailyAdvice = advice.dailyAdvice {
                    VStack(alignment: .leading, spacing: CosmicSpacing.small) {
                        Text("Совет на сегодня:")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.starWhite)

                        Text(dailyAdvice)
                            .font(.body)
                            .foregroundColor(.starYellow)
                            .lineSpacing(3)
                    }

                    Divider()
                        .background(Color.starWhite.opacity(0.3))
                }

                // Области для развития
                VStack(alignment: .leading, spacing: CosmicSpacing.small) {
                    Text("Что развивать в первую очередь:")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.starWhite)

                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: CosmicSpacing.tiny) {
                        ForEach(advice.developmentAreas.prefix(4), id: \.id) { area in
                            DevelopmentAreaCard(area: area, displayMode: displayModeManager.currentMode)
                        }
                    }
                }
            }
            .padding(CosmicSpacing.medium)
        }
    }

    // MARK: - Learning Path Section
    private func learningPathSection(_ path: AstrologyLearningPath) -> some View {
        CosmicCard(glowColor: .neonCyan.opacity(0.5)) {
            VStack(spacing: CosmicSpacing.medium) {
                HStack {
                    Text("🗺️")
                        .font(.title)

                    Text("Ваш путь изучения астрологии")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.starWhite)

                    Spacer()
                }

                // Текущий уровень
                HStack {
                    VStack(alignment: .leading, spacing: CosmicSpacing.tiny) {
                        Text("Ваш текущий уровень:")
                            .font(.caption)
                            .foregroundColor(.starWhite.opacity(0.8))

                        Text(path.currentLevel.displayName)
                            .font(.body)
                            .fontWeight(.medium)
                            .foregroundColor(.neonCyan)
                    }

                    Spacer()

                    // Прогресс-бар
                    ZStack {
                        Circle()
                            .stroke(Color.starWhite.opacity(0.3), lineWidth: 4)
                            .frame(width: 50, height: 50)

                        Circle()
                            .trim(from: 0, to: path.progress)
                            .stroke(Color.neonCyan, lineWidth: 4)
                            .frame(width: 50, height: 50)
                            .rotationEffect(.degrees(-90))

                        Text("\(Int(path.progress * 100))%")
                            .font(.caption2)
                            .fontWeight(.semibold)
                            .foregroundColor(.starWhite)
                    }
                }

                // Следующие шаги
                if !path.nextSteps.isEmpty {
                    Divider()
                        .background(Color.starWhite.opacity(0.3))

                    VStack(alignment: .leading, spacing: CosmicSpacing.small) {
                        Text("Следующие шаги:")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.starWhite)

                        LazyVStack(spacing: CosmicSpacing.tiny) {
                            ForEach(path.nextSteps.prefix(3), id: \.id) { step in
                                LearningStepRow(step: step)
                            }
                        }
                    }
                }
            }
            .padding(CosmicSpacing.medium)
        }
    }

    // MARK: - Educational Sections
    private var educationalSections: some View {
        LazyVStack(spacing: CosmicSpacing.medium) {
            // Основы астрологии
            if displayModeManager.currentMode == .human || displayModeManager.currentMode == .beginner {
                basicsSection
            }

            // Интерпретация символов
            symbolsSection

            // Практические упражнения
            practiceSection

            // Ресурсы для изучения
            if displayModeManager.currentMode != .human {
                resourcesSection
            }
        }
    }

    private var basicsSection: some View {
        VStack(spacing: CosmicSpacing.medium) {
            HStack {
                Text("📚")
                    .font(.title2)

                Text("Основы астрологии")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.starWhite)

                Spacer()
            }

            LazyVStack(spacing: CosmicSpacing.small) {
                EducationalCard(
                    title: "Что такое натальная карта",
                    description: "Карта неба в момент вашего рождения",
                    icon: "🌟",
                    level: .novice
                )

                EducationalCard(
                    title: "Планеты и их значения",
                    description: "Основные космические влияния",
                    icon: "🪐",
                    level: .novice
                )

                EducationalCard(
                    title: "Знаки зодиака",
                    description: "12 типов космической энергии",
                    icon: "♈",
                    level: .novice
                )
            }
        }
    }

    private var symbolsSection: some View {
        VStack(spacing: CosmicSpacing.medium) {
            HStack {
                Text("🔤")
                    .font(.title2)

                Text("Астрологические символы")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.starWhite)

                Spacer()
            }

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: CosmicSpacing.small) {
                ForEach(educationalSymbols, id: \.symbol) { symbolInfo in
                    SymbolCard(info: symbolInfo, displayMode: displayModeManager.currentMode)
                }
            }
        }
    }

    private var practiceSection: some View {
        VStack(spacing: CosmicSpacing.medium) {
            HStack {
                Text("🎯")
                    .font(.title2)

                Text("Практические упражнения")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.starWhite)

                Spacer()
            }

            LazyVStack(spacing: CosmicSpacing.small) {
                PracticeCard(
                    title: "Изучите ваше Солнце",
                    description: "Понимание основы личности",
                    difficulty: .easy,
                    timeEstimate: "5 минут"
                )

                PracticeCard(
                    title: "Найдите вашу Луну",
                    description: "Изучение эмоциональной природы",
                    difficulty: .medium,
                    timeEstimate: "10 минут"
                )

                if displayModeManager.currentMode != .human {
                    PracticeCard(
                        title: "Анализ аспектов",
                        description: "Понимание взаимосвязей планет",
                        difficulty: .hard,
                        timeEstimate: "20 минут"
                    )
                }
            }
        }
    }

    private var resourcesSection: some View {
        VStack(spacing: CosmicSpacing.medium) {
            HStack {
                Text("📖")
                    .font(.title2)

                Text("Ресурсы для изучения")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.starWhite)

                Spacer()
            }

            LazyVStack(spacing: CosmicSpacing.small) {
                ResourceCard(
                    title: "Астрологические термины",
                    description: "Словарь основных понятий",
                    type: .glossary
                )

                ResourceCard(
                    title: "Интерпретации",
                    description: "Как читать символы и их сочетания",
                    type: .guide
                )

                ResourceCard(
                    title: "История астрологии",
                    description: "Развитие знания через века",
                    type: .educational
                )
            }
        }
    }

    private var educationalSymbols: [SymbolInfo] {
        [
            SymbolInfo(symbol: "☉", name: "Солнце", description: "Ваша суть"),
            SymbolInfo(symbol: "☽", name: "Луна", description: "Ваши эмоции"),
            SymbolInfo(symbol: "☿", name: "Меркурий", description: "Ваше мышление"),
            SymbolInfo(symbol: "♀", name: "Венера", description: "Ваша любовь"),
            SymbolInfo(symbol: "♂", name: "Марс", description: "Ваша энергия"),
            SymbolInfo(symbol: "♃", name: "Юпитер", description: "Ваш рост")
        ]
    }

    private func getHeaderTitle() -> String {
        switch displayModeManager.currentMode {
        case .human:
            return "Персональные советы"
        case .beginner:
            return "Изучение астрологии"
        default:
            return "Образование и практика"
        }
    }

    // MARK: - Data Loading
    @MainActor
    private func loadPersonalizedEducation() async {
        isLoading = true

        do {
            // Создаем персонализированные советы и путь обучения
            async let adviceTask = createPersonalizedAdvice()
            async let pathTask = createLearningPath()

            personalizedAdvice = await adviceTask
            learningPath = await pathTask

        } catch {
            print("Ошибка загрузки персонализированного образования: \(error)")
        }

        isLoading = false
    }

    private func createPersonalizedAdvice() async -> PersonalizedAdvice {
        // Создаем персонализированные советы на основе карты пользователя
        let dailyAdvice = generateDailyAdvice()
        let developmentAreas = generateDevelopmentAreas()

        return PersonalizedAdvice(
            dailyAdvice: dailyAdvice,
            developmentAreas: developmentAreas,
            motivationalQuote: generateMotivationalQuote()
        )
    }

    private func createLearningPath() async -> AstrologyLearningPath {
        let currentLevel = determineCurrentLevel()
        let progress = calculateProgress(for: currentLevel)
        let nextSteps = generateNextSteps(for: currentLevel)

        return AstrologyLearningPath(
            currentLevel: currentLevel,
            progress: progress,
            nextSteps: nextSteps,
            estimatedCompletion: calculateEstimatedCompletion(currentLevel, progress)
        )
    }

    private func generateDailyAdvice() -> String {
        let advices = [
            "Сегодня обратите внимание на ваши эмоциональные реакции - они расскажут многое о вашей внутренней природе.",
            "Изучите одну планету в вашей карте более глубоко. Каждая деталь важна для понимания себя.",
            "Попробуйте медитировать на символы в вашей карте. Интуиция поможет их понять.",
            "Ведите дневник настроения и связывайте изменения с лунными фазами.",
            "Обратите внимание на повторяющиеся темы в вашей жизни - они отражают вашу карту."
        ]
        return advices.randomElement() ?? advices[0]
    }

    private func generateDevelopmentAreas() -> [DevelopmentArea] {
        [
            DevelopmentArea(
                id: UUID(),
                name: "Самопознание",
                description: "Изучение собственной натальной карты",
                priority: .high,
                category: .personal
            ),
            DevelopmentArea(
                id: UUID(),
                name: "Символическое мышление",
                description: "Понимание астрологических символов",
                priority: .medium,
                category: .technical
            ),
            DevelopmentArea(
                id: UUID(),
                name: "Интуитивное восприятие",
                description: "Развитие интуиции для интерпретации",
                priority: .medium,
                category: .intuitive
            ),
            DevelopmentArea(
                id: UUID(),
                name: "Практическое применение",
                description: "Использование знаний в повседневной жизни",
                priority: .high,
                category: .practical
            )
        ]
    }

    private func generateMotivationalQuote() -> String {
        let quotes = [
            "Астрология - это язык. Если вы понимаете этот язык, небеса говорят с вами.",
            "Звезды указывают путь, но идете по нему вы сами.",
            "Каждая карта уникальна, как и каждая душа.",
            "Изучение астрологии - это путешествие к самому себе."
        ]
        return quotes.randomElement() ?? quotes[0]
    }

    private func determineCurrentLevel() -> AstrologyLevel {
        // На основе режима отображения определяем уровень
        switch displayModeManager.currentMode {
        case .human: return .curious
        case .beginner: return .novice
        case .intermediate: return .advanced
        }
    }

    private func calculateProgress(for level: AstrologyLevel) -> Double {
        // Простой расчет прогресса
        switch level {
        case .curious: return 0.1
        case .novice: return 0.3
        case .intermediate: return 0.6
        case .advanced: return 0.9
        }
    }

    private func generateNextSteps(for level: AstrologyLevel) -> [LearningStep] {
        switch level {
        case .curious:
            return [
                LearningStep(id: UUID(), title: "Изучите ваше Солнце", description: "Основа личности", completed: false),
                LearningStep(id: UUID(), title: "Найдите вашу Луну", description: "Эмоциональная природа", completed: false),
                LearningStep(id: UUID(), title: "Определите Асцендент", description: "Внешнее проявление", completed: false)
            ]
        case .novice:
            return [
                LearningStep(id: UUID(), title: "Изучите дома", description: "Сферы жизни", completed: false),
                LearningStep(id: UUID(), title: "Основы аспектов", description: "Связи планет", completed: false),
                LearningStep(id: UUID(), title: "Элементы и качества", description: "Типы энергий", completed: false)
            ]
        case .intermediate:
            return [
                LearningStep(id: UUID(), title: "Сложные аспекты", description: "Тонкие влияния", completed: false),
                LearningStep(id: UUID(), title: "Транзиты", description: "Текущие влияния", completed: false),
                LearningStep(id: UUID(), title: "Прогрессии", description: "Развитие карты", completed: false)
            ]
        case .advanced:
            return [
                LearningStep(id: UUID(), title: "Композитные карты", description: "Карты отношений", completed: false),
                LearningStep(id: UUID(), title: "Мунданная астрология", description: "Мировые события", completed: false),
                LearningStep(id: UUID(), title: "Астрокартография", description: "География влияний", completed: false)
            ]
        }
    }

    private func calculateEstimatedCompletion(_ level: AstrologyLevel, _ progress: Double) -> String {
        let remainingTime = Int((1.0 - progress) * 100)
        return "\(remainingTime) дней"
    }
}

// MARK: - Supporting Models

struct PersonalizedAdvice {
    let dailyAdvice: String?
    let developmentAreas: [DevelopmentArea]
    let motivationalQuote: String
}

struct DevelopmentArea {
    let id: UUID
    let name: String
    let description: String
    let priority: Priority
    let category: Category

    enum Priority {
        case high, medium, low

        var color: Color {
            switch self {
            case .high: return .fireElement
            case .medium: return .starYellow
            case .low: return .airElement
            }
        }
    }

    enum Category {
        case personal, technical, intuitive, practical

        var emoji: String {
            switch self {
            case .personal: return "🔍"
            case .technical: return "⚙️"
            case .intuitive: return "🔮"
            case .practical: return "🎯"
            }
        }
    }
}

struct AstrologyLearningPath {
    let currentLevel: AstrologyLevel
    let progress: Double
    let nextSteps: [LearningStep]
    let estimatedCompletion: String
}

enum AstrologyLevel {
    case curious, novice, intermediate, advanced

    var displayName: String {
        switch self {
        case .curious: return "Любопытствующий"
        case .novice: return "Новичок"
        case .intermediate: return "Изучающий"
        case .advanced: return "Продвинутый"
        }
    }
}

struct LearningStep {
    let id: UUID
    let title: String
    let description: String
    let completed: Bool
}

struct SymbolInfo {
    let symbol: String
    let name: String
    let description: String
}

// MARK: - Supporting Components

/// Карточка области развития
struct DevelopmentAreaCard: View {
    let area: DevelopmentArea
    let displayMode: DisplayMode

    var body: some View {
        VStack(spacing: CosmicSpacing.small) {
            HStack {
                Text(area.category.emoji)
                    .font(.title3)

                Text(area.name)
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
                Circle()
                    .fill(area.priority.color)
                    .frame(width: 6, height: 6)

                Text(priorityName)
                    .font(.caption2)
                    .foregroundColor(.starWhite.opacity(0.7))

                Spacer()
            }
        }
        .padding(CosmicSpacing.small)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(area.priority.color.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(area.priority.color.opacity(0.3), lineWidth: 1)
                )
        )
    }

    private var priorityName: String {
        switch area.priority {
        case .high: return "Высокий"
        case .medium: return "Средний"
        case .low: return "Низкий"
        }
    }
}

/// Строка шага обучения
struct LearningStepRow: View {
    let step: LearningStep

    var body: some View {
        HStack(spacing: CosmicSpacing.small) {
            Circle()
                .fill(step.completed ? Color.neonCyan : Color.starWhite.opacity(0.3))
                .frame(width: 8, height: 8)

            VStack(alignment: .leading, spacing: 2) {
                Text(step.title)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.starWhite)

                Text(step.description)
                    .font(.caption2)
                    .foregroundColor(.starWhite.opacity(0.7))
            }

            Spacer()
        }
    }
}

/// Образовательная карточка
struct EducationalCard: View {
    let title: String
    let description: String
    let icon: String
    let level: AstrologyLevel

    var body: some View {
        HStack(spacing: CosmicSpacing.medium) {
            Text(icon)
                .font(.title2)

            VStack(alignment: .leading, spacing: CosmicSpacing.tiny) {
                Text(title)
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundColor(.starWhite)

                Text(description)
                    .font(.caption)
                    .foregroundColor(.starWhite.opacity(0.8))
                    .lineLimit(2)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.neonCyan.opacity(0.6))
        }
        .padding(CosmicSpacing.medium)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.cosmicPurple.opacity(0.15))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.neonCyan.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

/// Карточка символа
struct SymbolCard: View {
    let info: SymbolInfo
    let displayMode: DisplayMode

    var body: some View {
        VStack(spacing: CosmicSpacing.small) {
            Text(info.symbol)
                .font(.title)
                .foregroundColor(.starYellow)

            Text(info.name)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.starWhite)

            Text(info.description)
                .font(.caption2)
                .foregroundColor(.starWhite.opacity(0.7))
                .lineLimit(2)
                .multilineTextAlignment(.center)
        }
        .padding(CosmicSpacing.small)
        .frame(height: 80)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.starYellow.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.starYellow.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

/// Карточка практического упражнения
struct PracticeCard: View {
    let title: String
    let description: String
    let difficulty: Difficulty
    let timeEstimate: String

    enum Difficulty {
        case easy, medium, hard

        var color: Color {
            switch self {
            case .easy: return .neonCyan
            case .medium: return .starYellow
            case .hard: return .fireElement
            }
        }

        var name: String {
            switch self {
            case .easy: return "Легко"
            case .medium: return "Средне"
            case .hard: return "Сложно"
            }
        }
    }

    var body: some View {
        HStack(spacing: CosmicSpacing.medium) {
            VStack(spacing: CosmicSpacing.tiny) {
                Circle()
                    .fill(difficulty.color)
                    .frame(width: 12, height: 12)

                Text(difficulty.name)
                    .font(.caption2)
                    .foregroundColor(difficulty.color)
            }

            VStack(alignment: .leading, spacing: CosmicSpacing.tiny) {
                Text(title)
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundColor(.starWhite)

                Text(description)
                    .font(.caption)
                    .foregroundColor(.starWhite.opacity(0.8))
                    .lineLimit(2)

                Text("Время: \(timeEstimate)")
                    .font(.caption2)
                    .foregroundColor(.starWhite.opacity(0.6))
            }

            Spacer()

            Image(systemName: "play.circle")
                .font(.title2)
                .foregroundColor(difficulty.color)
        }
        .padding(CosmicSpacing.medium)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(difficulty.color.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(difficulty.color.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

/// Карточка ресурса
struct ResourceCard: View {
    let title: String
    let description: String
    let type: ResourceType

    enum ResourceType {
        case glossary, guide, educational

        var icon: String {
            switch self {
            case .glossary: return "📚"
            case .guide: return "🗺️"
            case .educational: return "🎓"
            }
        }

        var color: Color {
            switch self {
            case .glossary: return .earthElement
            case .guide: return .airElement
            case .educational: return .waterElement
            }
        }
    }

    var body: some View {
        HStack(spacing: CosmicSpacing.medium) {
            Text(type.icon)
                .font(.title2)

            VStack(alignment: .leading, spacing: CosmicSpacing.tiny) {
                Text(title)
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundColor(.starWhite)

                Text(description)
                    .font(.caption)
                    .foregroundColor(.starWhite.opacity(0.8))
                    .lineLimit(2)
            }

            Spacer()

            Image(systemName: "arrow.up.right")
                .font(.caption)
                .foregroundColor(type.color)
        }
        .padding(CosmicSpacing.medium)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(type.color.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(type.color.opacity(0.3), lineWidth: 1)
                )
        )
    }
}