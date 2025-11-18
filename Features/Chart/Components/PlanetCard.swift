//
//  PlanetCard.swift
//  Astrolog
//
//  Created by Claude on 21.10.2025.
//

// Features/Chart/Components/PlanetCard.swift
import SwiftUI

/// Карточка для отображения планеты с интерпретацией
struct PlanetCard: View {
    let planet: Planet
    let interpretation: Interpretation?
    let displayMode: DisplayMode
    let isHighlighted: Bool

    @EnvironmentObject var tooltipService: TooltipService
    @Environment(\.colorScheme) private var colorScheme

    // Анимационные состояния
    @State private var isExpanded = false
    @State private var rotationAngle: Double = 0
    @State private var scale: CGFloat = 1.0

    var body: some View {
        VStack(spacing: 0) {
            // Основная карточка
            mainCardContent
                .background(cardBackground)
                .overlay(cardBorder)
                .onTapGesture {
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                        isExpanded.toggle()
                    }
                }
                .scaleEffect(scale)
                .rotation3DEffect(
                    .degrees(rotationAngle),
                    axis: (x: 0, y: 1, z: 0)
                )

            // Расширенная информация
            if isExpanded {
                expandedContent
                    .transition(.asymmetric(
                        insertion: .opacity.combined(with: .scale(scale: 0.9, anchor: .top)),
                        removal: .opacity.combined(with: .scale(scale: 0.9, anchor: .top))
                    ))
            }
        }
        .tooltip(
            for: .planet(planet),
            in: displayMode,
            service: tooltipService,
            position: .automatic
        )
        .onAppear {
            setupAnimations()
        }
    }

    // MARK: - Main Card Content
    private var mainCardContent: some View {
        HStack(spacing: CosmicSpacing.medium) {
            // Символ планеты
            planetSymbol

            // Информация о планете
            VStack(alignment: .leading, spacing: CosmicSpacing.tiny) {
                planetHeader
                planetDetails
            }

            Spacer()

            // Дополнительная информация справа
            VStack(alignment: .trailing, spacing: CosmicSpacing.tiny) {
                planetStatusIndicators
                expandButton
            }
        }
        .padding(CosmicSpacing.medium)
    }

    // MARK: - Planet Symbol
    private var planetSymbol: some View {
        ZStack {
            // Фоновый круг
            Circle()
                .fill(planetBackgroundGradient)
                .frame(width: 60, height: 60)
                .shadow(
                    color: planet.type.color,
                    radius: isHighlighted ? 8 : 4,
                    x: 0, y: 0
                )

            // Символ планеты
            Text(planet.type.symbol)
                .font(CosmicTypography.planetSymbol)
                .foregroundColor(.starWhite)
                .shadow(color: .spaceBlack, radius: 1, x: 0, y: 1)
        }
        .scaleEffect(isHighlighted ? 1.1 : 1.0)
        .animation(.easeInOut(duration: 0.3), value: isHighlighted)
    }

    // MARK: - Planet Header
    private var planetHeader: some View {
        HStack(spacing: CosmicSpacing.tiny) {
            Text(planet.type.displayName)
                .font(CosmicTypography.headline)
                .fontWeight(.semibold)
                .foregroundColor(.starWhite)

            Text("в")
                .font(CosmicTypography.caption)
                .foregroundColor(.starWhite.opacity(0.7))

            Text(planet.zodiacSign.displayName)
                .font(CosmicTypography.body)
                .fontWeight(.medium)
                .foregroundColor(planet.zodiacSign.color)

            // Символ знака
            Text(planet.zodiacSign.symbol)
                .font(.caption)
                .foregroundColor(planet.zodiacSign.color)
        }
    }

    // MARK: - Planet Details
    private var planetDetails: some View {
        VStack(alignment: .leading, spacing: 2) {
            // Дом
            HStack(spacing: 4) {
                Image(systemName: "house.fill")
                    .font(.caption2)
                    .foregroundColor(.cosmicViolet)

                Text("\(planet.house) дом")
                    .font(.caption)
                    .foregroundColor(.starWhite.opacity(0.8))
            }

            // Градусы (для промежуточного и экспертного режимов)
            if displayMode != .beginner {
                HStack(spacing: 4) {
                    Image(systemName: "location.fill")
                        .font(.caption2)
                        .foregroundColor(.neonCyan)

                    Text("\(String(format: "%.1f", planet.degreeInSign))°")
                        .font(.caption)
                        .foregroundColor(.starWhite.opacity(0.8))
                }
            }
        }
    }

    // MARK: - Status Indicators
    private var planetStatusIndicators: some View {
        VStack(alignment: .trailing, spacing: 4) {
            // Ретроград
            if planet.isRetrograde {
                retrogradeIndicator
            }

            // Особые положения (для экспертного режима)
            if displayMode == .intermediate {
                specialPositionIndicators
            }

            // Приоритет планеты
            priorityIndicator
        }
    }

    private var retrogradeIndicator: some View {
        HStack(spacing: 2) {
            Image(systemName: "arrow.counterclockwise")
                .font(.caption2)
                .foregroundColor(.warningAmber)

            Text("R")
                .font(.caption2)
                .fontWeight(.bold)
                .foregroundColor(.warningAmber)
        }
        .padding(.horizontal, 4)
        .padding(.vertical, 2)
        .background(
            RoundedRectangle(cornerRadius: 4)
                .fill(Color.warningAmber.opacity(0.2))
        )
    }

    private var specialPositionIndicators: some View {
        VStack(spacing: 2) {
            // Можно добавить индикаторы для домициля, экзальтации и т.д.
            if isInDomicile {
                specialPositionBadge("D", color: .positive, tooltip: "Домициль")
            }

            if isInExaltation {
                specialPositionBadge("E", color: .starYellow, tooltip: "Экзальтация")
            }

            if isInDetriment {
                specialPositionBadge("De", color: .challenging, tooltip: "Изгнание")
            }

            if isInFall {
                specialPositionBadge("F", color: .challenging, tooltip: "Падение")
            }
        }
    }

    private func specialPositionBadge(_ symbol: String, color: Color, tooltip: String) -> some View {
        Text(symbol)
            .font(.caption2)
            .fontWeight(.bold)
            .foregroundColor(.starWhite)
            .frame(width: 16, height: 16)
            .background(Circle().fill(color))
            .help(tooltip) // Подсказка при наведении на macOS
    }

    private var priorityIndicator: some View {
        Circle()
            .fill(priorityColor)
            .frame(width: 8, height: 8)
            .shadow(color: priorityColor, radius: 2)
    }

    // MARK: - Expand Button
    private var expandButton: some View {
        Button(action: {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                isExpanded.toggle()
            }
        }) {
            Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                .font(.caption)
                .foregroundColor(.starWhite.opacity(0.7))
                .rotationEffect(.degrees(isExpanded ? 180 : 0))
        }
        .buttonStyle(PlainButtonStyle())
    }

    // MARK: - Expanded Content
    private var expandedContent: some View {
        VStack(spacing: CosmicSpacing.medium) {
            // Интерпретация
            if let interpretation = interpretation {
                interpretationSection(interpretation)
            }

            // Дополнительная информация
            if displayMode != .beginner {
                additionalInfoSection
            }
        }
        .padding(CosmicSpacing.medium)
        .background(expandedBackground)
    }

    private func interpretationSection(_ interpretation: Interpretation) -> some View {
        VStack(alignment: .leading, spacing: CosmicSpacing.small) {
            // Заголовок интерпретации
            HStack {
                Text(interpretation.emoji)
                    .font(.title2)

                Text(interpretation.title)
                    .font(CosmicTypography.body)
                    .fontWeight(.medium)
                    .foregroundColor(.starWhite)

                Spacer()
            }

            // Текст интерпретации
            Text(interpretation.getText(for: displayMode.recommendedDepth))
                .font(CosmicTypography.body)
                .foregroundColor(.starWhite.opacity(0.9))
                .fixedSize(horizontal: false, vertical: true)

            // Ключевые слова
            if !interpretation.keywords.isEmpty && displayMode != .beginner {
                keywordsView(interpretation.keywords)
            }
        }
    }

    private func keywordsView(_ keywords: [String]) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Ключевые качества:")
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.starWhite.opacity(0.7))

            FlowLayout(spacing: 6) {
                ForEach(keywords.prefix(5), id: \.self) { keyword in
                    keywordChip(keyword)
                }
            }
        }
    }

    private func keywordChip(_ keyword: String) -> some View {
        Text(keyword)
            .font(.caption2)
            .fontWeight(.medium)
            .foregroundColor(.cosmicDarkPurple)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(planet.type.color.opacity(0.8))
            )
    }

    private var additionalInfoSection: some View {
        VStack(alignment: .leading, spacing: CosmicSpacing.small) {
            Text("Дополнительная информация")
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.starWhite.opacity(0.7))

            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 8) {
                infoItem("Долгота", value: "\(String(format: "%.2f", planet.longitude))°")
                infoItem("Элемент", value: planet.zodiacSign.element.displayName)

                if displayMode == .intermediate {
                    infoItem("Деканат", value: getDecanInfo())
                    infoItem("Терм", value: getTermInfo())
                }
            }
        }
    }

    private func infoItem(_ title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(.caption2)
                .foregroundColor(.starWhite.opacity(0.6))

            Text(value)
                .font(.caption)
                .foregroundColor(.starWhite.opacity(0.9))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(
            RoundedRectangle(cornerRadius: 6)
                .fill(Color.starWhite.opacity(0.1))
        )
    }

    // MARK: - Background & Styling
    private var cardBackground: some View {
        RoundedRectangle(cornerRadius: 16)
            .fill(cardBackgroundGradient)
            .shadow(
                color: isHighlighted ? planet.type.color.opacity(0.5) : .spaceBlack.opacity(0.3),
                radius: isHighlighted ? 10 : 6,
                x: 0, y: 3
            )
    }

    private var expandedBackground: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(
                LinearGradient(
                    colors: [
                        .cosmicPurple.opacity(0.3),
                        .cosmicDarkPurple.opacity(0.5)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
    }

    private var cardBorder: some View {
        RoundedRectangle(cornerRadius: 16)
            .stroke(
                LinearGradient(
                    colors: isHighlighted ?
                        [planet.type.color.opacity(0.8), planet.type.color.opacity(0.3)] :
                        [.starWhite.opacity(0.3), .clear],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                lineWidth: isHighlighted ? 2 : 1
            )
    }

    // MARK: - Computed Properties
    private var cardBackgroundGradient: LinearGradient {
        LinearGradient(
            colors: [
                planet.zodiacSign.elementColor.opacity(0.3),
                .cosmicDarkPurple.opacity(0.8),
                .spaceBlack.opacity(0.6)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    private var planetBackgroundGradient: RadialGradient {
        RadialGradient(
            colors: [
                planet.type.color.opacity(0.8),
                planet.type.color.opacity(0.4),
                planet.type.color.opacity(0.1)
            ],
            center: .center,
            startRadius: 5,
            endRadius: 30
        )
    }

    private var priorityColor: Color {
        if planet.type.isPersonalPlanet {
            return .neonPurple
        } else if planet.type.isAngularPoint {
            return .starYellow
        } else {
            return .neutral
        }
    }

    // MARK: - Special Position Logic
    private var isInDomicile: Bool {
        // Упрощенная логика для домицилей
        switch (planet.type, planet.zodiacSign) {
        case (.sun, .leo), (.moon, .cancer), (.mercury, .gemini), (.mercury, .virgo),
             (.venus, .taurus), (.venus, .libra), (.mars, .aries), (.mars, .scorpio):
            return true
        default:
            return false
        }
    }

    private var isInExaltation: Bool {
        // Упрощенная логика для экзальтаций
        switch (planet.type, planet.zodiacSign) {
        case (.sun, .aries), (.moon, .taurus), (.mercury, .aquarius), (.venus, .pisces), (.mars, .capricorn):
            return true
        default:
            return false
        }
    }

    private var isInDetriment: Bool {
        // Логика для изгнания (противоположные знаки домициля)
        switch (planet.type, planet.zodiacSign) {
        case (.sun, .aquarius), (.moon, .capricorn), (.venus, .scorpio), (.venus, .aries):
            return true
        default:
            return false
        }
    }

    private var isInFall: Bool {
        // Логика для падения (противоположные знаки экзальтации)
        switch (planet.type, planet.zodiacSign) {
        case (.sun, .libra), (.moon, .scorpio), (.venus, .virgo), (.mars, .cancer):
            return true
        default:
            return false
        }
    }

    private func getDecanInfo() -> String {
        let degree = planet.degreeInSign
        if degree < 10 {
            return "1-й"
        } else if degree < 20 {
            return "2-й"
        } else {
            return "3-й"
        }
    }

    private func getTermInfo() -> String {
        // Упрощенная логика для термов
        return "Терм \(Int(planet.degreeInSign / 6) + 1)"
    }

    // MARK: - Animation Setup
    private func setupAnimations() {
        // Небольшое вращение при появлении
        withAnimation(.easeOut(duration: 0.6).delay(Double.random(in: 0...0.3))) {
            rotationAngle = 360
        }

        // Пульсация для выделенных планет
        if isHighlighted {
            Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { _ in
                withAnimation(.easeInOut(duration: 1.0)) {
                    scale = scale == 1.0 ? 1.05 : 1.0
                }
            }
        }
    }
}

// MARK: - Flow Layout для ключевых слов
private struct FlowLayout: Layout {
    let spacing: CGFloat

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let maxWidth = proposal.width ?? 200
        var height: CGFloat = 0
        var currentRowWidth: CGFloat = 0
        var currentRowHeight: CGFloat = 0

        for subview in subviews {
            let viewSize = subview.sizeThatFits(.unspecified)

            if currentRowWidth + viewSize.width > maxWidth && currentRowWidth > 0 {
                height += currentRowHeight + spacing
                currentRowWidth = viewSize.width
                currentRowHeight = viewSize.height
            } else {
                currentRowWidth += viewSize.width + (currentRowWidth > 0 ? spacing : 0)
                currentRowHeight = max(currentRowHeight, viewSize.height)
            }
        }

        height += currentRowHeight
        return CGSize(width: maxWidth, height: height)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var currentX: CGFloat = bounds.minX
        var currentY: CGFloat = bounds.minY
        var rowHeight: CGFloat = 0

        for subview in subviews {
            let viewSize = subview.sizeThatFits(.unspecified)

            if currentX + viewSize.width > bounds.maxX && currentX > bounds.minX {
                currentX = bounds.minX
                currentY += rowHeight + spacing
                rowHeight = 0
            }

            subview.place(
                at: CGPoint(x: currentX, y: currentY),
                anchor: .topLeading,
                proposal: .init(viewSize)
            )

            currentX += viewSize.width + spacing
            rowHeight = max(rowHeight, viewSize.height)
        }
    }
}

// MARK: - Preview
struct PlanetCard_Previews: PreviewProvider {
    static var previews: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Обычная карточка
                PlanetCard(
                    planet: Planet(
                        id: "sun",
                        type: .sun,
                        longitude: 135.5,
                        zodiacSign: .leo,
                        house: 10,
                        isRetrograde: false
                    ),
                    interpretation: Interpretation.emoji(
                        title: "Солнце в Льве",
                        emoji: "☀️♌",
                        oneLiner: "Вы - прирожденный лидер с творческими способностями",
                        elementType: .planetInSign
                    ),
                    displayMode: .intermediate,
                    isHighlighted: false
                )

                // Выделенная карточка с ретроградом
                PlanetCard(
                    planet: Planet(
                        id: "mercury",
                        type: .mercury,
                        longitude: 67.3,
                        zodiacSign: .gemini,
                        house: 7,
                        isRetrograde: true
                    ),
                    interpretation: nil,
                    displayMode: .intermediate,
                    isHighlighted: true
                )
            }
            .padding()
        }
        .background(CosmicGradients.mainCosmic)
        .environmentObject(TooltipService())
    }
}