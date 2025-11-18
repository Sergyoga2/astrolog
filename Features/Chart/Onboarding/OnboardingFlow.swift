//
//  OnboardingFlow.swift
//  Astrolog
//
//  Created by Claude on 21.10.2025.
//

// Features/Chart/Onboarding/OnboardingFlow.swift
import SwiftUI
import Combine

/// Интерактивный тур по натальной карте для новых пользователей
public class OnboardingFlow: OnboardingFlowProtocol {

    // MARK: - Published Properties

    @Published public var isActive: Bool = false
    @Published public var currentStep: OnboardingStepData? = nil
    @Published public var completedSteps: Set<OnboardingStepData.ID> = []
    @Published public var canSkip: Bool = true
    @Published public var animationProgress: Double = 0.0

    // MARK: - Configuration

    @Published public var onboardingMode: OnboardingMode = .firstTime
    @Published public var userExperienceLevel: UserExperienceLevel = .beginner

    // MARK: - Private Properties

    private let displayModeManager: ChartDisplayModeManager
    private let tooltipService: TooltipService
    private var cancellables = Set<AnyCancellable>()

    private var stepQueue: [OnboardingStepData] = []
    private var currentStepIndex: Int = 0

    // MARK: - Initialization

    init(
        displayModeManager: ChartDisplayModeManager,
        tooltipService: TooltipService
    ) {
        self.displayModeManager = displayModeManager
        self.tooltipService = tooltipService

        setupBindings()
        loadOnboardingState()
    }

    // MARK: - Public Methods

    /// Начать онбординг для определенного режима
    public func startOnboarding(
        mode: OnboardingMode = .firstTime,
        experienceLevel: UserExperienceLevel = .beginner
    ) {
        onboardingMode = mode
        userExperienceLevel = experienceLevel

        stepQueue = generateSteps(for: mode, experienceLevel: experienceLevel)
        currentStepIndex = 0

        guard !stepQueue.isEmpty else { return }

        withAnimation(.easeInOut(duration: 0.5)) {
            isActive = true
            currentStep = stepQueue[0]
            animationProgress = 1.0
        }

        // Настраиваем подсказки для онбординга
        tooltipService.setTooltipDelay(0.3) // Быстрые подсказки во время тура

        logAnalyticsEvent(.onboardingStarted(mode: mode, level: experienceLevel))
    }

    /// Перейти к следующему шагу
    public func nextStep() {
        guard let currentStep = currentStep else { return }

        // Отмечаем текущий шаг как завершенный
        completedSteps.insert(currentStep.id)
        logAnalyticsEvent(.onboardingStepCompleted(step: currentStep))

        currentStepIndex += 1

        if currentStepIndex >= stepQueue.count {
            // Завершаем онбординг
            completeOnboarding()
        } else {
            // Переходим к следующему шагу
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                self.currentStep = stepQueue[currentStepIndex]
            }
        }
    }

    /// Перейти к предыдущему шагу
    public func previousStep() {
        guard currentStepIndex > 0 else { return }

        currentStepIndex -= 1

        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
            currentStep = stepQueue[currentStepIndex]
        }
    }

    /// Пропустить онбординг
    public func skipOnboarding() {
        guard canSkip else { return }

        logAnalyticsEvent(.onboardingSkipped(
            currentStep: currentStep,
            completedSteps: completedSteps.count,
            totalSteps: stepQueue.count
        ))

        completeOnboarding()
    }

    /// Завершить онбординг
    public func completeOnboarding() {
        withAnimation(.easeOut(duration: 0.4)) {
            isActive = false
            animationProgress = 0.0
        }

        // Задержка перед очисткой состояния
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.currentStep = nil
            self.currentStepIndex = 0

            // Возвращаем обычные настройки подсказок
            self.tooltipService.setTooltipDelay(0.8)
        }

        // Сохраняем состояние завершенного онбординга
        saveOnboardingCompletion()

        logAnalyticsEvent(.onboardingCompleted(
            mode: onboardingMode,
            completedSteps: completedSteps.count,
            totalSteps: stepQueue.count
        ))
    }

    /// Перезапустить онбординг
    public func restartOnboarding() {
        completedSteps.removeAll()
        startOnboarding(mode: onboardingMode, experienceLevel: userExperienceLevel)
    }

    /// Проверить, нужно ли показывать онбординг
    public func shouldShowOnboarding(for mode: DisplayMode) -> Bool {
        let hasCompletedOnboarding = UserDefaults.standard.bool(forKey: "onboarding_completed_\(mode.rawValue)")
        let hasCompletedAnyOnboarding = UserDefaults.standard.bool(forKey: "onboarding_completed_any")

        switch mode {
        case .human:
            return !hasCompletedAnyOnboarding
        case .beginner:
            return !hasCompletedAnyOnboarding
        case .intermediate:
            return !hasCompletedOnboarding
        }
    }

    // MARK: - Step Management

    /// Получить прогресс онбординга
    public var progress: Double {
        guard !stepQueue.isEmpty else { return 0 }
        return Double(currentStepIndex) / Double(stepQueue.count)
    }

    /// Проверить, есть ли следующий шаг
    public var hasNextStep: Bool {
        return currentStepIndex < stepQueue.count - 1
    }

    /// Проверить, есть ли предыдущий шаг
    public var hasPreviousStep: Bool {
        return currentStepIndex > 0
    }

    /// Получить информацию о текущем прогрессе
    public var progressInfo: OnboardingProgressInfo {
        return OnboardingProgressInfo(
            currentStep: currentStepIndex + 1,
            totalSteps: stepQueue.count,
            progress: progress,
            canGoNext: hasNextStep,
            canGoBack: hasPreviousStep,
            canSkip: canSkip
        )
    }
}

