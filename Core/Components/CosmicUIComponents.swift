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
        Button(action: action) {
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
