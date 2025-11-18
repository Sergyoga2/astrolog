//
//  TooltipView.swift
//  Astrolog
//
//  Created by Claude on 21.10.2025.
//

// Core/Components/TooltipView.swift
import SwiftUI

/// Основное представление для отображения подсказок
struct TooltipView: View {
    let tooltip: TooltipData
    let position: CGPoint
    let opacity: Double

    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        VStack(alignment: .leading, spacing: CosmicSpacing.small) {
            // Заголовок с иконкой
            headerView

            // Основной контент
            contentView

            // Контекстная информация (если есть)
            if let contextualInfo = tooltip.contextualInfo,
               tooltip.style.shouldShowContextualInfo {
                contextualInfoView(contextualInfo)
            }
        }
        .padding(CosmicSpacing.medium)
        .background(backgroundView)
        .overlay(borderView)
        .shadow(
            color: CosmicEffects.deepShadowColor,
            radius: CosmicEffects.deepShadowRadius,
            x: CosmicEffects.deepShadowX,
            y: CosmicEffects.deepShadowY
        )
        .opacity(opacity)
        .scaleEffect(opacity) // Масштабирование при появлении
        .animation(.spring(response: 0.3, dampingFraction: 0.8, blendDuration: 0), value: opacity)
        .frame(maxWidth: tooltip.maxWidth)
        .position(x: position.x, y: position.y)
        .allowsHitTesting(false) // Подсказки не должны блокировать взаимодействие
    }

    // MARK: - Header View
    private var headerView: some View {
        HStack(spacing: CosmicSpacing.small) {
            // Иконка
            Text(tooltip.icon)
                .font(CosmicTypography.planetSymbol)
                .foregroundColor(.starWhite)
                .frame(width: 24, height: 24)

            // Заголовок
            Text(tooltip.title)
                .font(CosmicTypography.headline)
                .fontWeight(.semibold)
                .foregroundColor(.starWhite)
                .lineLimit(1)

            Spacer()

            // Индикатор типа
            typeIndicator
        }
    }

    // MARK: - Content View
    private var contentView: some View {
        Text(tooltip.content)
            .font(contentFont)
            .foregroundColor(.starWhite.opacity(0.9))
            .fixedSize(horizontal: false, vertical: true)
            .lineLimit(contentLineLimit)
    }

    // MARK: - Contextual Info View
    private func contextualInfoView(_ info: ContextualInfo) -> some View {
        VStack(alignment: .leading, spacing: CosmicSpacing.tiny) {
            if !info.keywords.isEmpty {
                keywordsView(info.keywords)
            }

            if !info.lifeAreas.isEmpty {
                lifeAreasView(info.lifeAreas)
            }
        }
        .padding(.top, CosmicSpacing.small)
    }

    private func keywordsView(_ keywords: [String]) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text("Ключевые слова:")
                .font(CosmicTypography.caption)
                .fontWeight(.medium)
                .foregroundColor(.starWhite.opacity(0.7))

            FlowLayout(spacing: 4) {
                ForEach(keywords, id: \.self) { keyword in
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
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.starWhite.opacity(0.9))
            )
    }

    private func lifeAreasView(_ lifeAreas: [String]) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text("Области влияния:")
                .font(CosmicTypography.caption)
                .fontWeight(.medium)
                .foregroundColor(.starWhite.opacity(0.7))

            Text(lifeAreas.joined(separator: ", "))
                .font(.caption)
                .foregroundColor(.starWhite.opacity(0.8))
                .italic()
        }
    }

    // MARK: - Background & Styling
    private var backgroundView: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(tooltip.backgroundColor)
            .background(
                // Стеклянный эффект
                RoundedRectangle(cornerRadius: 12)
                    .fill(.ultraThinMaterial)
                    .opacity(0.3)
            )
    }

    private var borderView: some View {
        RoundedRectangle(cornerRadius: 12)
            .stroke(
                LinearGradient(
                    colors: [.starWhite.opacity(0.3), .clear],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                lineWidth: 1
            )
    }

    private var typeIndicator: some View {
        Circle()
            .fill(priorityColor)
            .frame(width: 8, height: 8)
            .shadow(color: priorityColor, radius: 2)
    }

    // MARK: - Computed Properties
    private var contentFont: Font {
        switch tooltip.style {
        case .simple:
            return CosmicTypography.caption
        case .detailed:
            return CosmicTypography.body
        case .educational:
            return CosmicTypography.body
        }
    }

    private var contentLineLimit: Int {
        switch tooltip.style {
        case .simple: return 2
        case .detailed: return 4
        case .educational: return 6
        }
    }

    private var priorityColor: Color {
        switch tooltip.priority {
        case .low: return .neutral
        case .medium: return .cosmicViolet
        case .high: return .neonPurple
        }
    }
}

