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

        do {

        // 1. ПРИОРИТЕТ OpenStreetMap: Ищем сначала в самом полном источнике
        let nominatimResults = await searchWithNominatim(query: query, limit: limit)
        print("🗺️ OpenStreetMap search for '\(query)' found \(nominatimResults.count) results")

        // 2. УМНЫЙ РАННИЙ ВЫХОД: Если OpenStreetMap нашел точное совпадение - возвращаем только его!
        if let exactMatch = nominatimResults.first(where: {
            let normalizedName = $0.name.components(separatedBy: " (").first ?? $0.name
            let isExactMatch = normalizedName.localizedCaseInsensitiveCompare(query) == .orderedSame
            print("  - Checking OSM '\(normalizedName)': exactMatch=\(isExactMatch)")
            return isExactMatch
        }) {
            print("🎯 OSM early exit: Found exact match for '\(query)': \(exactMatch.name)")
            return [exactMatch]
        }

        // 3. Если OpenStreetMap не нашел точного совпадения, используем другие источники
        print("🔍 OSM fallback: No exact match in OpenStreetMap, trying other sources...")

        // 4. Запускаем остальные источники параллельно
        let popularResults = searchInPopularCities(query: query)
        async let geonamesResults = searchWithGeonames(query: query, limit: limit)
        async let appleResults = searchWithAppleGeocoder(query: query)

        // 5. Объединяем результаты из всех источников
        var allResults = await [
            nominatimResults, // Включаем результаты OSM (но без точного совпадения)
            popularResults,
            geonamesResults,
            appleResults
        ].flatMap { $0 }

        // 6. Если результатов мало, попробуем дополнительные стратегии поиска
        if allResults.count < max(3, limit / 2) {
            let fallbackResults = await searchWithFallbackStrategies(query: query, limit: limit)
            allResults.append(contentsOf: fallbackResults)
        }

        // 7. Удаляем дубликаты и сортируем по релевантности
        let uniqueResults = removeDuplicates(from: allResults)
        let sortedResults = sortByRelevance(results: uniqueResults, query: query)

        return Array(sortedResults.prefix(limit))
        } catch {
            print("Global city search error: \(error)")
            // В случае ошибки возвращаем хотя бы популярные города
            return Array(searchInPopularCities(query: query).prefix(limit))
        }
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
            // Россия (русские названия)
            CityResult(name: "Москва", country: "Russia", latitude: 55.7558, longitude: 37.6173, population: 12506468, timeZoneId: "Europe/Moscow", importance: 1.0),
            CityResult(name: "Санкт-Петербург", country: "Russia", latitude: 59.9311, longitude: 30.3609, population: 5351935, timeZoneId: "Europe/Moscow", importance: 0.9),
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

    // OpenStreetMap Nominatim API - ЛЮБЫЕ населенные пункты
    func searchWithNominatim(query: String, limit: Int) async -> [CityResult] {
        guard let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            return []
        }

        // МАКСИМАЛЬНО РАСШИРЕННЫЙ поиск: города, поселки, деревни, хутора, фермы, станции, дачные поселки и т.д.
        // ПРИОРИТЕТ РУССКОГО ЯЗЫКА: ru,en вместо en,ru
        let urlString = "https://nominatim.openstreetmap.org/search?q=\(encodedQuery)&format=json&limit=\(limit)&addressdetails=1&class=place&type=city,town,village,hamlet,suburb,neighbourhood,isolated_dwelling,farm,locality,allotments,borough,city_block,district,municipality,quarter,square&accept-language=ru,en"

        guard let url = URL(string: urlString) else { return [] }

        do {
            // Добавляем User-Agent для лучшей совместимости
            var request = URLRequest(url: url)
            request.setValue("AstrologApp/1.0", forHTTPHeaderField: "User-Agent")
            request.setValue("1", forHTTPHeaderField: "limit")

            let (data, _) = try await URLSession.shared.data(for: request)
            let jsonArray = try JSONSerialization.jsonObject(with: data) as? [[String: Any]] ?? []

            return jsonArray.compactMap { item in
                guard let lat = Double(item["lat"] as? String ?? ""),
                      let lon = Double(item["lon"] as? String ?? ""),
                      let displayName = item["display_name"] as? String else {
                    return nil
                }

                let components = displayName.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }

                // Попробуем получить русское название из разных полей OSM
                var placeName = components.first ?? "Unknown"

                // OSM может вернуть русское название в разных полях
                if let nameRu = item["name:ru"] as? String, !nameRu.isEmpty {
                    placeName = nameRu
                } else if let name = item["name"] as? String, !name.isEmpty {
                    placeName = name
                }

                let country = components.last ?? "Unknown"

                // Получаем тип населенного пункта
                let placeType = item["type"] as? String ?? "city"
                let _ = item["class"] as? String ?? "place" // Для будущего использования

                // Получаем важность из OSM (для малых населенных пунктов может быть очень низкой)
                let importance = item["importance"] as? Double ?? 0.0

                // Определяем административные единицы
                var state: String? = nil
                if let address = item["address"] as? [String: Any] {
                    state = address["state"] as? String ??
                           address["region"] as? String ??
                           address["province"] as? String ??
                           address["county"] as? String
                } else if components.count > 2 {
                    state = components[components.count - 2]
                }

                // Генерируем описательный тип места
                let localizedType = localizeePlaceType(placeType)

                return CityResult(
                    name: "\(placeName) (\(localizedType))",
                    country: String(country),
                    state: state,
                    latitude: lat,
                    longitude: lon,
                    timeZoneId: nil, // Nominatim не предоставляет timezone
                    importance: max(importance, 0.01) // Минимальная важность для мелких мест
                )
            }
        } catch {
            print("Nominatim API error: \(error)")
            return []
        }
    }

    // Переводим типы населенных пунктов на русский
    private func localizeePlaceType(_ type: String) -> String {
        switch type.lowercased() {
        case "city": return "город"
        case "town": return "город"
        case "village": return "село"
        case "hamlet": return "деревня"
        case "suburb": return "район"
        case "neighbourhood": return "микрорайон"
        case "isolated_dwelling": return "хутор"
        case "farm": return "ферма"
        case "locality": return "местность"
        case "allotments": return "дачный поселок"
        case "borough": return "район"
        case "city_block": return "квартал"
        case "district": return "округ"
        case "municipality": return "муниципалитет"
        case "quarter": return "квартал"
        case "square": return "площадь"
        default: return "населённый пункт"
        }
    }

    // GeoNames API - ВСЕ населенные пункты (даже самые маленькие)
    func searchWithGeonames(query: String, limit: Int) async -> [CityResult] {
        guard let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            return []
        }

        // Используем демо username для тестирования (в проде нужен настоящий)
        let username = "demo" // В продакшене заменить на реальный username

        // Делаем РАСШИРЕННЫЕ запросы для максимального покрытия всех типов населенных пунктов
        let searchQueries = [
            // 1. ВСЕ населенные пункты (включая самые мелкие деревни, хутора, фермы)
            "https://secure.geonames.org/searchJSON?q=\(encodedQuery)&maxRows=\(limit)&featureClass=P&username=\(username)&orderby=relevance",

            // 2. Поиск по точному совпадению без ограничений по типу
            "https://secure.geonames.org/searchJSON?name_equals=\(encodedQuery)&maxRows=\(limit)&featureClass=P&username=\(username)",

            // 3. Поиск административных центров всех уровней
            "https://secure.geonames.org/searchJSON?q=\(encodedQuery)&maxRows=\(limit)&featureCode=PPLA,PPLA2,PPLA3,PPLA4,PPLC&username=\(username)",

            // 4. Поиск ВСЕХ типов поселений (включая фермы, хутора, изолированные жилища)
            "https://secure.geonames.org/searchJSON?q=\(encodedQuery)&maxRows=\(limit)&featureCode=PPL,PPLF,PPLH,PPLL,PPLS&username=\(username)",

            // 5. Поиск с нечетким совпадением для учета опечаток
            "https://secure.geonames.org/searchJSON?name_startsWith=\(encodedQuery)&maxRows=\(min(limit, 5))&featureClass=P&username=\(username)"
        ]

        var allResults: [CityResult] = []

        for (index, urlString) in searchQueries.enumerated() {
            guard let url = URL(string: urlString) else { continue }

            do {
                let (data, _) = try await URLSession.shared.data(from: url)

                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let geonames = json["geonames"] as? [[String: Any]] {

                    let results = geonames.compactMap { item -> CityResult? in
                        guard let name = item["name"] as? String,
                              let country = item["countryName"] as? String,
                              let lat = item["lat"] as? Double,
                              let lon = item["lng"] as? Double else {
                            return nil
                        }

                        let population = item["population"] as? Int
                        let state = item["adminName1"] as? String
                        let timezoneId = (item["timezone"] as? [String: Any])?["timeZoneId"] as? String

                        // Получаем код типа населенного пункта для классификации
                        let featureCode = item["fcode"] as? String ?? ""
                        let localizedType = localizeGeonamesFeatureCode(featureCode)

                        // Рассчитываем важность на основе населения, типа и источника запроса
                        var importance = 0.05 // Базовая важность для любого места
                        if let pop = population, pop > 0 {
                            importance = min(0.9, Double(pop) / 1_000_000.0)
                        }

                        // Повышаем важность для административных центров
                        if featureCode.contains("PPLA") || featureCode == "PPLC" {
                            importance = max(importance, 0.6)
                        }

                        // Повышаем важность для точных совпадений
                        if index == 1 { // name_equals запрос
                            importance = max(importance, 0.7)
                        }

                        // Для малых населенных пунктов показываем тип
                        let shouldShowType = population == nil || population! < 5000 ||
                                           featureCode.contains("F") || featureCode.contains("H") ||
                                           featureCode.contains("L")

                        let displayName = shouldShowType ? "\(name) (\(localizedType))" : name

                        return CityResult(
                            name: displayName,
                            country: country,
                            state: state,
                            latitude: lat,
                            longitude: lon,
                            population: population,
                            timeZoneId: timezoneId,
                            importance: importance
                        )
                    }

                    allResults.append(contentsOf: results)
                }
            } catch {
                print("GeoNames API error for \(urlString): \(error)")
                continue
            }

            // Задержка между запросами для соблюдения лимитов API
            try? await Task.sleep(nanoseconds: 150_000_000) // 150ms
        }

        return allResults
    }

    // Переводим коды GeoNames на русский язык
    private func localizeGeonamesFeatureCode(_ code: String) -> String {
        switch code {
        case "PPLC": return "столица"
        case "PPLA": return "областной центр"
        case "PPLA2": return "районный центр"
        case "PPLA3": return "местный центр"
        case "PPLA4": return "сельский центр"
        case "PPL": return "населённый пункт"
        case "PPLF": return "ферма"
        case "PPLH": return "хутор"
        case "PPLL": return "поселение"
        case "PPLQ": return "заброшенное место"
        case "PPLR": return "религиозное поселение"
        case "PPLS": return "поселения"
        case "PPLW": return "разрушенный населённый пункт"
        case "PPLX": return "район"
        default: return "место"
        }
    }

    // Дополнительные стратегии поиска для максимального покрытия
    func searchWithFallbackStrategies(query: String, limit: Int) async -> [CityResult] {
        var fallbackResults: [CityResult] = []

        // Стратегия 1: Поиск с измененными окончаниями (для русских названий)
        let queryVariations = generateQueryVariations(query)
        for variation in queryVariations.prefix(3) {
            let variationResults = await searchWithNominatim(query: variation, limit: min(limit, 5))
            fallbackResults.append(contentsOf: variationResults)
            if fallbackResults.count >= limit { break }
        }

        // Стратегия 2: Поиск по частям запроса (если запрос содержит несколько слов)
        if query.contains(" ") {
            let words = query.split(separator: " ")
            for word in words {
                if word.count >= 3 {
                    let wordResults = await searchWithNominatim(query: String(word), limit: 3)
                    fallbackResults.append(contentsOf: wordResults)
                }
            }
        }

        return Array(fallbackResults.prefix(limit))
    }

    // Генерируем варианты запроса для более широкого поиска
    private func generateQueryVariations(_ query: String) -> [String] {
        var variations: [String] = []
        let lowercased = query.lowercased()

        // Для русских названий: убираем/добавляем типичные окончания
        let commonEndings = ["ск", "град", "бург", "городок", "село", "деревня"]

        for ending in commonEndings {
            if lowercased.hasSuffix(ending) {
                let withoutEnding = String(lowercased.dropLast(ending.count))
                if withoutEnding.count >= 3 {
                    variations.append(withoutEnding)
                }
            } else if lowercased.count >= 3 {
                variations.append(lowercased + ending)
            }
        }

        // Альтернативные транслитерации
        let transliterationMap: [String: String] = [
            "ya": "я", "yu": "ю", "zh": "ж", "ch": "ч", "sh": "ш", "shch": "щ"
        ]

        for (latin, cyrillic) in transliterationMap {
            if lowercased.contains(latin) {
                variations.append(lowercased.replacingOccurrences(of: latin, with: cyrillic))
            }
            if lowercased.contains(cyrillic) {
                variations.append(lowercased.replacingOccurrences(of: cyrillic, with: latin))
            }
        }

        return Array(Set(variations)) // Убираем дубликаты
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
        var cityMap = [String: CityResult]()

        for result in results {
            // Нормализуем название города (убираем тип из скобок для сравнения)
            let normalizedName = result.name.components(separatedBy: " (").first?.lowercased() ?? result.name.lowercased()
            let key = "\(normalizedName)_\(result.country.lowercased())"

            // Если города еще нет или новый результат лучше
            if let existing = cityMap[key] {
                // Приоритет: наличие timeZone > население > важность
                let shouldReplace = (result.timeZoneId != nil && existing.timeZoneId == nil) ||
                                   (result.timeZoneId != nil && existing.timeZoneId != nil &&
                                    ((result.population ?? 0) > (existing.population ?? 0))) ||
                                   (result.timeZoneId == nil && existing.timeZoneId == nil &&
                                    result.importance > existing.importance)

                if shouldReplace {
                    cityMap[key] = result
                }
            } else {
                cityMap[key] = result
            }
        }

        return Array(cityMap.values)
    }

    func sortByRelevance(results: [CityResult], query: String) -> [CityResult] {
        return results.sorted { first, second in
            // 1. Точное совпадение названия города (без учета типа в скобках)
            let firstNormalized = first.name.components(separatedBy: " (").first ?? first.name
            let secondNormalized = second.name.components(separatedBy: " (").first ?? second.name

            let firstExactMatch = firstNormalized.localizedCaseInsensitiveCompare(query) == .orderedSame
            let secondExactMatch = secondNormalized.localizedCaseInsensitiveCompare(query) == .orderedSame

            if firstExactMatch != secondExactMatch {
                return firstExactMatch
            }

            // 2. Среди точных совпадений: приоритет городам с timeZone (полная информация)
            if firstExactMatch && secondExactMatch {
                let firstHasTimezone = first.timeZoneId != nil
                let secondHasTimezone = second.timeZoneId != nil

                if firstHasTimezone != secondHasTimezone {
                    return firstHasTimezone
                }

                // Среди точных совпадений с timezone: приоритет по важности
                if first.importance != second.importance {
                    return first.importance > second.importance
                }
            }

            // 3. Приоритет городам с timeZone среди остальных
            let firstHasTimezone = first.timeZoneId != nil
            let secondHasTimezone = second.timeZoneId != nil

            if firstHasTimezone != secondHasTimezone {
                return firstHasTimezone
            }

            // 4. Начинается ли название с поискового запроса
            let firstStartsWithQuery = firstNormalized.localizedCaseInsensitiveHasPrefix(query)
            let secondStartsWithQuery = secondNormalized.localizedCaseInsensitiveHasPrefix(query)

            if firstStartsWithQuery != secondStartsWithQuery {
                return firstStartsWithQuery
            }

            // 5. Важность города (население, значимость)
            if first.importance != second.importance {
                return first.importance > second.importance
            }

            // 6. Население (если есть)
            let firstPop = first.population ?? 0
            let secondPop = second.population ?? 0

            if firstPop != secondPop {
                return firstPop > secondPop
            }

            // 7. Алфавитный порядок
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