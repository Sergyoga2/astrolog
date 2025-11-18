//
//  MockAstrologyService.swift
//  Astrolog
//
//  Created by Sergey on 19.09.2025.
//
import Foundation
import Combine

class MockAstrologyService: ObservableObject {
    
    func calculateBirthChart(from birthData: BirthData) async -> BirthChart {
        // Имитируем задержку расчета
        try? await Task.sleep(nanoseconds: 2_000_000_000)
        
        return BirthChart(
            id: UUID().uuidString,
            userId: "mock_user",
            name: "Mock Birth Chart",
            birthDate: birthData.date,
            birthTime: DateFormatter.localizedString(from: birthData.date, dateStyle: .none, timeStyle: .short),
            location: "\(birthData.cityName), \(birthData.countryName)",
            latitude: birthData.latitude,
            longitude: birthData.longitude,
            planets: createMockPlanets(),
            houses: createMockHouses(),
            aspects: createMockAspects(),
            calculatedAt: Date()
        )
    }
    
    func generateDailyHoroscope(for sunSign: ZodiacSign) async -> String {
        let horoscopes = [
            "Сегодня звезды благоволят новым начинаниям. Отличный день для проявления инициативы.",
            "Луна в вашем знаке усиливает интуицию. Доверяйтесь внутреннему голосу.",
            "Венера дарит гармонию в отношениях. Время для важных разговоров.",
            "Меркурий активизирует умственную деятельность. Удачный период для обучения."
        ]
        
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        return horoscopes.randomElement() ?? horoscopes[0]
    }
    
    private func createMockPlanets() -> [Planet] {
        var planets: [Planet] = []
        
        for planetType in PlanetType.allCases {
            let randomSign = ZodiacSign.allCases.randomElement() ?? .aries
            let randomHouse = Int.random(in: 1...12)
            let randomLongitude = Double.random(in: 0...360)
            
            let planet = Planet(
                id: UUID().uuidString,
                type: planetType,
                longitude: randomLongitude,
                zodiacSign: randomSign,
                house: randomHouse,
                isRetrograde: Bool.random()
            )
            planets.append(planet)
        }
        
        return planets
    }
    
    private func createMockHouses() -> [House] {
        var houses: [House] = []
        
        for houseNumber in 1...12 {
            let randomSign = ZodiacSign.allCases.randomElement() ?? .aries
            let cuspLongitude = Double(houseNumber - 1) * 30 + Double.random(in: 0...30)
            
            let house = House(
                id: UUID().uuidString,
                number: houseNumber,
                cuspLongitude: cuspLongitude,
                zodiacSign: randomSign,
                planetsInHouse: []
            )
            houses.append(house)
        }
        
        return houses
    }
    
    private func createMockAspects() -> [Aspect] {
        var aspects: [Aspect] = []
        
        let majorPlanets: [PlanetType] = [.sun, .moon, .mercury, .venus, .mars, .jupiter]
        
        for i in 0..<majorPlanets.count {
            for j in (i+1)..<majorPlanets.count {
                if Bool.random() {
                    let aspectType = AspectType.allCases.randomElement() ?? .conjunction
                    let aspect = Aspect(
                        id: UUID().uuidString,
                        planet1Type: majorPlanets[i],
                        planet2Type: majorPlanets[j],
                        type: aspectType,
                        orb: Double.random(in: 0...8),
                        isApplying: Bool.random()
                    )
                    aspects.append(aspect)
                }
            }
        }
        
        return aspects
    }
}