// MARK: - Private Methods

private extension OnboardingFlow {

    func setupBindings() {
        // Подписываемся на изменения режима отображения
        displayModeManager.$currentMode
            .sink { [weak self] newMode in
                self?.handleDisplayModeChange(newMode)
            }
            .store(in: &cancellables)
    }

    func handleDisplayModeChange(_ mode: DisplayMode) {
        // Если онбординг активен и режим изменился, адаптируем шаги
        guard isActive else { return }

        // Можем адаптировать текущие шаги под новый режим
        if shouldShowOnboarding(for: mode) {
            let newSteps = generateSteps(for: .modeChange, experienceLevel: mode.toExperienceLevel())
            if !newSteps.isEmpty {
                stepQueue = newSteps
                currentStepIndex = 0
                currentStep = stepQueue[0]
            }
        }
    }

    func generateSteps(
        for mode: OnboardingMode,
        experienceLevel: UserExperienceLevel
    ) -> [OnboardingStepData] {
        switch mode {
        case .firstTime:
            return generateFirstTimeSteps(for: experienceLevel)
        case .modeChange:
            return generateModeChangeSteps(for: experienceLevel)
        case .featureUpdate:
            return generateFeatureUpdateSteps()
        case .custom(let steps):
            return steps
        }
    }

    func generateFirstTimeSteps(for level: UserExperienceLevel) -> [OnboardingStepData] {
        var steps: [OnboardingStepData] = []

        // Шаг 1: Добро пожаловать
        steps.append(OnboardingStepData(
            id: "welcome",
            title: "Добро пожаловать в мир астрологии! ✨",
            description: "Я покажу вам, как читать вашу натальную карту. Это займет всего несколько минут!",
            type: .introduction,
            targetElement: nil,
            highlightArea: nil,
            action: .none,
            duration: 3.0,
            canSkip: true
        ))

        // Шаг 2: Переключатель режимов
        steps.append(OnboardingStepData(
            id: "display_modes",
            title: "Выберите свой уровень",
            description: "Здесь вы можете переключаться между режимами отображения. Начнем с простого!",
            type: .feature,
            targetElement: .header(.modeSelector),
            highlightArea: CGRect(x: 0, y: 0, width: 300, height: 60),
            action: .tap(.header(.modeSelector)),
            duration: 4.0,
            canSkip: true
        ))

        // Шаг 3: Основная троица
        steps.append(OnboardingStepData(
            id: "big_three",
            title: "Ваша астрологическая основа",
            description: "Солнце, Луна и Асцендент — это три самых важных элемента вашей карты. Они определяют основу вашей личности.",
            type: .education,
            targetElement: .overview(.bigThree),
            highlightArea: CGRect(x: 0, y: 0, width: 350, height: 200),
            action: .highlight,
            duration: 5.0,
            canSkip: true
        ))

        if level != .beginner {
            // Шаг 4: Вкладки навигации
            steps.append(OnboardingStepData(
                id: "navigation_tabs",
                title: "Исследуйте разделы карты",
                description: "Используйте вкладки для изучения разных аспектов: планеты, дома, аспекты.",
                type: .navigation,
                targetElement: .tabBar(.all),
                highlightArea: CGRect(x: 0, y: 0, width: 400, height: 80),
                action: .swipe(.horizontal),
                duration: 4.0,
                canSkip: true
            ))

            // Шаг 5: Интерактивность
            steps.append(OnboardingStepData(
                id: "interactivity",
                title: "Касайтесь элементов для подробностей",
                description: "Нажимайте на планеты, знаки и аспекты, чтобы увидеть подробную информацию и интерпретации.",
                type: .interaction,
                targetElement: .chart(.planets),
                highlightArea: CGRect(x: 0, y: 0, width: 200, height: 200),
                action: .tap(.chart(.planets)),
                duration: 4.0,
                canSkip: true
            ))
        }

        // Завершающий шаг
        steps.append(OnboardingStepData(
            id: "completion",
            title: "Готово! 🎉",
            description: level == .beginner ?
                "Теперь вы знаете основы! Исследуйте свою карту и откройте новое о себе." :
                "Отлично! Вы готовы к глубокому изучению астрологии. Удачного путешествия к самопознанию!",
            type: .completion,
            targetElement: nil,
            highlightArea: nil,
            action: .none,
            duration: 3.0,
            canSkip: false
        ))

        return steps
    }

