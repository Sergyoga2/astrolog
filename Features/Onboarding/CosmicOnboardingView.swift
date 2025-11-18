//
//  CosmicOnboardingView.swift
//  Astrolog
//
//  Created by Claude on 22.09.2025.
//

// Features/Onboarding/CosmicOnboardingView.swift
import SwiftUI

struct CosmicOnboardingView: View {
    @EnvironmentObject var appCoordinator: AppCoordinator
    @State private var currentStep = 0
    @State private var showingSteps: [Bool] = [true, false, false]
    @State private var animationProgress: Double = 0

    let onboardingSteps = [
        CosmicOnboardingStep(
            title: "Добро пожаловать во Вселенную",
            subtitle: "Откройте тайны звезд и познайте себя через космическую мудрость астрологии",
            icon: "star.circle.fill",
            color: .neonPurple
        ),
        CosmicOnboardingStep(
            title: "Ваша Натальная Карта",
            subtitle: "Создайте персональную карту неба на момент вашего рождения и раскройте свой потенциал",
            icon: "globe.americas.fill",
            color: .neonBlue
        ),
        CosmicOnboardingStep(
            title: "Космические Практики",
            subtitle: "Медитации, аффирмации и астрологические практики для развития и гармонии",
            icon: "leaf.circle.fill",
            color: .neonCyan
        )
    ]

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Космический фон
                StarfieldBackground()

                ScrollView {
                    VStack(spacing: 0) {
                        ForEach(0..<onboardingSteps.count, id: \.self) { index in
                            if showingSteps[index] {
                                CosmicOnboardingStepView(
                                    step: onboardingSteps[index],
                                    geometry: geometry,
                                    isLast: index == onboardingSteps.count - 1,
                                    onNext: {
                                        if index < onboardingSteps.count - 1 {
                                            nextStep(to: index + 1)
                                        } else {
                                            completeOnboarding()
                                        }
                                    },
                                    onSkip: {
                                        completeOnboarding()
                                    }
                                )
                                .transition(.asymmetric(
                                    insertion: .move(edge: .trailing).combined(with: .opacity),
                                    removal: .move(edge: .leading).combined(with: .opacity)
                                ))
                            }
                        }
                    }
                }

                // Прогресс индикатор
                VStack {
                    HStack(spacing: 8) {
                        ForEach(0..<onboardingSteps.count, id: \.self) { index in
                            Capsule()
                                .fill(index <= currentStep ? Color.neonPurple : Color.starWhite.opacity(0.3))
                                .frame(width: index == currentStep ? 24 : 8, height: 8)
                                .modifier(NeonGlow(
                                    color: index <= currentStep ? .neonPurple : .clear,
                                    intensity: index <= currentStep ? 0.8 : 0
                                ))
                                .animation(.spring(response: 0.5, dampingFraction: 0.7), value: currentStep)
                        }
                    }
                    .padding(.top, 60)

                    Spacer()
                }
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.5)) {
                animationProgress = 1.0
            }
        }
    }

    private func nextStep(to step: Int) {
        withAnimation(.spring(response: 0.8, dampingFraction: 0.8)) {
            showingSteps[currentStep] = false
            currentStep = step
            showingSteps[step] = true
        }
    }

    private func completeOnboarding() {
        appCoordinator.completeOnboarding()
    }
}

// MARK: - Onboarding Step Model
struct CosmicOnboardingStep {
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
}

// MARK: - Step View
struct CosmicOnboardingStepView: View {
    let step: CosmicOnboardingStep
    let geometry: GeometryProxy
    let isLast: Bool
    let onNext: () -> Void
    let onSkip: () -> Void

    @State private var iconRotation: Double = 0
    @State private var showContent: Bool = false

