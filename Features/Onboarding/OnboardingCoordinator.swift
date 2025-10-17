//
//  OnboardingCoordinator.swift
//  Astrolog
//
//  Created by Sergey on 19.09.2025.
//
// Features/Onboarding/OnboardingCoordinator.swift
import SwiftUI
import Combine

struct OnboardingCoordinator: View {
    @EnvironmentObject var appCoordinator: AppCoordinator

    var body: some View {
        CosmicOnboardingView()
            .environmentObject(appCoordinator)
    }
}

#Preview {
    OnboardingCoordinator()
        .environmentObject(AppCoordinator())
}