/// Представление для отображения системы подсказок
struct TooltipOverlay: View {
    @ObservedObject var tooltipService: TooltipService

    var body: some View {
        ZStack {
            if let tooltip = tooltipService.currentTooltip,
               tooltipService.isTooltipVisible {
                TooltipView(
                    tooltip: tooltip,
                    position: tooltipService.tooltipPosition,
                    opacity: tooltipService.tooltipOpacity
                )
                .zIndex(tooltip.priority.zIndex)
            }
        }
        .allowsHitTesting(false) // Оверлей не должен блокировать взаимодействие
        .animation(.easeInOut(duration: 0.2), value: tooltipService.isTooltipVisible)
    }
}

/// Модификатор для добавления подсказок к View
struct TooltipModifier: ViewModifier {
    let element: ChartElement
    let displayMode: DisplayMode
    let tooltipService: TooltipService
    let position: TooltipPosition

    @State private var isHovering = false

    func body(content: Content) -> some View {
        content
            .background(
                GeometryReader { geometry in
                    Color.clear
                        .onTapGesture(count: 2) {
                            // Двойное нажатие показывает подсказку
                            let position = calculateTooltipPosition(geometry: geometry)
                            tooltipService.showTooltip(
                                for: element,
                                at: position,
                                in: displayMode,
                                delayed: false
                            )
                        }
                        .onLongPressGesture(minimumDuration: 0.5) {
                            // Длительное нажатие также показывает подсказку
                            let position = calculateTooltipPosition(geometry: geometry)
                            tooltipService.showTooltip(
                                for: element,
                                at: position,
                                in: displayMode,
                                delayed: false
                            )
                        }
                }
            )
            .onHover { hovering in
                isHovering = hovering
                if hovering {
                    // Показываем подсказку при наведении (для Mac)
                    DispatchQueue.main.asyncAfter(deadline: .now() + tooltipService.tooltipDelay) {
                        if isHovering {
                            let dummyGeometry = GeometryProxy.dummy
                            let position = calculateTooltipPosition(geometry: dummyGeometry)
                            tooltipService.showTooltip(
                                for: element,
                                at: position,
                                in: displayMode
                            )
                        }
                    }
                } else {
                    tooltipService.hideTooltip()
                }
            }
    }

    private func calculateTooltipPosition(geometry: GeometryProxy) -> CGPoint {
        let frame = geometry.frame(in: .global)

        switch position {
        case .above:
            return CGPoint(x: frame.midX, y: frame.minY - 10)
        case .below:
            return CGPoint(x: frame.midX, y: frame.maxY + 10)
        case .leading:
            return CGPoint(x: frame.minX - 10, y: frame.midY)
        case .trailing:
            return CGPoint(x: frame.maxX + 10, y: frame.midY)
        case .center:
            return CGPoint(x: frame.midX, y: frame.midY)
        case .automatic:
            // Автоматически выбираем позицию на основе расположения элемента
            let screenCenter = UIScreen.main.bounds.center
            if frame.midY < screenCenter.y {
                return CGPoint(x: frame.midX, y: frame.maxY + 10) // Показываем снизу
            } else {
                return CGPoint(x: frame.midX, y: frame.minY - 10) // Показываем сверху
            }
        }
    }
}

/// Позиция подсказки относительно элемента
enum TooltipPosition {
    case above, below, leading, trailing, center, automatic
}

/// Расширение для добавления подсказок
extension View {
    func tooltip(
        for element: ChartElement,
        in displayMode: DisplayMode,
        service: TooltipService,
        position: TooltipPosition = .automatic
    ) -> some View {
        modifier(TooltipModifier(
            element: element,
            displayMode: displayMode,
            tooltipService: service,
            position: position
        ))
    }

