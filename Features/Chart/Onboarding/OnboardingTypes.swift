//
//  OnboardingTypes.swift
//  Astrolog
//
//  Created by Claude on 21.10.2025.
//

// Features/Chart/Onboarding/OnboardingTypes.swift
import SwiftUI
import Combine

// MARK: - Supporting Types

/// Шаг онбординга
public struct OnboardingStepData: Identifiable, Hashable {
    public let id: String
    public let title: String
    public let description: String
    public let type: StepType
    public let targetElement: OnboardingTargetElement?
    public let highlightArea: CGRect?
    public let action: OnboardingAction
    public let duration: TimeInterval
    public let canSkip: Bool

    public enum StepType: Hashable {
        case introduction
        case feature
        case education
        case navigation
        case interaction
        case completion
        case modeTransition
        case featureAnnouncement
    }

    // Кастомная реализация Hashable
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(title)
        hasher.combine(type)
    }

    public static func == (lhs: OnboardingStepData, rhs: OnboardingStepData) -> Bool {
        return lhs.id == rhs.id
    }

    public init(id: String, title: String, description: String, type: StepType, targetElement: OnboardingTargetElement?, highlightArea: CGRect?, action: OnboardingAction, duration: TimeInterval, canSkip: Bool) {
        self.id = id
        self.title = title
        self.description = description
        self.type = type
        self.targetElement = targetElement
        self.highlightArea = highlightArea
        self.action = action
        self.duration = duration
        self.canSkip = canSkip
    }
}

/// Целевой элемент для подсветки
public enum OnboardingTargetElement: Hashable {
    case header(HeaderElement)
    case tabBar(TabElement)
    case chart(ChartElement)
    case overview(OverviewElement)

    public enum HeaderElement: Hashable {
        case modeSelector
        case chartInfo
    }

    public enum TabElement: Hashable {
        case overview, planets, houses, aspects, all
    }

    public enum ChartElement: Hashable {
        case planets, signs, houses, aspects, center
    }

    public enum OverviewElement: Hashable {
        case bigThree, keyInterpretations, elements
    }
}

/// Действие для пользователя
public enum OnboardingAction: Hashable {
    case none
    case tap(OnboardingTargetElement)
    case swipe(Direction)
    case highlight

    public enum Direction: Hashable {
        case horizontal, vertical
    }
}

/// Режим онбординга
public enum OnboardingMode: Hashable {
    case firstTime
    case modeChange
    case featureUpdate
    case custom([OnboardingStepData])

    // Кастомная реализация Hashable для OnboardingMode
    public func hash(into hasher: inout Hasher) {
        switch self {
        case .firstTime:
            hasher.combine("firstTime")
        case .modeChange:
            hasher.combine("modeChange")
        case .featureUpdate:
            hasher.combine("featureUpdate")
        case .custom(let steps):
            hasher.combine("custom")
            hasher.combine(steps.map { $0.id }) // Используем только ID для хеша
        }
    }

    public static func == (lhs: OnboardingMode, rhs: OnboardingMode) -> Bool {
        switch (lhs, rhs) {
        case (.firstTime, .firstTime),
             (.modeChange, .modeChange),
             (.featureUpdate, .featureUpdate):
            return true
        case (.custom(let lhsSteps), .custom(let rhsSteps)):
            return lhsSteps.map { $0.id } == rhsSteps.map { $0.id }
        default:
            return false
        }
    }
}

/// Уровень опыта пользователя
public enum UserExperienceLevel: String, CaseIterable {
    case beginner = "beginner"
    case intermediate = "intermediate"
    case advanced = "advanced"
}

/// Информация о прогрессе онбординга
public struct OnboardingProgressInfo {
    public let currentStep: Int
    public let totalSteps: Int
    public let progress: Double
    public let canGoNext: Bool
    public let canGoBack: Bool
    public let canSkip: Bool

    public var progressText: String {
        return "\(currentStep) из \(totalSteps)"
    }

    public init(currentStep: Int, totalSteps: Int, progress: Double, canGoNext: Bool, canGoBack: Bool, canSkip: Bool) {
        self.currentStep = currentStep
        self.totalSteps = totalSteps
        self.progress = progress
        self.canGoNext = canGoNext
        self.canGoBack = canGoBack
        self.canSkip = canSkip
    }
}

/// События аналитики онбординга
public enum OnboardingAnalyticsEvent {
    case onboardingStarted(mode: OnboardingMode, level: UserExperienceLevel)
    case onboardingStepCompleted(step: OnboardingStepData)
    case onboardingSkipped(currentStep: OnboardingStepData?, completedSteps: Int, totalSteps: Int)
    case onboardingCompleted(mode: OnboardingMode, completedSteps: Int, totalSteps: Int)
}

// MARK: - Protocols

/// Протокол для менеджера онбординга
public protocol OnboardingFlowProtocol: ObservableObject {
    var isActive: Bool { get }
    var currentStep: OnboardingStepData? { get }
    var completedSteps: Set<OnboardingStepData.ID> { get }
    var canSkip: Bool { get }
    var animationProgress: Double { get }
    var onboardingMode: OnboardingMode { get }
    var userExperienceLevel: UserExperienceLevel { get }
    var progress: Double { get }
    var hasNextStep: Bool { get }
    var hasPreviousStep: Bool { get }
    var progressInfo: OnboardingProgressInfo { get }

    func startOnboarding(mode: OnboardingMode, experienceLevel: UserExperienceLevel)
    func nextStep()
    func previousStep()
    func skipOnboarding()
    func completeOnboarding()
    func restartOnboarding()
    func shouldShowOnboarding(for mode: DisplayMode) -> Bool
    func highlightCurrentStepElement(using highlightSystem: OnboardingHighlightSystem)
    func removeCurrentStepHighlight(using highlightSystem: OnboardingHighlightSystem)
}

// MARK: - Extensions

extension DisplayMode {
    func toExperienceLevel() -> UserExperienceLevel {
        switch self {
        case .human: return .beginner
        case .beginner: return .beginner
        case .intermediate: return .advanced
        }
    }
}

extension OnboardingTargetElement {
    public var accessibilityIdentifier: String {
        switch self {
        case .header(.modeSelector): return "onboarding_mode_selector"
        case .header(.chartInfo): return "onboarding_chart_info"
        case .tabBar(.overview): return "onboarding_tab_overview"
        case .tabBar(.planets): return "onboarding_tab_planets"
        case .tabBar(.houses): return "onboarding_tab_houses"
        case .tabBar(.aspects): return "onboarding_tab_aspects"
        case .tabBar(.all): return "onboarding_tab_bar"
        case .chart(.planets): return "onboarding_chart_planets"
        case .chart(.signs): return "onboarding_chart_signs"
        case .chart(.houses): return "onboarding_chart_houses"
        case .chart(.aspects): return "onboarding_chart_aspects"
        case .chart(.center): return "onboarding_chart_center"
        case .overview(.bigThree): return "onboarding_big_three"
        case .overview(.keyInterpretations): return "onboarding_key_interpretations"
        case .overview(.elements): return "onboarding_elements"
        }
    }
}