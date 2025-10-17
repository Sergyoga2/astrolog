//
//  CosmicChartDisplayView.swift
//  Astrolog
//
//  Created by Sergey on 22.09.2025.
//

// Features/Chart/CosmicChartDisplayView.swift
import SwiftUI

struct CosmicChartDisplayView: View {
    let chart: BirthChart
    @State private var selectedPlanet: PlanetType?
    @State private var animationProgress: Double = 0
    @State private var rotation: Double = 0

    var body: some View {
        GeometryReader { geometry in
            let size = min(geometry.size.width, geometry.size.height)
            let centerX = geometry.size.width / 2
            let centerY = geometry.size.height / 2
            let radius = size / 2 - 60

            ZStack {
                // Фоновые концентрические круги
                ForEach([0.3, 0.5, 0.7, 0.9], id: \.self) { scale in
                    Circle()
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color.neonPurple.opacity(0.2),
                                    Color.neonBlue.opacity(0.1),
                                    Color.cosmicViolet.opacity(0.15)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: scale == 0.9 ? 2 : 1
                        )
                        .frame(width: radius * 2 * scale, height: radius * 2 * scale)
                        .modifier(NeonGlow(
                            color: scale == 0.9 ? .neonPurple : .neonBlue,
                            intensity: scale == 0.9 ? 0.8 : 0.3
                        ))
                        .rotationEffect(.degrees(rotation * scale))
                }

                // Знаки зодиака по внешнему кругу
                CosmicZodiacRing(
                    radius: radius * 0.85,
                    centerX: centerX,
                    centerY: centerY,
                    animationProgress: animationProgress
                )

                // Дома (внутренний круг)
                CosmicHousesRing(
                    chart: chart,
                    radius: radius * 0.65,
                    centerX: centerX,
                    centerY: centerY,
                    animationProgress: animationProgress
                )

                // Планеты
                CosmicPlanetsRing(
                    chart: chart,
                    radius: radius * 0.75,
                    centerX: centerX,
                    centerY: centerY,
                    selectedPlanet: $selectedPlanet,
                    animationProgress: animationProgress
                )

                // Аспекты между планетами
                CosmicAspectsLayer(
                    chart: chart,
                    radius: radius * 0.4,
                    centerX: centerX,
                    centerY: centerY,
                    animationProgress: animationProgress
                )

                // Центральная точка
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color.starWhite,
                                Color.neonPurple,
                                Color.cosmicViolet
                            ],
                            center: .center,
                            startRadius: 2,
                            endRadius: 8
                        )
                    )
                    .frame(width: 16, height: 16)
                    .modifier(NeonGlow(color: .starWhite, intensity: 1.2))
                    .scaleEffect(1.0 + sin(animationProgress * .pi * 4) * 0.2)
            }
            .onAppear {
                withAnimation(.easeInOut(duration: 2.5)) {
                    animationProgress = 1.0
                }

                withAnimation(
                    .linear(duration: 120)
                    .repeatForever(autoreverses: false)
                ) {
                    rotation = 360
                }
            }
        }
        .overlay(alignment: .bottom) {
            // Информация о выбранной планете
            if let selectedPlanet = selectedPlanet {
                CosmicPlanetInfoCard(
                    planet: chart.planets.first { $0.type == selectedPlanet },
                    onDismiss: { self.selectedPlanet = nil }
                )
                .transition(.move(edge: .bottom).combined(with: .opacity))
                .animation(.spring(response: 0.6, dampingFraction: 0.8), value: selectedPlanet)
            }
        }
    }
}

// MARK: - Zodiac Ring
struct CosmicZodiacRing: View {
    let radius: Double
    let centerX: Double
    let centerY: Double
    let animationProgress: Double

