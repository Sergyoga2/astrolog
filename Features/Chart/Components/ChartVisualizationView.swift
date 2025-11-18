//
//  ChartVisualizationView.swift
//  Astrolog
//
//  Created by Claude on 21.10.2025.
//

// Features/Chart/Components/ChartVisualizationView.swift
import SwiftUI
import Darwin

/// Адаптивная визуализация натальной карты
struct ChartVisualizationView: View {
    let birthChart: BirthChart
    @ObservedObject var displayModeManager: ChartDisplayModeManager
    @EnvironmentObject var tooltipService: TooltipService

    // Состояние визуализации
    @State private var selectedPlanet: Planet?
    @State private var highlightedAspects: [Aspect] = []
    @State private var zoomScale: CGFloat = 1.0
    @State private var rotationAngle: Double = 0
    @State private var showAspectLines: Bool = true
    @State private var animationProgress: Double = 0

    // Размеры и позиции
    @State private var chartCenter: CGPoint = .zero
    @State private var chartRadius: CGFloat = 150

    private let maxZoom: CGFloat = 2.5
    private let minZoom: CGFloat = 0.5

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Фоновый круг карты
                chartBackground

                // Дома (если включены)
                if displayModeManager.currentMode.showHouses {
                    housesView
                }

                // Знаки зодиака
                zodiacSignsView

                // Аспекты (линии связей)
                if showAspectLines && displayModeManager.currentMode != .beginner {
                    aspectLinesView
                }

                // Планеты
                planetsView

                // Выбранный элемент (подсветка)
                if let selectedPlanet = selectedPlanet {
                    selectedPlanetHighlight(selectedPlanet)
                }

