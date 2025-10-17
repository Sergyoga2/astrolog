//
//  NotificationSettingsView.swift
//  Astrolog
//
//  Created by Claude on 23.09.2025.
//

import SwiftUI

struct NotificationSettingsView: View {
    @State private var dailyHoroscope = true
    @State private var transitAlerts = false
    @State private var moonPhaseNotifications = true
    @State private var retrogradeWarnings = true

    var body: some View {
        ZStack {
            StarfieldBackground()
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: CosmicSpacing.large) {
                    CosmicSectionHeader(
                        "Астрологические уведомления",
                        subtitle: "Настройте когда получать космические сообщения",
                        icon: "bell.badge"
                    )

                    CosmicCard(glowColor: .cosmicCyan) {
                        VStack(spacing: CosmicSpacing.medium) {
                            NotificationToggle(
                                title: "Ежедневный гороскоп",
                                description: "Получайте прогноз каждое утро",
                                isOn: $dailyHoroscope
                            )

                            Divider()
                                .background(Color.starWhite.opacity(0.2))

                            NotificationToggle(
                                title: "Транзиты планет",
                                description: "Уведомления о важных аспектах",
                                isOn: $transitAlerts
                            )

                            Divider()
                                .background(Color.starWhite.opacity(0.2))

                            NotificationToggle(
                                title: "Фазы Луны",
                                description: "Новолуние, полнолуние и квадратуры",
                                isOn: $moonPhaseNotifications
                            )

                            Divider()
                                .background(Color.starWhite.opacity(0.2))

                            NotificationToggle(
                                title: "Ретроградные планеты",
                                description: "Предупреждения о ретроградных периодах",
                                isOn: $retrogradeWarnings
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

struct NotificationToggle: View {
    let title: String
    let description: String
    @Binding var isOn: Bool

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
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

struct CosmicToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        RoundedRectangle(cornerRadius: 16)
            .fill(toggleBackground(isOn: configuration.isOn))
            .frame(width: 50, height: 28)
            .overlay(
                Circle()
                    .fill(Color.starWhite)
                    .frame(width: 22, height: 22)
                    .offset(x: configuration.isOn ? 11 : -11)
                    .animation(.spring(response: 0.3), value: configuration.isOn)
                    .modifier(NeonGlow(color: configuration.isOn ? .cosmicCyan : .clear, intensity: 0.5))
            )
            .onTapGesture {
                configuration.isOn.toggle()
            }
    }

    private func toggleBackground(isOn: Bool) -> LinearGradient {
        if isOn {
            return LinearGradient(colors: [.cosmicCyan, .neonPurple], startPoint: .leading, endPoint: .trailing)
        } else {
            return LinearGradient(colors: [Color.starWhite.opacity(0.2), Color.starWhite.opacity(0.2)], startPoint: .leading, endPoint: .trailing)
        }
    }
}