    var body: some View {
        ForEach(Array(ZodiacSign.allCases.enumerated()), id: \.offset) { index, sign in
            let angle = Double(index) * 30.0 - 90.0 // Начинаем с Овна сверху
            let radians = angle * .pi / 180.0
            let x = centerX + cos(radians) * radius
            let y = centerY + sin(radians) * radius

            ZStack {
                // Фон символа
                Circle()
                    .fill(sign.color.opacity(0.2))
                    .frame(width: 40, height: 40)
                    .modifier(NeonGlow(color: sign.color, intensity: 0.5))

                // Символ знака
                Text(sign.symbol)
                    .font(.system(size: 20, weight: .medium, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [sign.color, Color.starWhite],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
            .position(x: x, y: y)
            .scaleEffect(0.3 + 0.7 * animationProgress)
            .opacity(animationProgress)
            .rotationEffect(.degrees(Double(index) * 15 * animationProgress))
            .animation(
                .spring(response: 0.8, dampingFraction: 0.6)
                .delay(Double(index) * 0.05),
                value: animationProgress
            )
        }
    }
}

// MARK: - Houses Ring
struct CosmicHousesRing: View {
    let chart: BirthChart
    let radius: Double
    let centerX: Double
    let centerY: Double
    let animationProgress: Double

    var body: some View {
        ForEach(chart.houses) { house in
            let angle = Double(house.number - 1) * 30.0 - 90.0
            let radians = angle * .pi / 180.0
            let x = centerX + cos(radians) * radius
            let y = centerY + sin(radians) * radius

            VStack(spacing: 2) {
                Text(String(house.number))
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .foregroundColor(.starWhite)

                Text(house.zodiacSign.symbol)
                    .font(.system(size: 14))
                    .foregroundColor(house.zodiacSign.color)
            }
            .padding(8)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(house.zodiacSign.color.opacity(0.5), lineWidth: 1)
                    )
            )
            .modifier(NeonGlow(color: house.zodiacSign.color, intensity: 0.3))
            .position(x: x, y: y)
            .scaleEffect(0.2 + 0.8 * animationProgress)
            .opacity(animationProgress)
            .animation(
                .spring(response: 1.0, dampingFraction: 0.7)
                .delay(Double(house.number) * 0.03),
                value: animationProgress
            )
        }
    }
}

// MARK: - Planets Ring
struct CosmicPlanetsRing: View {
    let chart: BirthChart
    let radius: Double
    let centerX: Double
    let centerY: Double
    @Binding var selectedPlanet: PlanetType?
    let animationProgress: Double

    var body: some View {
        ForEach(Array(chart.planets.filter { $0.type != .ascendant && $0.type != .midheaven }.enumerated()), id: \.element.id) { index, planet in
            let angle = planet.longitude - 90.0
            let radians = angle * .pi / 180.0
            let x = centerX + cos(radians) * radius
            let y = centerY + sin(radians) * radius
            let isSelected = selectedPlanet == planet.type

            Button(action: {
                CosmicFeedbackManager.shared.starTouch()
                selectedPlanet = selectedPlanet == planet.type ? nil : planet.type
            }) {
                ZStack {
                    // Орбита планеты
                    Circle()
                        .stroke(
                            planet.type.color.opacity(0.3),
                            lineWidth: isSelected ? 3 : 1
                        )
                        .frame(width: isSelected ? 50 : 40, height: isSelected ? 50 : 40)
                        .modifier(NeonGlow(
                            color: planet.type.color,
                            intensity: isSelected ? 1.2 : 0.6
                        ))

                    // Символ планеты
                    Text(planet.type.symbol)
                        .font(.system(size: isSelected ? 22 : 18, weight: .medium))
                        .foregroundColor(planet.type.color)
                        .shadow(color: planet.type.color, radius: isSelected ? 8 : 4)

                    // Ретроградный индикатор
                    if planet.isRetrograde {
                        Text("℞")
                            .font(.system(size: 8, weight: .bold))
                            .foregroundColor(.neonPink)
                            .offset(x: 15, y: -15)
                    }
                }
            }
            .buttonStyle(.plain)
            .position(x: x, y: y)
            .scaleEffect(0.1 + 0.9 * animationProgress)
            .opacity(animationProgress)
            .scaleEffect(isSelected ? 1.2 : 1.0)
            .animation(
                .spring(response: 0.6, dampingFraction: 0.8)
                .delay(Double(index) * 0.05),
                value: animationProgress
            )
            .animation(.spring(response: 0.4, dampingFraction: 0.6), value: isSelected)
        }
    }
}

// MARK: - Aspects Layer
struct CosmicAspectsLayer: View {
    let chart: BirthChart
    let radius: Double
    let centerX: Double
    let centerY: Double
    let animationProgress: Double

