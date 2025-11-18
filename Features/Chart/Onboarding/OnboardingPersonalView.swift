//
//  OnboardingPersonalView.swift
//  Astrolog
//
//  Created by Claude on 26.10.2025.
//

// Features/Chart/Onboarding/OnboardingPersonalView.swift
import SwiftUI

/// Экран персональных инсайтов - показ уникальных особенностей карты пользователя
struct OnboardingPersonalView: View {
    @ObservedObject var coordinator: ChartOnboardingCoordinator
    let birthChart: BirthChart

    @State private var currentInsight = 0
    @State private var showContent = false
    
    private var personalInsights: [OnboardingPersonalInsight] {
        generateOnboardingPersonalInsights()
    }

    var body: some View {
        ZStack {
            StarfieldBackground()
                .ignoresSafeArea()

            VStack(spacing: CosmicSpacing.large) {
                // Заголовок
                headerSection
                    .opacity(showContent ? 1.0 : 0.0)
                    
                Spacer()

                // Персональный инсайт
                if !personalInsights.isEmpty {
                    insightCard(personalInsights[currentInsight])
                        .opacity(showContent ? 1.0 : 0.0)
                        .scaleEffect(showContent ? 1.0 : 0.9)
                                        }

                Spacer()

                // Навигация
                navigationSection
                    .opacity(showContent ? 1.0 : 0.0)
                                }
            .padding(CosmicSpacing.large)
        }
        .onAppear {
            showContent = true
        }
    }

    // MARK: - Header
    private var headerSection: some View {
        VStack(spacing: CosmicSpacing.small) {
            Text("Уникальные особенности именно вашей натальной карты")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.starWhite)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    // MARK: - Insight Card
    private func insightCard(_ insight: OnboardingPersonalInsight) -> some View {
        VStack(spacing: CosmicSpacing.large) {
            // Основной инсайт
            VStack(spacing: CosmicSpacing.medium) {
                // Эмодзи и заголовок
                VStack(spacing: CosmicSpacing.small) {
                    Text(insight.emoji)
                        .font(.system(size: 60))

                    Text(insight.title)
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.starWhite)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                }

                // Описание
                Text(insight.description)
                    .font(.body)
                    .foregroundColor(.starWhite.opacity(0.9))
                    .lineSpacing(4)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal, CosmicSpacing.small)
            }
            .padding(CosmicSpacing.large)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(insight.color.opacity(0.4), lineWidth: 2)
                    )
            )
            .modifier(NeonGlow(color: insight.color, intensity: 0.4))

            // Практический совет (если есть)
            if let advice = insight.practicalAdvice {
                practicalAdviceSection(advice, color: insight.color)
            }
        }
    }

    private func practicalAdviceSection(_ advice: String, color: Color) -> some View {
        VStack(spacing: CosmicSpacing.small) {
            HStack {
                Text("💡")
                    .font(.title3)
                Text("Практический совет:")
                    .font(.headline)
                    .foregroundColor(color)
                    .fixedSize(horizontal: false, vertical: true)
                Spacer()
            }

            Text(advice)
                .font(.body)
                .foregroundColor(.starWhite.opacity(0.9))
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)
                .lineSpacing(2)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
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

    // MARK: - Navigation
    private var navigationSection: some View {
        VStack(spacing: CosmicSpacing.medium) {
            // Прогресс по инсайтам
            if personalInsights.count > 1 {
                insightProgressIndicator
            }

            // Кнопки навигации по инсайтам
            HStack(spacing: CosmicSpacing.medium) {
                if personalInsights.count > 1 {
                    Button(action: previousInsight) {
                        HStack {
                            Image(systemName: "chevron.left")
                            Text("Предыдущий")
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .foregroundColor(currentInsight > 0 ? .starWhite : .starWhite.opacity(0.4))
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
                    .disabled(currentInsight == 0)
                }

                Spacer()

                if currentInsight < personalInsights.count - 1 {
                    Button(action: nextInsight) {
                        HStack {
                            Text("Следующий")
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
                        title: "Интересно!",
                        color: .positive
                    ) {
                        coordinator.nextStep()
                    }
                }
            }

        }
    }

    private var insightProgressIndicator: some View {
        HStack(spacing: 6) {
            ForEach(0..<personalInsights.count, id: \.self) { index in
                Circle()
                    .fill(index == currentInsight ? Color.neonPink : Color.starWhite.opacity(0.4))
                    .frame(width: index == currentInsight ? 12 : 8, height: index == currentInsight ? 12 : 8)
                                }
        }
    }

    // MARK: - Helper Methods
    private func nextInsight() {
        if currentInsight < personalInsights.count - 1 {
            currentInsight += 1
        }
    }

    private func previousInsight() {
        if currentInsight > 0 {
            currentInsight -= 1
        }
    }

    private func generateOnboardingPersonalInsights() -> [OnboardingPersonalInsight] {
        let humanService = HumanLanguageService()
        var insights: [OnboardingPersonalInsight] = []

        // Инсайт на основе Солнца
        if let sun = birthChart.planets.first(where: { $0.type == .sun }) {
            let sunTranslation = humanService.translateZodiacSign(sun.zodiacSign)
            insights.append(
                OnboardingPersonalInsight(
                    title: "Ваша уникальная сила",
                    description: "Ваша основная энергия проявляется как \(sunTranslation.personality.lowercased()). Это ваша естественная суперсила, которая помогает вам выделяться среди других.",
                    emoji: humanService.signEmoji(sun.zodiacSign),
                    color: .starYellow,
                    practicalAdvice: "Используйте свою \(sunTranslation.strengths.first?.lowercased() ?? "индивидуальность") в важных жизненных решениях. Это ваш путь к успеху."
                )
            )
        }

        // Инсайт на основе Луны
        if let moon = birthChart.planets.first(where: { $0.type == .moon }) {
            let moonTranslation = humanService.translateZodiacSign(moon.zodiacSign)
            insights.append(
                OnboardingPersonalInsight(
                    title: "Ваш эмоциональный код",
                    description: "Для эмоционального счастья вам важно то, что \(moonTranslation.personality.lowercased()). Это ключ к пониманию ваших глубинных потребностей.",
                    emoji: "🌙",
                    color: .waterElement,
                    practicalAdvice: "Когда чувствуете стресс, помните: вам нужна \(moonTranslation.strengths.first?.lowercased() ?? "эмоциональная безопасность"). Создавайте для себя такую среду."
                )
            )
        }

        // Инсайт на основе Асцендента
        let ascTranslation = humanService.translateZodiacSign(birthChart.ascendant)
        insights.append(
            OnboardingPersonalInsight(
                title: "Ваша природная харизма",
                description: "Люди естественно воспринимают вас как человека, который \(ascTranslation.personality.lowercased()). Это ваш природный магнетизм в общении.",
                emoji: "✨",
                color: .airElement,
                practicalAdvice: "В новых знакомствах полагайтесь на свою естественную \(ascTranslation.strengths.first?.lowercased() ?? "привлекательность"). Люди это чувствуют."
            )
        )

        return insights
    }
}

// MARK: - Supporting Models

struct OnboardingPersonalInsight {
    let title: String
    let description: String
    let emoji: String
    let color: Color
    let practicalAdvice: String?
}

#Preview {
    OnboardingPersonalView(
        coordinator: ChartOnboardingCoordinator(
            birthChart: BirthChart.mock,
            displayModeManager: ChartDisplayModeManager()
        ),
        birthChart: BirthChart.mock
    )
}