    func generateModeChangeSteps(for level: UserExperienceLevel) -> [OnboardingStepData] {
        var steps: [OnboardingStepData] = []

        let (title, description) = getModeChangeContent(for: level)

        steps.append(OnboardingStepData(
            id: "mode_change_\(level.rawValue)",
            title: title,
            description: description,
            type: .modeTransition,
            targetElement: nil,
            highlightArea: nil,
            action: .none,
            duration: 3.0,
            canSkip: true
        ))

        return steps
    }

    func generateFeatureUpdateSteps() -> [OnboardingStepData] {
        return [
            OnboardingStepData(
                id: "feature_update",
                title: "Новые возможности! 🆕",
                description: "Мы добавили новые функции для более глубокого понимания вашей карты.",
                type: .featureAnnouncement,
                targetElement: nil,
                highlightArea: nil,
                action: .none,
                duration: 3.0,
                canSkip: true
            )
        ]
    }

    func getModeChangeContent(for level: UserExperienceLevel) -> (String, String) {
        switch level {
        case .beginner:
            return (
                "Добро пожаловать в простой режим! 🌱",
                "Здесь показаны только основные элементы карты. Идеально для начала изучения астрологии."
            )
        case .intermediate:
            return (
                "Расширенный режим активирован! 📈",
                "Теперь вы видите больше планет, аспектов и домов. Время углубиться в детали!"
            )
        case .advanced:
            return (
                "Экспертный режим! 🎓",
                "Полная информация, все аспекты и дополнительные детали. Для серьезного изучения астрологии."
            )
        }
    }

    func loadOnboardingState() {
        let defaults = UserDefaults.standard
        completedSteps = Set(defaults.stringArray(forKey: "completed_onboarding_steps")?.compactMap { OnboardingStepData.ID($0) } ?? [])
    }

    func saveOnboardingCompletion() {
        let defaults = UserDefaults.standard
        defaults.set(true, forKey: "onboarding_completed_any")
        defaults.set(true, forKey: "onboarding_completed_\(displayModeManager.currentMode.rawValue)")
        defaults.set(Array(completedSteps), forKey: "completed_onboarding_steps")
        defaults.set(Date(), forKey: "onboarding_completion_date")
    }

    func logAnalyticsEvent(_ event: OnboardingAnalyticsEvent) {
        // Здесь будет интеграция с аналитикой
        print("📊 Onboarding Analytics: \(event)")
    }
}

// Типы теперь определены в OnboardingTypes.swift

// MARK: - Integration with OnboardingHighlightSystem

extension OnboardingFlow {
    /// Подсветить элемент для текущего шага
    public func highlightCurrentStepElement(using highlightSystem: OnboardingHighlightSystem) {
        guard let currentStep = currentStep,
              let targetElement = currentStep.targetElement else { return }

        let config = getHighlightConfig(for: currentStep)
        let elementId = targetElement.accessibilityIdentifier

        highlightSystem.highlightElement(
            id: elementId,
            config: config,
            duration: currentStep.duration
        )
    }

    /// Убрать подсветку текущего элемента
    public func removeCurrentStepHighlight(using highlightSystem: OnboardingHighlightSystem) {
        guard let currentStep = currentStep,
              let targetElement = currentStep.targetElement else { return }

        let elementId = targetElement.accessibilityIdentifier
        highlightSystem.removeHighlight(for: elementId)
    }

    private func getHighlightConfig(for step: OnboardingStepData) -> HighlightConfig {
        switch step.type {
        case .introduction, .completion:
            return .softGlow
        case .feature, .featureAnnouncement:
            return .brightHighlight
        case .education:
            return .spotlight
        case .navigation:
            return .subtleBorder
        case .interaction:
            return .attention
        case .modeTransition:
            return .brightHighlight
        }
    }
}