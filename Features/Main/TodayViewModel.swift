//
//  TodayViewModel.swift
//  Astrolog
//
//  Created by Sergey on 19.09.2025.
//
// Features/Main/TodayViewModel.swift
import Foundation
import Combine

@MainActor
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
            let transits = try await astrologyService.getCurrentTransits()
            self.transits = transits
            self.isLoadingTransits = false

            // Для отладки - выводим количество транзитов
            print("✅ Loaded \(transits.count) transits")

        } catch {
            self.errorMessage = "Не удалось загрузить транзиты: \(error.localizedDescription)"
            self.isLoadingTransits = false

            // Создаем fallback транзиты при ошибке
            self.transits = createFallbackTransits()
            print("❌ Transit loading failed, using fallback: \(error)")
        }
    }

    private func createFallbackTransits() -> [Transit] {
        return [
            Transit(
                planet: .venus,
                sign: .taurus,
                aspectType: .trine,
                natalPlanet: .sun,
                startDate: Date(),
                endDate: Calendar.current.date(byAdding: .day, value: 10, to: Date()) ?? Date(),
                description: "Венера в Тельце образует благоприятный аспект",
                influence: "Гармония в отношениях и финансах",
                influenceLevel: 4
            ),
            Transit(
                planet: .mars,
                sign: .aries,
                aspectType: .square,
                natalPlanet: .mercury,
                startDate: Date(),
                endDate: Calendar.current.date(byAdding: .day, value: 5, to: Date()) ?? Date(),
                description: "Марс в Овне создает напряжение с Меркурием",
                influence: "Будьте осторожны с импульсивными решениями",
                influenceLevel: 3
            ),
            Transit(
                planet: .jupiter,
                sign: .sagittarius,
                aspectType: .sextile,
                natalPlanet: .venus,
                startDate: Date(),
                endDate: Calendar.current.date(byAdding: .day, value: 20, to: Date()) ?? Date(),
                description: "Юпитер в Стрельце поддерживает Венеру",
                influence: "Расширение возможностей в любви и творчестве",
                influenceLevel: 5
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
