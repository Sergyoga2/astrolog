//
//  CosmicFeedbackManager.swift
//  Astrolog
//
//  Created by Claude on 22.09.2025.
//

// Core/Utils/CosmicFeedbackManager.swift
import UIKit
import AVFoundation

class CosmicFeedbackManager {
    static let shared = CosmicFeedbackManager()

    // Haptic feedback генераторы
    private let lightHaptic = UIImpactFeedbackGenerator(style: .light)
    private let mediumHaptic = UIImpactFeedbackGenerator(style: .medium)
    private let heavyHaptic = UIImpactFeedbackGenerator(style: .heavy)
    private let selectionHaptic = UISelectionFeedbackGenerator()
    private let notificationHaptic = UINotificationFeedbackGenerator()

    // Звуковые эффекты
    private var audioPlayers: [String: AVAudioPlayer] = [:]

    private init() {
        // Подготавливаем генераторы
        lightHaptic.prepare()
        mediumHaptic.prepare()
        heavyHaptic.prepare()
        selectionHaptic.prepare()
        notificationHaptic.prepare()

        // Инициализируем звуки
        setupAudioPlayers()
    }

    private func setupAudioPlayers() {
        // Создаем программные звуки (без файлов)
        // В будущем можно добавить звуковые файлы
    }

    // MARK: - Haptic Feedback

    /// Легкая вибрация для нажатий кнопок
    func lightImpact() {
        lightHaptic.impactOccurred()
    }

    /// Средняя вибрация для важных действий
    func mediumImpact() {
        mediumHaptic.impactOccurred()
    }

    /// Сильная вибрация для критических действий
    func heavyImpact() {
        heavyHaptic.impactOccurred()
    }

    /// Вибрация выбора для переключений и пикеров
    func selection() {
        selectionHaptic.selectionChanged()
    }

    /// Успешное завершение действия
    func success() {
        notificationHaptic.notificationOccurred(.success)
    }

    /// Предупреждение
    func warning() {
        notificationHaptic.notificationOccurred(.warning)
    }

    /// Ошибка
    func error() {
        notificationHaptic.notificationOccurred(.error)
    }

    // MARK: - Cosmic-Specific Feedback

    /// Космическая магия - комбинированный эффект
    func cosmicMagic() {
        // Последовательность вибраций с увеличением интенсивности
        lightHaptic.impactOccurred()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.mediumHaptic.impactOccurred()
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.heavyHaptic.impactOccurred()
        }
    }

    /// Звездное взаимодействие - для касаний планет
    func starTouch() {
        selectionHaptic.selectionChanged()
        playSystemSound(.peek)
    }

    /// Космический переход между экранами
    func cosmicTransition() {
        lightHaptic.impactOccurred()
        playSystemSound(.swipeNext)
    }

    /// Создание натальной карты
    func chartCreation() {
        cosmicMagic()
        playSystemSound(.flourish)
    }

    /// Открытие нового раздела
    func sectionReveal() {
        mediumHaptic.impactOccurred()
        playSystemSound(.appearMagic)
    }

    // MARK: - System Sounds

    private enum CosmicSound: SystemSoundID {
        case peek = 1519
        case pop = 1520
        case cancelled = 1521
        case tryAgain = 1102
        case failed = 1107
        case beginRecording = 1113
        case endRecording = 1114
        case swipeNext = 1105
        case flourish = 1108
        case appearMagic = 1109
    }

    private func playSystemSound(_ sound: CosmicSound) {
        AudioServicesPlaySystemSound(sound.rawValue)
    }

    // MARK: - Animation Integration

    /// Sync haptic with animation timing
    func syncWithAnimation(duration: Double, intensity: FeedbackIntensity) {
        switch intensity {
        case .subtle:
            lightImpact()
        case .moderate:
            mediumHaptic.impactOccurred()
        case .strong:
            heavyHaptic.impactOccurred()
        case .cosmic:
            cosmicMagic()
        }
    }
}

// MARK: - Feedback Intensity
enum FeedbackIntensity {
    case subtle
    case moderate
    case strong
    case cosmic
}

// MARK: - SwiftUI Integration
import SwiftUI

extension View {
    /// Добавляет космическую тактильную обратную связь к кнопке
    func cosmicFeedback(_ type: CosmicFeedbackType = .selection) -> some View {
        self.simultaneousGesture(
            TapGesture().onEnded { _ in
                switch type {
                case .selection:
                    CosmicFeedbackManager.shared.selection()
                case .impact:
                    CosmicFeedbackManager.shared.lightImpact()
                case .success:
                    CosmicFeedbackManager.shared.success()
                case .magic:
                    CosmicFeedbackManager.shared.cosmicMagic()
                case .starTouch:
                    CosmicFeedbackManager.shared.starTouch()
                }
            }
        )
    }
}

enum CosmicFeedbackType {
    case selection
    case impact
    case success
    case magic
    case starTouch
}