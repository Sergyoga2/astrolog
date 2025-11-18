//
//  KeyEnergiesSection.swift
//  Astrolog
//
//  Created by Claude on 18.11.2025.
//
// Features/Main/Components/KeyEnergiesSection.swift
import SwiftUI

struct KeyEnergiesSection: View {
    let energies: [KeyEnergy]

    var body: some View {
        VStack(alignment: .leading, spacing: CosmicSpacing.medium) {
            CosmicSectionHeader(
                "⚡ Ключевые энергии сегодня",
                subtitle: "Планетарные влияния"
            )

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: CosmicSpacing.medium) {
                    ForEach(energies) { energy in
                        EnergyCard(energy: energy)
                    }
                }
            }
        }
    }
}

// MARK: - Energy Card
struct EnergyCard: View {
    let energy: KeyEnergy

    var body: some View {
        CosmicCard(glowColor: energy.type.color) {
            VStack(alignment: .leading, spacing: CosmicSpacing.medium) {
                // Иконка и тип
                HStack {
                    Text(energy.icon)
                        .font(.system(size: 32))

                    Spacer()

                    Text(energy.type.displayName)
                        .font(.caption2)
                        .fontWeight(.medium)
                        .foregroundColor(energy.type.color)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            Capsule()
                                .fill(energy.type.color.opacity(0.2))
                        )
                }

                // Заголовок
                Text(energy.title)
                    .font(CosmicTypography.body)
                    .fontWeight(.semibold)
                    .foregroundColor(.starWhite)
                    .lineLimit(2)

                // Описание
                Text(energy.description)
                    .font(CosmicTypography.caption)
                    .foregroundColor(.starWhite.opacity(0.8))
                    .lineLimit(3)
                    .fixedSize(horizontal: false, vertical: true)

                CosmicDivider()

                // Метаданные
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 4) {
                        Image(systemName: "clock")
                            .font(.caption2)
                        Text(energy.duration)
                            .font(.caption2)
                    }
                    .foregroundColor(.starWhite.opacity(0.6))

                    HStack(spacing: 4) {
                        Image(systemName: "star")
                            .font(.caption2)
                        Text(energy.area)
                            .font(.caption2)
                    }
                    .foregroundColor(.starWhite.opacity(0.6))

                    if let peakTime = energy.peakTime {
                        HStack(spacing: 4) {
                            Image(systemName: "bolt.fill")
                                .font(.caption2)
                            Text("Пик: \(peakTime)")
                                .font(.caption2)
                        }
                        .foregroundColor(.starYellow)
                    }
                }
            }
        }
        .frame(width: 280)
    }
}

#Preview {
    ZStack {
        StarfieldBackground()
            .ignoresSafeArea()

        ScrollView {
            KeyEnergiesSection(energies: KeyEnergy.mockList)
                .padding()
        }
    }
}