    var body: some View {
        Canvas { context, size in
            let majorAspects = chart.aspects.filter { aspect in
                [.conjunction, .opposition, .trine, .square].contains(aspect.type)
            }

            for (index, aspect) in majorAspects.enumerated() {
                guard let planet1 = chart.planets.first(where: { $0.type == aspect.planet1 }),
                      let planet2 = chart.planets.first(where: { $0.type == aspect.planet2 }) else {
                    continue
                }

                let angle1 = planet1.longitude - 90.0
                let angle2 = planet2.longitude - 90.0
                let radians1 = angle1 * .pi / 180.0
                let radians2 = angle2 * .pi / 180.0

                let x1 = centerX + cos(radians1) * (radius * 0.9)
                let y1 = centerY + sin(radians1) * (radius * 0.9)
                let x2 = centerX + cos(radians2) * (radius * 0.9)
                let y2 = centerY + sin(radians2) * (radius * 0.9)

                let opacity = animationProgress * (aspect.type.isHarmonic ? 0.6 : 0.4)
                let strokeColor = aspect.type.isHarmonic ? Color.neonBlue : Color.neonPink
                let lineWidth: CGFloat = aspect.type == .conjunction ? 3 : 2

                // Линия аспекта
                var path = Path()
                path.move(to: CGPoint(x: x1, y: y1))
                path.addLine(to: CGPoint(x: x2, y: y2))

                context.stroke(
                    path,
                    with: .color(strokeColor.opacity(opacity)),
                    style: StrokeStyle(
                        lineWidth: lineWidth,
                        lineCap: .round,
                        dash: aspect.type == .square ? [5, 5] : []
                    )
                )

                // Символ аспекта в центре линии
                let midX = (x1 + x2) / 2
                let midY = (y1 + y2) / 2

                context.draw(
                    Text(aspect.type.symbol)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(strokeColor),
                    at: CGPoint(x: midX, y: midY)
                )
            }
        }
        .opacity(animationProgress)
        .animation(.easeInOut(duration: 1.5).delay(1.0), value: animationProgress)
    }
}

// MARK: - Planet Info Card
struct CosmicPlanetInfoCard: View {
    let planet: Planet?
    let onDismiss: () -> Void

    var body: some View {
        if let planet = planet {
            CosmicCard(glowColor: planet.type.color.opacity(0.4)) {
                HStack(spacing: CosmicSpacing.medium) {
                    // Символ планеты
                    PlanetSymbolView(planetType: planet.type)
                        .frame(width: 50, height: 50)

                    VStack(alignment: .leading, spacing: 4) {
                        Text(planet.type.displayName)
                            .font(CosmicTypography.headline)
                            .foregroundColor(.starWhite)

                        Text("в \(planet.zodiacSign.displayName)")
                            .font(CosmicTypography.body)
                            .foregroundColor(planet.zodiacSign.color)

                        HStack {
                            Text("\(Int(planet.degreeInSign))° дом \(planet.house)")
                                .font(CosmicTypography.caption)
                                .foregroundColor(.starWhite.opacity(0.8))

                            if planet.isRetrograde {
                                Text("• Ретроград")
                                    .font(CosmicTypography.caption)
                                    .foregroundColor(.neonPink)
                            }
                        }
                    }

                    Spacer()

                    Button(action: onDismiss) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .foregroundColor(.starWhite.opacity(0.6))
                    }
                }
            }
            .padding(.horizontal, CosmicSpacing.medium)
            .padding(.bottom, CosmicSpacing.large)
        }
    }
}