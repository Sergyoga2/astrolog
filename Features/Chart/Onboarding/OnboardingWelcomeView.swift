//
//  OnboardingWelcomeView.swift
//  Astrolog
//
//  Created by Claude on 26.10.2025.
//

// Features/Chart/Onboarding/OnboardingWelcomeView.swift
import SwiftUI

/// Экран приветствия онбординга - первое знакомство с астрологией
struct OnboardingWelcomeView: View {
    @ObservedObject var coordinator: ChartOnboardingCoordinator
    let birthChart: BirthChart


    var body: some View {
        ZStack {
            StarfieldBackground()
                .ignoresSafeArea()

            VStack(spacing: CosmicSpacing.large) {
                Spacer()

                // Космический символ приветствия
                welcomeSymbol

                // Основной контент
                welcomeContent

                Spacer()

                // Кнопки навигации
                navigationButtons
            }
            .padding(CosmicSpacing.large)
        }
    }

    // MARK: - Welcome Symbol
    private var welcomeSymbol: some View {
        ZStack {
            // Пульсирующий круг
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            .starYellow.opacity(0.3),
                            .cosmicViolet.opacity(0.6),
                            .cosmicPurple.opacity(0.2)
                        ],
                        center: .center,
                        startRadius: 20,
                        endRadius: 80
                    )
                )
                .frame(width: 160, height: 160)

            // Центральная звезда
            Text("✨")
                .font(.system(size: 60))
                .shadow(color: .starYellow, radius: 10)

            // Статичные орбитальные элементы
            ForEach(0..<3, id: \.self) { index in
                staticPlanetarySymbol(index: index)
            }
        }
    }

    private func staticPlanetarySymbol(index: Int) -> some View {
        let symbols = ["☀️", "🌙", "⭐"]
        let radius = 100.0
        let angle = Double(index) * 120.0  // Статичные позиции

        return Text(symbols[index])
            .font(.system(size: 20))
            .offset(
                x: cos(angle * .pi / 180) * radius,
                y: sin(angle * .pi / 180) * radius
            )
    }

    // MARK: - Welcome Content
    private var welcomeContent: some View {
        VStack(spacing: CosmicSpacing.large) {
            // Заголовок
            VStack(spacing: CosmicSpacing.medium) {
                Text(ChartOnboardingStep.welcome.title)
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.starWhite)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)

                Text(ChartOnboardingStep.welcome.description)
                    .font(.title3)
                    .foregroundColor(.starWhite.opacity(0.9))
                    .multilineTextAlignment(.center)
                    .lineSpacing(3)
                    .fixedSize(horizontal: false, vertical: true)
            }

            // Что вас ждет
            whatAwaitsSection
        }
    }

    private var whatAwaitsSection: some View {
        VStack(spacing: CosmicSpacing.medium) {
            Text(ChartOnboardingStep.whatAwaitsTitle)
                .font(.headline)
                .foregroundColor(.neonCyan)
                .multilineTextAlignment(.center)

            VStack(spacing: CosmicSpacing.small) {
                ForEach(ChartOnboardingStep.welcomeFeatures, id: \.title) { feature in
                    featureRow(
                        icon: feature.icon,
                        title: feature.title,
                        description: feature.description
                    )
                }
            }
        }
        .padding(CosmicSpacing.medium)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.starWhite.opacity(0.2), lineWidth: 1)
                )
        )
    }

    private func featureRow(icon: String, title: String, description: String) -> some View {
        HStack(alignment: .top, spacing: CosmicSpacing.medium) {
            Text(icon)
                .font(.title2)
                .frame(minWidth: 30, alignment: .center)

            VStack(alignment: .leading, spacing: CosmicSpacing.tiny) {
                Text(title)
                    .font(.body)
                    .fontWeight(.semibold)
                    .foregroundColor(.starWhite)
                    .fixedSize(horizontal: false, vertical: true)

                Text(description)
                    .font(.caption)
                    .foregroundColor(.starWhite.opacity(0.7))
                    .fixedSize(horizontal: false, vertical: true)
                    .lineSpacing(2)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    // MARK: - Navigation
    private var navigationButtons: some View {
        VStack(spacing: CosmicSpacing.medium) {
            // Прогресс
            progressIndicator

            HStack(spacing: CosmicSpacing.medium) {
                // Пропустить
                Button(ChartOnboardingStep.skipButtonTitle) {
                    coordinator.skipOnboarding()
                }
                .font(.body)
                .foregroundColor(.starWhite.opacity(0.6))

                Spacer()

                // Начать знакомство
                CosmicButton(
                    title: ChartOnboardingStep.startButtonTitle,
                    icon: "arrow.right",
                    color: .positive
                ) {
                    coordinator.nextStep()
                }
            }
        }
    }

    private var progressIndicator: some View {
        HStack(spacing: 8) {
            ForEach(0..<4, id: \.self) { index in
                Circle()
                    .fill(index == 0 ? Color.starYellow : Color.starWhite.opacity(0.3))
                    .frame(width: 8, height: 8)
            }
        }
    }
}

// MARK: - Preview
#Preview {
    OnboardingWelcomeView(
        coordinator: ChartOnboardingCoordinator(
            birthChart: BirthChart.mock,
            displayModeManager: ChartDisplayModeManager()
        ),
        birthChart: BirthChart.mock
    )
}