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
    @State private var currentStep = 0
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            // Лого
            Image(systemName: "star.circle.fill")
                .font(.system(size: 100))
                .foregroundColor(.purple)
            
            VStack(spacing: 16) {
                Text("Добро пожаловать в Astrolog")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                
                Text("Откройте секреты звезд и познайте себя через астрологию")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            
            Spacer()
            
            VStack(spacing: 12) {
                Button(action: {
                    appCoordinator.completeOnboarding()
                }) {
                    Text("Начать путешествие")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.purple)
                        .cornerRadius(12)
                }
                
                Button(action: {
                    appCoordinator.showSubscription()
                }) {
                    Text("Узнать о Premium")
                        .font(.subheadline)
                        .foregroundColor(.purple)
                }
            }
            .padding(.horizontal)
            
            Spacer()
        }
        .padding()
    }
}

#Preview {
    OnboardingCoordinator()
        .environmentObject(AppCoordinator())
}
