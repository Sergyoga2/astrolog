//
//  SubscriptionManager.swift
//  Astrolog
//
//  Created by Sergey on 22.09.2025.
//
// Core/Services/SubscriptionManager.swift
import Foundation
import StoreKit
import Combine

@MainActor
class SubscriptionManager: ObservableObject {
    @Published var subscriptionStatus: SubscriptionStatus = .free
    @Published var products: [Product] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let productIdentifiers = [
        "astrolog_pro_monthly",
        "astrolog_guru_monthly"
    ]
    
    enum SubscriptionStatus: String, CaseIterable {
        case free, pro, guru
        
        var displayName: String {
            switch self {
            case .free: return "Базовый"
            case .pro: return "Pro"
            case .guru: return "Guru"
            }
        }
    }
    
    init() {
        loadStoredSubscriptionStatus()
    }
    
    func loadProducts() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let storeProducts = try await Product.products(for: productIdentifiers)
            self.products = storeProducts
            self.isLoading = false
        } catch {
            self.errorMessage = "Не удалось загрузить продукты: \(error.localizedDescription)"
            self.isLoading = false
        }
    }
    
    func purchase(_ product: Product) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let result = try await product.purchase()
            
            switch result {
            case .success(let verification):
                switch verification {
                case .verified(let transaction):
                    await updateSubscriptionStatus(for: product.id)
                    await transaction.finish()
                case .unverified:
                    errorMessage = "Не удалось верифицировать покупку"
                }
            case .pending:
                errorMessage = "Покупка ожидает подтверждения"
            case .userCancelled:
                break
            @unknown default:
                errorMessage = "Неизвестная ошибка покупки"
            }
        } catch {
            errorMessage = "Ошибка покупки: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    func restorePurchases() async {
        isLoading = true
        errorMessage = nil
        
        do {
            try await AppStore.sync()
            await checkCurrentSubscriptions()
        } catch {
            errorMessage = "Ошибка восстановления: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    private func updateSubscriptionStatus(for productId: String) async {
        switch productId {
        case "astrolog_pro_monthly":
            subscriptionStatus = .pro
        case "astrolog_guru_monthly":
            subscriptionStatus = .guru
        default:
            subscriptionStatus = .free
        }
        
        UserDefaults.standard.set(subscriptionStatus.rawValue, forKey: "subscription_status")
    }
    
    private func checkCurrentSubscriptions() async {
        for await result in Transaction.currentEntitlements {
            switch result {
            case .verified(let transaction):
                await updateSubscriptionStatus(for: transaction.productID)
            case .unverified:
                continue
            }
        }
    }
    
    private func loadStoredSubscriptionStatus() {
        let stored = UserDefaults.standard.string(forKey: "subscription_status") ?? "free"
        subscriptionStatus = SubscriptionStatus(rawValue: stored) ?? .free
    }
    
    func hasAccess(to feature: PremiumFeature) -> Bool {
        switch feature {
        case .detailedHoroscope, .basicCompatibility:
            return subscriptionStatus != .free
        case .advancedCompatibility, .personalConsultations, .extendedMeditations:
            return subscriptionStatus == .guru
        }
    }
}

enum PremiumFeature {
    case detailedHoroscope
    case basicCompatibility
    case advancedCompatibility
    case personalConsultations
    case extendedMeditations
}
