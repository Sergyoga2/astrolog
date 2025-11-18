//
//  MoonCalendarCard.swift
//  Astrolog
//
//  Created by Claude on 18.11.2025.
//
// Features/Main/Components/MoonCalendarCard.swift
import SwiftUI

struct MoonCalendarCard: View {
    let moonData: MoonData
    @State private var moonScale: CGFloat = 1.0

    var body: some View {
        CosmicCard(glowColor: .starWhite) {
            VStack(alignment: .leading, spacing: CosmicSpacing.large) {
                // Заголовок с фазой
                HStack(spacing: CosmicSpacing.medium) {
                    ZStack {
                        Circle()
                            .fill(
                                RadialGradient(
                                    colors: [.starWhite, .starWhite.opacity(0.3)],
                                    center: .center,
                                    startRadius: 20,
                                    endRadius: 50
                                )
                            )
                            .frame(width: 80, height: 80)
                            .scaleEffect(moonScale)
                            .modifier(NeonGlow(color: .starWhite, intensity: 0.8))

                        Text(moonData.phase.emoji)
                            .font(.system(size: 40))
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        Text("\(moonData.phase.name) в \(moonData.zodiacSign.displayName)")
                            .font(CosmicTypography.headline)
                            .foregroundColor(.starWhite)

                        Text("День \(moonData.dayOfCycle) лунного цикла")
                            .font(CosmicTypography.caption)
                            .foregroundColor(.starWhite.opacity(0.7))
                    }

                    Spacer()
                }

                CosmicDivider()

                // Рекомендации
                VStack(alignment: .leading, spacing: CosmicSpacing.medium) {
                    Text("📅 Рекомендации на сегодня:")
                        .font(CosmicTypography.body)
                        .fontWeight(.semibold)
                        .foregroundColor(.starWhite)

                    ForEach(moonData.recommendations, id: \.self) { rec in
                        HStack(alignment: .top, spacing: 8) {
                            Text("✓")
                                .foregroundColor(.neonCyan)
                                .fontWeight(.bold)
                            Text(rec)
                                .font(CosmicTypography.caption)
                                .foregroundColor(.starWhite.opacity(0.9))
                        }
                    }
                }

                // Предостережения
                if !moonData.warnings.isEmpty {
                    VStack(alignment: .leading, spacing: CosmicSpacing.medium) {
                        Text("⚠️ Чего избегать:")
                            .font(CosmicTypography.body)
                            .fontWeight(.semibold)
                            .foregroundColor(.starWhite)

                        ForEach(moonData.warnings, id: \.self) { warning in
                            HStack(alignment: .top, spacing: 8) {
                                Text("✗")
                                    .foregroundColor(.cosmicPink)
                                    .fontWeight(.bold)
                                Text(warning)
                                    .font(CosmicTypography.caption)
                                    .foregroundColor(.starWhite.opacity(0.9))
                            }
                        }
                    }
                }

                CosmicDivider()

                // Следующая фаза
                VStack(alignment: .leading, spacing: CosmicSpacing.small) {
                    HStack {
                        Text("⏳")
                        Text("До Новолуния: \(moonData.nextPhase.countdown)")
                            .font(CosmicTypography.caption)
                            .foregroundColor(.starYellow)
                            .fontWeight(.semibold)
                    }

                    Text("🌑 \(moonData.nextPhase.name) будет в \(moonData.nextPhase.zodiacSign)")
                        .font(CosmicTypography.caption)
                        .foregroundColor(.starWhite.opacity(0.8))

                    Text("→ \(moonData.nextPhase.description)")
                        .font(.caption2)
                        .foregroundColor(.starWhite.opacity(0.7))
                        .italic()
                }

                // Void of Course
                if let voidOfCourse = moonData.voidOfCourse {
                    CosmicDivider()

                    VStack(alignment: .leading, spacing: CosmicSpacing.small) {
                        Text("🌙 Void of Course (холостой ход Луны):")
                            .font(CosmicTypography.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.neonPurple)

                        Text("Сегодня \(voidOfCourse.formatted())")
                            .font(CosmicTypography.caption)
                            .foregroundColor(.starWhite.opacity(0.8))

                        Text("В это время: отдыхайте, не принимайте важных решений")
                            .font(.caption2)
                            .foregroundColor(.starWhite.opacity(0.6))
                            .italic()
                    }
                }
            }
        }
        .onAppear {
            withAnimation(
                .easeInOut(duration: 3)
                .repeatForever(autoreverses: true)
            ) {
                moonScale = 1.1
            }
        }
    }
}

#Preview {
    ZStack {
        StarfieldBackground()
            .ignoresSafeArea()

        ScrollView {
            MoonCalendarCard(moonData: .mock)
                .padding()
        }
    }
}
