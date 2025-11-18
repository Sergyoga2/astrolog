//
//  ChartOnboardingOverlay.swift
//  Astrolog
//
//  Created by Claude on 21.10.2025.
//

// Features/Chart/Onboarding/ChartOnboardingOverlay.swift
import SwiftUI
import Combine

/// Оверлей для отображения онбординга с пошаговыми подсказками
struct ChartOnboardingOverlay<T: OnboardingFlowProtocol>: View {
    @ObservedObject var onboardingFlow: T
    @EnvironmentObject var tooltipService: TooltipService

    // Анимации и состояния
    @State private var spotlightPosition: CGPoint = .zero
    @State private var spotlightRadius: CGFloat = 100
    @State private var overlayOpacity: Double = 0.0
    @State private var contentOffset: CGSize = .zero
    @State private var pulseAnimation: Bool = false

    // Геометрия для позиционирования
    @State private var screenSize: CGSize = .zero

    var body: some View {
        ZStack {
            if onboardingFlow.isActive, let currentStep = onboardingFlow.currentStep {
                // Затемненный фон с вырезом-прожектором
                spotlightOverlay(for: currentStep)

                // Контент подсказки
                stepContentView(currentStep)
                    .transition(.asymmetric(
                        insertion: .opacity.combined(with: .scale(scale: 0.9)),
                        removal: .opacity.combined(with: .scale(scale: 0.9))
                    ))

                // Элементы управления
                onboardingControls
                    .transition(.opacity.combined(with: .move(edge: .bottom)))

                // Прогресс-индикатор
                progressIndicator
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .opacity(overlayOpacity)
        .allowsHitTesting(onboardingFlow.isActive)
        .ignoresSafeArea()
        .onChange(of: onboardingFlow.isActive) { isActive in
            withAnimation(.easeInOut(duration: 0.4)) {
                overlayOpacity = isActive ? 1.0 : 0.0
            }
        }
        .onChange(of: onboardingFlow.currentStep) { newStep in
            if let step = newStep {
                updateSpotlightForStep(step)
            }
        }
        .onAppear {
            setupInitialState()
        }
    }

    // MARK: - Spotlight Overlay
    private func spotlightOverlay(for step: OnboardingStepData) -> some View {
        Rectangle()
            .fill(
                RadialGradient(
                    colors: [
                        Color.clear,
                        Color.spaceBlack.opacity(0.3),
                        Color.spaceBlack.opacity(0.8)
                    ],
                    center: UnitPoint(
                        x: spotlightPosition.x / screenSize.width,
                        y: spotlightPosition.y / screenSize.height
                    ),
                    startRadius: spotlightRadius * 0.8,
                    endRadius: spotlightRadius * 2.5
                )
            )
            .overlay(
                // Анимированное кольцо вокруг подсвеченной области
                Circle()
                    .stroke(
                        LinearGradient(
                            colors: [.neonCyan, .cosmicViolet],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 3
                    )
                    .frame(width: spotlightRadius * 2, height: spotlightRadius * 2)
                    .position(spotlightPosition)
                    .scaleEffect(pulseAnimation ? 1.1 : 1.0)
                    .opacity(step.targetElement != nil ? 1.0 : 0.0)
            )
            .animation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true), value: pulseAnimation)
    }

    // MARK: - Step Content View
    private func stepContentView(_ step: OnboardingStepData) -> some View {
        VStack(spacing: 0) {
            Spacer()

            // Карточка с контентом шага
            ChartOnboardingStepCard(
                step: step,
                onNext: onboardingFlow.nextStep,
                onPrevious: onboardingFlow.hasPreviousStep ? onboardingFlow.previousStep : nil,
                onSkip: onboardingFlow.canSkip ? onboardingFlow.skipOnboarding : nil
            )
            .padding(.horizontal, CosmicSpacing.large)
            .offset(contentOffset)

            Spacer()
                .frame(height: 100) // Место для контролов
        }
    }

    // MARK: - Onboarding Controls
    private var onboardingControls: some View {
        VStack {
            Spacer()

            HStack(spacing: CosmicSpacing.large) {
                // Кнопка "Назад"
                if onboardingFlow.hasPreviousStep {
                    OnboardingControlButton(
                        title: "Назад",
                        icon: "chevron.left",
                        style: .secondary,
                        action: onboardingFlow.previousStep
                    )
                }

                Spacer()

                // Кнопка "Пропустить"
                if onboardingFlow.canSkip {
                    OnboardingControlButton(
                        title: "Пропустить",
                        icon: "xmark",
                        style: .tertiary,
                        action: onboardingFlow.skipOnboarding
                    )
                }

                // Кнопка "Далее" или "Готово"
                OnboardingControlButton(
                    title: onboardingFlow.hasNextStep ? "Далее" : "Готово",
                    icon: onboardingFlow.hasNextStep ? "chevron.right" : "checkmark",
                    style: .primary,
                    action: onboardingFlow.nextStep
                )
            }
            .padding(.horizontal, CosmicSpacing.large)
            .padding(.bottom, CosmicSpacing.large)
        }
    }

    // MARK: - Progress Indicator
    private var progressIndicator: some View {
        VStack {
            OnboardingProgressView(progressInfo: onboardingFlow.progressInfo)
                .padding(.horizontal, CosmicSpacing.large)
                .padding(.top, CosmicSpacing.large)

            Spacer()
        }
    }

    // MARK: - Helper Methods
    private func setupInitialState() {
        // Получаем размер экрана
        screenSize = UIScreen.main.bounds.size
        spotlightPosition = CGPoint(x: screenSize.width / 2, y: screenSize.height / 2)

        // Запускаем анимацию пульсации
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            pulseAnimation = true
        }
    }

