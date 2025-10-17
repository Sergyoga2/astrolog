//
//  GlobalCitySearchService.swift
//  Astrolog
//
//  Created by Claude on 17.10.2025.
//

import Foundation
import CoreLocation

class GlobalCitySearchService {
    static let shared = GlobalCitySearchService()

    private init() {}

    // MARK: - Public API

    func searchCities(query: String, limit: Int = 10) async -> [CityResult] {
        guard !query.isEmpty, query.count >= 2 else { return [] }

        // 1. Сначала ищем в популярных городах для быстрого доступа
        let popularResults = searchInPopularCities(query: query)

        // 2. Если нашли точные совпадения в популярных городах, возвращаем их
        if let exactMatch = popularResults.first(where: {
            $0.name.localizedCaseInsensitiveCompare(query) == .orderedSame
        }) {
            var results = [exactMatch]
            results.append(contentsOf: popularResults.filter { $0.id != exactMatch.id })
            return Array(results.prefix(limit))
        }

        // 3. Параллельный поиск в нескольких источниках
        async let nominatimResults = searchWithNominatim(query: query, limit: limit)
        async let geonamesResults = searchWithGeonames(query: query, limit: limit)
        async let appleResults = searchWithAppleGeocoder(query: query)

        // 4. Объединяем результаты
        let allResults = await [
            popularResults,
            nominatimResults,
            geonamesResults,
            appleResults
        ].flatMap { $0 }

        // 5. Удаляем дубликаты и сортируем по релевантности
        let uniqueResults = removeDuplicates(from: allResults)
        let sortedResults = sortByRelevance(results: uniqueResults, query: query)

        return Array(sortedResults.prefix(limit))
    }
}

// MARK: - Data Models

struct CityResult: Identifiable, Hashable {
    let id: String
    let name: String
    let country: String
    let state: String?
    let latitude: Double
    let longitude: Double
    let population: Int?
    let timeZoneId: String?
    let importance: Double // Для сортировки по релевантности

    init(name: String, country: String, state: String? = nil,
         latitude: Double, longitude: Double,
         population: Int? = nil, timeZoneId: String? = nil,
         importance: Double = 0.0) {
        self.id = "\(latitude),\(longitude)"
        self.name = name
        self.country = country
        self.state = state
        self.latitude = latitude
        self.longitude = longitude
        self.population = population
        self.timeZoneId = timeZoneId
        self.importance = importance
    }

