//
//  ChartView.swift
//  Astrolog
//
//  Created by Claude on 22.09.2025.
//
// Features/Chart/ChartView.swift
import SwiftUI

struct ChartView: View {
    @StateObject private var viewModel = ChartViewModel()

    var body: some View {
        ZStack {
            StarfieldBackground()
                .ignoresSafeArea()

            GeometryReader { geometry in
                ScrollView {
                VStack(spacing: CosmicSpacing.large) {
                    if viewModel.hasBirthData {
                        if let chart = viewModel.birthChart {
                            // Интерактивная космическая натальная карта
                            VStack(spacing: CosmicSpacing.large) {
                                CosmicSectionHeader(
                                    "Ваша натальная карта",
                                    subtitle: "Коснитесь планет для подробной информации",
                                    icon: "star.circle"
                                )

                                CosmicChartDisplayView(chart: chart)
                                    .frame(height: min(geometry.size.width, 400))
                                    .clipShape(RoundedRectangle(cornerRadius: 20))

                                // Дополнительная информация
                                MainChartInfoCard(chart: chart)
                                PlanetsSection(planets: chart.planets)
                                HousesSection(houses: chart.houses)
                                AspectsSection(aspects: chart.aspects)
                            }
                        } else if viewModel.isLoading {
                            CosmicLoadingView()
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                        }
                    } else {
                        // Приглашение ввести данные рождения
                        NoBirthDataView()
                    }
                }
                .padding(.horizontal, CosmicSpacing.medium)
            }
        }
        .background(Color.clear)
        }
    }
}


// MARK: - Карточка основной информации карты
struct MainChartInfoCard: View {
    let chart: BirthChart

    var body: some View {
        CosmicCard(glowColor: .cosmicViolet) {
            VStack(spacing: CosmicSpacing.large) {
                // Основная троица
                HStack(spacing: CosmicSpacing.large) {
                    VStack(spacing: CosmicSpacing.small) {
                        Text("☉")
                            .font(CosmicTypography.zodiacSymbol)
                            .foregroundColor(.starYellow)

                        Text("Солнце")
                            .font(CosmicTypography.caption)
                            .foregroundColor(.starWhite.opacity(0.8))

                        ZodiacSignBadge(sign: chart.sunSign)
                    }

                    VStack(spacing: CosmicSpacing.small) {
                        Text("☽")
                            .font(CosmicTypography.zodiacSymbol)
                            .foregroundColor(.starWhite)

                        Text("Луна")
                            .font(CosmicTypography.caption)
                            .foregroundColor(.starWhite.opacity(0.8))

                        ZodiacSignBadge(sign: chart.moonSign)
                    }

                    VStack(spacing: CosmicSpacing.small) {
                        Text("↗")
                            .font(CosmicTypography.zodiacSymbol)
                            .foregroundColor(.neonPurple)

                        Text("Асцендент")
                            .font(CosmicTypography.caption)
                            .foregroundColor(.starWhite.opacity(0.8))

                        ZodiacSignBadge(sign: chart.ascendant)
                    }
                }
                .padding(.horizontal, CosmicSpacing.large)

                CosmicDivider()

                // Краткая интерпретация
                VStack(alignment: .leading, spacing: CosmicSpacing.small) {
                    Text("Ваша космическая подпись")
                        .font(CosmicTypography.headline)
                        .foregroundColor(.starWhite)

                    Text("Солнце в \(chart.sunSign.displayName) определяет вашу основную личность, Луна в \(chart.moonSign.displayName) отражает эмоциональную природу, а Асцендент в \(chart.ascendant.displayName) показывает, как вас воспринимают другие.")
                        .font(CosmicTypography.body)
                        .foregroundColor(.starWhite.opacity(0.9))
                        .multilineTextAlignment(.leading)
                }
            }
        }
    }
}

// MARK: - Секция планет
struct PlanetsSection: View {
    let planets: [Planet]

    var body: some View {
        VStack(alignment: .leading, spacing: CosmicSpacing.medium) {
            CosmicSectionHeader(
                "Планеты в знаках",
                subtitle: "Расположение планет в вашей карте",
                icon: "sparkles"
            )

            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: CosmicSpacing.medium) {
                ForEach(planets) { planet in
                    PlanetCard(planet: planet)
                }
            }
        }
    }
}

// MARK: - Карточка планеты
struct PlanetCard: View {
    let planet: Planet

    var body: some View {
        CosmicCard(glowColor: planet.type.color.opacity(0.6)) {
            VStack(spacing: CosmicSpacing.small) {
                // Символ планеты
                PlanetSymbolView(planetType: planet.type)
                    .frame(width: 50, height: 50)

                // Информация о планете
                VStack(spacing: 2) {
                    Text(planet.type.displayName)
                        .font(CosmicTypography.body)
                        .foregroundColor(.starWhite)
                        .fontWeight(.semibold)

                    HStack(spacing: 4) {
                        Text(planet.zodiacSign.symbol)
                            .font(CosmicTypography.caption)
                            .foregroundColor(planet.type.color)

                        Text(planet.zodiacSign.displayName)
                            .font(CosmicTypography.caption)
                            .foregroundColor(.starWhite.opacity(0.8))
                    }

                    Text("\(Int(planet.degreeInSign))°")
                        .font(.caption2)
                        .foregroundColor(.starWhite.opacity(0.6))
                }

                if planet.isRetrograde {
                    Text("℞")
                        .font(.caption)
                        .foregroundColor(.neonPink)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(
                            Capsule()
                                .fill(.ultraThinMaterial)
                        )
                }
            }
        }
    }
}

