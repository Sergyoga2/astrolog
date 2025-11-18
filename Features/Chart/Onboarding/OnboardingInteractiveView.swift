//
//  OnboardingInteractiveView.swift
//  Astrolog
//
//  Created by Claude on 26.10.2025.
//

// Features/Chart/Onboarding/OnboardingInteractiveView.swift
import SwiftUI

/// Интерактивный экран онбординга - обучение пользованию картой
struct OnboardingInteractiveView: View {
    @ObservedObject var coordinator: ChartOnboardingCoordinator
    let birthChart: BirthChart

    @State private var currentStep = 0
    @State private var showContent = false
    @State private var highlightedTab: ChartTab? = nil
    @State private var showTabHighlight = false

    private let interactionSteps = InteractionStep.allSteps

    var body: some View {
        ZStack {
            StarfieldBackground()
                .ignoresSafeArea()

            VStack(spacing: CosmicSpacing.large) {
                // Заголовок
                headerSection
                    .opacity(showContent ? 1.0 : 0.0)
                    
                // Интерактивная демонстрация
                Spacer()

                interactiveDemo
                    .opacity(showContent ? 1.0 : 0.0)
                    
                Spacer()

                // Навигация
                navigationSection
                    .opacity(showContent ? 1.0 : 0.0)
                                }
            .padding(CosmicSpacing.large)
        }
        .onAppear {
            showContent = true
            startInteractiveDemo()
        }
    }

