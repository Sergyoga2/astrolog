//
//  CosmicUIComponents.swift
//  Astrolog
//
//  Created by Sergey on 22.09.2025.
//
// Core/Components/CosmicUIComponents.swift
import SwiftUI

// MARK: - Cosmic Loading View
struct CosmicLoadingView: View {
    @State private var rotation: Double = 0
    
    var body: some View {
        VStack(spacing: CosmicSpacing.medium) {
            ZStack {
                ForEach(0..<8) { index in
                    Circle()
                        .fill(Color.neonPurple.opacity(0.3))
                        .frame(width: 10, height: 10)
                        .offset(y: -30)
                        .rotationEffect(.degrees(Double(index) * 45))
                        .rotationEffect(.degrees(rotation))
                        .modifier(NeonGlow(color: .neonPurple, intensity: 0.5))
                }
            }
            .frame(width: 60, height: 60)
            
            Text("Читаем звезды...")
                .font(CosmicTypography.caption)
                .foregroundColor(.neonPurple)
                .shimmer()
        }
        .padding(CosmicSpacing.large)
        .onAppear {
            withAnimation(.linear(duration: 2).repeatForever(autoreverses: false)) {
                rotation = 360
            }
        }
    }
}

// MARK: - Cosmic Card
struct CosmicCard<Content: View>: View {
    let content: Content
    var glowColor: Color = .neonPurple
    
    init(glowColor: Color = .neonPurple, @ViewBuilder content: () -> Content) {
        self.glowColor = glowColor
        self.content = content()
    }
    
    var body: some View {
        content
            .padding(CosmicSpacing.large)
            .glassmorphicCard(glowColor: glowColor)
    }
}

// MARK: - Cosmic Button
struct CosmicButton: View {
    let title: String
    let icon: String?
    let color: Color
    let action: () -> Void
    
    init(title: String, icon: String? = nil, color: Color = .cosmicViolet, action: @escaping () -> Void) {
        self.title = title
        self.icon = icon
        self.color = color
        self.action = action
    }
    
    var body: some View {
        Button(action: {
            CosmicFeedbackManager.shared.lightImpact()
            action()
        }) {
            HStack(spacing: 8) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: 16))
                }
                Text(title)
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
            }
        }
        .buttonStyle(CosmicButtonStyle(primaryColor: color))
    }
}

// MARK: - Zodiac Sign Badge
struct ZodiacSignBadge: View {
    let sign: ZodiacSign
    
    var body: some View {
        HStack(spacing: 4) {
            Text(sign.symbol)
                .font(CosmicTypography.zodiacSymbol)
            Text(sign.displayName)
                .font(CosmicTypography.caption)
                .fontWeight(.medium)
        }
        .foregroundStyle(
            LinearGradient(
                colors: [Color.neonPurple, Color.cosmicPink],
                startPoint: .leading,
                endPoint: .trailing
            )
        )
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(
            Capsule()
                .fill(.ultraThinMaterial)
                .overlay(
                    Capsule()
                        .stroke(Color.neonPurple.opacity(0.3), lineWidth: 1)
                )
        )
        .modifier(NeonGlow(color: .neonPurple, intensity: 0.3))
    }
}

// MARK: - Planet Symbol View
struct PlanetSymbolView: View {
    let planetType: PlanetType
    @State private var rotation: Double = 0

    var body: some View {
        Text(planetType.symbol)
            .font(CosmicTypography.planetSymbol)
            .foregroundColor(planetType.color)
            .rotationEffect(.degrees(rotation))
            .modifier(NeonGlow(color: planetType.color, intensity: 0.6))
            .onAppear {
                withAnimation(
                    .linear(duration: Double.random(in: 8...15))
                    .repeatForever(autoreverses: false)
                ) {
                    rotation = 360
                }
            }
    }
}

// MARK: - Cosmic Progress Ring
struct CosmicProgressRing: View {
    let progress: Double
    let lineWidth: CGFloat
    let size: CGFloat

    init(progress: Double, lineWidth: CGFloat = 8, size: CGFloat = 100) {
        self.progress = progress
        self.lineWidth = lineWidth
        self.size = size
    }

