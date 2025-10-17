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
        } catch {
            self.isLoadingTransits = false
        }
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
