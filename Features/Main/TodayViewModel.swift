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
    @Published var currentTransits: [Transit] = []
    @Published var isLoadingHoroscope = false
    @Published var isLoadingTransits = false
    @Published var errorMessage: String?
    
    private let astrologyService: AstrologyServiceProtocol
    
    init(astrologyService: AstrologyServiceProtocol = EnhancedMockAstrologyService()) {
        self.astrologyService = astrologyService
    }
    
    func loadTodayContent() {
        loadDailyHoroscope()
        loadCurrentTransits()
    }
    
    private func loadDailyHoroscope() {
        isLoadingHoroscope = true
        errorMessage = nil
        
        Task {
            do {
                let sunSign = ZodiacSign.leo
                // ИСПРАВЛЕНО: добавляем параметр date
                let horoscope = try await astrologyService.generateDailyHoroscope(for: sunSign, date: Date())
                
                await MainActor.run {
                    self.dailyHoroscope = horoscope
                    self.isLoadingHoroscope = false
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = "Не удалось загрузить гороскоп: \(error.localizedDescription)"
                    self.isLoadingHoroscope = false
                }
            }
        }
    }
    
    private func loadCurrentTransits() {
        isLoadingTransits = true
        
        Task {
            do {
                let transits = try await astrologyService.getCurrentTransits()
                
                await MainActor.run {
                    self.currentTransits = transits
                    self.isLoadingTransits = false
                }
            } catch {
                await MainActor.run {
                    self.isLoadingTransits = false
                }
            }
        }
    }
    
    func refreshContent() {
        loadTodayContent()
    }
}
