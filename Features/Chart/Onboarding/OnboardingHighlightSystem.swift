//
//  OnboardingHighlightSystem.swift
//  Astrolog
//
//  Created by Claude on 21.10.2025.
//

// Features/Chart/Onboarding/OnboardingHighlightSystem.swift
import SwiftUI
import Combine

/// Система подсветки элементов для онбординга
public class OnboardingHighlightSystem: ObservableObject {

    // MARK: - Published Properties

    @Published var highlightedElements: [String: HighlightConfig] = [:]
    @Published var isHighlightingEnabled: Bool = false

    // MARK: - Private Properties

    private var activeHighlights: Set<String> = []
    private var highlightTimers: [String: Timer] = [:]

    // MARK: - Public Methods

    /// Подсветить элемент
    func highlightElement(
        id: String,
        config: HighlightConfig = HighlightConfig(),
        duration: TimeInterval? = nil
    ) {
        withAnimation(config.animation) {
            highlightedElements[id] = config
            activeHighlights.insert(id)
        }

        // Автоматическое убирание подсветки через заданное время
        if let duration = duration {
            highlightTimers[id]?.invalidate()
            highlightTimers[id] = Timer.scheduledTimer(withTimeInterval: duration, repeats: false) { [weak self] _ in
                self?.removeHighlight(for: id)
            }
        }
    }

    /// Убрать подсветку элемента
    func removeHighlight(for id: String) {
        highlightTimers[id]?.invalidate()
        highlightTimers[id] = nil

        guard let config = highlightedElements[id] else { return }

        withAnimation(config.animation) {
            highlightedElements.removeValue(forKey: id)
            activeHighlights.remove(id)
        }
    }

    /// Убрать все подсветки
    func removeAllHighlights() {
        highlightTimers.values.forEach { $0.invalidate() }
        highlightTimers.removeAll()

        withAnimation(.easeOut(duration: 0.3)) {
            highlightedElements.removeAll()
            activeHighlights.removeAll()
        }
    }

    /// Проверить, подсвечен ли элемент
    func isHighlighted(_ id: String) -> Bool {
        return activeHighlights.contains(id)
    }

    /// Включить/отключить систему подсветки
    func setHighlightingEnabled(_ enabled: Bool) {
        isHighlightingEnabled = enabled

        if !enabled {
            removeAllHighlights()
        }
    }

    /// Пульсирующая подсветка для привлечения внимания
    func pulseHighlight(
        id: String,
        config: HighlightConfig = HighlightConfig(style: .pulse),
        pulseCount: Int = 3
    ) {
        highlightElement(id: id, config: config)

        // Создаем серию анимаций пульсации
        for i in 0..<pulseCount {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 1.5) {
                if self.isHighlighted(id) {
                    // Временно увеличиваем интенсивность
                    var pulseConfig = config
                    pulseConfig.glowIntensity *= 1.5
                    pulseConfig.borderWidth *= 1.3

                    withAnimation(.easeInOut(duration: 0.6)) {
                        self.highlightedElements[id] = pulseConfig
                    }

                    // Возвращаем к нормальной интенсивности
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                        withAnimation(.easeInOut(duration: 0.6)) {
                            self.highlightedElements[id] = config
                        }
                    }
                }
            }
        }

        // Убираем подсветку после всех пульсаций
        DispatchQueue.main.asyncAfter(deadline: .now() + Double(pulseCount) * 1.5 + 1.0) {
            self.removeHighlight(for: id)
        }
    }

    /// Последовательная подсветка нескольких элементов
    func highlightSequence(
        elements: [(id: String, config: HighlightConfig, duration: TimeInterval)],
        intervalBetween: TimeInterval = 0.5
    ) {
        for (index, element) in elements.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * (element.duration + intervalBetween)) {
                self.highlightElement(id: element.id, config: element.config, duration: element.duration)
            }
        }
    }
}

// MARK: - Supporting Types

/// Конфигурация подсветки
public struct HighlightConfig {
    public var style: HighlightStyle = .glow
    public var color: Color = Color.cyan
    public var glowIntensity: CGFloat = 1.0
    public var borderWidth: CGFloat = 3.0
    public var cornerRadius: CGFloat = 8.0
    public var padding: CGFloat = 8.0
    public var animation: Animation = .easeInOut(duration: 0.6)
    public var shouldPulse: Bool = false

    public init(style: HighlightStyle = .glow, color: Color = Color.cyan, glowIntensity: CGFloat = 1.0, borderWidth: CGFloat = 3.0, cornerRadius: CGFloat = 8.0, padding: CGFloat = 8.0, animation: Animation = .easeInOut(duration: 0.6), shouldPulse: Bool = false) {
        self.style = style
        self.color = color
        self.glowIntensity = glowIntensity
        self.borderWidth = borderWidth
        self.cornerRadius = cornerRadius
        self.padding = padding
        self.animation = animation
        self.shouldPulse = shouldPulse
    }

    public enum HighlightStyle {
        case glow
        case border
        case pulse
        case spotlight
        case arrow
    }
}

// MARK: - View Extensions

/// Модификатор для добавления подсветки к элементу
struct OnboardingHighlightModifier: ViewModifier {
    let id: String
    @ObservedObject var highlightSystem: OnboardingHighlightSystem

    func body(content: Content) -> some View {
        content
            .overlay(
                highlightOverlay
                    .allowsHitTesting(false)
            )
            .accessibilityIdentifier("onboarding_\(id)")
    }

