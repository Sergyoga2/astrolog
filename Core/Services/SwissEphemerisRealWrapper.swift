import Foundation

// MARK: - Swiss Ephemeris Real Wrapper
// This wrapper provides Swift interface to Swiss Ephemeris C library
// IMPORTANT: Requires Swiss Ephemeris C library integration (see SWISS_EPHEMERIS_INTEGRATION.md)

/// Thread-safe wrapper for Swiss Ephemeris calculations
@MainActor
final class SwissEphemerisRealWrapper {
    static let shared = SwissEphemerisRealWrapper()

    private let calculationQueue = DispatchQueue(label: "com.astrolog.swisseph", qos: .userInitiated)
    private var isInitialized = false

    // MARK: - Initialization

    private init() {
        setupEphemerisPath()
    }

    private func setupEphemerisPath() {
        #if SWISS_EPHEMERIS_AVAILABLE
        if let resourcePath = Bundle.main.resourcePath {
            let ephePath = resourcePath + "/Data"
            let cPath = (ephePath as NSString).utf8String
            swe_set_ephe_path(UnsafeMutablePointer(mutating: cPath))
            isInitialized = true
            print("✅ Swiss Ephemeris initialized with path: \(ephePath)")
        } else {
            print("⚠️ Failed to initialize Swiss Ephemeris: Resource path not found")
        }
        #else
        print("⚠️ Swiss Ephemeris not available - using simplified calculations")
        #endif
    }

    // MARK: - Planet Calculations

    /// Calculate planet position for given Julian Day
    func calculatePlanetPosition(
        planet: PlanetType,
        julianDay: Double
    ) async throws -> PlanetPosition {
        #if SWISS_EPHEMERIS_AVAILABLE
        return try await withCheckedThrowingContinuation { continuation in
            calculationQueue.async {
                var result = [Double](repeating: 0, count: 6)
                var errorString = [CChar](repeating: 0, count: 256)

                let flags = SEFLG_SWIEPH | SEFLG_SPEED

                let returnCode = swe_calc_ut(
                    julianDay,
                    planet.swissEphemerisCode,
                    flags,
                    &result,
                    &errorString
                )

                if returnCode < 0 {
                    let error = String(cString: errorString)
                    continuation.resume(throwing: SwissEphemerisError.calculationFailed(error))
                    return
                }

                let position = PlanetPosition(
                    longitude: result[0],
                    latitude: result[1],
                    distance: result[2],
                    longitudeSpeed: result[3],
                    latitudeSpeed: result[4],
                    distanceSpeed: result[5]
                )

                continuation.resume(returning: position)
            }
        }
        #else
        throw SwissEphemerisError.notAvailable
        #endif
    }

    /// Calculate positions for all major planets
    func calculateAllPlanets(julianDay: Double) async throws -> [PlanetType: PlanetPosition] {
        var positions: [PlanetType: PlanetPosition] = [:]

        let planets: [PlanetType] = [
            .sun, .moon, .mercury, .venus, .mars,
            .jupiter, .saturn, .uranus, .neptune, .pluto,
            .northNode, .chiron
        ]

        for planet in planets {
            do {
                let position = try await calculatePlanetPosition(planet: planet, julianDay: julianDay)
                positions[planet] = position
            } catch {
                print("⚠️ Failed to calculate \(planet): \(error)")
                // Continue with other planets
            }
        }

        return positions
    }

    // MARK: - House Calculations

    /// Calculate house cusps and angles (ASC, MC, etc.)
    func calculateHouses(
        julianDay: Double,
        latitude: Double,
        longitude: Double,
        houseSystem: HouseSystem = .placidus
    ) async throws -> HouseData {
        #if SWISS_EPHEMERIS_AVAILABLE
        return try await withCheckedThrowingContinuation { continuation in
            calculationQueue.async {
                var cusps = [Double](repeating: 0, count: 13) // 12 houses + index 0
                var ascmc = [Double](repeating: 0, count: 10)

                let returnCode = swe_houses(
                    julianDay,
                    latitude,
                    longitude,
                    houseSystem.code,
                    &cusps,
                    &ascmc
                )

                if returnCode < 0 {
                    continuation.resume(throwing: SwissEphemerisError.houseCalculationFailed)
                    return
                }

                // Extract house cusps (indices 1-12)
                let houseCusps = Array(cusps[1...12])

                let houseData = HouseData(
                    cusps: houseCusps,
                    ascendant: ascmc[0],      // SE_ASC
                    mc: ascmc[1],             // SE_MC (Midheaven)
                    armc: ascmc[2],           // SE_ARMC
                    vertex: ascmc[3],         // SE_VERTEX
                    equatorialAscendant: ascmc[4], // SE_EQUASC
                    coAscendant1: ascmc[5],   // SE_COASC1
                    coAscendant2: ascmc[6],   // SE_COASC2
                    polarAscendant: ascmc[7]  // SE_POLASC
                )

                continuation.resume(returning: houseData)
            }
        }
        #else
        throw SwissEphemerisError.notAvailable
        #endif
    }

    // MARK: - Julian Day Conversion

