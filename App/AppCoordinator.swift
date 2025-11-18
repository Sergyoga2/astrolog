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
        case auth
        case main
        case subscription
    }

    private let firebaseService: FirebaseService

    init(firebaseService: FirebaseService = .shared) {
        self.firebaseService = firebaseService

        // Determine initial flow
        let onboardingCompleted = UserDefaults.standard.bool(forKey: "onboarding_completed")

        if !onboardingCompleted {
            currentFlow = .onboarding
        } else if !firebaseService.isAuthenticated {
            currentFlow = .auth
        } else {
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
        UserDefaults.standard.set(true, forKey: "onboarding_completed")

        // After onboarding, check auth status
        if firebaseService.isAuthenticated {
            currentFlow = .main
        } else {
            currentFlow = .auth
        }
    }

    func showAuth() {
        currentFlow = .auth
    }

    func completeAuth() {
        currentFlow = .main
    }

    func showSubscription() {
        currentFlow = .subscription
    }

    func navigateToChartTab() {
        currentFlow = .main
        selectedMainTab = 1 // Таб "Карта"
    }

    func signOut() {
        try? firebaseService.signOut()
        currentFlow = .auth
    }
}