    var displayName: String {
        if let state = state, !state.isEmpty {
            return "\(name), \(state), \(country)"
        }
        return "\(name), \(country)"
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: CityResult, rhs: CityResult) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Popular Cities Database

private extension GlobalCitySearchService {
    func searchInPopularCities(query: String) -> [CityResult] {
        let popularCities: [CityResult] = [
            // Россия
            CityResult(name: "Moscow", country: "Russia", latitude: 55.7558, longitude: 37.6173, population: 12506468, timeZoneId: "Europe/Moscow", importance: 1.0),
            CityResult(name: "Saint Petersburg", country: "Russia", latitude: 59.9311, longitude: 30.3609, population: 5351935, timeZoneId: "Europe/Moscow", importance: 0.9),
            CityResult(name: "Novosibirsk", country: "Russia", latitude: 55.0084, longitude: 82.9357, population: 1618039, timeZoneId: "Asia/Novosibirsk", importance: 0.7),
            CityResult(name: "Yekaterinburg", country: "Russia", latitude: 56.8431, longitude: 60.6454, population: 1495066, timeZoneId: "Asia/Yekaterinburg", importance: 0.7),
            CityResult(name: "Nizhny Novgorod", country: "Russia", latitude: 56.2965, longitude: 43.9361, population: 1252236, timeZoneId: "Europe/Moscow", importance: 0.6),
            CityResult(name: "Kazan", country: "Russia", latitude: 55.8304, longitude: 49.0661, population: 1257391, timeZoneId: "Europe/Moscow", importance: 0.6),
            CityResult(name: "Samara", country: "Russia", latitude: 53.2001, longitude: 50.1500, population: 1156644, timeZoneId: "Europe/Samara", importance: 0.6),
            CityResult(name: "Omsk", country: "Russia", latitude: 54.9885, longitude: 73.3242, population: 1154116, timeZoneId: "Asia/Omsk", importance: 0.6),
            CityResult(name: "Rostov-on-Don", country: "Russia", latitude: 47.2357, longitude: 39.7015, population: 1137904, timeZoneId: "Europe/Moscow", importance: 0.6),
            CityResult(name: "Ufa", country: "Russia", latitude: 54.7388, longitude: 55.9721, population: 1128787, timeZoneId: "Asia/Yekaterinburg", importance: 0.6),
            CityResult(name: "Krasnoyarsk", country: "Russia", latitude: 56.0184, longitude: 92.8672, population: 1093771, timeZoneId: "Asia/Krasnoyarsk", importance: 0.6),
            CityResult(name: "Vladivostok", country: "Russia", latitude: 43.1056, longitude: 131.8735, population: 606589, timeZoneId: "Asia/Vladivostok", importance: 0.5),

            // Мировые столицы и крупные города
            CityResult(name: "London", country: "United Kingdom", latitude: 51.5074, longitude: -0.1278, population: 9648110, timeZoneId: "Europe/London", importance: 1.0),
            CityResult(name: "New York", country: "United States", state: "New York", latitude: 40.7128, longitude: -74.0060, population: 8336817, timeZoneId: "America/New_York", importance: 1.0),
            CityResult(name: "Los Angeles", country: "United States", state: "California", latitude: 34.0522, longitude: -118.2437, population: 3898747, timeZoneId: "America/Los_Angeles", importance: 0.9),
            CityResult(name: "Paris", country: "France", latitude: 48.8566, longitude: 2.3522, population: 2165423, timeZoneId: "Europe/Paris", importance: 1.0),
            CityResult(name: "Berlin", country: "Germany", latitude: 52.5200, longitude: 13.4050, population: 3669491, timeZoneId: "Europe/Berlin", importance: 0.9),
            CityResult(name: "Tokyo", country: "Japan", latitude: 35.6762, longitude: 139.6503, population: 13960236, timeZoneId: "Asia/Tokyo", importance: 1.0),
            CityResult(name: "Beijing", country: "China", latitude: 39.9042, longitude: 116.4074, population: 21542000, timeZoneId: "Asia/Shanghai", importance: 1.0),
            CityResult(name: "Mumbai", country: "India", latitude: 19.0760, longitude: 72.8777, population: 12691836, timeZoneId: "Asia/Kolkata", importance: 0.9),
            CityResult(name: "Sydney", country: "Australia", latitude: -33.8688, longitude: 151.2093, population: 5312163, timeZoneId: "Australia/Sydney", importance: 0.8),
            CityResult(name: "Toronto", country: "Canada", latitude: 43.6532, longitude: -79.3832, population: 2794356, timeZoneId: "America/Toronto", importance: 0.8),
            CityResult(name: "Dubai", country: "United Arab Emirates", latitude: 25.2048, longitude: 55.2708, population: 3331420, timeZoneId: "Asia/Dubai", importance: 0.8),
            CityResult(name: "Istanbul", country: "Turkey", latitude: 41.0082, longitude: 28.9784, population: 15462452, timeZoneId: "Europe/Istanbul", importance: 0.9),

            // Европейские столицы
            CityResult(name: "Rome", country: "Italy", latitude: 41.9028, longitude: 12.4964, population: 2872800, timeZoneId: "Europe/Rome", importance: 0.8),
            CityResult(name: "Madrid", country: "Spain", latitude: 40.4168, longitude: -3.7038, population: 3223334, timeZoneId: "Europe/Madrid", importance: 0.8),
            CityResult(name: "Amsterdam", country: "Netherlands", latitude: 52.3676, longitude: 4.9041, population: 873555, timeZoneId: "Europe/Amsterdam", importance: 0.7),
            CityResult(name: "Vienna", country: "Austria", latitude: 48.2082, longitude: 16.3738, population: 1911191, timeZoneId: "Europe/Vienna", importance: 0.7),
            CityResult(name: "Prague", country: "Czech Republic", latitude: 50.0755, longitude: 14.4378, population: 1335084, timeZoneId: "Europe/Prague", importance: 0.7),
            CityResult(name: "Warsaw", country: "Poland", latitude: 52.2297, longitude: 21.0122, population: 1790658, timeZoneId: "Europe/Warsaw", importance: 0.7),
            CityResult(name: "Stockholm", country: "Sweden", latitude: 59.3293, longitude: 18.0686, population: 975551, timeZoneId: "Europe/Stockholm", importance: 0.7),
            CityResult(name: "Oslo", country: "Norway", latitude: 59.9139, longitude: 10.7522, population: 697549, timeZoneId: "Europe/Oslo", importance: 0.6),
            CityResult(name: "Helsinki", country: "Finland", latitude: 60.1699, longitude: 24.9384, population: 658864, timeZoneId: "Europe/Helsinki", importance: 0.6),

            // Азиатско-Тихоокеанский регион
            CityResult(name: "Seoul", country: "South Korea", latitude: 37.5665, longitude: 126.9780, population: 9720846, timeZoneId: "Asia/Seoul", importance: 0.9),
            CityResult(name: "Bangkok", country: "Thailand", latitude: 13.7563, longitude: 100.5018, population: 10156000, timeZoneId: "Asia/Bangkok", importance: 0.8),
            CityResult(name: "Singapore", country: "Singapore", latitude: 1.3521, longitude: 103.8198, population: 5685807, timeZoneId: "Asia/Singapore", importance: 0.8),
            CityResult(name: "Hong Kong", country: "Hong Kong", latitude: 22.3193, longitude: 114.1694, population: 7496981, timeZoneId: "Asia/Hong_Kong", importance: 0.8),
            CityResult(name: "Manila", country: "Philippines", latitude: 14.5995, longitude: 120.9842, population: 13482462, timeZoneId: "Asia/Manila", importance: 0.7),

            // Америки
            CityResult(name: "Mexico City", country: "Mexico", latitude: 19.4326, longitude: -99.1332, population: 21581000, timeZoneId: "America/Mexico_City", importance: 0.8),
            CityResult(name: "São Paulo", country: "Brazil", latitude: -23.5558, longitude: -46.6396, population: 12325232, timeZoneId: "America/Sao_Paulo", importance: 0.8),
            CityResult(name: "Buenos Aires", country: "Argentina", latitude: -34.6118, longitude: -58.3960, population: 3054300, timeZoneId: "America/Argentina/Buenos_Aires", importance: 0.8),
            CityResult(name: "Lima", country: "Peru", latitude: -12.0464, longitude: -77.0428, population: 10719188, timeZoneId: "America/Lima", importance: 0.7),
            CityResult(name: "Bogotá", country: "Colombia", latitude: 4.7110, longitude: -74.0721, population: 7412566, timeZoneId: "America/Bogota", importance: 0.7),

            // Африка и Ближний Восток
            CityResult(name: "Cairo", country: "Egypt", latitude: 30.0444, longitude: 31.2357, population: 20484965, timeZoneId: "Africa/Cairo", importance: 0.8),
            CityResult(name: "Lagos", country: "Nigeria", latitude: 6.5244, longitude: 3.3792, population: 14862000, timeZoneId: "Africa/Lagos", importance: 0.7),
            CityResult(name: "Casablanca", country: "Morocco", latitude: 33.5731, longitude: -7.5898, population: 3359818, timeZoneId: "Africa/Casablanca", importance: 0.6),
            CityResult(name: "Tel Aviv", country: "Israel", latitude: 32.0853, longitude: 34.7818, population: 460613, timeZoneId: "Asia/Jerusalem", importance: 0.6),
        ]

        return popularCities.filter { city in
            city.name.localizedCaseInsensitiveContains(query) ||
            city.country.localizedCaseInsensitiveContains(query) ||
            (city.state?.localizedCaseInsensitiveContains(query) ?? false)
        }.sorted { $0.importance > $1.importance }
    }
}

// MARK: - External APIs

private extension GlobalCitySearchService {