    /// Convert Date to Julian Day
    func dateToJulianDay(date: Date, timeZone: TimeZone) -> Double {
        #if SWISS_EPHEMERIS_AVAILABLE
        // Convert to UTC
        let utcDate = date.addingTimeInterval(-Double(timeZone.secondsFromGMT(for: date)))

        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!

        let components = calendar.dateComponents(
            [.year, .month, .day, .hour, .minute, .second],
            from: utcDate
        )

        let year = Int32(components.year ?? 2000)
        let month = Int32(components.month ?? 1)
        let day = Int32(components.day ?? 1)
        let hour = Double(components.hour ?? 12)
        let minute = Double(components.minute ?? 0)
        let second = Double(components.second ?? 0)

        let totalHours = hour + minute/60.0 + second/3600.0

        let jd = swe_julday(year, month, day, totalHours, SE_GREG_CAL)

        return jd
        #else
        // Fallback calculation
        return SwissEphemerisWrapper.julianDay(
            year: Int32(Calendar.current.component(.year, from: date)),
            month: Int32(Calendar.current.component(.month, from: date)),
            day: Int32(Calendar.current.component(.day, from: date)),
            hour: Double(Calendar.current.component(.hour, from: date))
        )
        #endif
    }

    // MARK: - Cleanup

    deinit {
        #if SWISS_EPHEMERIS_AVAILABLE
        swe_close()
        print("Swiss Ephemeris closed")
        #endif
    }
}

// MARK: - Supporting Types

struct PlanetPosition {
    let longitude: Double        // Ecliptic longitude in degrees
    let latitude: Double         // Ecliptic latitude in degrees
    let distance: Double         // Distance in AU
    let longitudeSpeed: Double   // Daily motion in longitude
    let latitudeSpeed: Double    // Daily motion in latitude
    let distanceSpeed: Double    // Daily motion in distance

    var zodiacSign: ZodiacSign {
        let normalized = longitude.truncatingRemainder(dividingBy: 360)
        let index = Int(normalized / 30)
        let signs: [ZodiacSign] = [
            .aries, .taurus, .gemini, .cancer, .leo, .virgo,
            .libra, .scorpio, .sagittarius, .capricorn, .aquarius, .pisces
        ]
        return signs[index % 12]
    }

    var degreeInSign: Double {
        longitude.truncatingRemainder(dividingBy: 30)
    }

    var isRetrograde: Bool {
        longitudeSpeed < 0
    }
}

struct HouseData {
    let cusps: [Double]              // 12 house cusps
    let ascendant: Double            // ASC (1st house cusp)
    let mc: Double                   // MC (10th house cusp)
    let armc: Double                 // ARMC
    let vertex: Double               // Vertex
    let equatorialAscendant: Double  // Equatorial Ascendant
    let coAscendant1: Double         // Co-Ascendant (Koch)
    let coAscendant2: Double         // Co-Ascendant (Porphyry)
    let polarAscendant: Double       // Polar Ascendant
}

enum PlanetType {
    case sun, moon, mercury, venus, mars
    case jupiter, saturn, uranus, neptune, pluto
    case northNode, southNode, chiron

    #if SWISS_EPHEMERIS_AVAILABLE
    var swissEphemerisCode: Int32 {
        switch self {
        case .sun: return SE_SUN          // 0
        case .moon: return SE_MOON        // 1
        case .mercury: return SE_MERCURY  // 2
        case .venus: return SE_VENUS      // 3
        case .mars: return SE_MARS        // 4
        case .jupiter: return SE_JUPITER  // 5
        case .saturn: return SE_SATURN    // 6
        case .uranus: return SE_URANUS    // 7
        case .neptune: return SE_NEPTUNE  // 8
        case .pluto: return SE_PLUTO      // 9
        case .northNode: return SE_MEAN_NODE  // 10
        case .southNode: return SE_MEAN_NODE  // 10 (opposite of North Node)
        case .chiron: return SE_CHIRON    // 15
        }
    }
    #endif
}

enum HouseSystem {
    case placidus
    case koch
    case porphyry
    case regiomontanus
    case campanus
    case equal
    case wholeSign

    var code: Int8 {
        switch self {
        case .placidus: return 80       // 'P'
        case .koch: return 75           // 'K'
        case .porphyry: return 79       // 'O'
        case .regiomontanus: return 82  // 'R'
        case .campanus: return 67       // 'C'
        case .equal: return 65          // 'A'
        case .wholeSign: return 87      // 'W'
        }
    }
}

// MARK: - Errors

enum SwissEphemerisError: LocalizedError {
    case notAvailable
    case calculationFailed(String)
    case houseCalculationFailed
    case invalidDate

    var errorDescription: String? {
        switch self {
        case .notAvailable:
            return "Swiss Ephemeris library is not available"
        case .calculationFailed(let message):
            return "Swiss Ephemeris calculation failed: \(message)"
        case .houseCalculationFailed:
            return "Failed to calculate houses"
        case .invalidDate:
            return "Invalid date for calculation"
        }
    }
}

// MARK: - Compilation Flag Documentation

/*
 To enable Swiss Ephemeris integration:

 1. Add Swiss Ephemeris source files to project
 2. Create bridging header
 3. Add compiler flag in Build Settings:
    - Other Swift Flags: -DSWISS_EPHEMERIS_AVAILABLE

 Until then, the wrapper will throw .notAvailable errors
 and the app will use simplified calculations from SwissEphemerisWrapper
 */
