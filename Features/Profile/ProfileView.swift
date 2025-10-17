//
//  ProfileView.swift
//  Astrolog
//
//  Created by Claude on 22.09.2025.
//
// Features/Profile/ProfileView.swift
import SwiftUI

struct ProfileView: View {
    @State private var showBirthDataInput = false
    @State private var showNotificationSettings = false
    @State private var showSubscription = false
    @State private var showAppSettings = false
    @State private var showFirebaseTest = false

    var body: some View {
        NavigationView {
        ScrollView {
            VStack(spacing: CosmicSpacing.large) {
                CosmicSectionHeader(
                    "Ваш космический профиль",
                    subtitle: "Настройки и персональная информация",
                    icon: "person.circle"
                )

                // Карточка профиля
                CosmicCard(glowColor: .cosmicTeal) {
                    VStack(spacing: CosmicSpacing.large) {
                        // Аватар
                        ZStack {
                            Circle()
                                .fill(
                                    RadialGradient(
                                        colors: [.cosmicTeal.opacity(0.3), .cosmicTeal.opacity(0.1)],
                                        center: .center,
                                        startRadius: 10,
                                        endRadius: 60
                                    )
                                )
                                .frame(width: 100, height: 100)

                            Image(systemName: "person.circle.fill")
                                .font(.system(size: 60))
                                .foregroundColor(.cosmicTeal)
                                .modifier(NeonGlow(color: .cosmicTeal, intensity: 0.8))
                        }

                        VStack(spacing: CosmicSpacing.small) {
                            Text("Звездный путешественник")
                                .font(CosmicTypography.headline)
                                .foregroundColor(.starWhite)

                            Text("Исследуйте тайны космоса")
                                .font(CosmicTypography.caption)
                                .foregroundColor(.starWhite.opacity(0.8))
                        }

                        // Настройки
                        VStack(spacing: CosmicSpacing.medium) {
                            ProfileMenuItem(
                                icon: "person.crop.circle",
                                title: "Данные рождения",
                                subtitle: "Дата, время и место рождения"
                            ) {
                                showBirthDataInput = true
                            }

                            ProfileMenuItem(
                                icon: "bell.badge",
                                title: "Уведомления",
                                subtitle: "Астрологические события"
                            ) {
                                showNotificationSettings = true
                            }

                            ProfileMenuItem(
                                icon: "crown",
                                title: "Подписка",
                                subtitle: "Премиум функции"
                            ) {
                                showSubscription = true
                            }

                            ProfileMenuItem(
                                icon: "gear",
                                title: "Настройки",
                                subtitle: "Общие параметры приложения"
                            ) {
                                showAppSettings = true
                            }

                            // Firebase Test - только для разработки
                            ProfileMenuItem(
                                icon: "cloud.bolt",
                                title: "Firebase Test",
                                subtitle: "Тестирование интеграции с Firebase"
                            ) {
                                showFirebaseTest = true
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, CosmicSpacing.medium)
        }
        .sheet(isPresented: $showBirthDataInput) {
            NavigationView {
                CosmicBirthDataInputView()
            }
        }
        .sheet(isPresented: $showNotificationSettings) {
            NavigationView {
                NotificationSettingsView()
            }
        }
        .sheet(isPresented: $showSubscription) {
            NavigationView {
                SubscriptionView()
            }
        }
        .sheet(isPresented: $showAppSettings) {
            NavigationView {
                AppSettingsView()
            }
        }
        .sheet(isPresented: $showFirebaseTest) {
            NavigationView {
                AuthTestView()
            }
        }
        }
    }
}

// MARK: - Элемент меню профиля
struct ProfileMenuItem: View {
    let icon: String
    let title: String
    let subtitle: String
    let action: () -> Void

    var body: some View {
        HStack(spacing: CosmicSpacing.medium) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.cosmicTeal)
                .frame(width: 30, height: 30)
                .modifier(NeonGlow(color: .cosmicTeal, intensity: 0.5))

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(CosmicTypography.body)
                    .foregroundColor(.starWhite)

                Text(subtitle)
                    .font(CosmicTypography.caption)
                    .foregroundColor(.starWhite.opacity(0.7))
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.starWhite.opacity(0.5))
        }
        .padding(.vertical, CosmicSpacing.small)
        .contentShape(Rectangle())
        .onTapGesture {
            CosmicFeedbackManager.shared.lightImpact()
            action()
        }
    }
}