    // MARK: - Header
    private var headerSection: some View {
        VStack(spacing: CosmicSpacing.small) {
            VStack(spacing: CosmicSpacing.tiny) {
                Text("Как пользоваться картой:")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.starWhite)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)

                Text(interactionSteps[currentStep].demoTitle)
                    .font(.title3)
                    .fontWeight(.medium)
                    .foregroundColor(.starYellow)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    // MARK: - Interactive Demo
    private var interactiveDemo: some View {
        let currentStepData = interactionSteps[currentStep]

        return VStack(spacing: CosmicSpacing.large) {
            // Демонстрационная область
            demoArea(for: currentStepData)

            // Объяснение шага
            stepExplanation(for: currentStepData)
        }
    }

    private func demoArea(for step: InteractionStep) -> some View {
        VStack(spacing: CosmicSpacing.medium) {

            // Интерактивная часть
            switch step.type {
            case .tabNavigation:
                tabNavigationDemo
            case .tapInteraction:
                tapInteractionDemo
            case .todayTab:
                todayTabDemo
            case .modeSelection:
                modeSelectionDemo
            }
        }
        .padding(CosmicSpacing.large)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(step.color.opacity(0.4), lineWidth: 2)
                )
        )
        .modifier(NeonGlow(color: step.color, intensity: 0.2))
    }

    private var tabNavigationDemo: some View {
        VStack(spacing: CosmicSpacing.medium) {
            Text("Попробуйте переключаться между вкладками:")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.starWhite)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)

            // Упрощенная демонстрация вкладок
            HStack(spacing: CosmicSpacing.small) {
                ForEach([ChartTab.today, .overview, .planets], id: \.self) { tab in
                    demoTabButton(tab)
                }
            }
        }
    }

    private func demoTabButton(_ tab: ChartTab) -> some View {
        Button(action: {
            withAnimation(.spring()) {
                highlightedTab = tab
            }
        }) {
            VStack(spacing: 4) {
                Text(tab.emoji)
                    .font(.title3)

                Text(tab.rawValue)
                    .font(.caption2)
                    .lineLimit(1)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(highlightedTab == tab ? tab.color.opacity(0.3) : Color.clear)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(tab.color, lineWidth: highlightedTab == tab ? 2 : 1)
                    )
            )
            .foregroundColor(highlightedTab == tab ? .starWhite : .starWhite.opacity(0.7))
        }
        .scaleEffect(highlightedTab == tab ? 1.1 : 1.0)
            }

    private var tapInteractionDemo: some View {
        VStack(spacing: CosmicSpacing.medium) {
            Text("Нажмите на карточку, чтобы увидеть подробности:")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.starWhite)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)

            // Демо-карточка
            DemoCard(isExpanded: .constant(false))
        }
    }

    private var todayTabDemo: some View {
        VStack(spacing: CosmicSpacing.medium) {
            Text("Вкладка 'Сегодня' — ваш ежедневный помощник:")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.starWhite)
                .fixedSize(horizontal: false, vertical: true)

            // Мини-превью вкладки "Сегодня"
            TodayTabPreview()
        }
    }

    private var modeSelectionDemo: some View {
        VStack(spacing: CosmicSpacing.medium) {
            Text("Выберите подходящий уровень:")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.starWhite)
                .fixedSize(horizontal: false, vertical: true)

            // Демо-переключатель режимов
            ModeSelector(coordinator: coordinator)
        }
    }

    private func stepExplanation(for step: InteractionStep) -> some View {
        VStack(spacing: CosmicSpacing.medium) {
            Text(step.explanation)
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(.starWhite)
                .lineSpacing(3)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)

            if let tip = step.tip {
                HStack {
                    Text("💡")
                        .font(.title3)
                    Text(tip)
                        .font(.body)
                        .foregroundColor(.starYellow)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(CosmicSpacing.medium)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.starYellow.opacity(0.1))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.starYellow.opacity(0.3), lineWidth: 1)
                        )
                )
            }
        }
    }

    // MARK: - Navigation
    private var navigationSection: some View {
        VStack(spacing: CosmicSpacing.medium) {
            // Прогресс по шагам
            stepProgressIndicator

            // Кнопки навигации
            HStack(spacing: CosmicSpacing.medium) {
                Button(action: previousStep) {
                    HStack {
                        Image(systemName: "chevron.left")
                        Text("Назад")
                    }
                    .foregroundColor(currentStep > 0 ? .starWhite : .starWhite.opacity(0.4))
                    .padding(.horizontal, CosmicSpacing.medium)
                    .padding(.vertical, CosmicSpacing.small)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.starWhite.opacity(0.1))
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.starWhite.opacity(0.2), lineWidth: 1)
                            )
                    )
                }
                .disabled(currentStep == 0)

                Spacer()

                if currentStep < interactionSteps.count - 1 {
                    Button(action: nextStep) {
                        HStack {
                            Text("Далее")
                            Image(systemName: "chevron.right")
                        }
                        .foregroundColor(.starWhite)
                        .padding(.horizontal, CosmicSpacing.medium)
                        .padding(.vertical, CosmicSpacing.small)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.starWhite.opacity(0.1))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.starWhite.opacity(0.2), lineWidth: 1)
                                )
                        )
                    }
                } else {
                    CosmicButton(
                        title: "К звездам!",
                        icon: "sparkles",
                        color: .positive
                    ) {
                        coordinator.completeOnboarding()
                    }
                }
            }

        }
    }

    private var stepProgressIndicator: some View {
        HStack(spacing: 4) {
            ForEach(0..<interactionSteps.count, id: \.self) { index in
                RoundedRectangle(cornerRadius: 2)
                    .fill(index <= currentStep ? interactionSteps[currentStep].color : Color.starWhite.opacity(0.3))
                    .frame(width: index == currentStep ? 24 : 8, height: 4)
                                }
        }
    }

    // MARK: - Helper Methods
    private func nextStep() {
        if currentStep < interactionSteps.count - 1 {
            withAnimation(.easeInOut(duration: 0.4)) {
                currentStep += 1
            }
            highlightedTab = nil
        }
    }

    private func previousStep() {
        if currentStep > 0 {
            withAnimation(.easeInOut(duration: 0.4)) {
                currentStep -= 1
            }
            highlightedTab = nil
        }
    }

    private func startInteractiveDemo() {
        // Инициализация интерактивной демонстрации
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            if currentStep == 0 {
                withAnimation(.easeInOut(duration: 0.8)) {
                    highlightedTab = .today
                }
            }
        }
    }
}

// MARK: - Supporting Components

struct DemoCard: View {
    @Binding var isExpanded: Bool
    @State private var showExpansion = false

