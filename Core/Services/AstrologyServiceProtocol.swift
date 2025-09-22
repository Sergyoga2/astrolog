//
//  AstrologyServiceProtocol.swift
//  Astrolog
//
//  Created by Sergey on 19.09.2025.
//
// Core/Services/AstrologyServiceProtocol.swift
import Foundation

protocol AstrologyServiceProtocol {
    func calculateBirthChart(from birthData: BirthData) async throws -> BirthChart
    func generateDailyHoroscope(for sunSign: ZodiacSign, date: Date) async throws -> DailyHoroscope
    func calculateCompatibility(chart1: BirthChart, chart2: BirthChart) async throws -> CompatibilityResult
    func getCurrentTransits() async throws -> [Transit]
}

// Новые модели для гороскопов
struct DailyHoroscope: Codable, Identifiable {
    let id = UUID().uuidString
    let date: Date
    let sunSign: ZodiacSign
    let generalForecast: String
    let loveAndRelationships: String
    let careerAndFinances: String
    let healthAndEnergy: String
    let luckyNumbers: [Int]
    let luckyColors: [String]
    let advice: String
}

struct CompatibilityResult: Codable, Identifiable {
    let id = UUID().uuidString
    let chart1UserId: String
    let chart2UserId: String
    let overallScore: Double // 0-100
    let categories: CompatibilityCategories
    let strengths: [String]
    let challenges: [String]
    let advice: String
}

struct CompatibilityCategories: Codable {
    let communication: Double
    let emotional: Double
    let intellectual: Double
    let physical: Double
    let spiritual: Double
}

struct Transit: Codable, Identifiable {
    let id = UUID().uuidString
    let planet: PlanetType
    let aspectType: AspectType
    let natalPlanet: PlanetType
    let startDate: Date
    let endDate: Date
    let description: String
    let influence: String
}