                // Центральная информация
                centerInfoView
            }
            .onAppear {
                setupChart(geometry: geometry)
                startInitialAnimation()
            }
            .onChange(of: geometry.size) { _ in
                updateChartSize(geometry: geometry)
            }
            .scaleEffect(zoomScale)
            .rotationEffect(.degrees(rotationAngle))
            .gesture(chartGestures)
        }
        .clipped()
        .background(visualizationBackground)
    }

    // MARK: - Chart Background
    private var chartBackground: some View {
        let circleGradient = LinearGradient(
            colors: [Color.starWhite.opacity(0.8), Color.starWhite.opacity(0.3)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )

        return ZStack {
            // Основной круг
            Circle()
                .stroke(circleGradient, lineWidth: 2)
                .frame(width: chartRadius * 2, height: chartRadius * 2)

            // Внутренние концентрические окружности
            ForEach([0, 1, 2], id: \.self) { (index: Int) in
                let indexFloat: CGFloat = CGFloat(index)
                let sizeFactor: CGFloat = 0.3 + indexFloat * 0.2
                let circleSize: CGFloat = chartRadius * 2 * sizeFactor

                Circle()
                    .stroke(Color.starWhite.opacity(0.2), lineWidth: 1)
                    .frame(width: circleSize, height: circleSize)
            }

            // Линии домов (если включены)
            if displayModeManager.currentMode.showHouses {
                houseLines
            }
        }
        .opacity(animationProgress)
        .animation(.easeInOut(duration: 1.0), value: animationProgress)
    }

    // MARK: - Houses View
    private var housesView: some View {
        ZStack {
            let relevantHouses = displayModeManager.getRelevantHouses(from: birthChart)

            ForEach(relevantHouses, id: \.id) { house in
                houseSegment(house)
            }
        }
    }

    private func houseSegment(_ house: House) -> some View {
        let angle = Double(house.number - 1) * 30 // 30 градусов на дом
        let startAngle = Angle.degrees(angle - 15)
        let endAngle = Angle.degrees(angle + 15)

        let elementColorFill = house.zodiacSign.elementColor.opacity(0.1)
        let elementColorStroke = house.zodiacSign.elementColor.opacity(0.3)

        let angleRadians = Double.pi * (angle - 90) / 180
        let numberRadius = chartRadius * 0.85
        let numberPosition = CGPoint(
            x: chartCenter.x + Darwin.cos(angleRadians) * numberRadius,
            y: chartCenter.y + Darwin.sin(angleRadians) * numberRadius
        )

        let frameSize = chartRadius * 2

        return ZStack {
            // Сектор дома
            PieSlice(startAngle: startAngle, endAngle: endAngle)
                .fill(elementColorFill)
                .overlay(
                    PieSlice(startAngle: startAngle, endAngle: endAngle)
                        .stroke(elementColorStroke, lineWidth: 1)
                )

            // Номер дома
            Text("\(house.number)")
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.starWhite.opacity(0.8))
                .position(numberPosition)
        }
        .frame(width: frameSize, height: frameSize)
        .onTapGesture {
            // Показать подсказку для дома
            tooltipService.showTooltip(
                for: .house(house),
                at: CGPoint(x: chartCenter.x, y: chartCenter.y),
                in: displayModeManager.currentMode,
                delayed: false
            )
        }
    }

    private var houseLines: some View {
        ZStack {
            ForEach([0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11], id: \.self) { (houseIndex: Int) in
                let indexDouble: Double = Double(houseIndex)
                let angle: Double = indexDouble * 30
                let angleRadians: Double = Double.pi * (angle - 90) / 180
                let cosAngle: CGFloat = CGFloat(Darwin.cos(angleRadians))
                let sinAngle: CGFloat = CGFloat(Darwin.sin(angleRadians))

                let innerRadius: CGFloat = chartRadius * 0.3
                let outerRadius: CGFloat = chartRadius

                Path { path in
                    let startX: CGFloat = chartCenter.x + cosAngle * innerRadius
                    let startY: CGFloat = chartCenter.y + sinAngle * innerRadius
                    let endX: CGFloat = chartCenter.x + cosAngle * outerRadius
                    let endY: CGFloat = chartCenter.y + sinAngle * outerRadius

                    path.move(to: CGPoint(x: startX, y: startY))
                    path.addLine(to: CGPoint(x: endX, y: endY))
                }
                .stroke(Color.starWhite.opacity(0.2), lineWidth: 1)
            }
        }
    }

    // MARK: - Zodiac Signs View
    private var zodiacSignsView: some View {
        ZStack {
            ForEach(ZodiacSign.allCases, id: \.rawValue) { sign in
                zodiacSignView(sign)
            }
        }
        .opacity(animationProgress)
        .animation(.easeInOut(duration: 1.2).delay(0.3), value: animationProgress)
    }

    private func zodiacSignView(_ sign: ZodiacSign) -> some View {
        let angle = Double(sign.rawValue) * 30
        let angleRadians = Double.pi * (angle - 90) / 180
        let cosAngle = Darwin.cos(angleRadians)
        let sinAngle = Darwin.sin(angleRadians)

        let symbolRadius = chartRadius * 1.15
        let nameRadius = chartRadius * 1.3

        let symbolPosition = CGPoint(
            x: chartCenter.x + cosAngle * symbolRadius,
            y: chartCenter.y + sinAngle * symbolRadius
        )

        let namePosition = CGPoint(
            x: chartCenter.x + cosAngle * nameRadius,
            y: chartCenter.y + sinAngle * nameRadius
        )

        let fontSize: CGFloat = displayModeManager.currentMode == .beginner ? 20 : 24

        return ZStack {
            // Символ знака
            Text(sign.symbol)
                .font(.system(size: fontSize))
                .foregroundColor(sign.color)
                .shadow(color: sign.color.opacity(0.5), radius: 2)
                .position(symbolPosition)

            // Название знака (только для экспертного режима)
            if displayModeManager.currentMode == .intermediate {
                Text(sign.displayName)
                    .font(.caption2)
                    .fontWeight(.medium)
                    .foregroundColor(.starWhite.opacity(0.7))
                    .position(namePosition)
            }
        }
        .tooltip(
            for: .sign(sign),
            in: displayModeManager.currentMode,
            service: tooltipService,
            position: .automatic
        )
    }

    // MARK: - Aspect Lines View
    private var aspectLinesView: some View {
        ZStack {
            let significantAspects = displayModeManager.getSignificantAspects(from: birthChart)

            ForEach(significantAspects, id: \.id) { aspect in
                aspectLine(aspect)
            }
        }
        .opacity(showAspectLines ? animationProgress : 0)
        .animation(.easeInOut(duration: 0.8).delay(0.6), value: animationProgress)
        .animation(.easeInOut(duration: 0.3), value: showAspectLines)
    }

    private func aspectLine(_ aspect: Aspect) -> some View {
        guard let planet1 = birthChart.planets.first(where: { $0.type == aspect.planet1Type }),
              let planet2 = birthChart.planets.first(where: { $0.type == aspect.planet2Type }) else {
            return AnyView(EmptyView())
        }

        let planet1Position = planetPosition(planet1.type)
        let planet2Position = planetPosition(planet2.type)

        let isHighlighted = highlightedAspects.contains { $0.id == aspect.id }

        return AnyView(Path { path in
            path.move(to: planet1Position)
            path.addLine(to: planet2Position)
        }
        .stroke(
            aspect.type.color.opacity(isHighlighted ? 0.8 : 0.4),
            style: StrokeStyle(
                lineWidth: isHighlighted ? 2 : 1,
                lineCap: .round,
                dash: aspect.type.isHarmonic ? [] : [5, 3]
            )
        )
        .shadow(
            color: aspect.type.color.opacity(0.3),
            radius: isHighlighted ? 3 : 1
        )
        .tooltip(
            for: .aspect(aspect),
            in: displayModeManager.currentMode,
            service: tooltipService,
            position: .automatic
        )
        .onTapGesture {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                toggleAspectHighlight(aspect)
            }
        })
    }

    // MARK: - Planets View
    private var planetsView: some View {
        ZStack {
            let priorityPlanets = displayModeManager.getPriorityPlanets(from: birthChart)

            ForEach(priorityPlanets, id: \.id) { planet in
                planetView(planet)
            }
        }
        .opacity(animationProgress)
        .animation(.spring(response: 0.8, dampingFraction: 0.8).delay(0.8), value: animationProgress)
    }

    private func planetView(_ planet: Planet) -> some View {
        let position = planetPosition(planet.type)
        let isSelected = selectedPlanet?.id == planet.id
        let isHighlighted = displayModeManager.isElementHighlighted(.planet(planet))

        return ZStack {
            // Фоновый круг планеты
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            planet.type.color.opacity(0.8),
                            planet.type.color.opacity(0.3)
                        ],
                        center: .center,
                        startRadius: 5,
                        endRadius: 25
                    )
                )
                .frame(width: planetSize(planet.type), height: planetSize(planet.type))
                .overlay(
                    Circle()
                        .stroke(
                            planet.type.color,
                            lineWidth: isSelected ? 3 : (isHighlighted ? 2 : 1)
                        )
                )
                .shadow(
                    color: planet.type.color.opacity(0.5),
                    radius: isSelected ? 8 : (isHighlighted ? 4 : 2)
                )

            // Символ планеты
            Text(planet.type.symbol)
                .font(.system(size: planetSymbolSize(planet.type)))
                .foregroundColor(.starWhite)
                .shadow(color: .spaceBlack, radius: 1)

            // Индикатор ретрограда
            if planet.isRetrograde {
                Text("R")
                    .font(.caption2)
                    .fontWeight(.bold)
                    .foregroundColor(.warningAmber)
                    .background(Circle().fill(Color.spaceBlack))
                    .offset(x: 15, y: -15)
            }
        }
        .position(position)
        .scaleEffect(isSelected ? 1.2 : (isHighlighted ? 1.1 : 1.0))
        .tooltip(
            for: .planet(planet),
            in: displayModeManager.currentMode,
            service: tooltipService,
            position: .automatic
        )
        .onTapGesture {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                selectPlanet(planet)
            }
        }
        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: isSelected)
        .animation(.easeInOut(duration: 0.2), value: isHighlighted)
    }

    // MARK: - Selected Planet Highlight
    private func selectedPlanetHighlight(_ planet: Planet) -> some View {
        let position = planetPosition(planet.type)

        return Circle()
            .stroke(
                LinearGradient(
                    colors: [planet.type.color, planet.type.color.opacity(0.3)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                lineWidth: 3
            )
            .frame(width: 80, height: 80)
            .position(position)
            .opacity(0.8)
            .scaleEffect(1.0)
            .animation(
                .easeInOut(duration: 1.5)
                .repeatForever(autoreverses: true),
                value: selectedPlanet != nil
            )
    }

    // MARK: - Center Info View
    private var centerInfoView: some View {
        VStack(spacing: CosmicSpacing.tiny) {
            // Название карты
            Text(birthChart.name)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.starWhite)

            // Дата рождения
            Text(formatBirthDate())
                .font(.caption2)
                .foregroundColor(.starWhite.opacity(0.8))

            // Выбранная планета (если есть)
            if let selectedPlanet = selectedPlanet {
                VStack(spacing: 2) {
                    HStack(spacing: 4) {
                        Text(selectedPlanet.type.symbol)
                            .font(.caption)
                        Text(selectedPlanet.type.displayName)
                            .font(.caption2)
                            .fontWeight(.medium)
                    }
                    .foregroundColor(selectedPlanet.type.color)

                    Text("в \(selectedPlanet.zodiacSign.displayName)")
                        .font(.caption2)
                        .foregroundColor(.starWhite.opacity(0.7))
                }
                .padding(.top, 4)
                .transition(.opacity.combined(with: .scale(scale: 0.9)))
            }
        }
        .position(chartCenter)
        .opacity(animationProgress)
    }

    // MARK: - Background
    private var visualizationBackground: some View {
        RadialGradient(
            colors: [
                .cosmicPurple.opacity(0.1),
                .cosmicDarkPurple.opacity(0.3),
                .spaceBlack.opacity(0.8)
            ],
            center: .center,
            startRadius: 50,
            endRadius: 300
        )
        .ignoresSafeArea()
    }

    // MARK: - Gestures
    private var chartGestures: some Gesture {
        SimultaneousGesture(
            // Масштабирование
            MagnificationGesture()
                .onChanged { value in
                    let newScale = zoomScale * value
                    let clampedScale = min(maxZoom, newScale)
                    zoomScale = max(minZoom, clampedScale)
                },

            // Вращение (для экспертного режима)
            RotationGesture()
                .onChanged { value in
                    if displayModeManager.currentMode == .intermediate {
                        rotationAngle = value.degrees
                    }
                }
        )
    }

    // MARK: - Helper Methods
    private func setupChart(geometry: GeometryProxy) {
        let size = min(geometry.size.width, geometry.size.height)
        chartRadius = size * 0.35
        chartCenter = CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 2)
    }

    private func updateChartSize(geometry: GeometryProxy) {
        let size = min(geometry.size.width, geometry.size.height)
        chartRadius = size * 0.35
        chartCenter = CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 2)
    }

    private func startInitialAnimation() {
        withAnimation(.easeInOut(duration: 1.5)) {
            animationProgress = 1.0
        }
    }

    private func planetPosition(_ planetType: PlanetType) -> CGPoint {
        // Находим планету в карте
        guard let planet = birthChart.planets.first(where: { $0.type == planetType }) else {
            return chartCenter
        }

        // Преобразуем долготу в угол (0° = Овен = верх круга)
        let angle = planet.longitude - 90 // Корректируем, чтобы 0° был наверху
        let angleRadians = Double.pi * angle / 180

        let radiusOffset = chartRadius * 0.8
        let x = chartCenter.x + Darwin.cos(angleRadians) * radiusOffset
        let y = chartCenter.y + Darwin.sin(angleRadians) * radiusOffset

        return CGPoint(x: x, y: y)
    }

    private func planetSize(_ planetType: PlanetType) -> CGFloat {
        switch displayModeManager.currentMode {
        case .human, .beginner:
            return planetType.isPersonalPlanet ? 40 : 35
        case .intermediate:
            return planetType.isPersonalPlanet ? 50 : 42
        }
    }

    private func planetSymbolSize(_ planetType: PlanetType) -> CGFloat {
        switch displayModeManager.currentMode {
        case .human, .beginner:
            return planetType.isPersonalPlanet ? 18 : 16
        case .intermediate:
            return planetType.isPersonalPlanet ? 22 : 20
        }
    }

    private func selectPlanet(_ planet: Planet) {
        if selectedPlanet?.id == planet.id {
            selectedPlanet = nil
            highlightedAspects = []
        } else {
            selectedPlanet = planet
            // Найти все аспекты для выбранной планеты
            highlightedAspects = birthChart.aspects.filter {
                $0.planet1Type == planet.type || $0.planet2Type == planet.type
            }
        }
    }

    private func toggleAspectHighlight(_ aspect: Aspect) {
        if highlightedAspects.contains(where: { $0.id == aspect.id }) {
            highlightedAspects.removeAll { $0.id == aspect.id }
        } else {
            highlightedAspects.append(aspect)
        }
    }

    private func formatBirthDate() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.locale = Locale(identifier: "ru_RU")
        return formatter.string(from: birthChart.birthDate)
    }
}

