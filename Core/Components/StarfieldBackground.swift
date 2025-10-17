//
//  StarfieldBackground.swift
//  Astrolog
//
//  Created by Sergey on 22.09.2025.
//
// Core/Components/StarfieldBackground.swift
import SwiftUI

// MARK: - Animated Starfield Background
struct StarfieldBackground: View {
    @State private var animationPhase: CGFloat = 0
    @StateObject private var performanceManager = CosmicPerformanceManager.shared

    var starCount: Int {
        performanceManager.starFieldDensity.starCount
    }
    
    var body: some View {
        ZStack {
            // Основной градиент фона
            CosmicGradients.galaxy
                .ignoresSafeArea()
            
            // Слой туманности
            Canvas { context, size in
                for _ in 0..<3 {
                    let center = CGPoint(
                        x: CGFloat.random(in: 0...size.width),
                        y: CGFloat.random(in: 0...size.height)
                    )
                    
                    context.drawLayer { ctx in
                        ctx.addFilter(.blur(radius: 40))
                        ctx.fill(
                            Circle().path(in: CGRect(
                                x: center.x - 100,
                                y: center.y - 100,
                                width: 200,
                                height: 200
                            )),
                            with: .color(.cosmicPink.opacity(0.2))
                        )
                    }
                }
            }
            .ignoresSafeArea()
            
            // Звезды
            GeometryReader { geometry in
                ForEach(0..<starCount, id: \.self) { index in
                    Star(index: index, size: geometry.size, phase: animationPhase)
                }
            }
            .ignoresSafeArea()
            
            // Мерцающие частицы
            ParticleEmitterView()
                .ignoresSafeArea()
        }
        .onAppear {
            withAnimation(.linear(duration: 100).repeatForever(autoreverses: false)) {
                animationPhase = 1
            }
        }
    }
}

// MARK: - Individual Star
struct Star: View {
    let index: Int
    let size: CGSize
    let phase: CGFloat
    
    @State private var opacity: Double = Double.random(in: 0.3...1.0)
    @State private var scale: CGFloat = CGFloat.random(in: 0.5...1.5)
    
    private var position: CGPoint {
        let seed = Double(index)
        return CGPoint(
            x: (sin(seed) + 1) / 2 * size.width,
            y: (cos(seed * 1.5) + 1) / 2 * size.height
        )
    }
    
    var body: some View {
        Image(systemName: "sparkle")
            .font(.system(size: CGFloat.random(in: 2...8)))
            .foregroundColor(.starWhite)
            .opacity(opacity)
            .scaleEffect(scale)
            .position(position)
            .onAppear {
                withAnimation(
                    .easeInOut(duration: Double.random(in: 2...5))
                    .repeatForever(autoreverses: true)
                ) {
                    opacity = Double.random(in: 0.1...1.0)
                    scale = CGFloat.random(in: 0.3...1.8)
                }
            }
    }
}

// MARK: - Particle Emitter
struct ParticleEmitterView: UIViewRepresentable {
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        view.backgroundColor = .clear
        
        let emitterLayer = CAEmitterLayer()
        emitterLayer.emitterPosition = CGPoint(x: UIScreen.main.bounds.width / 2, y: -10)
        emitterLayer.emitterShape = .line
        emitterLayer.emitterSize = CGSize(width: UIScreen.main.bounds.width, height: 1)
        
        let cell = CAEmitterCell()
        cell.birthRate = 2
        cell.lifetime = 20
        cell.velocity = 50
        cell.velocityRange = 20
        cell.emissionLongitude = .pi
        cell.emissionRange = .pi / 4
        cell.scale = 0.003
        cell.scaleRange = 0.002
        cell.contents = createParticleImage().cgImage
        
        emitterLayer.emitterCells = [cell]
        view.layer.addSublayer(emitterLayer)
        
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {}
    
    private func createParticleImage() -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 20, height: 20))
        return renderer.image { context in
            context.cgContext.setFillColor(UIColor.white.cgColor)
            context.cgContext.fillEllipse(in: CGRect(x: 0, y: 0, width: 20, height: 20))
        }
    }
}