    @ViewBuilder
    private var highlightOverlay: some View {
        if let config = highlightSystem.highlightedElements[id],
           highlightSystem.isHighlightingEnabled {

            switch config.style {
            case .glow:
                glowHighlight(config: config)
            case .border:
                borderHighlight(config: config)
            case .pulse:
                pulseHighlight(config: config)
            case .spotlight:
                spotlightHighlight(config: config)
            case .arrow:
                arrowHighlight(config: config)
            }
        }
    }

    private func glowHighlight(config: HighlightConfig) -> some View {
        RoundedRectangle(cornerRadius: config.cornerRadius)
            .stroke(config.color, lineWidth: config.borderWidth)
            .background(
                RoundedRectangle(cornerRadius: config.cornerRadius)
                    .fill(config.color.opacity(0.1))
            )
            .shadow(
                color: config.color,
                radius: 10 * config.glowIntensity,
                x: 0, y: 0
            )
            .padding(-config.padding)
    }

    private func borderHighlight(config: HighlightConfig) -> some View {
        RoundedRectangle(cornerRadius: config.cornerRadius)
            .stroke(
                LinearGradient(
                    colors: [config.color, config.color.opacity(0.3)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                lineWidth: config.borderWidth
            )
            .padding(-config.padding)
    }

    private func pulseHighlight(config: HighlightConfig) -> some View {
        ZStack {
            // Внешнее кольцо
            RoundedRectangle(cornerRadius: config.cornerRadius + 4)
                .stroke(config.color.opacity(0.6), lineWidth: 2)
                .scaleEffect(config.shouldPulse ? 1.2 : 1.0)
                .opacity(config.shouldPulse ? 0.3 : 0.8)

            // Внутреннее кольцо
            RoundedRectangle(cornerRadius: config.cornerRadius)
                .stroke(config.color, lineWidth: config.borderWidth)
                .shadow(color: config.color, radius: 8)
        }
        .padding(-config.padding)
        .animation(
            .easeInOut(duration: 1.5).repeatForever(autoreverses: true),
            value: config.shouldPulse
        )
        .onAppear {
            // Запускаем пульсацию
        }
    }

    private func spotlightHighlight(config: HighlightConfig) -> some View {
        Circle()
            .fill(
                RadialGradient(
                    colors: [
                        Color.clear,
                        config.color.opacity(0.3),
                        config.color.opacity(0.1)
                    ],
                    center: .center,
                    startRadius: 20,
                    endRadius: 60
                )
            )
            .frame(width: 120, height: 120)
            .scaleEffect(config.glowIntensity)
    }

    private func arrowHighlight(config: HighlightConfig) -> some View {
        VStack {
            Image(systemName: "arrow.down")
                .font(.title2)
                .foregroundColor(config.color)
                .shadow(color: config.color, radius: 4)
                .offset(y: -40)
                .scaleEffect(1.2)
                .animation(
                    .easeInOut(duration: 1.0).repeatForever(autoreverses: true),
                    value: highlightSystem.isHighlightingEnabled
                )

            Spacer()
        }
    }
}

/// Расширение View для добавления подсветки
extension View {
    func onboardingHighlight(
        id: String,
        system: OnboardingHighlightSystem
    ) -> some View {
        modifier(OnboardingHighlightModifier(id: id, highlightSystem: system))
    }
}

// MARK: - Preset Configurations

extension HighlightConfig {
    /// Мягкое свечение для общих элементов
    static let softGlow = HighlightConfig(
        style: .glow,
        color: .neonCyan.opacity(0.8),
        glowIntensity: 0.8,
        borderWidth: 2.0,
        animation: .easeInOut(duration: 0.8)
    )

    /// Яркая подсветка для важных элементов
    static let brightHighlight = HighlightConfig(
        style: .pulse,
        color: .starYellow,
        glowIntensity: 1.5,
        borderWidth: 4.0,
        cornerRadius: 8.0,
        padding: 8.0,
        animation: .spring(response: 0.6, dampingFraction: 0.7),
        shouldPulse: true
    )

    /// Тонкая рамка для неосновных элементов
    static let subtleBorder = HighlightConfig(
        style: .border,
        color: .cosmicViolet.opacity(0.6),
        borderWidth: 1.5,
        animation: .linear(duration: 0.4)
    )

    /// Внимание привлекающая стрелка
    static let attention = HighlightConfig(
        style: .arrow,
        color: .neonPink,
        glowIntensity: 1.2
    )

    /// Прожектор для центральных элементов
    static let spotlight = HighlightConfig(
        style: .spotlight,
        color: .starWhite,
        glowIntensity: 1.8,
        animation: .easeInOut(duration: 1.0)
    )
}

// MARK: - Integration with ChartView

extension View {
    /// Интегрирует систему подсветки онбординга в представление
    func withOnboardingHighlights<T: OnboardingFlowProtocol>(
        onboardingFlow: T,
        highlightSystem: OnboardingHighlightSystem
    ) -> some View {
        self
            .environmentObject(highlightSystem)
            .onChange(of: onboardingFlow.currentStep) { newStep in
                if newStep != nil {
                    onboardingFlow.highlightCurrentStepElement(using: highlightSystem)
                } else {
                    highlightSystem.removeAllHighlights()
                }
            }
            .onChange(of: onboardingFlow.isActive) { isActive in
                highlightSystem.setHighlightingEnabled(isActive)
                if !isActive {
                    highlightSystem.removeAllHighlights()
                }
            }
    }
}