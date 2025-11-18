//
//  ChartViewModel.swift
//  Astrolog
//
//  Created by Sergey on 20.09.2025.
//
// Features/Chart/ChartViewModel.swift
import Foundation
import Combine

class ChartViewModel: ObservableObject {
    @Published var birthChart: BirthChart?
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var hasBirthData = false
    
    private let astrologyService: AstrologyServiceProtocol
    
    init(astrologyService: AstrologyServiceProtocol = SwissEphemerisService()) {
        self.astrologyService = astrologyService
        loadBirthData()
    }
    
    func loadBirthData() {
        if let data = UserDefaults.standard.data(forKey: "user_birth_data"),
           let birthData = try? JSONDecoder().decode(BirthData.self, from: data) {
            hasBirthData = true
            calculateChart(from: birthData)
        } else {
            hasBirthData = false
        }
    }
    
    func calculateChart(from birthData: BirthData) {
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                let chart = try await astrologyService.calculateBirthChart(from: birthData)
                
                await MainActor.run {
                    self.birthChart = chart
                    self.isLoading = false
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = error.localizedDescription
                    self.isLoading = false
                }
            }
        }
    }
    
    func refreshChart() {
        loadBirthData()
    }
}
