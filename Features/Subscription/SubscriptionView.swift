//
//  SubscriptionView.swift
//  Astrolog
//
//  Created by Sergey on 19.09.2025.
// Features/Subscription/SubscriptionView.swift
import SwiftUI
import StoreKit
import Combine

struct SubscriptionView: View {
    @EnvironmentObject var appCoordinator: AppCoordinator
    @StateObject private var subscriptionManager = SubscriptionManager()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    HeaderSection()
                    
                    if subscriptionManager.isLoading {
                        LoadingSection()
                    } else {
                        BenefitsSection()
                        PlansSection(subscriptionManager: subscriptionManager)
                        TestimonialsSection()
                        FAQSection()
                    }
                    
                    if let errorMessage = subscriptionManager.errorMessage {
                        ErrorSection(message: errorMessage)
                    }
                }
                .padding()
            }
            .navigationTitle("Astrolog Premium")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Закрыть") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Восстановить") {
                        Task {
                            await subscriptionManager.restorePurchases()
                        }
                    }
                    .font(.caption)
                }
            }
        }
        .task {
            await subscriptionManager.loadProducts()
        }
    }
}

struct HeaderSection: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "star.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(.purple)
            
            Text("Откройте полный потенциал звезд")
                .font(.title2)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
            
            Text("Получите доступ ко всем функциям персонального астрологического анализа")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
    }
}

struct LoadingSection: View {
    var body: some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(1.5)
            Text("Загружаем планы подписки...")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(height: 200)
    }
}

struct BenefitsSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Что вы получите:")
                .font(.headline)
            
            VStack(spacing: 12) {
                BenefitRow(icon: "star.fill", title: "Детальные ежедневные прогнозы", description: "Углубленный анализ для всех сфер жизни")
                BenefitRow(icon: "heart.fill", title: "Безлимитная совместимость", description: "Анализ отношений с друзьями и партнерами")
                BenefitRow(icon: "chart.line.uptrend.xyaxis", title: "Персональные транзиты", description: "Предсказания важных жизненных периодов")
                BenefitRow(icon: "leaf.fill", title: "Премиум медитации", description: "Эксклюзивные практики и ритуалы")
                BenefitRow(icon: "person.fill.checkmark", title: "Консультации астролога", description: "Личные сессии с сертифицированными экспертами")
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct BenefitRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.purple)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
    }
}

struct PlansSection: View {
    @ObservedObject var subscriptionManager: SubscriptionManager
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Выберите ваш план")
                .font(.headline)
            
            if subscriptionManager.products.isEmpty {
                // Mock plans если продукты не загрузились
                MockPlanCard(title: "Pro Plan", price: "₽299", features: [
                    "Детальные прогнозы",
                    "Безлимитная совместимость",
                    "Премиум медитации"
                ], isPopular: true)
                
                MockPlanCard(title: "Guru Plan", price: "₽649", features: [
                    "Все функции Pro",
                    "2 консультации астролога",
                    "Персональные ритуалы"
                ], isPopular: false)
            } else {
                ForEach(subscriptionManager.products, id: \.id) { product in
                    PlanCard(product: product, subscriptionManager: subscriptionManager)
                }
            }
        }
    }
}

struct MockPlanCard: View {
    let title: String
    let price: String
    let features: [String]
    let isPopular: Bool
    @State private var showAlert = false
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading) {
                    HStack {
                        Text(title)
                            .font(.title3)
                            .fontWeight(.bold)
                        
                        if isPopular {
                            Text("ПОПУЛЯРНЫЙ")
                                .font(.caption2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.orange)
                                .cornerRadius(4)
                        }
                    }
                    
                    Text("\(price)/месяц")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.purple)
                }
                
                Spacer()
                
                Button(action: {
                    showAlert = true
                }) {
                    Text("Выбрать")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(width: 100, height: 44)
                        .background(Color.purple)
                        .cornerRadius(8)
                }
            }
            
            VStack(alignment: .leading, spacing: 8) {
                ForEach(features, id: \.self) { feature in
                    HStack {
                        Image(systemName: "checkmark")
                            .foregroundColor(.green)
                            .font(.caption)
                        Text(feature)
                            .font(.caption)
                        Spacer()
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isPopular ? Color.orange : Color(.systemGray4), lineWidth: isPopular ? 2 : 1)
        )
        .cornerRadius(12)
        .alert("Демо версия", isPresented: $showAlert) {
            Button("OK") { }
        } message: {
            Text("В демо версии покупки недоступны. Продолжайте пользоваться бесплатными функциями!")
        }
    }
}

