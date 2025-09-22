//
//  User.swift
//  Astrolog
//
//  Created by Sergey on 19.09.2025.
//
import Foundation

struct User: Codable, Identifiable {
    let id = UUID().uuidString
    var name: String
    var email: String?
    var birthData: BirthData?
    var subscriptionStatus: SubscriptionStatus = .free
    let createdAt = Date()
    
    enum SubscriptionStatus: String, Codable, CaseIterable {
        case free = "free"
        case pro = "pro"
        case guru = "guru"
        
        var displayName: String {
            switch self {
            case .free: return "Базовый"
            case .pro: return "Pro"
            case .guru: return "Guru"
            }
        }
    }
}

struct BirthData: Codable {
    let date: Date
    let timeZone: TimeZone
    let latitude: Double
    let longitude: Double
    let cityName: String
    let countryName: String
    let isTimeExact: Bool
    
    // Вспомогательные свойства
    var birthDateComponents: DateComponents {
        Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: date)
    }
}

