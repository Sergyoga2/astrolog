//
//  MindfulnessView.swift
//  Astrolog
//
//  Created by Claude on 22.09.2025.
//
// Features/Mindfulness/MindfulnessView.swift
import SwiftUI

struct MindfulnessView: View {
    var body: some View {
        ZStack {
            StarfieldBackground()
                .ignoresSafeArea()

            ScrollView {
            VStack(spacing: CosmicSpacing.large) {
                CosmicSectionHeader(
                    "Космическая осознанность",
                    subtitle: "Медитации и практики для духовного роста",
                    icon: "sparkles"
                )

                // Карточка-заглушка
                CosmicCard(glowColor: .neonPurple) {
                    VStack(spacing: CosmicSpacing.large) {
                        Image(systemName: "meditation")
                            .font(.system(size: 60))
                            .foregroundColor(.neonPurple)
                            .modifier(NeonGlow(color: .neonPurple, intensity: 0.8))
                            .floatingAnimation()

                        VStack(spacing: CosmicSpacing.small) {
                            Text("Медитативное пространство")
                                .font(CosmicTypography.headline)
                                .foregroundColor(.starWhite)

                            Text("Здесь будут медитации, практики осознанности и духовные упражнения, основанные на астрологических циклах")
                                .font(CosmicTypography.body)
                                .foregroundColor(.starWhite.opacity(0.8))
                                .multilineTextAlignment(.center)
                        }

                        CosmicButton(
                            title: "Начать практику",
                            icon: "play.circle",
                            color: .neonPurple
                        ) {
                            // Функционал медитаций
                        }
                    }
                }
                .padding(.top, CosmicSpacing.massive)
            }
            .padding(.horizontal, CosmicSpacing.medium)
            }
        }
    }
}