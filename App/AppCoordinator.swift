//
//  AppCoordinator.swift
//  Astrolog
//
//  Created by Sergey on 19.09.2025.
//
// App/AppCoordinator.swift
import SwiftUI
import Combine

@MainActor
final class AppCoordinator: ObservableObject {
    @Published var currentFlow: AppFlow = .onboarding
    @Published var isLoading = false
    @Published var selectedMainTab: Int = 0

    enum AppFlow: CaseIterable {
        case onboarding
        case main
        case subscription
    }
    
    init() {
        if UserDefaults.standard.bool(forKey: "onboarding_completed") {
            currentFlow = .main
        }

        // Подписываемся на уведомления о навигации к карте
        NotificationCenter.default.addObserver(
            forName: .navigateToChart,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor in
                self?.navigateToChartTab()
            }
        }
    }
    
    func startOnboarding() {
        currentFlow = .onboarding
    }
    
    func completeOnboarding() {
        currentFlow = .main
        UserDefaults.standard.set(true, forKey: "onboarding_completed")
    }
    
    func showSubscription() {
        currentFlow = .subscription
    }

    func navigateToChartTab() {
        currentFlow = .main
        selectedMainTab = 1 // Таб "Карта"
    }
}