    // OpenStreetMap Nominatim API - бесплатный, хороший охват
    func searchWithNominatim(query: String, limit: Int) async -> [CityResult] {
        guard let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            return []
        }

        let urlString = "https://nominatim.openstreetmap.org/search?q=\(encodedQuery)&format=json&limit=\(limit)&addressdetails=1&featureType=city,town,village&accept-language=en"

        guard let url = URL(string: urlString) else { return [] }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let jsonArray = try JSONSerialization.jsonObject(with: data) as? [[String: Any]] ?? []

            return jsonArray.compactMap { item in
                guard let lat = Double(item["lat"] as? String ?? ""),
                      let lon = Double(item["lon"] as? String ?? ""),
                      let displayName = item["display_name"] as? String else {
                    return nil
                }

                let components = displayName.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }
                let cityName = components.first ?? "Unknown"
                let country = components.last ?? "Unknown"

                // Получаем важность из OSM
                let importance = item["importance"] as? Double ?? 0.0

                // Пытаемся определить штат/область
                var state: String? = nil
                if components.count > 2 {
                    state = components[components.count - 2]
                }

                return CityResult(
                    name: String(cityName),
                    country: String(country),
                    state: state,
                    latitude: lat,
                    longitude: lon,
                    timeZoneId: nil, // Nominatim не предоставляет timezone
                    importance: importance
                )
            }
        } catch {
            print("Nominatim API error: \(error)")
            return []
        }
    }

    // GeoNames API - очень подробная база данных (требует регистрации для prod)
    func searchWithGeonames(query: String, limit: Int) async -> [CityResult] {
        guard let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            return []
        }

        // Используем демо username для тестирования (в проде нужен настоящий)
        let username = "demo" // В продакшене заменить на реальный username
        let urlString = "http://api.geonames.org/searchJSON?q=\(encodedQuery)&maxRows=\(limit)&cities=cities5000&username=\(username)"

        guard let url = URL(string: urlString) else { return [] }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)

            if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
               let geonames = json["geonames"] as? [[String: Any]] {

                return geonames.compactMap { item in
                    guard let name = item["name"] as? String,
                          let country = item["countryName"] as? String,
                          let lat = item["lat"] as? Double,
                          let lon = item["lng"] as? Double else {
                        return nil
                    }

                    let population = item["population"] as? Int
                    let state = item["adminName1"] as? String
                    let timezoneId = (item["timezone"] as? [String: Any])?["timeZoneId"] as? String

                    // Рассчитываем важность на основе населения
                    let importance = population != nil ? min(1.0, Double(population!) / 10_000_000.0) : 0.1

                    return CityResult(
                        name: name,
                        country: country,
                        state: state,
                        latitude: lat,
                        longitude: lon,
                        population: population,
                        timeZoneId: timezoneId,
                        importance: importance
                    )
                }
            }
        } catch {
            print("GeoNames API error: \(error)")
        }

        return []
    }

    // Apple CLGeocoder - работает на устройстве, но ограничен в симуляторе
    func searchWithAppleGeocoder(query: String) async -> [CityResult] {
        let geocoder = CLGeocoder()

        do {
            let placemarks = try await geocoder.geocodeAddressString(query)

            return placemarks.compactMap { placemark in
                guard let location = placemark.location,
                      let locality = placemark.locality ?? placemark.name else {
                    return nil
                }

                let country = placemark.country ?? "Unknown"
                let state = placemark.administrativeArea
                let timeZoneId = placemark.timeZone?.identifier

                return CityResult(
                    name: locality,
                    country: country,
                    state: state,
                    latitude: location.coordinate.latitude,
                    longitude: location.coordinate.longitude,
                    timeZoneId: timeZoneId,
                    importance: 0.5 // Средняя важность для Apple результатов
                )
            }
        } catch {
            print("Apple Geocoder error: \(error)")
            return []
        }
    }
}

