//
//  CosmicViewModifiers.swift
//  Astrolog
//
//  Created by Sergey on 22.09.2025.
//
// Core/Theme/CosmicViewModifiers.swift
import SwiftUI

// MARK: - Glassmorphism Card
struct GlassmorphicCard: ViewModifier {
    var cornerRadius: CGFloat = 20
    var glowColor: Color = .neonPurple
    
    func body(content: Content) -> some View {
        content
            .background(
                ZStack {
                    // Градиентный фон
                    CosmicGradients.mysticCard
                    
                    // Стеклянный эффект
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .fill(.ultraThinMaterial)
                        .overlay(
                            RoundedRectangle(cornerRadius: cornerRadius)
                                .stroke(
                                    LinearGradient(
                                        colors: [
                                            glowColor.opacity(0.6),
                                            glowColor.opacity(0.2),
                                            .clear
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 1
                                )
                        )
                }
            )
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            .shadow(color: glowColor.opacity(0.3), radius: 20, x: 0, y: 10)
    }
}

// MARK: - Neon Glow
struct NeonGlow: ViewModifier {
    var color: Color = .neonPurple
    var intensity: Double = 1.0
    
    func body(content: Content) -> some View {
        ZStack {
            content
                .shadow(color: color.opacity(0.8 * intensity), radius: 4)
                .shadow(color: color.opacity(0.6 * intensity), radius: 8)
                .shadow(color: color.opacity(0.4 * intensity), radius: 12)
                .shadow(color: color.opacity(0.2 * intensity), radius: 20)
        }
    }
}

// MARK: - Cosmic Button Style
struct CosmicButtonStyle: ButtonStyle {
    var primaryColor: Color = .cosmicViolet
    var isProminent: Bool = true
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 17, weight: .semibold, design: .rounded))
            .foregroundColor(isProminent ? .white : primaryColor)
            .padding(.horizontal, 24)
            .padding(.vertical, 14)
            .background(
                Group {
                    if isProminent {
                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        primaryColor,
                                        primaryColor.opacity(0.8)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    } else {
                        Capsule()
                            .stroke(primaryColor, lineWidth: 2)
                    }
                }
            )
            .modifier(NeonGlow(color: primaryColor, intensity: configuration.isPressed ? 0.5 : 1.0))
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.spring(response: 0.3), value: configuration.isPressed)
    }
}

// MARK: - Floating Animation
struct FloatingAnimation: ViewModifier {
    @State private var offset: CGFloat = 0
    var amplitude: CGFloat = 10
    var duration: Double = 3
    
    func body(content: Content) -> some View {
        content
            .offset(y: offset)
            .onAppear {
                withAnimation(
                    .easeInOut(duration: duration)
                    .repeatForever(autoreverses: true)
                ) {
                    offset = amplitude
                }
            }
    }
}

// MARK: - Shimmer Effect
struct ShimmerEffect: ViewModifier {
    @State private var phase: CGFloat = 0
    
    func body(content: Content) -> some View {
        content
            .overlay(
                LinearGradient(
                    gradient: Gradient(colors: [
                        .clear,
                        .white.opacity(0.3),
                        .clear
                    ]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .rotationEffect(.degrees(30))
                .offset(x: phase)
                .mask(content)
            )
            .onAppear {
                withAnimation(.linear(duration: 2).repeatForever(autoreverses: false)) {
                    phase = 400
                }
            }
    }
}

// MARK: - Convenience Extensions
extension View {
    func glassmorphicCard(cornerRadius: CGFloat = 20, glowColor: Color = .neonPurple) -> some View {
        modifier(GlassmorphicCard(cornerRadius: cornerRadius, glowColor: glowColor))
    }
    
    func neonGlow(color: Color = .neonPurple, intensity: Double = 1.0) -> some View {
        modifier(NeonGlow(color: color, intensity: intensity))
    }
    
    func floatingAnimation(amplitude: CGFloat = 10, duration: Double = 3) -> some View {
        modifier(FloatingAnimation(amplitude: amplitude, duration: duration))
    }
    
    func shimmer() -> some View {
        modifier(ShimmerEffect())
    }
}