// MARK: - Секция домов
struct HousesSection: View {
    let houses: [House]

    var body: some View {
        VStack(alignment: .leading, spacing: CosmicSpacing.medium) {
            CosmicSectionHeader(
                "Астрологические дома",
                subtitle: "Сферы жизни в вашей карте",
                icon: "house"
            )

            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: CosmicSpacing.small) {
                ForEach(houses) { house in
                    HouseCard(house: house)
                }
            }
        }
    }
}

// MARK: - Карточка дома
struct HouseCard: View {
    let house: House

    var body: some View {
        CosmicCard(glowColor: .cosmicPurple.opacity(0.4)) {
            VStack(spacing: CosmicSpacing.tiny) {
                Text("Дом \(house.number)")
                    .font(CosmicTypography.caption)
                    .foregroundColor(.starWhite)
                    .fontWeight(.semibold)

                Text(house.zodiacSign.symbol)
                    .font(CosmicTypography.body)
                    .foregroundColor(.neonPurple)

                if !house.planetsInHouse.isEmpty {
                    HStack(spacing: 2) {
                        ForEach(house.planetsInHouse, id: \.rawValue) { planetType in
                            Text(planetType.symbol)
                                .font(.caption2)
                                .foregroundColor(planetType.color)
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Секция аспектов
struct AspectsSection: View {
    let aspects: [Aspect]

    var body: some View {
        VStack(alignment: .leading, spacing: CosmicSpacing.medium) {
            CosmicSectionHeader(
                "Планетарные аспекты",
                subtitle: "Взаимодействия между планетами",
                icon: "arrow.triangle.2.circlepath"
            )

            LazyVStack(spacing: CosmicSpacing.small) {
                ForEach(aspects.prefix(6)) { aspect in
                    AspectRowView(aspect: aspect)
                }
            }
        }
    }
}

// MARK: - Строка аспекта
struct AspectRowView: View {
    let aspect: Aspect

    var body: some View {
        CosmicCard(glowColor: .cosmicCyan.opacity(0.3)) {
            HStack(spacing: CosmicSpacing.medium) {
                // Первая планета
                VStack(spacing: 4) {
                    Text(aspect.planet1.symbol)
                        .font(CosmicTypography.body)
                        .foregroundColor(aspect.planet1.color)

                    Text(aspect.planet1.displayName)
                        .font(.caption2)
                        .foregroundColor(.starWhite.opacity(0.7))
                }

                // Аспект
                VStack(spacing: 4) {
                    Text(aspectSymbol(for: aspect.type))
                        .font(.title2)
                        .foregroundColor(.neonCyan)

                    Text(aspect.type.rawValue.capitalized)
                        .font(.caption2)
                        .foregroundColor(.neonCyan)
                }

                // Вторая планета
                VStack(spacing: 4) {
                    Text(aspect.planet2.symbol)
                        .font(CosmicTypography.body)
                        .foregroundColor(aspect.planet2.color)

                    Text(aspect.planet2.displayName)
                        .font(.caption2)
                        .foregroundColor(.starWhite.opacity(0.7))
                }

                Spacer()

                // Орб
                VStack(alignment: .trailing, spacing: 2) {
                    Text("Орб")
                        .font(.caption2)
                        .foregroundColor(.starWhite.opacity(0.6))

                    Text("\(aspect.orb, specifier: "%.1f")°")
                        .font(.caption)
                        .foregroundColor(.starWhite)
                }
            }
        }
    }

    private func aspectSymbol(for type: AspectType) -> String {
        switch type {
        case .conjunction: return "☌"
        case .sextile: return "⚹"
        case .square: return "☐"
        case .trine: return "△"
        case .opposition: return "☍"
        }
    }
}

// MARK: - Отсутствуют данные рождения
struct NoBirthDataView: View {
    var body: some View {
        CosmicCard(glowColor: .neonPurple) {
            VStack(spacing: CosmicSpacing.large) {
                Image(systemName: "star.circle")
                    .font(.system(size: 60))
                    .foregroundColor(.neonPurple)
                    .modifier(NeonGlow(color: .neonPurple, intensity: 1.0))

                VStack(spacing: CosmicSpacing.small) {
                    Text("Создайте свою натальную карту")
                        .font(CosmicTypography.headline)
                        .foregroundColor(.starWhite)
                        .multilineTextAlignment(.center)

                    Text("Введите данные рождения, чтобы увидеть полную астрологическую карту")
                        .font(CosmicTypography.body)
                        .foregroundColor(.starWhite.opacity(0.8))
                        .multilineTextAlignment(.center)
                }

                CosmicButton(
                    title: "Добавить данные рождения",
                    icon: "plus.circle",
                    color: .neonPurple
                ) {
                    // Переход к экрану ввода данных
                }
            }
        }
        .padding(.top, CosmicSpacing.massive)
    }
}