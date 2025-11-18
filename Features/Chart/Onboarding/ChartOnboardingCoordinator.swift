//
//  ChartOnboardingCoordinator.swift
//  Astrolog
//
//  Created by Claude on 26.10.2025.
//

// Features/Chart/Onboarding/ChartOnboardingCoordinator.swift
import SwiftUI
import Combine

/// Координатор направленного онбординга для экрана натальной карты
/// Ведет пользователя через поэтапное знакомство с картой
class ChartOnboardingCoordinator: ObservableObject {

    // MARK: - Published Properties
    @Published var isActive = false
    @Published var currentStep: ChartOnboardingStep = .welcome
    @Published var isCompleted = false
    @Published var userProgress: OnboardingProgress = .notStarted

    // MARK: - Private Properties
    @AppStorage("chart_onboarding_completed") private var onboardingCompleted = false
    @AppStorage("user_display_mode") private var userDisplayMode: String = DisplayMode.human.rawValue

    private let birthChart: BirthChart
    let displayModeManager: ChartDisplayModeManager
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Initialization
    init(birthChart: BirthChart, displayModeManager: ChartDisplayModeManager) {
        self.birthChart = birthChart
        self.displayModeManager = displayModeManager

        setupObservers()
        determineOnboardingNeed()
    }

    // MARK: - Public Methods

    /// Запустить онбординг
    func startOnboarding() {
        guard !onboardingCompleted else { return }

        isActive = true
        currentStep = .welcome
        userProgress = .inProgress

        // Устанавливаем режим "Понятно" для новичков
        displayModeManager.currentMode = .human
    }

    /// Установить режим отображения
    func setDisplayMode(_ mode: DisplayMode) {
        displayModeManager.currentMode = mode
    }

    /// Перейти к следующему шагу
    func nextStep() {
        withAnimation(.easeInOut(duration: 0.5)) {
            switch currentStep {
            case .welcome:
                currentStep = .basics
            case .basics:
                currentStep = .personalInsights
            case .personalInsights:
                currentStep = .interactive
            case .interactive:
                completeOnboarding()
            }
        }
    }

    /// Перейти к предыдущему шагу
    func previousStep() {
        withAnimation(.easeInOut(duration: 0.5)) {
            switch currentStep {
            case .interactive:
                currentStep = .personalInsights
            case .personalInsights:
                currentStep = .basics
            case .basics:
                currentStep = .welcome
            case .welcome:
                break // Нельзя идти назад с первого шага
            }
        }
    }

    /// Пропустить онбординг
    func skipOnboarding() {
        completeOnboarding()
    }

    /// Завершить онбординг
    func completeOnboarding() {
        withAnimation(.easeInOut(duration: 0.3)) {
            isActive = false
            isCompleted = true
            userProgress = .completed
            onboardingCompleted = true
        }
    }

    /// Сбросить онбординг (для тестирования)
    func resetOnboarding() {
        onboardingCompleted = false
        isCompleted = false
        userProgress = .notStarted
        currentStep = .welcome
    }

    // MARK: - Private Methods

    private func setupObservers() {
        // Наблюдаем за изменениями пользователя
        displayModeManager.$currentMode
            .sink { [weak self] newMode in
                // Сохраняем предпочтения пользователя
                self?.userDisplayMode = newMode.rawValue
            }
            .store(in: &cancellables)
    }

    private func determineOnboardingNeed() {
        // Определяем, нужен ли онбординг
        if !onboardingCompleted {
            userProgress = .pending
        } else {
            userProgress = .completed
            isCompleted = true
        }
    }
}

// MARK: - Supporting Enums

/// Шаги онбординга для натальной карты
enum ChartOnboardingStep: String, CaseIterable {
    case welcome = "Приветствие"
    case basics = "Основы"
    case personalInsights = "Персональные инсайты"
    case interactive = "Интерактивное знакомство"

    var title: String {
        switch self {
        case .welcome:
            return "Добро пожаловать в мир астрологии! ✨"
        case .basics:
            return "Познакомимся с основами 🌟"
        case .personalInsights:
            return "Ваши персональные открытия 💎"
        case .interactive:
            return "Как пользоваться картой 🎯"
        }
    }

    var description: String {
        switch self {
        case .welcome:
            return "Мы покажем вам, что натальная карта это легко и просто!"
        case .basics:
            return "Узнайте о трех главных элементах вашей личности"
        case .personalInsights:
            return "Откройте уникальные особенности именно вашей карты"
        case .interactive:
            return "Научимся находить ответы на жизненные вопросы"
        }
    }

