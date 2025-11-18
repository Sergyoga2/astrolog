//
//  OnboardingBasicsView.swift
//  Astrolog
//
//  Created by Claude on 26.10.2025.
//

// Features/Chart/Onboarding/OnboardingBasicsView.swift
import SwiftUI

/// Экран объяснения основ - знакомство с большой тройкой
struct OnboardingBasicsView: View {
    @ObservedObject var coordinator: ChartOnboardingCoordinator
    let birthChart: BirthChart

    @State private var currentExplanation = 0
    @State private var showExplanations = false
    
    private let explanations = BigThreeExplanation.all

    var body: some View {
        ZStack {
            StarfieldBackground()
                .ignoresSafeArea()

            VStack(spacing: CosmicSpacing.large) {
                // Отступ от верха
                Spacer()
                    .frame(height: CosmicSpacing.medium)

                // Заголовок
                headerSection
                    .opacity(showExplanations ? 1.0 : 0.0)

                // Основное содержимое
                Spacer()

                explanationContent
                    .opacity(showExplanations ? 1.0 : 0.0)
                                        
                Spacer()

                // Навигация
                navigationSection
                    .opacity(showExplanations ? 1.0 : 0.0)
                                }
            .padding(CosmicSpacing.large)
            .padding(.top, CosmicSpacing.small) // Дополнительный отступ от safe area
        }
        .onAppear {
            showExplanations = true
        }
    }

    // MARK: - Header
    private var headerSection: some View {
        VStack(spacing: CosmicSpacing.small) {
            Text("Три главных элемента, которые формируют вашу личность")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.starWhite)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    // MARK: - Explanation Content
    private var explanationContent: some View {
        let currentExp = explanations[currentExplanation]

        return VStack(spacing: CosmicSpacing.large) {
            // Символ и эмодзи
            symbolSection(for: currentExp)

            // Объяснение
            explanationCard(for: currentExp)
        }
    }

    private func symbolSection(for explanation: BigThreeExplanation) -> some View {
        ZStack {
            // Фоновое свечение
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            explanation.color.opacity(0.4),
                            explanation.color.opacity(0.1),
                            Color.clear
                        ],
                        center: .center,
                        startRadius: 30,
                        endRadius: 80
                    )
                )
                .frame(width: 160, height: 160)

            // Эмодзи
            Text(explanation.emoji)
                .font(.system(size: 80))
                .shadow(color: explanation.color, radius: 10)

