//
//  TodayView.swift
//  Astrolog
//
//  Created by Claude on 22.09.2025.
//
// Features/Main/TodayView.swift
import SwiftUI

struct TodayView: View {
    @StateObject private var viewModel: TodayViewModel
    @State private var headerOffset: CGFloat = 0

    init() {
        self._viewModel = StateObject(wrappedValue: TodayViewModel())
    }

    var body: some View {
        ZStack {
            StarfieldBackground()
                .ignoresSafeArea()

            GeometryReader { geometry in
            ScrollView(.vertical, showsIndicators: false) {
                LazyVStack(spacing: CosmicSpacing.large) {
                    // Космический заголовок
                    CosmicHeaderView()
                        .offset(y: headerOffset)
                        .opacity(1 - abs(headerOffset) / 200.0)

                    // Основной контент
                    VStack(spacing: CosmicSpacing.large) {
                        // Дневной гороскоп
                        if let horoscope = viewModel.dailyHoroscope {
                            DailyCosmicCard(horoscope: horoscope)
                        }

                        // Фазы луны
                        MoonPhaseCard()

                        // Планетарные транзиты
                        if !viewModel.transits.isEmpty {
                            PlanetaryTransitsSection(transits: viewModel.transits)
                        }

                        // Мистические практики
                        MysticPracticesCard()
                    }
                    .padding(.horizontal, CosmicSpacing.medium)
                }
            }
            .coordinateSpace(name: "scroll")
            .background(Color.clear)
            .onAppear {
                Task {
                    await viewModel.loadTodayData()
                }
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

// MARK: - Карточка дневного гороскопа
struct DailyCosmicCard: View {
    let horoscope: DailyHoroscope
    @State private var isExpanded = false

    var body: some View {
        CosmicCard(glowColor: horoscope.sunSign.color) {
            VStack(alignment: .leading, spacing: CosmicSpacing.medium) {
                // Заголовок с знаком зодиака
                HStack(spacing: CosmicSpacing.medium) {
                    ZodiacSignBadge(sign: horoscope.sunSign)

                    Spacer()

                    VStack(alignment: .trailing, spacing: 2) {
                        Text("Энергия дня")
                            .font(CosmicTypography.caption)
                            .foregroundColor(.starWhite.opacity(0.7))

                        CosmicProgressRing(
                            progress: Double(horoscope.energyLevel) / 10.0,
                            size: 40
                        )
                    }
                }

                // Краткий прогноз
                Text(isExpanded ? horoscope.detailedForecast : horoscope.summary)
                    .font(CosmicTypography.body)
                    .foregroundColor(.starWhite)
                    .lineLimit(isExpanded ? nil : 3)
                    .animation(.easeInOut, value: isExpanded)

                // Ключевые темы
                if !horoscope.keyThemes.isEmpty {
                    CosmicDivider()

                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: CosmicSpacing.small) {
                        ForEach(horoscope.keyThemes, id: \.self) { theme in
                            Text(theme)
                                .font(CosmicTypography.caption)
                                .foregroundColor(.neonCyan)
                                .padding(.horizontal, CosmicSpacing.small)
                                .padding(.vertical, 4)
                                .background(
                                    Capsule()
                                        .fill(.ultraThinMaterial)
                                        .overlay(
                                            Capsule()
                                                .stroke(Color.neonCyan.opacity(0.3), lineWidth: 1)
                                        )
                                )
                        }
                    }
                }

                // Кнопка развернуть/свернуть
                Button {
                    withAnimation(.spring()) {
                        isExpanded.toggle()
                    }
                } label: {
                    HStack {
                        Spacer()
                        Text(isExpanded ? "Свернуть" : "Подробнее")
                            .font(CosmicTypography.caption)
                            .foregroundColor(.neonPurple)
                        Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                            .foregroundColor(.neonPurple)
                        Spacer()
                    }
                }
                .padding(.top, CosmicSpacing.small)
            }
        }
    }
}

// MARK: - Карточка фаз луны
struct MoonPhaseCard: View {
    @State private var moonScale: CGFloat = 1.0

    var body: some View {
        CosmicCard(glowColor: .starWhite) {
            HStack(spacing: CosmicSpacing.large) {
                // Луна с анимацией
                ZStack {
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [.starWhite, .starWhite.opacity(0.3)],
                                center: .center,
                                startRadius: 10,
                                endRadius: 40
                            )
                        )
                        .frame(width: 60, height: 60)
                        .scaleEffect(moonScale)
                        .modifier(NeonGlow(color: .starWhite, intensity: 0.8))

                    Text("🌙")
                        .font(.system(size: 30))
                }

                VStack(alignment: .leading, spacing: CosmicSpacing.small) {
                    Text("Убывающая луна")
                        .font(CosmicTypography.headline)
                        .foregroundColor(.starWhite)

                    Text("Время для освобождения от ненужного и внутренней работы")
                        .font(CosmicTypography.caption)
                        .foregroundColor(.starWhite.opacity(0.8))
                        .lineLimit(2)

                    HStack {
                        Text("Влияние:")
                            .font(CosmicTypography.caption)
                            .foregroundColor(.starWhite.opacity(0.6))

                        Text("Высокое")
                            .font(CosmicTypography.caption)
                            .foregroundColor(.neonCyan)
                            .fontWeight(.semibold)
                    }
                }

                Spacer()
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

// MARK: - Секция планетарных транзитов
struct PlanetaryTransitsSection: View {
    let transits: [Transit]

    var body: some View {
        VStack(alignment: .leading, spacing: CosmicSpacing.medium) {
            CosmicSectionHeader(
                "Транзиты сегодня",
                subtitle: "Планетарные влияния",
                icon: "globe"
            )

            LazyVStack(spacing: CosmicSpacing.medium) {
                ForEach(transits.prefix(3)) { transit in
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
                        progress: 0.7, // Fallback value since influenceLevel doesn't exist
                        size: 30
                    )
                }
            }
        }
    }
}

// MARK: - Карточка мистических практик
struct MysticPracticesCard: View {
    let practices = [
        ("meditation.circle", "Медитация", "15 мин", Color.neonPurple),
        ("sparkles", "Аффирмации", "5 мин", Color.cosmicPink),
        ("moon.stars", "Визуализация", "10 мин", Color.neonCyan)
    ]

    var body: some View {
        CosmicCard(glowColor: .neonPurple) {
            VStack(alignment: .leading, spacing: CosmicSpacing.medium) {
                CosmicSectionHeader(
                    "Практики дня",
                    subtitle: "Рекомендовано для вас"
                )

                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: CosmicSpacing.small) {
                    ForEach(0..<practices.count, id: \.self) { index in
                        let practice = practices[index]

                        VStack(spacing: CosmicSpacing.small) {
                            Circle()
                                .fill(practice.3.opacity(0.2))
                                .frame(width: 50, height: 50)
                                .overlay(
                                    Image(systemName: practice.0)
                                        .font(.title2)
                                        .foregroundColor(practice.3)
                                        .modifier(NeonGlow(color: practice.3, intensity: 0.6))
                                )

                            Text(practice.1)
                                .font(CosmicTypography.caption)
                                .foregroundColor(.starWhite)
                                .fontWeight(.medium)

                            Text(practice.2)
                                .font(.caption2)
                                .foregroundColor(.starWhite.opacity(0.6))
                        }
                    }
                }
            }
        }
    }
}