//
//  CosmicPerformanceManager.swift
//  Astrolog
//
//  Created by Claude on 22.09.2025.
//

// Core/Utils/CosmicPerformanceManager.swift
import SwiftUI
import Combine

class CosmicPerformanceManager: ObservableObject {
    static let shared = CosmicPerformanceManager()

    @Published var isLowPowerMode: Bool = false
    @Published var shouldReduceAnimations: Bool = false
    @Published var starFieldDensity: StarFieldDensity = .normal
    @Published var particleCount: ParticleCount = .normal

    private var cancellables = Set<AnyCancellable>()

    private init() {
        setupPerformanceMonitoring()
    }

    private func setupPerformanceMonitoring() {
        // Мониторинг низкого энергопотребления
        NotificationCenter.default.publisher(for: .NSProcessInfoPowerStateDidChange)
            .sink { [weak self] _ in
                self?.updatePowerState()
            }
            .store(in: &cancellables)

        // Проверяем настройки доступности
        updateAccessibilitySettings()
        updatePowerState()
    }

    private func updatePowerState() {
        DispatchQueue.main.async {
            self.isLowPowerMode = ProcessInfo.processInfo.isLowPowerModeEnabled
            self.adjustPerformanceForPowerMode()
        }
    }

    private func updateAccessibilitySettings() {
        shouldReduceAnimations = UIAccessibility.isReduceMotionEnabled
    }

    private func adjustPerformanceForPowerMode() {
        if isLowPowerMode {
            starFieldDensity = .low
            particleCount = .minimal
        } else {
            starFieldDensity = .normal
            particleCount = .normal
        }
    }

    // MARK: - Animation Helpers

    /// Возвращает оптимизированную анимацию для текущих условий
    func optimizedAnimation(
        _ baseAnimation: Animation,
        reducedMotion fallback: Animation? = nil
    ) -> Animation {
        if shouldReduceAnimations {
            return fallback ?? .easeInOut(duration: 0.2)
        }
        return baseAnimation
    }

    /// Возвращает оптимизированную длительность анимации
    func optimizedDuration(_ baseDuration: Double) -> Double {
        if shouldReduceAnimations {
            return baseDuration * 0.3
        }
        if isLowPowerMode {
            return baseDuration * 0.7
        }
        return baseDuration
    }

    /// Должна ли воспроизводиться анимация
    func shouldAnimate() -> Bool {
        return !shouldReduceAnimations
    }

    /// Оптимизированная задержка для анимаций
    func optimizedDelay(_ baseDelay: Double) -> Double {
        if shouldReduceAnimations {
            return 0
        }
        return baseDelay
    }
}

// MARK: - Performance Levels

enum StarFieldDensity {
    case minimal  // 50 звезд
    case low      // 75 звезд
    case normal   // 150 звезд
    case high     // 200 звезд

    var starCount: Int {
        switch self {
        case .minimal: return 50
        case .low: return 75
        case .normal: return 150
        case .high: return 200
        }
    }
}

enum ParticleCount {
    case minimal  // Без частиц
    case low      // 20 частиц
    case normal   // 50 частиц
    case high     // 100 частиц

    var count: Int {
        switch self {
        case .minimal: return 0
        case .low: return 20
        case .normal: return 50
        case .high: return 100
        }
    }
}

// MARK: - SwiftUI Extensions

extension View {
    /// Применяет оптимизированную анимацию
    func optimizedAnimation(
        _ animation: Animation,
        value: some Equatable,
        reducedMotion fallback: Animation? = nil
    ) -> some View {
        let optimized = CosmicPerformanceManager.shared.optimizedAnimation(animation, reducedMotion: fallback)
        return self.animation(optimized, value: value)
    }

    /// Условная анимация в зависимости от настроек производительности
    func conditionalAnimation<V: Equatable>(
        _ animation: Animation,
        value: V
    ) -> some View {
        Group {
            if CosmicPerformanceManager.shared.shouldAnimate() {
                self.animation(animation, value: value)
            } else {
                self
            }
        }
    }

    /// Оптимизированное сочетание с производительностью
    func performanceOptimized() -> some View {
        self.drawingGroup(opaque: false, colorMode: .nonLinear)
    }
}

// MARK: - Animation Timing Utilities

struct CosmicAnimationTiming {
    static let shared = CosmicAnimationTiming()
    private let performanceManager = CosmicPerformanceManager.shared

    private init() {}

    // Стандартные анимации с оптимизацией
    var quickSpring: Animation {
        performanceManager.optimizedAnimation(
            .spring(response: 0.4, dampingFraction: 0.8),
            reducedMotion: .easeInOut(duration: 0.2)
        )
    }

    var smoothSpring: Animation {
        performanceManager.optimizedAnimation(
            .spring(response: 0.6, dampingFraction: 0.8),
            reducedMotion: .easeInOut(duration: 0.3)
        )
    }

    var cosmicFloat: Animation {
        if performanceManager.shouldReduceAnimations {
            return .easeInOut(duration: 0.1)
        }
        return .easeInOut(duration: performanceManager.optimizedDuration(3.0))
            .repeatForever(autoreverses: true)
    }

    var starRotation: Animation {
        if performanceManager.shouldReduceAnimations {
            return .linear(duration: 0.1)
        }
        return .linear(duration: performanceManager.optimizedDuration(20.0))
            .repeatForever(autoreverses: false)
    }

    var shimmer: Animation {
        if performanceManager.shouldReduceAnimations {
            return .easeInOut(duration: 0.1)
        }
        return .easeInOut(duration: performanceManager.optimizedDuration(1.5))
            .repeatForever(autoreverses: true)
    }
}

// MARK: - Performance Metrics

class CosmicMetrics: ObservableObject {
    static let shared = CosmicMetrics()

    @Published private(set) var frameRate: Double = 60.0
    @Published private(set) var memoryUsage: Double = 0.0

    private var displayLink: CADisplayLink?
    private var frameCount: Int = 0
    private var lastTimestamp: CFTimeInterval = 0

    private init() {
        startFrameRateMonitoring()
    }

    private func startFrameRateMonitoring() {
        displayLink = CADisplayLink(target: self, selector: #selector(displayLinkTick))
        displayLink?.add(to: .main, forMode: .common)
    }

    @objc private func displayLinkTick(displayLink: CADisplayLink) {
        if lastTimestamp == 0 {
            lastTimestamp = displayLink.timestamp
            return
        }

        frameCount += 1

        let currentTime = displayLink.timestamp
        let deltaTime = currentTime - lastTimestamp

        if deltaTime >= 1.0 {
            frameRate = Double(frameCount) / deltaTime
            frameCount = 0
            lastTimestamp = currentTime

            // Автоматическая оптимизация при низком FPS
            if frameRate < 45 {
                CosmicPerformanceManager.shared.starFieldDensity = .low
                CosmicPerformanceManager.shared.particleCount = .minimal
            }
        }
    }

    deinit {
        displayLink?.invalidate()
    }
}