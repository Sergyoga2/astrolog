//
//  BirthDataInputViewModel.swift
//  Astrolog
//
//  Created by Sergey on 20.09.2025.
//
// Features/Profile/BirthDataInputViewModel.swift
import Foundation
import CoreLocation
import Combine

extension Notification.Name {
    static let navigateToChart = Notification.Name("navigateToChart")
}

@MainActor
class BirthDataInputViewModel: ObservableObject {
    @Published var birthDate = Date()
    @Published var birthTime = Date()
    @Published var isTimeKnown = true
    @Published var cityName = ""
    @Published var countryName = ""
    @Published var latitude: Double = 0
    @Published var longitude: Double = 0
    @Published var selectedTimeZone = TimeZone.current
    @Published var isSearchingLocation = false
    @Published var errorMessage: String?
    @Published var showTimeInfoSheet = false
    @Published var isSaved = false
    @Published var locationSuggestions: [LocationSuggestion] = []
    @Published var showingSuggestions = false

    private let geocoder = CLGeocoder()
    private let globalCitySearch = GlobalCitySearchService.shared
    private var searchTask: Task<Void, Never>?
    private var isSelectingLocation = false
    
    var hasCoordinates: Bool {
        latitude != 0 && longitude != 0
    }
    
    var canSave: Bool {
        !cityName.isEmpty && hasCoordinates
    }
    
    var availableTimeZones: [TimeZone] {
        let identifiers = [
            "Europe/Moscow", "Europe/London", "Europe/Paris", "Europe/Berlin",
            "America/New_York", "America/Los_Angeles", "America/Chicago",
            "Asia/Tokyo", "Asia/Shanghai", "Asia/Kolkata",
            "Australia/Sydney", "Pacific/Auckland"
        ]
        
        return identifiers.compactMap { TimeZone(identifier: $0) }
    }
    
    // Предопределенные города для быстрого доступа
    private let popularCities: [LocationSuggestion] = [
        LocationSuggestion(city: "Moscow", country: "Russia", latitude: 55.7558, longitude: 37.6173, timeZoneId: "Europe/Moscow"),
        LocationSuggestion(city: "Saint Petersburg", country: "Russia", latitude: 59.9311, longitude: 30.3609, timeZoneId: "Europe/Moscow"),
        LocationSuggestion(city: "London", country: "United Kingdom", latitude: 51.5074, longitude: -0.1278, timeZoneId: "Europe/London"),
        LocationSuggestion(city: "New York", country: "United States", latitude: 40.7128, longitude: -74.0060, timeZoneId: "America/New_York"),
        LocationSuggestion(city: "Los Angeles", country: "United States", latitude: 34.0522, longitude: -118.2437, timeZoneId: "America/Los_Angeles"),
        LocationSuggestion(city: "Paris", country: "France", latitude: 48.8566, longitude: 2.3522, timeZoneId: "Europe/Paris"),
        LocationSuggestion(city: "Berlin", country: "Germany", latitude: 52.5200, longitude: 13.4050, timeZoneId: "Europe/Berlin"),
        LocationSuggestion(city: "Tokyo", country: "Japan", latitude: 35.6762, longitude: 139.6503, timeZoneId: "Asia/Tokyo"),
        LocationSuggestion(city: "Sydney", country: "Australia", latitude: -33.8688, longitude: 151.2093, timeZoneId: "Australia/Sydney"),
        LocationSuggestion(city: "Yekaterinburg", country: "Russia", latitude: 56.8431, longitude: 60.6454, timeZoneId: "Asia/Yekaterinburg"),
        LocationSuggestion(city: "Novosibirsk", country: "Russia", latitude: 55.0084, longitude: 82.9357, timeZoneId: "Asia/Novosibirsk"),
        LocationSuggestion(city: "Vladivostok", country: "Russia", latitude: 43.1056, longitude: 131.8735, timeZoneId: "Asia/Vladivostok")
    ]
    
