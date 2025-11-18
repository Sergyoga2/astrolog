//
//  TodayView.swift
//  Astrolog
//
//  Created by Claude on 22.09.2025.
//  Updated by Claude on 18.11.2025.
//
// Features/Main/TodayView.swift
import SwiftUI

struct TodayView: View {
    @StateObject private var viewModel = TodayViewModel()
    @State private var headerOffset: CGFloat = 0

    var body: some View {
        ZStack {
            StarfieldBackground()
                .ignoresSafeArea()

            if viewModel.isLoading && viewModel.detailedHoroscope == nil {
                // Loading state
                VStack(spacing: CosmicSpacing.large) {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .neonPurple))
                        .scaleEffect(1.5)

                    Text("Загрузка данных из космоса...")
                        .font(CosmicTypography.body)
                        .foregroundColor(.starWhite.opacity(0.8))
                        .shimmer()
                }
            } else {
                ScrollView(.vertical, showsIndicators: false) {
                    LazyVStack(spacing: CosmicSpacing.large) {
                        // Космический заголовок
                        CosmicHeaderView()
                            .offset(y: headerOffset)
                            .opacity(1 - abs(headerOffset) / 200.0)

                        // Основной контент
                        VStack(spacing: CosmicSpacing.large) {
                            // 1. Детальный гороскоп
                            if let horoscope = viewModel.detailedHoroscope {
                                DetailedHoroscopeCard(horoscope: horoscope)
                            }

                            // 2. Ключевые энергии сегодня
                            if !viewModel.keyEnergies.isEmpty {
                                KeyEnergiesSection(energies: viewModel.keyEnergies)
                            }

                            // 3. Лунный календарь
                            if let moonData = viewModel.moonData {
                                MoonCalendarCard(moonData: moonData)
                            }

                            // 4. Персональные транзиты
                            if !viewModel.personalTransits.isEmpty {
                                PersonalTransitsSection(transits: viewModel.personalTransits)
                            }

                            // 5. Совет дня
                            if let advice = viewModel.dailyAdvice {
                                DailyAdviceCard(advice: advice)
                            }

                            Spacer(minLength: 40)
                        }
                        .padding(.horizontal, CosmicSpacing.medium)
                    }
                }
                .coordinateSpace(name: "scroll")
                .refreshable {
                    await viewModel.refreshContent()
                }
            }

            // Error message overlay
            if let errorMessage = viewModel.errorMessage {
                VStack {
                    Spacer()
                    CosmicCard(glowColor: .cosmicPink) {
                        HStack {
                            Image(systemName: "exclamationmark.triangle")
                                .foregroundColor(.cosmicPink)
                            Text(errorMessage)
                                .font(CosmicTypography.caption)
                                .foregroundColor(.starWhite)
                        }
                    }
                    .padding()
                }
                .transition(.move(edge: .bottom))
            }
        }
        .onAppear {
            if viewModel.detailedHoroscope == nil {
                Task {
                    await viewModel.loadTodayContent()
                }
            }
        }
    }
}

// MARK: - Космический заголовок
struct CosmicHeaderView: View {
    @State private var pulsing = false
    @State private var rotating = false

    var body: some View {
        VStack(spacing: CosmicSpacing.medium) {
            // Анимированная приветственная иконка
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                .neonPurple.opacity(0.3),
                                .cosmicViolet.opacity(0.1),
                                .clear
                            ],
                            center: .center,
                            startRadius: 10,
                            endRadius: 80
                        )
                    )
                    .frame(width: 120, height: 120)
                    .scaleEffect(pulsing ? 1.2 : 1.0)
                    .animation(
                        .easeInOut(duration: 2)
                        .repeatForever(autoreverses: true),
                        value: pulsing
                    )

                Image(systemName: "sparkles")
                    .font(.system(size: 40))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.starYellow, .neonPurple, .cosmicPink],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .rotationEffect(.degrees(rotating ? 360 : 0))
                    .animation(
                        .linear(duration: 10)
                        .repeatForever(autoreverses: false),
                        value: rotating
                    )
                    .modifier(NeonGlow(color: .neonPurple, intensity: 0.8))
            }

            // Приветствие
            VStack(spacing: CosmicSpacing.small) {
                Text("Добро пожаловать в космос!")
                    .font(CosmicTypography.title)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.starWhite, .neonPurple],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .multilineTextAlignment(.center)

                Text("Сегодня, \(Date().formatted(date: .complete, time: .omitted))")
                    .font(CosmicTypography.caption)
                    .foregroundColor(.starWhite.opacity(0.8))
                    .shimmer()
            }
        }
        .padding(.top, CosmicSpacing.large)
        .onAppear {
            pulsing = true
            rotating = true
        }
    }
}

// MARK: - Personal Transits Section
struct PersonalTransitsSection: View {
    let transits: [Transit]

    var body: some View {
        VStack(alignment: .leading, spacing: CosmicSpacing.medium) {
            CosmicSectionHeader(
                "Транзиты сегодня",
                subtitle: "Планетарные влияния",
                icon: "globe"
            )

            LazyVStack(spacing: CosmicSpacing.medium) {
                ForEach(transits.prefix(5)) { transit in
                    TransitRowView(transit: transit)
                }
            }
        }
    }
}

// MARK: - Строка транзита
struct TransitRowView: View {
    let transit: Transit

    var body: some View {
        CosmicCard(glowColor: transit.transitingPlanet.color.opacity(0.3)) {
            HStack(spacing: CosmicSpacing.medium) {
                // Символ планеты
                PlanetSymbolView(planetType: transit.transitingPlanet)
                    .frame(width: 40, height: 40)

                VStack(alignment: .leading, spacing: 4) {
                    Text("\(transit.transitingPlanet.displayName)")
                        .font(CosmicTypography.body)
                        .foregroundColor(.starWhite)

                    Text(transit.interpretation)
                        .font(CosmicTypography.caption)
                        .foregroundColor(.starWhite.opacity(0.7))
                        .lineLimit(2)
                }

                Spacer()

                // Индикатор влияния
                VStack {
                    Text("Влияние")
                        .font(.caption2)
                        .foregroundColor(.starWhite.opacity(0.6))

                    CosmicProgressRing(
                        progress: 0.7,
                        size: 30
                    )
                }
            }
        }
    }
}

#Preview {
    TodayView()
}