    var icon: String {
        switch self {
        case .welcome:
            return "star.circle.fill"
        case .basics:
            return "book.circle.fill"
        case .personalInsights:
            return "heart.circle.fill"
        case .interactive:
            return "hand.tap.fill"
        }
    }

    var color: Color {
        switch self {
        case .welcome:
            return .starYellow
        case .basics:
            return .neonCyan
        case .personalInsights:
            return .neonPink
        case .interactive:
            return .cosmicViolet
        }
    }

    var duration: TimeInterval {
        switch self {
        case .welcome:
            return 3.0
        case .basics:
            return 5.0
        case .personalInsights:
            return 4.0
        case .interactive:
            return 6.0
        }
    }

    // Статические тексты для UI
    static let whatAwaitsTitle = "Что вас ждет:"
    static let skipButtonTitle = "Пропустить"
    static let startButtonTitle = "Начнем!"

    // Возвращает фичи для секции "Что вас ждет"
    static var welcomeFeatures: [(icon: String, title: String, description: String)] {
        return [
            (
                icon: "🌟",
                title: "Это про вас!",
                description: "Узнаете о трех главных аспектах вашей личности"
            ),
            (
                icon: "💎",
                title: "Вы уникальны",
                description: "Узнаете личные особенности вашей карты"
            ),
            (
                icon: "🎯",
                title: "Жизнь лучше!",
                description: "Поймете, как использовать астрологию в жизни"
            )
        ]
    }
}

/// Прогресс онбординга
enum OnboardingProgress: String, CaseIterable {
    case notStarted = "Не начат"
    case pending = "Ожидает"
    case inProgress = "В процессе"
    case completed = "Завершен"

    var emoji: String {
        switch self {
        case .notStarted:
            return "⭐️"
        case .pending:
            return "⏳"
        case .inProgress:
            return "🚀"
        case .completed:
            return "✅"
        }
    }
}

// MARK: - Onboarding Configuration

/// Конфигурация онбординга для разных пользователей
struct OnboardingConfiguration {
    let userType: UserType
    let focusAreas: [OnboardingFocusArea]
    let skipOptional: Bool
    let duration: OnboardingDuration

    static let `default` = OnboardingConfiguration(
        userType: .newcomer,
        focusAreas: [.bigThree, .basicUnderstanding, .dailyValue],
        skipOptional: false,
        duration: .full
    )

    static let experienced = OnboardingConfiguration(
        userType: .experienced,
        focusAreas: [.advancedFeatures, .shortcuts],
        skipOptional: true,
        duration: .quick
    )
}

enum UserType {
    case newcomer        // Полный новичок в астрологии
    case curious         // Интересующийся, но без глубоких знаний
    case experienced     // Уже знаком с астрологией
    case expert          // Профессионал или глубоко изучающий
}

enum OnboardingFocusArea {
    case bigThree           // Солнце, Луна, Асцендент
    case basicUnderstanding // Базовое понимание символов
    case dailyValue         // Ежедневная ценность приложения
    case advancedFeatures   // Продвинутые функции
    case shortcuts          // Быстрые способы использования
}

enum OnboardingDuration {
    case quick      // 2-3 минуты
    case standard   // 5-7 минут
    case full       // 10-12 минут

    var estimatedMinutes: Int {
        switch self {
        case .quick: return 3
        case .standard: return 6
        case .full: return 10
        }
    }
}

// MARK: - Onboarding Analytics

/// Аналитика онбординга для улучшения UX
struct OnboardingAnalytics {
    let startTime: Date
    var stepDurations: [ChartOnboardingStep: TimeInterval] = [:]
    var skippedSteps: [ChartOnboardingStep] = []
    var completionTime: Date?
    var completionRate: Double = 0.0

    mutating func recordStepCompletion(_ step: ChartOnboardingStep, duration: TimeInterval) {
        stepDurations[step] = duration
    }

    mutating func recordSkip(_ step: ChartOnboardingStep) {
        skippedSteps.append(step)
    }

    mutating func recordCompletion() {
        completionTime = Date()
        let completedSteps = ChartOnboardingStep.allCases.count - skippedSteps.count
        completionRate = Double(completedSteps) / Double(ChartOnboardingStep.allCases.count)
    }

    var totalDuration: TimeInterval? {
        guard let completionTime = completionTime else { return nil }
        return completionTime.timeIntervalSince(startTime)
    }

    var averageStepDuration: TimeInterval {
        let totalDuration = stepDurations.values.reduce(0, +)
        return stepDurations.isEmpty ? 0 : totalDuration / Double(stepDurations.count)
    }
}
