//
//  CosmicMainTabView.swift
//  Astrolog
//
//  Created by Sergey on 22.09.2025.
//
// Features/Main/CosmicMainTabView.swift
import SwiftUI

struct CosmicMainTabView: View {
    @State private var selectedTab = 0
    @State private var tabBarOffset: CGFloat = 0
    
    init() {
        // Настройка прозрачного TabBar
        UITabBar.appearance().backgroundColor = UIColor.clear
        UITabBar.appearance().backgroundImage = UIImage()
        UITabBar.appearance().shadowImage = UIImage()
    }
    
    var body: some View {
        ZStack {
            // Фоновый слой
            StarfieldBackground()
                .ignoresSafeArea()
            
            // Основной контент
            TabView(selection: $selectedTab) {
                TodayView() // Временно используем существующий
                    .tag(0)
                
                ChartView()
                    .tag(1)
                
                SocialView()
                    .tag(2)
                
                MindfulnessView()
                    .tag(3)
                
                ProfileView()
                    .tag(4)
            }
            .overlay(alignment: .bottom) {
                // Кастомный TabBar
                CosmicTabBar(selectedTab: $selectedTab)
                    .offset(y: tabBarOffset)
            }
        }
    }
}

// MARK: - Custom Cosmic TabBar
struct CosmicTabBar: View {
    @Binding var selectedTab: Int
    @Namespace private var animation
    
    let tabs: [(icon: String, title: String, color: Color)] = [
        ("house.fill", "Сегодня", .cosmicViolet),
        ("star.circle.fill", "Карта", .cosmicPink),
        ("person.2.fill", "Друзья", .cosmicCyan),
        ("sparkles", "Практики", .neonPurple),
        ("person.circle.fill", "Профиль", .cosmicTeal)
    ]
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(0..<tabs.count, id: \.self) { index in
                CosmicTabButton(
                    icon: tabs[index].icon,
                    title: tabs[index].title,
                    color: tabs[index].color,
                    isSelected: selectedTab == index,
                    namespace: animation
                ) {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        selectedTab = index
                    }
                }
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 25)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 25)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color.neonPurple.opacity(0.3),
                                    Color.cosmicCyan.opacity(0.3)
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            ),
                            lineWidth: 1
                        )
                )
                .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
        )
        .padding(.horizontal)
        .padding(.bottom, 20)
    }
}

// MARK: - Cosmic Tab Button
struct CosmicTabButton: View {
    let icon: String
    let title: String
    let color: Color
    let isSelected: Bool
    let namespace: Namespace.ID
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                ZStack {
                    if isSelected {
                        Circle()
                            .fill(color.opacity(0.2))
                            .frame(width: 45, height: 45)
                            .matchedGeometryEffect(id: "tab_background", in: namespace)
                            .modifier(NeonGlow(color: color, intensity: 0.8))
                    }
                    
                    Image(systemName: icon)
                        .font(.system(size: isSelected ? 24 : 20))
                        .foregroundStyle(
                            isSelected ?
                            LinearGradient(
                                colors: [color, color.opacity(0.8)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ) :
                            LinearGradient(
                                colors: [Color.starWhite.opacity(0.6)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .scaleEffect(isSelected ? 1.2 : 1.0)
                        .animation(.spring(), value: isSelected)
                }
                .frame(width: 45, height: 45)
                
                if isSelected {
                    Text(title)
                        .font(.caption2)
                        .fontWeight(.medium)
                        .foregroundColor(color)
                        .transition(.asymmetric(
                            insertion: .scale.combined(with: .opacity),
                            removal: .scale.combined(with: .opacity)
                        ))
                }
            }
            .frame(maxWidth: .infinity)
        }
    }
}
