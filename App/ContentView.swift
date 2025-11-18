//
//  ContentView.swift
//  Astrolog
//
//  Created by Sergey on 19.09.2025.
//
import SwiftUI

struct ContentView: View {
    @EnvironmentObject var coordinator: AppCoordinator

    var body: some View {
        Group {
            switch coordinator.currentFlow {
            case .onboarding:
                OnboardingCoordinator()
            case .auth:
                AuthView()
            case .main:
                CosmicMainTabView()
            case .subscription:
                SubscriptionView()
            }
        }
        .animation(.easeInOut(duration: 0.3), value: coordinator.currentFlow)
    }
}

#Preview {
    ContentView()
        .environmentObject(AppCoordinator())
}

