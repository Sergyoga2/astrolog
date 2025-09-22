//
//  AppCoordinator.swift
//  Astrolog
//
//  Created by Sergey on 19.09.2025.
//
import SwiftUI

@MainActor
class AppCoordinator: ObservableObject {
    @Published var currentFlow: AppFlow = .onboarding
    @Published var isLoading = false
    
    enum AppFlow {
        case onboarding
        case main
        case subscription
    }
    
    func startOnboarding() {
        currentFlow = .onboarding
    }
    
    func completeOnboarding() {
        currentFlow = .main
    }
    
    func showSubscription() {
        currentFlow = .subscription
    }
}
