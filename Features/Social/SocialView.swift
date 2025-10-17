//
//  SocialView.swift
//  Astrolog
//
//  Created by Claude on 22.09.2025.
//
// Features/Social/SocialView.swift
import SwiftUI

struct SocialView: View {
    var body: some View {
        ZStack {
            StarfieldBackground()
                .ignoresSafeArea()

            ScrollView {
            VStack(spacing: CosmicSpacing.large) {
                CosmicSectionHeader(
                    "Космические связи",
                    subtitle: "Найдите свою астрологическую совместимость",
                    icon: "person.2"
                )

                // Карточка-заглушка
                CosmicCard(glowColor: .cosmicCyan) {
                    VStack(spacing: CosmicSpacing.large) {
                        Image(systemName: "person.2.circle")
                            .font(.system(size: 60))
                            .foregroundColor(.cosmicCyan)
                            .modifier(NeonGlow(color: .cosmicCyan, intensity: 0.8))

                        VStack(spacing: CosmicSpacing.small) {
                            Text("Раздел в разработке")
                                .font(CosmicTypography.headline)
                                .foregroundColor(.starWhite)

                            Text("Скоро здесь будет анализ совместимости с друзьями и партнёрами")
                                .font(CosmicTypography.body)
                                .foregroundColor(.starWhite.opacity(0.8))
                                .multilineTextAlignment(.center)
                        }

                        CosmicButton(
                            title: "Уведомить о готовности",
                            icon: "bell",
                            color: .cosmicCyan
                        ) {
                            // Функционал уведомлений
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