// MARK: - Result Processing

private extension GlobalCitySearchService {
    func removeDuplicates(from results: [CityResult]) -> [CityResult] {
        var seen = Set<String>()
        var uniqueResults: [CityResult] = []

        for result in results {
            // Создаем ключ для определения дубликатов (название + страна + приблизительные координаты)
            let key = "\(result.name.lowercased())_\(result.country.lowercased())_\(Int(result.latitude * 10))_\(Int(result.longitude * 10))"

            if !seen.contains(key) {
                seen.insert(key)
                uniqueResults.append(result)
            }
        }

        return uniqueResults
    }

    func sortByRelevance(results: [CityResult], query: String) -> [CityResult] {
        return results.sorted { first, second in
            // 1. Точное совпадение названия города
            let firstExactMatch = first.name.localizedCaseInsensitiveCompare(query) == .orderedSame
            let secondExactMatch = second.name.localizedCaseInsensitiveCompare(query) == .orderedSame

            if firstExactMatch != secondExactMatch {
                return firstExactMatch
            }

            // 2. Начинается ли название с поискового запроса
            let firstStartsWithQuery = first.name.localizedCaseInsensitiveHasPrefix(query)
            let secondStartsWithQuery = second.name.localizedCaseInsensitiveHasPrefix(query)

            if firstStartsWithQuery != secondStartsWithQuery {
                return firstStartsWithQuery
            }

            // 3. Важность города (население, значимость)
            if first.importance != second.importance {
                return first.importance > second.importance
            }

            // 4. Население (если есть)
            let firstPop = first.population ?? 0
            let secondPop = second.population ?? 0

            if firstPop != secondPop {
                return firstPop > secondPop
            }

            // 5. Алфавитный порядок
            return first.name < second.name
        }
    }
}

// MARK: - String Extensions

private extension String {
    func localizedCaseInsensitiveHasPrefix(_ prefix: String) -> Bool {
        return self.localizedCaseInsensitiveCompare(prefix.prefix(self.count)) == .orderedSame
    }
}