    var body: some View {
        ZStack {
            // Background ring
            Circle()
                .stroke(Color.cosmicPurple.opacity(0.3), lineWidth: lineWidth)
                .frame(width: size, height: size)

            // Progress ring
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    CosmicGradients.aurora,
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .frame(width: size, height: size)
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut(duration: 1), value: progress)
                .modifier(NeonGlow(color: .neonBlue, intensity: 0.8))
        }
    }
}

// MARK: - Cosmic Text Field
struct CosmicTextField: View {
    @Binding var text: String
    let placeholder: String
    let icon: String?

    init(_ placeholder: String, text: Binding<String>, icon: String? = nil) {
        self.placeholder = placeholder
        self._text = text
        self.icon = icon
    }

    var body: some View {
        HStack(spacing: CosmicSpacing.medium) {
            if let icon = icon {
                Image(systemName: icon)
                    .foregroundColor(.neonPurple)
                    .modifier(NeonGlow(color: .neonPurple, intensity: 0.5))
            }

            TextField(placeholder, text: $text)
                .font(CosmicTypography.body)
                .foregroundColor(.starWhite)
        }
        .padding(CosmicSpacing.medium)
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    .neonPurple.opacity(0.6),
                                    .neonBlue.opacity(0.4)
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            ),
                            lineWidth: 1.5
                        )
                )
        )
        .modifier(NeonGlow(color: .neonPurple, intensity: 0.3))
    }
}

// MARK: - Cosmic Section Header
struct CosmicSectionHeader: View {
    let title: String
    let subtitle: String?
    let icon: String?

    init(_ title: String, subtitle: String? = nil, icon: String? = nil) {
        self.title = title
        self.subtitle = subtitle
        self.icon = icon
    }

    var body: some View {
        VStack(alignment: .leading, spacing: CosmicSpacing.small) {
            HStack(spacing: CosmicSpacing.small) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(CosmicTypography.headline)
                        .foregroundColor(.neonPurple)
                        .modifier(NeonGlow(color: .neonPurple, intensity: 0.6))
                }

                Text(title)
                    .font(CosmicTypography.headline)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.starWhite, .neonPurple],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )

                Spacer()
            }

            if let subtitle = subtitle {
                Text(subtitle)
                    .font(CosmicTypography.caption)
                    .foregroundColor(.starWhite.opacity(0.7))
            }
        }
    }
}

// MARK: - Cosmic Back Button
struct CosmicBackButton: View {
    let action: () -> Void

    init(action: @escaping () -> Void) {
        self.action = action
    }

    var body: some View {
        Button(action: {
            CosmicFeedbackManager.shared.lightImpact()
            action()
        }) {
            HStack(spacing: 8) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 16, weight: .medium))
                Text("Назад")
                    .font(.system(size: 16, weight: .medium, design: .rounded))
            }
        }
        .buttonStyle(CosmicButtonStyle(primaryColor: .neonPurple, isProminent: false))
    }
}

// MARK: - Cosmic Divider
struct CosmicDivider: View {
    let gradient: LinearGradient
    let height: CGFloat

    init(gradient: LinearGradient = CosmicGradients.aurora, height: CGFloat = 1) {
        self.gradient = gradient
        self.height = height
    }

    var body: some View {
        Rectangle()
            .fill(gradient)
            .frame(height: height)
            .modifier(NeonGlow(color: .neonPurple, intensity: 0.4))
            .padding(.horizontal, CosmicSpacing.medium)
    }
}

// MARK: - Floating Action Button
struct CosmicFloatingButton: View {
    let icon: String
    let color: Color
    let action: () -> Void

    init(icon: String, color: Color = .cosmicViolet, action: @escaping () -> Void) {
        self.icon = icon
        self.color = color
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.starWhite)
        }
        .frame(width: 56, height: 56)
        .background(
            Circle()
                .fill(
                    RadialGradient(
                        colors: [color, color.opacity(0.7)],
                        center: .center,
                        startRadius: 5,
                        endRadius: 28
                    )
                )
        )
        .modifier(NeonGlow(color: color, intensity: 1.0))
        .floatingAnimation()
        .shadow(color: color.opacity(0.4), radius: 10, x: 0, y: 5)
    }
}