struct PlanCard: View {
    let product: Product
    @ObservedObject var subscriptionManager: SubscriptionManager
    
    private var isPopular: Bool {
        product.id.contains("pro")
    }
    
    private var planTitle: String {
        if product.id.contains("pro") {
            return "Pro Plan"
        } else if product.id.contains("guru") {
            return "Guru Plan"
        }
        return "Plan"
    }
    
    private var planFeatures: [String] {
        if product.id.contains("guru") {
            return [
                "Все функции Pro",
                "2 консультации астролога в месяц",
                "Персональные ритуалы",
                "Приоритетная поддержка"
            ]
        } else {
            return [
                "Детальные прогнозы",
                "Безлимитная совместимость",
                "Премиум медитации",
                "Персональные транзиты"
            ]
        }
    }
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading) {
                    HStack {
                        Text(planTitle)
                            .font(.title3)
                            .fontWeight(.bold)
                        
                        if isPopular {
                            Text("ПОПУЛЯРНЫЙ")
                                .font(.caption2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.orange)
                                .cornerRadius(4)
                        }
                    }
                    
                    Text("\(product.displayPrice)/месяц")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.purple)
                }
                
                Spacer()
                
                Button(action: {
                    Task {
                        await subscriptionManager.purchase(product)
                    }
                }) {
                    Text("Выбрать")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(width: 100, height: 44)
                        .background(Color.purple)
                        .cornerRadius(8)
                }
                .disabled(subscriptionManager.isLoading)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                ForEach(planFeatures, id: \.self) { feature in
                    HStack {
                        Image(systemName: "checkmark")
                            .foregroundColor(.green)
                            .font(.caption)
                        Text(feature)
                            .font(.caption)
                        Spacer()
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isPopular ? Color.orange : Color(.systemGray4), lineWidth: isPopular ? 2 : 1)
        )
        .cornerRadius(12)
    }
}

// Остальные компоненты остаются теми же...
struct TestimonialsSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Отзывы пользователей")
                .font(.headline)
            
            VStack(spacing: 12) {
                TestimonialCard(
                    name: "Анна М.",
                    rating: 5,
                    text: "Невероятно точные прогнозы! Помогли принять важное решение в карьере."
                )
                
                TestimonialCard(
                    name: "Максим К.",
                    rating: 5,
                    text: "Анализ совместимости просто поразил. Теперь лучше понимаю отношения."
                )
            }
        }
    }
}

struct TestimonialCard: View {
    let name: String
    let rating: Int
    let text: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(name)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Spacer()
                
                HStack(spacing: 2) {
                    ForEach(0..<rating, id: \.self) { _ in
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                            .font(.caption)
                    }
                }
            }
            
            Text(text)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
}

struct FAQSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Часто задаваемые вопросы")
                .font(.headline)
            
            VStack(spacing: 12) {
                FAQItem(
                    question: "Можно ли отменить подписку?",
                    answer: "Да, вы можете отменить подписку в любое время в настройках App Store."
                )
                
                FAQItem(
                    question: "Что произойдет с моими данными?",
                    answer: "Все ваши данные останутся сохранными. При возобновлении подписки доступ восстановится."
                )
                
                FAQItem(
                    question: "Есть ли семейный доступ?",
                    answer: "Да, подписка поддерживает семейный доступ до 6 человек через App Store."
                )
            }
        }
    }
}

struct FAQItem: View {
    let question: String
    let answer: String
    @State private var isExpanded = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Button(action: {
                withAnimation {
                    isExpanded.toggle()
                }
            }) {
                HStack {
                    Text(question)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .multilineTextAlignment(.leading)
                    
                    Spacer()
                    
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .buttonStyle(.plain)
            
            if isExpanded {
                Text(answer)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
}

struct ErrorSection: View {
    let message: String
    
    var body: some View {
        Text(message)
            .font(.subheadline)
            .foregroundColor(.red)
            .padding()
            .background(Color.red.opacity(0.1))
            .cornerRadius(8)
    }
}

#Preview {
    SubscriptionView()
        .environmentObject(AppCoordinator())
}
