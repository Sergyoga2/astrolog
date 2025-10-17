//
//  AppSettingsView.swift
//  Astrolog
//
//  Created by Claude on 23.09.2025.
//

import SwiftUI

struct AppSettingsView: View {
    @State private var animationsEnabled = true
    @State private var hapticFeedback = true
    @State private var autoBackup = true
    @State private var selectedLanguage = "ru"

    let languages = [
        ("ru", "Русский"),
        ("en", "English"),
        ("es", "Español")
    ]

    var body: some View {
        ZStack {
            StarfieldBackground()
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: CosmicSpacing.large) {
                    CosmicSectionHeader(
                        "Настройки приложения",
                        subtitle: "Персонализация вашего космического опыта",
                        icon: "gear"
                    )

                    // Основные настройки
                    CosmicCard(glowColor: .cosmicTeal) {
                        VStack(spacing: CosmicSpacing.medium) {
                            SettingsToggle(
                                icon: "sparkles",
                                title: "Анимации",
                                description: "Космические эффекты и переходы",
                                isOn: $animationsEnabled
                            )

                            Divider()
                                .background(Color.starWhite.opacity(0.2))

                            SettingsToggle(
                                icon: "iphone.radiowaves.left.and.right",
                                title: "Тактильная обратная связь",
                                description: "Вибрация при взаимодействии",
                                isOn: $hapticFeedback
                            )

                            Divider()
                                .background(Color.starWhite.opacity(0.2))

                            SettingsToggle(
                                icon: "icloud.and.arrow.up",
                                title: "Автоматический бэкап",
                                description: "Синхронизация с iCloud",
                                isOn: $autoBackup
                            )
                        }
                    }

                    // Язык
                    CosmicCard(glowColor: .cosmicViolet) {
                        VStack(alignment: .leading, spacing: CosmicSpacing.medium) {
                            HStack {
                                Image(systemName: "globe")
                                    .foregroundColor(.cosmicViolet)
                                    .frame(width: 24)

                                Text("Язык интерфейса")
                                    .font(CosmicTypography.body)
                                    .foregroundColor(.starWhite)
                            }

                            ForEach(languages, id: \.0) { code, name in
                                HStack {
                                    Text(name)
                                        .font(CosmicTypography.body)
                                        .foregroundColor(.starWhite)

                                    Spacer()

                                    if selectedLanguage == code {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(.cosmicViolet)
                                            .modifier(NeonGlow(color: .cosmicViolet, intensity: 0.8))
                                    }
                                }
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    withAnimation(.spring()) {
                                        selectedLanguage = code
                                    }
                                    CosmicFeedbackManager.shared.selection()
                                }
                            }
                        }
                    }

                    // О приложении
                    CosmicCard(glowColor: .neonPurple) {
                        VStack(spacing: CosmicSpacing.medium) {
                            SettingsRow(
                                icon: "info.circle",
                                title: "О приложении",
                                value: "Версия 1.0.0"
                            )

                            SettingsRow(
                                icon: "questionmark.circle",
                                title: "Справка и поддержка",
                                value: ""
                            )

                            SettingsRow(
                                icon: "star.circle",
                                title: "Оценить приложение",
                                value: ""
                            )
                        }
                    }
                }
                .padding(.horizontal, CosmicSpacing.medium)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct SettingsToggle: View {
    let icon: String
    let title: String
    let description: String
    @Binding var isOn: Bool

    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.cosmicTeal)
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(CosmicTypography.body)
                    .foregroundColor(.starWhite)

                Text(description)
                    .font(CosmicTypography.caption)
                    .foregroundColor(.starWhite.opacity(0.7))
            }

            Spacer()

            Toggle("", isOn: $isOn)
                .toggleStyle(CosmicToggleStyle())
        }
        .contentShape(Rectangle())
        .onTapGesture {
            withAnimation(.spring()) {
                isOn.toggle()
            }
            CosmicFeedbackManager.shared.selection()
        }
    }
}

struct SettingsRow: View {
    let icon: String
    let title: String
    let value: String

    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.neonPurple)
                .frame(width: 24)

            Text(title)
                .font(CosmicTypography.body)
                .foregroundColor(.starWhite)

            Spacer()

            if !value.isEmpty {
                Text(value)
                    .font(CosmicTypography.caption)
                    .foregroundColor(.starWhite.opacity(0.6))
            }

            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.starWhite.opacity(0.4))
        }
        .contentShape(Rectangle())
        .onTapGesture {
            CosmicFeedbackManager.shared.lightImpact()
            // TODO: Handle navigation
        }
    }
}