// MARK: - Supporting Shapes

/// Форма для сектора пирога (дома)
struct PieSlice: Shape {
    let startAngle: Angle
    let endAngle: Angle

    func path(in rect: CGRect) -> Path {
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2

        var path = Path()
        path.move(to: center)
        path.addArc(
            center: center,
            radius: radius,
            startAngle: startAngle,
            endAngle: endAngle,
            clockwise: false
        )
        path.closeSubpath()

        return path
    }
}

// MARK: - Preview
struct ChartVisualizationView_Previews: PreviewProvider {
    static var previews: some View {
        let sampleChart = BirthChart(
            id: "sample",
            userId: "user1",
            name: "Анна Иванова",
            birthDate: Date(),
            birthTime: "14:30",
            location: "Москва",
            latitude: 55.7558,
            longitude: 37.6176,
            planets: [
                Planet(id: "sun", type: .sun, longitude: 135, zodiacSign: .leo, house: 10, isRetrograde: false),
                Planet(id: "moon", type: .moon, longitude: 45, zodiacSign: .taurus, house: 7, isRetrograde: false),
                Planet(id: "mercury", type: .mercury, longitude: 120, zodiacSign: .cancer, house: 9, isRetrograde: true)
            ],
            houses: [],
            aspects: [],
            calculatedAt: Date()
        )

        let displayModeManager = ChartDisplayModeManager()

        ChartVisualizationView(
            birthChart: sampleChart,
            displayModeManager: displayModeManager
        )
        .environmentObject(TooltipService())
        .previewDevice("iPhone 15")
    }
}