    func searchLocation(for city: String) {
        // Не запускаем поиск, если пользователь выбирает город из результатов
        guard !city.isEmpty, !isSelectingLocation else {
            locationSuggestions = []
            showingSuggestions = false
            return
        }

        // Отменяем предыдущий поиск
        searchTask?.cancel()

        // Мгновенно показываем индикатор загрузки для лучшего UX
        isSearchingLocation = true
        errorMessage = nil

        searchTask = Task {
            do {
                // Небольшая задержка для debouncing
                try await Task.sleep(nanoseconds: 200_000_000) // 200ms

                // Проверяем, не был ли Task отменен
                guard !Task.isCancelled else { return }

                // Используем глобальный поиск городов
                let cityResults = await globalCitySearch.searchCities(query: city, limit: 15)

                // Проверяем, не был ли Task отменен после получения результатов
                guard !Task.isCancelled else { return }

                // Преобразуем результаты в LocationSuggestion
                let suggestions = cityResults.map { cityResult in
                    LocationSuggestion(
                        city: cityResult.name,
                        country: cityResult.country,
                        latitude: cityResult.latitude,
                        longitude: cityResult.longitude,
                        timeZoneId: cityResult.timeZoneId
                    )
                }

                await MainActor.run {
                    guard !Task.isCancelled else { return }

                    self.locationSuggestions = suggestions
                    self.showingSuggestions = !suggestions.isEmpty
                    self.isSearchingLocation = false

                    if suggestions.isEmpty {
                        self.errorMessage = "Город '\(city)' не найден. Попробуйте другое название или проверьте написание."
                    } else {
                        self.errorMessage = nil
                    }
                }

            } catch {
                print("Search error: \(error)")
                if !Task.isCancelled {
                    await MainActor.run {
                        self.errorMessage = "Произошла ошибка при поиске. Проверьте подключение к интернету."
                        self.isSearchingLocation = false
                    }
                }
            }
        }
    }

    
    func selectLocation(_ suggestion: LocationSuggestion) {
        // Отменяем текущий поиск
        searchTask?.cancel()
        isSearchingLocation = false

        // Устанавливаем флаг ДО изменения cityName
        isSelectingLocation = true

        cityName = suggestion.city
        countryName = suggestion.country
        latitude = suggestion.latitude
        longitude = suggestion.longitude

        if let timeZoneId = suggestion.timeZoneId,
           let timeZone = TimeZone(identifier: timeZoneId) {
            selectedTimeZone = timeZone
        }

        showingSuggestions = false
        errorMessage = nil

        // Сбрасываем флаг после небольшой задержки
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.isSelectingLocation = false
        }
    }
    
    func manuallySetCoordinates(lat: Double, lon: Double) {
        latitude = lat
        longitude = lon
        errorMessage = nil
    }
    
    func saveBirthData() {
        guard canSave else { return }
        
        let calendar = Calendar.current
        let dateComponents = calendar.dateComponents([.year, .month, .day], from: birthDate)
        let timeComponents = calendar.dateComponents([.hour, .minute], from: isTimeKnown ? birthTime : createNoonTime())
        
        var finalComponents = DateComponents()
        finalComponents.year = dateComponents.year
        finalComponents.month = dateComponents.month
        finalComponents.day = dateComponents.day
        finalComponents.hour = timeComponents.hour
        finalComponents.minute = timeComponents.minute
        finalComponents.timeZone = selectedTimeZone
        
        guard let finalDate = calendar.date(from: finalComponents) else {
            errorMessage = "Ошибка создания даты"
            return
        }
        
        let birthData = BirthData(
            date: finalDate,
            timeZone: selectedTimeZone,
            latitude: latitude,
            longitude: longitude,
            cityName: cityName,
            countryName: countryName,
            isTimeExact: isTimeKnown
        )
        
        saveBirthDataToUserDefaults(birthData)

        // Уведомляем координатор о необходимости навигации к карте
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            NotificationCenter.default.post(name: .navigateToChart, object: nil)
        }

        isSaved = true
    }
    
    private func createNoonTime() -> Date {
        let calendar = Calendar.current
        var components = DateComponents()
        components.hour = 12
        components.minute = 0
        return calendar.date(from: components) ?? Date()
    }
    
    private func saveBirthDataToUserDefaults(_ birthData: BirthData) {
        do {
            let data = try JSONEncoder().encode(birthData)
            UserDefaults.standard.set(data, forKey: "user_birth_data")
        } catch {
            errorMessage = "Ошибка сохранения данных"
        }
    }
    
    deinit {
        searchTask?.cancel()
    }
}

// MARK: - Helper Models

struct LocationSuggestion: Identifiable {
    let id = UUID()
    let city: String
    let country: String
    let latitude: Double
    let longitude: Double
    let timeZoneId: String?
}
