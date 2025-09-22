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
    private var searchTask: Task<Void, Never>?
    
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
        guard !city.isEmpty else {
            locationSuggestions = []
            showingSuggestions = false
            return
        }
        
        // Отменяем предыдущий поиск
        searchTask?.cancel()
        
        // Сначала ищем в популярных городах
        let filteredPopularCities = popularCities.filter {
            $0.city.localizedCaseInsensitiveContains(city) ||
            $0.country.localizedCaseInsensitiveContains(city)
        }
        
        locationSuggestions = filteredPopularCities
        showingSuggestions = !filteredPopularCities.isEmpty
        
        // Если найдено точное совпадение в популярных городах, используем его
        if let exactMatch = filteredPopularCities.first(where: {
            $0.city.localizedCaseInsensitiveCompare(city) == .orderedSame
        }) {
            selectLocation(exactMatch)
            return
        }
        
        // Если не нашли в популярных, ищем через Geocoder
        guard city.count >= 3 else { return }
        
        isSearchingLocation = true
        errorMessage = nil
        
        searchTask = Task {
            do {
                try await Task.sleep(nanoseconds: 500_000_000) // debouncing
                
                // Пробуем разные варианты поиска
                let searchQueries = [
                    city,
                    "\(city), \(countryName)".trimmingCharacters(in: .punctuationCharacters.union(.whitespaces)),
                    countryName.isEmpty ? city : "\(city), \(countryName)"
                ]
                
                var foundPlacemark: CLPlacemark?
                
                for query in searchQueries {
                    guard !query.isEmpty else { continue }
                    
                    do {
                        let placemarks = try await geocoder.geocodeAddressString(query)
                        if let placemark = placemarks.first {
                            foundPlacemark = placemark
                            break
                        }
                    } catch {
                        // Продолжаем поиск с другими вариантами
                        continue
                    }
                }
                
                if let placemark = foundPlacemark,
                   let location = placemark.location {
                    
                    let suggestion = LocationSuggestion(
                        city: placemark.locality ?? city,
                        country: placemark.country ?? countryName,
                        latitude: location.coordinate.latitude,
                        longitude: location.coordinate.longitude,
                        timeZoneId: placemark.timeZone?.identifier
                    )
                    
                    await MainActor.run {
                        // Добавляем найденное место к предложениям
                        if !self.locationSuggestions.contains(where: { $0.city == suggestion.city && $0.country == suggestion.country }) {
                            self.locationSuggestions.insert(suggestion, at: 0)
                        }
                        self.showingSuggestions = true
                        self.isSearchingLocation = false
                    }
                }
            } catch {
                if !Task.isCancelled {
                    await MainActor.run {
                        self.errorMessage = "Не удалось найти город. Попробуйте добавить страну или выберите из списка популярных городов."
                        self.isSearchingLocation = false
                    }
                }
            }
        }
    }
    
    func selectLocation(_ suggestion: LocationSuggestion) {
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
