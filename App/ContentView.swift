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
        ZStack {
            Color(.systemBackground)
                .ignoresSafeArea()
            
            switch coordinator.currentFlow {
            case .onboarding:
                OnboardingCoordinator()
            case .main:
                MainTabView()
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