    func educationalTooltip(
        title: String,
        content: String,
        service: TooltipService,
        position: TooltipPosition = .automatic
    ) -> some View {
        self
            .onTapGesture(count: 2) {
                service.showEducationalTooltip(
                    title: title,
                    content: content,
                    at: CGPoint(x: UIScreen.main.bounds.midX, y: UIScreen.main.bounds.midY)
                )
            }
    }
}

/// Компонент для отображения ключевых слов в виде потока
private struct FlowLayout: Layout {
    let spacing: CGFloat

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowLayoutHelper.calculateSize(
            subviews: subviews,
            proposal: proposal,
            spacing: spacing
        )
        return result
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        FlowLayoutHelper.placeViews(
            subviews: subviews,
            in: bounds,
            spacing: spacing
        )
    }
}

/// Помощник для флекс-лейаута
private struct FlowLayoutHelper {
    static func calculateSize(
        subviews: LayoutSubviews,
        proposal: ProposedViewSize,
        spacing: CGFloat
    ) -> CGSize {
        let maxWidth = proposal.width ?? 200
        var height: CGFloat = 0
        var currentRowWidth: CGFloat = 0
        var currentRowHeight: CGFloat = 0

        for subview in subviews {
            let viewSize = subview.sizeThatFits(.unspecified)

            if currentRowWidth + viewSize.width > maxWidth && currentRowWidth > 0 {
                // Новая строка
                height += currentRowHeight + spacing
                currentRowWidth = viewSize.width
                currentRowHeight = viewSize.height
            } else {
                // Добавляем к текущей строке
                currentRowWidth += viewSize.width + (currentRowWidth > 0 ? spacing : 0)
                currentRowHeight = max(currentRowHeight, viewSize.height)
            }
        }

        height += currentRowHeight
        return CGSize(width: maxWidth, height: height)
    }

    static func placeViews(
        subviews: LayoutSubviews,
        in bounds: CGRect,
        spacing: CGFloat
    ) {
        var currentX: CGFloat = bounds.minX
        var currentY: CGFloat = bounds.minY
        var rowHeight: CGFloat = 0

        for subview in subviews {
            let viewSize = subview.sizeThatFits(.unspecified)

            if currentX + viewSize.width > bounds.maxX && currentX > bounds.minX {
                // Новая строка
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

// MARK: - Helper Extensions

extension CGRect {
    var center: CGPoint {
        return CGPoint(x: midX, y: midY)
    }
}

extension GeometryProxy {
    static var dummy: GeometryProxy {
        // Создаем заглушку для случаев, когда нет доступа к реальной геометрии
        // В реальном коде это будет заменено правильной реализацией
        fatalError("GeometryProxy.dummy should not be used in production")
    }
}

// MARK: - Preview
struct TooltipView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            CosmicGradients.mainCosmic
                .ignoresSafeArea()

            VStack(spacing: 20) {
                // Простая подсказка
                TooltipView(
                    tooltip: TooltipData(
                        title: "Солнце в Льве",
                        content: "Вы - прирожденный лидер с творческими способностями",
                        icon: "☀️♌",
                        type: .planet,
                        priority: .high,
                        style: .simple,
                        contextualInfo: nil
                    ),
                    position: CGPoint(x: 150, y: 100),
                    opacity: 1.0
                )

                // Детальная подсказка
                TooltipView(
                    tooltip: TooltipData(
                        title: "Марс квадрат Сатурн",
                        content: "Напряженный аспект между энергией действия и структурой ограничений. Требует терпения и дисциплины для преодоления препятствий.",
                        icon: "♂□♄",
                        type: .aspect,
                        priority: .medium,
                        style: .detailed,
                        contextualInfo: ContextualInfo(
                            keywords: ["напряжение", "дисциплина", "препятствия"],
                            lifeAreas: ["карьера", "цели"],
                            elementType: .aspect
                        )
                    ),
                    position: CGPoint(x: 150, y: 300),
                    opacity: 1.0
                )
            }
        }
        .previewDevice("iPhone 15")
    }
}