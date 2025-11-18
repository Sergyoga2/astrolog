//
//  DetailedHoroscopeCard.swift
//  Astrolog
//
//  Created by Claude on 18.11.2025.
//
// Features/Main/Components/DetailedHoroscopeCard.swift
import SwiftUI

struct DetailedHoroscopeCard: View {
    let horoscope: DetailedHoroscope
    @State private var isExpanded = false

    var body: some View {
        CosmicCard(glowColor: .neonPurple) {
            VStack(alignment: .leading, spacing: CosmicSpacing.medium) {
                // Заголовок
                HStack {
                    VStack(alignment: .leading, spacing: CosmicSpacing.small) {
                        Text("🌟 Ваш гороскоп на \(horoscope.date.formatted(.dateTime.day().month()))")
                            .font(CosmicTypography.headline)
                            .foregroundColor(.starWhite)

                        Text(horoscope.greeting)
                            .font(CosmicTypography.caption)
                            .foregroundColor(.starWhite.opacity(0.8))
                    }

                    Spacer()
                }

                CosmicDivider()

                // Общий прогноз
                Text(horoscope.generalForecast)
                    .font(CosmicTypography.body)
                    .foregroundColor(.starWhite.opacity(0.9))
                    .lineSpacing(6)
                    .fixedSize(horizontal: false, vertical: true)

                // Развернутый контент
                if isExpanded {
                    VStack(alignment: .leading, spacing: CosmicSpacing.large) {
                        CosmicDivider()

                        // Секции по сферам жизни
                        LifeAreaSection(
                            icon: "💼",
                            title: "Карьера и финансы",
                            content: horoscope.careerAndFinances
                        )

                        LifeAreaSection(
                            icon: "❤️",
                            title: "Любовь и отношения",
                            content: horoscope.loveAndRelationships
                        )

                        LifeAreaSection(
                            icon: "⚡",
                            title: "Энергия и самочувствие",
                            content: horoscope.healthAndEnergy
                        )

                        LifeAreaSection(
                            icon: "👥",
                            title: "Друзья и социум",
                            content: horoscope.friendsAndSocial
                        )

                        CosmicDivider()

                        // Советы и предостережения
                        VStack(alignment: .leading, spacing: CosmicSpacing.medium) {
                            // Что делать
                            VStack(alignment: .leading, spacing: CosmicSpacing.small) {
                                Text("✨ Что делать сегодня:")
                                    .font(CosmicTypography.body)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.neonCyan)

                                ForEach(horoscope.todoList, id: \.self) { item in
                                    HStack(alignment: .top, spacing: 8) {
                                        Text("•")
                                            .foregroundColor(.neonCyan)
                                        Text(item)
                                            .font(CosmicTypography.caption)
                                            .foregroundColor(.starWhite.opacity(0.9))
                                    }
                                }
                            }

                            // Чего избегать
                            VStack(alignment: .leading, spacing: CosmicSpacing.small) {
                                Text("⚠️ Чего избегать:")
                                    .font(CosmicTypography.body)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.cosmicPink)

                                ForEach(horoscope.avoidList, id: \.self) { item in
                                    HStack(alignment: .top, spacing: 8) {
                                        Text("•")
                                            .foregroundColor(.cosmicPink)
                                        Text(item)
                                            .font(CosmicTypography.caption)
                                            .foregroundColor(.starWhite.opacity(0.9))
                                    }
                                }
                            }
                        }

                        CosmicDivider()

                        // Метаданные
                        VStack(alignment: .leading, spacing: CosmicSpacing.small) {
                            HStack {
                                Text("⏰")
                                Text("Лучшее время:")
                                    .font(CosmicTypography.caption)
                                    .foregroundColor(.starWhite.opacity(0.7))

                                Text(formatTimeRanges(horoscope.bestTimeRanges))
                                    .font(CosmicTypography.caption)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.starYellow)
                            }

                            HStack {
                                Text("🍀")
                                Text("Счастливые цвета:")
                                    .font(CosmicTypography.caption)
                                    .foregroundColor(.starWhite.opacity(0.7))

                                Text(horoscope.luckyColors.joined(separator: ", "))
                                    .font(CosmicTypography.caption)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.starYellow)
                            }

                            HStack {
                                Text("🔢")
                                Text("Счастливое число:")
                                    .font(CosmicTypography.caption)
                                    .foregroundColor(.starWhite.opacity(0.7))

                                Text("\(horoscope.luckyNumber)")
                                    .font(CosmicTypography.caption)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.starYellow)
                            }
                        }
                    }
                    .transition(.opacity.combined(with: .move(edge: .top)))
                }

                // Кнопка раскрытия
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        isExpanded.toggle()
                    }
                    CosmicFeedbackManager.shared.cosmicSelection()
                } label: {
                    HStack {
                        Spacer()
                        Text(isExpanded ? "Свернуть" : "Подробнее")
                            .font(CosmicTypography.caption)
                            .foregroundColor(.neonPurple)
                        Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                            .font(.caption)
                            .foregroundColor(.neonPurple)
                        Spacer()
                    }
                }
                .padding(.top, CosmicSpacing.small)
            }
        }
    }

    private func formatTimeRanges(_ ranges: [TimeRange]) -> String {
        ranges.map { $0.formatted() }.joined(separator: ", ")
    }
}

// MARK: - Life Area Section
struct LifeAreaSection: View {
    let icon: String
    let title: String
    let content: String

    var body: some View {
        VStack(alignment: .leading, spacing: CosmicSpacing.small) {
            HStack {
                Text(icon)
                    .font(.title2)
                Text(title)
                    .font(CosmicTypography.body)
                    .fontWeight(.semibold)
                    .foregroundColor(.starWhite)
            }

            Text(content)
                .font(CosmicTypography.caption)
                .foregroundColor(.starWhite.opacity(0.8))
                .lineSpacing(4)
        }
    }
}

#Preview {
    ZStack {
        StarfieldBackground()
            .ignoresSafeArea()

        ScrollView {
            DetailedHoroscopeCard(horoscope: .mock)
                .padding()
        }
    }
}
