//
//  DailyAdviceCard.swift
//  Astrolog
//
//  Created by Claude on 18.11.2025.
//
// Features/Main/Components/DailyAdviceCard.swift
import SwiftUI

struct DailyAdviceCard: View {
    let advice: DailyAdvice

    var body: some View {
        CosmicCard(glowColor: colorForType(advice.type)) {
            VStack(alignment: .leading, spacing: CosmicSpacing.medium) {
                // Заголовок
                HStack {
                    Text(advice.type.icon)
                        .font(.title2)

                    Text(advice.type.title)
                        .font(CosmicTypography.body)
                        .fontWeight(.semibold)
                        .foregroundColor(.starWhite)

                    Spacer()
                }

                // Содержание
                Text(advice.content)
                    .font(CosmicTypography.caption)
                    .foregroundColor(.starWhite.opacity(0.9))
                    .lineSpacing(6)

                // Источник
                if let source = advice.source {
                    HStack {
                        Image(systemName: "sparkles")
                            .font(.caption2)
                        Text(source)
                            .font(.caption2)
                            .italic()
                    }
                    .foregroundColor(colorForType(advice.type))
                }
            }
        }
    }

    private func colorForType(_ type: AdviceType) -> Color {
        switch type {
        case .affirmation:
            return .neonPurple
        case .practicalAdvice:
            return .neonCyan
        case .warning:
            return .cosmicPink
        case .challenge:
            return .starYellow
        }
    }
}

#Preview {
    ZStack {
        StarfieldBackground()
            .ignoresSafeArea()

        ScrollView {
            VStack(spacing: CosmicSpacing.large) {
                DailyAdviceCard(advice: .mockAffirmation)
                DailyAdviceCard(advice: .mockPracticalAdvice)
                DailyAdviceCard(advice: .mockWarning)
            }
            .padding()
        }
    }
}