    private func updateSpotlightForStep(_ step: OnboardingStepData) {
        guard let targetElement = step.targetElement else {
            // Нет конкретного элемента для подсветки
            withAnimation(.easeInOut(duration: 0.6)) {
                spotlightPosition = CGPoint(x: screenSize.width / 2, y: screenSize.height / 2)
                spotlightRadius = 150
            }
            return
        }

        // Вычисляем позицию и размер подсветки для конкретного элемента
        let (position, radius) = calculateSpotlightGeometry(for: targetElement, step: step)

        withAnimation(.spring(response: 0.8, dampingFraction: 0.7)) {
            spotlightPosition = position
            spotlightRadius = radius
        }

        // Адаптируем позицию контента в зависимости от расположения подсветки
        updateContentPosition(for: position)
    }

    private func calculateSpotlightGeometry(
        for element: OnboardingTargetElement,
        step: OnboardingStepData
    ) -> (CGPoint, CGFloat) {
        // Базовые позиции для разных элементов
        let position: CGPoint
        let radius: CGFloat

        switch element {
        case .header(.modeSelector):
            position = CGPoint(x: screenSize.width / 2, y: 120)
            radius = 80

        case .header(.chartInfo):
            position = CGPoint(x: screenSize.width / 2, y: 80)
            radius = 100

        case .tabBar(.all):
            position = CGPoint(x: screenSize.width / 2, y: screenSize.height - 150)
            radius = 120

        case .tabBar(.overview):
            position = CGPoint(x: screenSize.width * 0.2, y: screenSize.height - 150)
            radius = 60

        case .chart(.planets):
            position = CGPoint(x: screenSize.width / 2, y: screenSize.height * 0.4)
            radius = 100

        case .chart(.center):
            position = CGPoint(x: screenSize.width / 2, y: screenSize.height * 0.4)
            radius = 50

        case .overview(.bigThree):
            position = CGPoint(x: screenSize.width / 2, y: screenSize.height * 0.35)
            radius = 120

        default:
            position = CGPoint(x: screenSize.width / 2, y: screenSize.height / 2)
            radius = 100
        }

        return (position, radius)
    }

    private func updateContentPosition(for spotlightPosition: CGPoint) {
        // Адаптируем позицию контента, чтобы он не перекрывал подсвеченную область
        let screenCenter = screenSize.height / 2
        let newOffset: CGSize

        if spotlightPosition.y < screenCenter {
            // Подсветка сверху - контент вниз
            newOffset = CGSize(width: 0, height: 50)
        } else {
            // Подсветка снизу - контент вверх
            newOffset = CGSize(width: 0, height: -50)
        }

        withAnimation(.easeInOut(duration: 0.6)) {
            contentOffset = newOffset
        }
    }
}

// MARK: - Supporting Views

/// Карточка с содержимым шага онбординга
struct ChartOnboardingStepCard: View {
    let step: OnboardingStepData
    let onNext: () -> Void
    let onPrevious: (() -> Void)?
    let onSkip: (() -> Void)?