    var body: some View {
        VStack {
            Spacer()

            VStack(spacing: CosmicSpacing.large * 2) {
                // Космическая иконка
                ZStack {
                    // Орбитальные кольца
                    ForEach([0.8, 1.0, 1.2], id: \.self) { scale in
                        Circle()
                            .stroke(
                                LinearGradient(
                                    colors: [step.color.opacity(0.3), step.color.opacity(0.1)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 2
                            )
                            .frame(width: 120 * scale, height: 120 * scale)
                            .rotationEffect(.degrees(iconRotation * scale))
                            .modifier(NeonGlow(color: step.color, intensity: 0.4 / scale))
                    }

                    // Центральная иконка
                    Image(systemName: step.icon)
                        .font(.system(size: 60))
                        .foregroundStyle(
                            RadialGradient(
                                colors: [step.color, Color.starWhite],
                                center: .center,
                                startRadius: 10,
                                endRadius: 30
                            )
                        )
                        .modifier(NeonGlow(color: step.color, intensity: 1.2))
                        .scaleEffect(showContent ? 1.0 : 0.1)
                        .animation(.spring(response: 0.8, dampingFraction: 0.6).delay(0.2), value: showContent)
                }
                .frame(height: 160)
                .onAppear {
                    withAnimation(.linear(duration: 20).repeatForever(autoreverses: false)) {
                        iconRotation = 360
                    }
                }

                // Контент
                VStack(spacing: CosmicSpacing.large) {
                    VStack(spacing: CosmicSpacing.medium) {
                        Text(step.title)
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.starWhite, step.color],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .multilineTextAlignment(.center)
                            .opacity(showContent ? 1.0 : 0.0)
                            .offset(y: showContent ? 0 : 50)
                            .animation(.spring(response: 0.8, dampingFraction: 0.8).delay(0.4), value: showContent)

                        Text(step.subtitle)
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.starWhite.opacity(0.8))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, CosmicSpacing.medium)
                            .opacity(showContent ? 1.0 : 0.0)
                            .offset(y: showContent ? 0 : 30)
                            .animation(.spring(response: 0.8, dampingFraction: 0.8).delay(0.6), value: showContent)
                    }

                    // Кнопки
                    VStack(spacing: CosmicSpacing.medium) {
                        CosmicButton(
                            title: isLast ? "Начать путешествие" : "Далее",
                            icon: isLast ? "star.circle.fill" : "arrow.right.circle.fill",
                            color: step.color,
                            action: onNext
                        )
                        .opacity(showContent ? 1.0 : 0.0)
                        .offset(y: showContent ? 0 : 20)
                        .animation(.spring(response: 0.8, dampingFraction: 0.8).delay(0.8), value: showContent)

                        if !isLast {
                            Button(action: onSkip) {
                                Text("Пропустить")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.starWhite.opacity(0.7))
                            }
                            .opacity(showContent ? 1.0 : 0.0)
                            .animation(.spring(response: 0.8, dampingFraction: 0.8).delay(1.0), value: showContent)
                        } else {
                            Button(action: {
                                // appCoordinator.showSubscription()
                            }) {
                                VStack(spacing: 4) {
                                    Text("Узнать о Premium")
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(step.color)

                                    Text("Расширенные функции и персонализация")
                                        .font(.system(size: 12))
                                        .foregroundColor(.starWhite.opacity(0.6))
                                }
                            }
                            .opacity(showContent ? 1.0 : 0.0)
                            .animation(.spring(response: 0.8, dampingFraction: 0.8).delay(1.0), value: showContent)
                        }
                    }
                    .padding(.horizontal, CosmicSpacing.medium)
                }
            }

            Spacer()
        }
        .frame(height: geometry.size.height)
        .padding(.horizontal, CosmicSpacing.medium)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                showContent = true
            }
        }
    }
}

// MARK: - Cosmic Welcome Screen
struct CosmicWelcomeScreen: View {
    @EnvironmentObject var appCoordinator: AppCoordinator
    @State private var showOnboarding = false
    @State private var animationPhase = 0

    var body: some View {
        ZStack {
            StarfieldBackground()

            VStack(spacing: CosmicSpacing.large * 2) {
                Spacer()

                // Космический логотип
                VStack(spacing: CosmicSpacing.large) {
                    ZStack {
                        // Пульсирующее кольцо
                        Circle()
                            .stroke(
                                LinearGradient(
                                    colors: [.neonPurple, .neonBlue, .neonCyan],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 4
                            )
                            .frame(width: 140, height: 140)
                            .modifier(NeonGlow(color: .neonPurple, intensity: 1.5))
                            .scaleEffect(animationPhase == 0 ? 0.8 : 1.2)
                            .opacity(animationPhase == 0 ? 1.0 : 0.3)

                        Image(systemName: "star.circle.fill")
                            .font(.system(size: 80))
                            .foregroundStyle(
                                RadialGradient(
                                    colors: [.starWhite, .neonPurple, .cosmicViolet],
                                    center: .center,
                                    startRadius: 10,
                                    endRadius: 40
                                )
                            )
                            .modifier(NeonGlow(color: .neonPurple, intensity: 1.8))
                    }

                    VStack(spacing: CosmicSpacing.medium) {
                        Text("Astrolog")
                            .font(.system(size: 48, weight: .bold, design: .rounded))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.starWhite, .neonPurple, .neonBlue],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .shimmer()

                        Text("Ваш проводник в мир астрологии")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.starWhite.opacity(0.8))
                            .multilineTextAlignment(.center)
                    }
                }

                Spacer()

                // Кнопка входа
                VStack(spacing: CosmicSpacing.medium) {
                    CosmicButton(
                        title: "Войти в космос",
                        icon: "sparkles",
                        color: .cosmicViolet,
                        action: {
                            withAnimation(.spring(response: 0.8, dampingFraction: 0.8)) {
                                showOnboarding = true
                            }
                        }
                    )

                    Text("Откройте тайны звезд")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.starWhite.opacity(0.6))
                }
                .padding(.horizontal, CosmicSpacing.medium)

                Spacer()
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                animationPhase = 1
            }
        }
        .fullScreenCover(isPresented: $showOnboarding) {
            CosmicOnboardingView()
                .environmentObject(appCoordinator)
        }
    }
}

#Preview("Onboarding") {
    CosmicOnboardingView()
        .environmentObject(AppCoordinator())
}

#Preview("Welcome") {
    CosmicWelcomeScreen()
        .environmentObject(AppCoordinator())
}