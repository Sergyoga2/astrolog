// Core/Services/SwissEphemerisWrapper.swift
import Foundation

let SE_SUN: Int32 = 0
let SE_MOON: Int32 = 1
let SE_MERCURY: Int32 = 2
let SE_VENUS: Int32 = 3
let SE_MARS: Int32 = 4
let SE_JUPITER: Int32 = 5
let SE_SATURN: Int32 = 6
let SE_URANUS: Int32 = 7
let SE_NEPTUNE: Int32 = 8
let SE_PLUTO: Int32 = 9

let SE_GREG_CAL: Int32 = 1
let SEFLG_SPEED: Int32 = 256
let SEFLG_SWIEPH: Int32 = 2

class SwissEphemerisWrapper {
    
    static func julianDay(year: Int32, month: Int32, day: Int32, hour: Double) -> Double {
        // ИСПРАВЛЕНО: все вычисления в Double с использованием floor()
        let a = floor(Double(14 - month) / 12.0)
        let y = Double(year) + 4800.0 - a
        let m = Double(month) + 12.0 * a - 3.0
        
        let jd = Double(day) + floor((153.0 * m + 2.0) / 5.0) + 365.0 * y + floor(y / 4.0) - floor(y / 100.0) + floor(y / 400.0) - 32045.0
        return jd + (hour - 12.0) / 24.0
    }
    
    static func calculatePlanetPosition(julianDay: Double, planet: Int32) -> (longitude: Double, isRetrograde: Bool) {
        let t = (julianDay - 2451545.0) / 36525.0
        
        switch planet {
        case SE_SUN:
            let L = 280.46646 + 36000.76983 * t + 0.0003032 * t * t
            return (longitude: L.truncatingRemainder(dividingBy: 360.0), isRetrograde: false)
            
        case SE_MOON:
            let L = 218.3164477 + 481267.88123421 * t - 0.0015786 * t * t
            return (longitude: L.truncatingRemainder(dividingBy: 360.0), isRetrograde: false)
            
        case SE_MERCURY:
            let L = 252.250906 + 149472.6746358 * t - 0.00000535 * t * t
            let retrograde = sin(L * .pi / 180) < 0.2
            return (longitude: L.truncatingRemainder(dividingBy: 360.0), isRetrograde: retrograde)
            
        case SE_VENUS:
            let L = 181.979801 + 58517.8156760 * t + 0.00000165 * t * t
            let retrograde = sin(L * .pi / 180) < 0.1
            return (longitude: L.truncatingRemainder(dividingBy: 360.0), isRetrograde: retrograde)
            
        case SE_MARS:
            let L = 355.433 + 19140.299 * t + 0.000181 * t * t
            let retrograde = sin(L * .pi / 180) < 0.15
            return (longitude: L.truncatingRemainder(dividingBy: 360.0), isRetrograde: retrograde)
            
        case SE_JUPITER:
            let L = 34.351519 + 3034.90567 * t - 0.00008501 * t * t
            let retrograde = sin(L * .pi / 180) < 0.3
            return (longitude: L.truncatingRemainder(dividingBy: 360.0), isRetrograde: retrograde)
            
        case SE_SATURN:
            let L = 50.077444 + 1222.1138488 * t + 0.00021004 * t * t
            let retrograde = sin(L * .pi / 180) < 0.35
            return (longitude: L.truncatingRemainder(dividingBy: 360.0), isRetrograde: retrograde)
            
        case SE_URANUS:
            let L = 314.055005 + 428.466669 * t + 0.000688 * t * t
            let retrograde = sin(L * .pi / 180) < 0.4
            return (longitude: L.truncatingRemainder(dividingBy: 360.0), isRetrograde: retrograde)
            
        case SE_NEPTUNE:
            let L = 304.348665 + 218.486200 * t + 0.000108 * t * t
            let retrograde = sin(L * .pi / 180) < 0.4
            return (longitude: L.truncatingRemainder(dividingBy: 360.0), isRetrograde: retrograde)
            
        case SE_PLUTO:
            let L = 238.968 + 144.96 * t
            let retrograde = sin(L * .pi / 180) < 0.45
            return (longitude: L.truncatingRemainder(dividingBy: 360.0), isRetrograde: retrograde)
            
        default:
            return (longitude: 0.0, isRetrograde: false)
        }
    }
    
    static func calculateHouses(julianDay: Double, latitude: Double, longitude: Double) -> (ascendant: Double, midheaven: Double, houses: [Double]) {
        let lst = calculateLocalSiderealTime(julianDay: julianDay, longitude: longitude)
        let ascendant = (lst * 15.0).truncatingRemainder(dividingBy: 360.0)
        let midheaven = (ascendant + 90.0).truncatingRemainder(dividingBy: 360.0)
        
        var houses: [Double] = []
        for i in 0..<12 {
            let house = (ascendant + Double(i) * 30.0).truncatingRemainder(dividingBy: 360.0)
            houses.append(house)
        }
        
        return (ascendant: ascendant, midheaven: midheaven, houses: houses)
    }
    
    private static func calculateLocalSiderealTime(julianDay: Double, longitude: Double) -> Double {
        let t = (julianDay - 2451545.0) / 36525.0
        let gmst = 280.46061837 + 360.98564736629 * (julianDay - 2451545.0) + 0.000387933 * t * t
        let lst = gmst + longitude
        return lst.truncatingRemainder(dividingBy: 360.0) / 15.0
    }
}