    var body: some View {
        VStack(spacing: CosmicSpacing.large) {
            // Иконка типа шага
            stepTypeIcon
                .foregroundColor(.neonCyan)
                .font(.system(size: 40))

            // Заголовок
            Text(step.title)
                .font(CosmicTypography.title)
                .fontWeight(.bold)
                .foregroundColor(.starWhite)
                .multilineTextAlignment(.center)

            // Описание
            Text(step.description)
                .font(.title3)
                .foregroundColor(.starWhite.opacity(0.9))
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)

            // Дополнительная информация для образовательных шагов
            if step.type == .education {
                educationalHint
            }
        }
        .padding(CosmicSpacing.large)
        .background(cardBackground)
        .cornerRadius(20)
        .shadow(
            color: .spaceBlack.opacity(0.5),
            radius: 15,
            x: 0, y: 8
        )
    }

    private var stepTypeIcon: some View {
        Group {
            switch step.type {
            case .introduction:
                Image(systemName: "star.fill")
            case .feature:
                Image(systemName: "sparkles")
            case .education:
                Image(systemName: "book.fill")
            case .navigation:
                Image(systemName: "arrow.left.arrow.right")
            case .interaction:
                Image(systemName: "hand.tap.fill")
            case .completion:
                Image(systemName: "checkmark.circle.fill")
            case .modeTransition:
                Image(systemName: "arrow.triangle.2.circlepath")
            case .featureAnnouncement:
                Image(systemName: "megaphone.fill")
            }
        }
    }

    private var educationalHint: some View {
        HStack(spacing: CosmicSpacing.small) {
            Image(systemName: "lightbulb.fill")
                .foregroundColor(.starYellow)

            Text("Совет: Возвращайтесь к этой информации в любое время через глоссарий")
                .font(.caption)
                .foregroundColor(.starWhite.opacity(0.8))
                .italic()
        }
        .padding(CosmicSpacing.small)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.starYellow.opacity(0.1))
        )
    }

    private var cardBackground: some View {
        RoundedRectangle(cornerRadius: 20)
            .fill(
                LinearGradient(
                    colors: [
                        .cosmicViolet.opacity(0.9),
                        .cosmicPurple.opacity(0.8),
                        .cosmicDarkPurple.opacity(0.9)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .background(.ultraThinMaterial)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(
                        LinearGradient(
                            colors: [.neonCyan.opacity(0.6), .cosmicViolet.opacity(0.3)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
    }
}

/// Кнопка управления онбордингом
struct OnboardingControlButton: View {
    let title: String
    let icon: String
    let style: ButtonStyle
    let action: () -> Void

    enum ButtonStyle {
        case primary, secondary, tertiary
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: CosmicSpacing.tiny) {
                if style != .primary {
                    Image(systemName: icon)
                        .font(.caption)
                }

                Text(title)
                    .fontWeight(.semibold)

                if style == .primary {
                    Image(systemName: icon)
                        .font(.caption)
                }
            }
            .foregroundColor(foregroundColor)
            .padding(.horizontal, style == .primary ? CosmicSpacing.large : CosmicSpacing.medium)
            .padding(.vertical, CosmicSpacing.small)
            .background(backgroundColor)
            .cornerRadius(25)
            .shadow(color: shadowColor, radius: style == .primary ? 8 : 4)
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(1.0)
        .animation(.easeInOut(duration: 0.1), value: UUID())
    }

    private var foregroundColor: Color {
        switch style {
        case .primary: return .cosmicDarkPurple
        case .secondary: return .starWhite
        case .tertiary: return .starWhite.opacity(0.8)
        }
    }

    private var backgroundColor: some View {
        Group {
            switch style {
            case .primary:
                LinearGradient(
                    colors: [.neonCyan, .cosmicViolet],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            case .secondary:
                Color.cosmicPurple.opacity(0.8)
            case .tertiary:
                Color.clear
            }
        }
    }

    private var shadowColor: Color {
        switch style {
        case .primary: return .neonCyan.opacity(0.5)
        case .secondary: return .cosmicPurple.opacity(0.3)
        case .tertiary: return .clear
        }
    }
}

/// Индикатор прогресса онбординга
struct OnboardingProgressView: View {
    let progressInfo: OnboardingProgressInfo

    var body: some View {
        VStack(spacing: CosmicSpacing.small) {
            // Текстовый индикатор
            HStack {
                Text(progressInfo.progressText)
                    .font(.caption)
                    .foregroundColor(.starWhite.opacity(0.8))

                Spacer()

                Text("\(Int(progressInfo.progress * 100))%")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.neonCyan)
            }

            // Прогресс-бар
            ProgressView(value: progressInfo.progress)
                .progressViewStyle(CosmicProgressStyle())
        }
        .padding(CosmicSpacing.medium)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.cosmicPurple.opacity(0.3))
                .background(.ultraThinMaterial)
        )
    }
}

/// Кастомный стиль для прогресс-бара
struct CosmicProgressStyle: ProgressViewStyle {
    func makeBody(configuration: Configuration) -> some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Фон
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.cosmicPurple.opacity(0.3))
                    .frame(height: 8)

                // Заполнение
                RoundedRectangle(cornerRadius: 4)
                    .fill(
                        LinearGradient(
                            colors: [.neonCyan, .cosmicViolet],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(
                        width: geometry.size.width * CGFloat(configuration.fractionCompleted ?? 0),
                        height: 8
                    )
                    .animation(.easeInOut(duration: 0.6), value: configuration.fractionCompleted)
            }
        }
        .frame(height: 8)
    }
}

// MARK: - Preview
struct ChartOnboardingOverlay_Previews: PreviewProvider {
    static var previews: some View {
        // Simplified preview to avoid complex dependencies
        Text("ChartOnboardingOverlay Preview")
            .foregroundColor(.starWhite)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(CosmicGradients.mainCosmic)
            .previewDevice("iPhone 15")
    }
}