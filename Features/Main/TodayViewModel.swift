//
//  TodayViewModel.swift
//  Astrolog
//
//  Created by Sergey on 19.09.2025.
//
// Features/Main/TodayViewModel.swift
import Foundation
import Combine

class TodayViewModel: ObservableObject {
    @Published var dailyHoroscope: DailyHoroscope?
    @Published var transits: [Transit] = []
    @Published var isLoadingHoroscope = false
    @Published var isLoadingTransits = false
    @Published var errorMessage: String?
    
    private let astrologyService: AstrologyServiceProtocol
    
    init(astrologyService: AstrologyServiceProtocol = EnhancedMockAstrologyService()) {
        self.astrologyService = astrologyService
    }
    
    func loadTodayData() async {
        await loadDailyHoroscope()
        await loadCurrentTransits()
    }

    func loadTodayContent() {
        loadDailyHoroscopeSync()
        loadCurrentTransitsSync()
    }
    
    private func loadDailyHoroscope() async {
        isLoadingHoroscope = true
        errorMessage = nil

        do {
            let sunSign = ZodiacSign.leo
            let horoscope = try await astrologyService.generateDailyHoroscope(for: sunSign, date: Date())

            self.dailyHoroscope = horoscope
            self.isLoadingHoroscope = false
        } catch {
            self.errorMessage = "Не удалось загрузить гороскоп: \(error.localizedDescription)"
            self.isLoadingHoroscope = false
        }
    }

    private func loadCurrentTransits() async {
        isLoadingTransits = true

        do {
            let dailyTransits = try await astrologyService.getCurrentTransits()
            // Конвертируем DailyTransit в Transit
            self.transits = convertDailyTransitsToTransits(dailyTransits)
            self.isLoadingTransits = false

            // Для отладки - выводим количество транзитов
            print("✅ Loaded \(self.transits.count) transits")

        } catch {
            self.errorMessage = "Не удалось загрузить транзиты: \(error.localizedDescription)"
            self.isLoadingTransits = false

            // Создаем fallback транзиты при ошибке
            self.transits = createFallbackTransits()
            print("❌ Transit loading failed, using fallback: \(error)")
        }
    }

    private func convertDailyTransitsToTransits(_ dailyTransits: [DailyTransit]) -> [Transit] {
        return dailyTransits.compactMap { dailyTransit in
            guard let natalPlanet = dailyTransit.natalPlanet,
                  let aspectType = dailyTransit.aspectType else {
                return nil
            }

            return Transit(
                transitingPlanet: dailyTransit.planet,
                natalPlanet: natalPlanet,
                aspectType: aspectType,
                orb: 2.0, // Стандартный орб
                influence: .harmonious, // Упрощенная логика
                duration: DateInterval(start: dailyTransit.startDate, end: dailyTransit.endDate),
                peak: Date(),
                interpretation: dailyTransit.description,
                humanDescription: dailyTransit.influence,
                emoji: "✨"
            )
        }
    }

    private func createFallbackTransits() -> [Transit] {
        let endDate1 = Calendar.current.date(byAdding: .day, value: 10, to: Date()) ?? Date()
        let endDate2 = Calendar.current.date(byAdding: .day, value: 5, to: Date()) ?? Date()
        let endDate3 = Calendar.current.date(byAdding: .day, value: 20, to: Date()) ?? Date()

        return [
            Transit(
                transitingPlanet: .venus,
                natalPlanet: .sun,
                aspectType: .trine,
                orb: 2.0,
                influence: .harmonious,
                duration: DateInterval(start: Date(), end: endDate1),
                peak: Date(),
                interpretation: "Венера в Тельце образует благоприятный аспект",
                humanDescription: "Гармония в отношениях и финансах",
                emoji: "♀️✨"
            ),
            Transit(
                transitingPlanet: .mars,
                natalPlanet: .mercury,
                aspectType: .square,
                orb: 3.0,
                influence: .challenging,
                duration: DateInterval(start: Date(), end: endDate2),
                peak: Date(),
                interpretation: "Марс в Овне создает напряжение с Меркурием",
                humanDescription: "Будьте осторожны с импульсивными решениями",
                emoji: "♂️⚡️"
            ),
            Transit(
                transitingPlanet: .jupiter,
                natalPlanet: .venus,
                aspectType: .sextile,
                orb: 1.5,
                influence: .harmonious,
                duration: DateInterval(start: Date(), end: endDate3),
                peak: Date(),
                interpretation: "Юпитер в Стрельце поддерживает Венеру",
                humanDescription: "Расширение возможностей в любви и творчестве",
                emoji: "♃✨"
            )
        ]
    }

    // Синхронные версии для обратной совместимости
    private func loadDailyHoroscopeSync() {
        Task { await loadDailyHoroscope() }
    }

    private func loadCurrentTransitsSync() {
        Task { await loadCurrentTransits() }
    }
    
    func refreshContent() {
        loadTodayContent()
    }
}