    var body: some View {
        Button(action: {
            withAnimation(.spring()) {
                showExpansion.toggle()
            }
        }) {
            VStack(alignment: .leading, spacing: CosmicSpacing.small) {
                HStack {
                    Text("☀️")
                        .font(.title2)

                    VStack(alignment: .center) {
                        Text("Ваша суть")
                            .font(.body)
                            .fontWeight(.semibold)
                            .foregroundColor(.starWhite)
                            .multilineTextAlignment(.center)

                        Text("Энергичный первопроходец")
                            .font(.callout)
                            .foregroundColor(.starYellow)
                            .multilineTextAlignment(.center)
                    }

                    Spacer()

                    Image(systemName: showExpansion ? "chevron.up" : "chevron.down")
                        .foregroundColor(.starYellow)
                }

                if showExpansion {
                    Text("Вы полны энергии и любите быть первым во всем.")
                        .font(.body)
                        .foregroundColor(.starWhite.opacity(0.9))
                        .fixedSize(horizontal: false, vertical: true)
                        .multilineTextAlignment(.leading)
                        .transition(.opacity.combined(with: .scale(scale: 0.95)))
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.starWhite.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.starYellow.opacity(0.4), lineWidth: 1)
                    )
            )
        }
    }
}

struct TodayTabPreview: View {
    var body: some View {
        VStack(spacing: CosmicSpacing.small) {
            HStack {
                Text("🌅")
                Text("Энергия дня: Гармоничная")
                    .font(.body)
                    .foregroundColor(.starWhite)
                Spacer()
            }

            HStack {
                Text("💕")
                Text("Отличное время\u{00A0}для романтики")
                    .font(.body)
                    .foregroundColor(.starWhite)
                Spacer()
            }
        }
        .padding(CosmicSpacing.small)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(.ultraThinMaterial)
        )
    }
}

struct ModeSelector: View {
    @ObservedObject var coordinator: ChartOnboardingCoordinator

    var body: some View {
        VStack(spacing: CosmicSpacing.small) {
            ForEach([DisplayMode.human, .beginner, .intermediate], id: \.self) { mode in
                modeSelectorButton(for: mode)
            }
        }
    }

    private func modeSelectorButton(for mode: DisplayMode) -> some View {
        let isSelected = coordinator.displayModeManager.currentMode == mode

        return Button(action: {
            withAnimation(.easeInOut(duration: 0.3)) {
                coordinator.setDisplayMode(mode)
            }
        }) {
            HStack {
                Image(systemName: mode.icon)
                Text(mode.rawValue)
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark")
                }
            }
            .foregroundColor(isSelected ? .starWhite : .starWhite.opacity(0.9))
            .padding(.horizontal, CosmicSpacing.medium)
            .padding(.vertical, CosmicSpacing.small)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isSelected ? mode.color.opacity(0.2) : Color.clear)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(mode.color.opacity(isSelected ? 0.6 : 0.3), lineWidth: 1)
                    )
            )
        }
    }
}

// MARK: - Supporting Models

enum InteractionType {
    case tabNavigation
    case tapInteraction
    case todayTab
    case modeSelection
}

struct InteractionStep {
    let type: InteractionType
    let demoTitle: String
    let explanation: String
    let tip: String?
    let color: Color

    static let allSteps: [InteractionStep] = [
        InteractionStep(
            type: .tabNavigation,
            demoTitle: "Навигация по вкладкам",
            explanation: "Переключайтесь между разными разделами карты. Каждая вкладка раскрывает определенный аспект вашей личности.",
            tip: "Начните с вкладки 'Сегодня' — она всегда актуальна!",
            color: .neonCyan
        ),
        InteractionStep(
            type: .tapInteraction,
            demoTitle: "Подробная информация",
            explanation: "Нажимайте на карточки, чтобы узнать больше. Каждый элемент содержит детальные объяснения и практические советы.",
            tip: "Не бойтесь исследовать — все объяснено понятным языком",
            color: .neonPink
        ),
        InteractionStep(
            type: .todayTab,
            demoTitle: "Ежедневная ценность",
            explanation: "Возвращайтесь к вкладке 'Сегодня' каждый день. Здесь вы найдете актуальные астрологические влияния и персональные рекомендации.",
            tip: "Утром загляните сюда за вдохновением на день",
            color: .fireElement
        ),
        InteractionStep(
            type: .modeSelection,
            demoTitle: "Выбор уровня",
            explanation: "В любой момент можете изменить уровень. От простого режима 'Новичок' до экспертного.",
            tip: "Начните с режима 'Новичок', потом переключитесь на более сложный",
            color: .cosmicViolet
        )
    ]
}

#Preview {
    OnboardingInteractiveView(
        coordinator: ChartOnboardingCoordinator(
            birthChart: BirthChart.mock,
            displayModeManager: ChartDisplayModeManager()
        ),
        birthChart: BirthChart.mock
    )
}
