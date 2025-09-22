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
    
    enum AppFlow: CaseIterable {
        case onboarding
        case main
        case subscription
    }
    
    init() {
        if UserDefaults.standard.bool(forKey: "onboarding_completed") {
            currentFlow = .main
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
}
