//
//  TodayViewModel.swift
//  Astrolog
//
//  Created by Sergey on 19.09.2025.
//  Updated by Claude on 18.11.2025.
//
// Features/Main/TodayViewModel.swift
import Foundation
import Combine

@MainActor
class TodayViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var detailedHoroscope: DetailedHoroscope?
    @Published var keyEnergies: [KeyEnergy] = []
    @Published var moonData: MoonData?
    @Published var personalTransits: [Transit] = []
    @Published var dailyAdvice: DailyAdvice?

    @Published var isLoading = false
    @Published var isRefreshing = false
    @Published var errorMessage: String?

    // Legacy properties for compatibility
    @Published var dailyHoroscope: DailyHoroscope?
    @Published var transits: [Transit] = []
    @Published var isLoadingHoroscope = false
    @Published var isLoadingTransits = false

    // MARK: - Private Properties
    private let astrologyService: AstrologyServiceProtocol
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Initialization
    init(astrologyService: AstrologyServiceProtocol = EnhancedMockAstrologyService()) {
        self.astrologyService = astrologyService
    }

    // MARK: - Public Methods
    func loadTodayContent() async {
        guard !isLoading else { return }

        isLoading = true
        errorMessage = nil

        do {
            // Create mock birth data for testing
            let mockBirthData = BirthData(
                date: Date(timeIntervalSince1970: 631152000), // 1990-01-01
                latitude: 55.7558,
                longitude: 37.6173,
                cityName: "Moscow",
                countryName: "Russia",
                timeZone: TimeZone.current
            )

            let chart = try await astrologyService.calculateBirthChart(from: mockBirthData)

            // Параллельная загрузка всех блоков
            async let horoscope = astrologyService.generateDetailedHoroscope(for: chart, date: Date())
            async let energies = astrologyService.getKeyEnergies(for: Date())
            async let moon = astrologyService.getMoonData(for: Date())
            async let transits = astrologyService.calculatePersonalTransits(for: chart)
            async let advice = astrologyService.getDailyAdvice(for: chart, date: Date())

            let results = try await (
                horoscope: horoscope,
                energies: energies,
                moon: moon,
                transits: transits,
                advice: advice
            )

            self.detailedHoroscope = results.horoscope
            self.keyEnergies = results.energies
            self.moonData = results.moon
            self.personalTransits = results.transits
            self.dailyAdvice = results.advice
            self.transits = results.transits

        } catch {
            self.errorMessage = "Не удалось загрузить данные: \(error.localizedDescription)"
            print("❌ Error loading today content: \(error)")
        }

        isLoading = false
    }

    func refreshContent() async {
        isRefreshing = true
        await loadTodayContent()
        isRefreshing = false
    }

    // Legacy method for compatibility
    func loadTodayData() async {
        await loadTodayContent()
    }
}