            // Пульсирующее кольцо
            Circle()
                .stroke(explanation.color.opacity(0.6), lineWidth: 3)
                .frame(width: 120, height: 120)
                .scaleEffect(1.0 + sin(Date().timeIntervalSinceReferenceDate * 2) * 0.05)
                        }
    }

    private func explanationCard(for explanation: BigThreeExplanation) -> some View {
        VStack(spacing: CosmicSpacing.medium) {
            // Заголовок
            VStack(spacing: CosmicSpacing.small) {
                Text("\(explanation.title) - \(explanation.subtitle)")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.starWhite)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }

            // Объяснение
            Text(explanation.explanation)
                .font(.body)
                .foregroundColor(.starWhite.opacity(0.9))
                .lineSpacing(4)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)

            // Персональная информация для этого пользователя
            if let personalInfo = getPersonalInfo(for: explanation) {
                personalInfoSection(personalInfo, color: explanation.color)
            }
        }
        .padding(CosmicSpacing.large)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(explanation.color.opacity(0.3), lineWidth: 2)
                )
        )
        .modifier(NeonGlow(color: explanation.color, intensity: 0.3))
    }

    private func personalInfoSection(_ info: String, color: Color) -> some View {
        VStack(spacing: CosmicSpacing.small) {
            Text("Лично для вас:")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(color)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)

            Text(info)
                .font(.body)
                .fontWeight(.medium)
                .foregroundColor(color)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .lineSpacing(2)
                .padding(CosmicSpacing.medium)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(color.opacity(0.1))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(color.opacity(0.3), lineWidth: 1)
                        )
                )
        }
    }

    // MARK: - Navigation
    private var navigationSection: some View {
        VStack(spacing: CosmicSpacing.medium) {
            // Индикатор прогресса
            explanationProgressIndicator

            // Кнопки навигации по объяснениям
            HStack(spacing: CosmicSpacing.medium) {
                Button(action: previousExplanation) {
                    HStack {
                        Image(systemName: "chevron.left")
                        Text("Назад")
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .foregroundColor(currentExplanation > 0 ? .starWhite : .starWhite.opacity(0.4))
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
                .disabled(currentExplanation == 0)

                Spacer()

                if currentExplanation < explanations.count - 1 {
                    Button(action: nextExplanation) {
                        HStack {
                            Text("Далее")
                                .fixedSize(horizontal: false, vertical: true)
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
                        title: "Понятно!",
                        icon: "checkmark",
                        color: .positive
                    ) {
                        coordinator.nextStep()
                    }
                }
            }

            // Общий прогресс онбординга
            HStack(spacing: 8) {
                ForEach(0..<4, id: \.self) { index in
                    Circle()
                        .fill(index <= 1 ? Color.neonCyan : Color.starWhite.opacity(0.3))
                        .frame(width: 8, height: 8)
                }
            }
            .padding(.top, CosmicSpacing.small)
        }
    }

    private var explanationProgressIndicator: some View {
        HStack(spacing: 4) {
            ForEach(0..<explanations.count, id: \.self) { index in
                RoundedRectangle(cornerRadius: 2)
                    .fill(index <= currentExplanation ? explanations[currentExplanation].color : Color.starWhite.opacity(0.3))
                    .frame(width: index == currentExplanation ? 24 : 8, height: 4)
                                }
        }
    }

    // MARK: - Helper Methods
    private func nextExplanation() {
        if currentExplanation < explanations.count - 1 {
            currentExplanation += 1
        }
    }

    private func previousExplanation() {
        if currentExplanation > 0 {
            currentExplanation -= 1
        }
    }

    private func getPersonalInfo(for explanation: BigThreeExplanation) -> String? {
        let humanService = HumanLanguageService()

        switch explanation.type {
        case .sun:
            guard let sun = birthChart.planets.first(where: { $0.type == .sun }) else { return nil }
            let translation = humanService.translateZodiacSign(sun.zodiacSign)
            return "Вы \(translation.humanName.lowercased())"

        case .moon:
            guard let moon = birthChart.planets.first(where: { $0.type == .moon }) else { return nil }
            let translation = humanService.translateZodiacSign(moon.zodiacSign)
            return "Эмоционально вы \(translation.personality.lowercased())"

        case .ascendant:
            let translation = humanService.translateZodiacSign(birthChart.ascendant)
            return "Люди видят вас как \(translation.humanName.lowercased())"

        default:
            return nil
        }
    }
}

// MARK: - Supporting Models

struct BigThreeExplanation {
    let type: PlanetType
    let title: String
    let subtitle: String
    let emoji: String
    let explanation: String
    let color: Color

    static let all: [BigThreeExplanation] = [
        BigThreeExplanation(
            type: .sun,
            title: "Ваша суть",
            subtitle: "Солнце в астрологии",
            emoji: "☀️",
            explanation: "Это то, кем вы являетесь в глубине души. Ваша основная энергия, творческая сила и то, что делает вас уникальным. Солнце показывает, как вы самовыражаетесь и к чему стремитесь в жизни.",
            color: .starYellow
        ),
        BigThreeExplanation(
            type: .moon,
            title: "Ваши эмоции",
            subtitle: "Луна в астрологии",
            emoji: "🌙",
            explanation: "Это ваш внутренний мир и эмоциональная природа. Луна показывает, что вам нужно для счастья, как вы чувствуете и реагируете на жизненные события. Это ваша интуиция и подсознание.",
            color: .waterElement
        ),
        BigThreeExplanation(
            type: .ascendant,
            title: "Ваша подача",
            subtitle: "Асцендент в астрологии",
            emoji: "🎭",
            explanation: "Это то, как вас воспринимают другие люди при первой встрече. Ваш естественный стиль поведения, манера общения и подход к жизни. Это ваша 'маска' или внешняя личность.",
            color: .airElement
        )
    ]
}

#Preview {
    OnboardingBasicsView(
        coordinator: ChartOnboardingCoordinator(
            birthChart: BirthChart.mock,
            displayModeManager: ChartDisplayModeManager()
        ),
        birthChart: BirthChart.mock
    )
}
