# Swiss Ephemeris Integration Guide

## Overview

Swiss Ephemeris - это профессиональная астрономическая библиотека, используемая для точных астрологических расчетов. Она написана на C и требует специальной интеграции в Swift проект.

## Шаг 1: Загрузка Swiss Ephemeris

### Вариант A: Через SPM (рекомендуется)

Добавить в `Package.swift`:
```swift
dependencies: [
    .package(url: "https://github.com/mivion/SwissEphemeris", from: "2.10.0")
]
```

### Вариант B: Ручная интеграция

1. Скачать Swiss Ephemeris с официального сайта:
   - https://www.astro.com/swisseph/
   - Версия: 2.10.03 или новее

2. Извлечь файлы:
   - Заголовочные файлы (.h): `swephexp.h`, `sweodef.h`, `sweph.h`
   - Исходные файлы (.c): все файлы из папки `src/`

## Шаг 2: Создание структуры в проекте

```
Astrolog/
├── SwissEphemeris/
│   ├── Include/
│   │   ├── swephexp.h
│   │   ├── sweodef.h
│   │   └── sweph.h
│   ├── Source/
│   │   ├── sweph.c
│   │   ├── swephlib.c
│   │   ├── swejpl.c
│   │   ├── swemmoon.c
│   │   ├── swemplan.c
│   │   └── ... (остальные .c файлы)
│   └── Data/
│       ├── seas_18.se1   # Ephemeris data files
│       ├── semo_18.se1
│       ├── sepl_18.se1
│       └── ... (остальные .se1 файлы)
└── Astrolog-Bridging-Header.h
```

## Шаг 3: Создание Bridging Header

Создать файл `Astrolog-Bridging-Header.h`:

```objc
//
//  Astrolog-Bridging-Header.h
//  Astrolog
//

#ifndef Astrolog_Bridging_Header_h
#define Astrolog_Bridging_Header_h

#import "swephexp.h"

#endif /* Astrolog_Bridging_Header_h */
```

## Шаг 4: Настройка Build Settings в Xcode

1. Открыть проект в Xcode
2. Выбрать Target "Astrolog"
3. Build Settings → Swift Compiler - General
4. Установить "Objective-C Bridging Header":
   - `$(SRCROOT)/Astrolog/Astrolog-Bridging-Header.h`

5. Build Settings → Search Paths
6. Header Search Paths:
   - `$(SRCROOT)/Astrolog/SwissEphemeris/Include`
   - Recursive: NO

7. Library Search Paths (если используете .a библиотеку):
   - `$(SRCROOT)/Astrolog/SwissEphemeris/Lib`

## Шаг 5: Добавление Ephemeris Data Files

1. Скачать ephemeris data files:
   - https://www.astro.com/ftp/swisseph/ephe/
   - Минимум: `seas_18.se1`, `semo_18.se1`, `sepl_18.se1`
   - Рекомендуется: все файлы для диапазона 1800-2400 гг.

2. Добавить в Xcode:
   - Drag & Drop в папку `SwissEphemeris/Data`
   - Target Membership: Astrolog
   - Copy items if needed: YES

3. Настроить путь к данным в коде:
```swift
let ephePath = Bundle.main.resourcePath! + "/SwissEphemeris/Data"
swe_set_ephe_path(ephePath)
```

## Шаг 6: Создание Swift Wrapper

Создать `SwissEphemerisWrapper.swift`:

```swift
import Foundation

class SwissEphemerisWrapper {
    static let shared = SwissEphemerisWrapper()

    private init() {
        setupEphemerisPath()
    }

    private func setupEphemerisPath() {
        if let resourcePath = Bundle.main.resourcePath {
            let ephePath = resourcePath + "/Data"
            swe_set_ephe_path(ephePath)
        }
    }

    func calculatePlanetPosition(planet: Int32, julianDay: Double) -> (longitude: Double, latitude: Double, distance: Double)? {
        var result = [Double](repeating: 0, count: 6)
        var errorString = [CChar](repeating: 0, count: 256)

        let flags = SEFLG_SWIEPH | SEFLG_SPEED

        let returnCode = swe_calc_ut(
            julianDay,
            planet,
            flags,
            &result,
            &errorString
        )

        if returnCode < 0 {
            let error = String(cString: errorString)
            print("Swiss Ephemeris error: \(error)")
            return nil
        }

        return (
            longitude: result[0],
            latitude: result[1],
            distance: result[2]
        )
    }

    func calculateHouses(julianDay: Double, latitude: Double, longitude: Double) -> (cusps: [Double], ascmc: [Double])? {
        var cusps = [Double](repeating: 0, count: 13) // 12 houses + 1
        var ascmc = [Double](repeating: 0, count: 10)

        let houseSystem: Int8 = 80 // 'P' for Placidus

        let returnCode = swe_houses(
            julianDay,
            latitude,
            longitude,
            houseSystem,
            &cusps,
            &ascmc
        )

        if returnCode < 0 {
            return nil
        }

        return (cusps: Array(cusps[1...12]), ascmc: ascmc)
    }

    deinit {
        swe_close()
    }
}
```

## Шаг 7: Константы планет

```swift
extension SwissEphemerisWrapper {
    enum Planet: Int32 {
        case sun = 0        // SE_SUN
        case moon = 1       // SE_MOON
        case mercury = 2    // SE_MERCURY
        case venus = 3      // SE_VENUS
        case mars = 4       // SE_MARS
        case jupiter = 5    // SE_JUPITER
        case saturn = 6     // SE_SATURN
        case uranus = 7     // SE_URANUS
        case neptune = 8    // SE_NEPTUNE
        case pluto = 9      // SE_PLUTO
        case meanNode = 10  // SE_MEAN_NODE (North Node)
        case trueNode = 11  // SE_TRUE_NODE
        case chiron = 15    // SE_CHIRON
    }
}
```

## Шаг 8: Обновление SwissEphemerisService

Обновить `Core/Services/SwissEphemerisService.swift` для использования реального Swiss Ephemeris вместо приблизительных формул.

## Шаг 9: Тестирование

```swift
let wrapper = SwissEphemerisWrapper.shared
let julianDay = 2451545.0 // 2000-01-01 12:00 TT

if let sunPos = wrapper.calculatePlanetPosition(planet: .sun, julianDay: julianDay) {
    print("Sun longitude: \(sunPos.longitude)°")
    // Ожидаемо: ~280° (Capricorn)
}
```

## Известные проблемы

### 1. Размер приложения
Swiss Ephemeris data files занимают ~50-100 MB. Решения:
- Использовать только необходимые диапазоны дат
- On-demand download ephemeris files
- Использовать облачный API как fallback

### 2. Расчеты на фоне
Swiss Ephemeris - blocking operations. Рекомендуется:
```swift
Task.detached {
    let result = wrapper.calculatePlanetPosition(...)
    await MainActor.run {
        // Update UI
    }
}
```

### 3. Thread Safety
Swiss Ephemeris не thread-safe. Использовать serial queue:
```swift
private let ephemerisQueue = DispatchQueue(label: "com.astrolog.ephemeris")
```

## Полезные ссылки

- [Swiss Ephemeris Documentation](https://www.astro.com/swisseph/swephprg.htm)
- [Swiss Ephemeris Programmer's Manual](https://www.astro.com/swisseph/swisseph.htm)
- [Ephemeris Files](https://www.astro.com/ftp/swisseph/ephe/)
- [House Systems](https://www.astro.com/swisseph/swephprg.htm#_Toc19111265)

## Лицензия

Swiss Ephemeris доступен под двойной лицензией:
1. **GNU GPL** - для open-source проектов
2. **Swiss Ephemeris Professional License** - для коммерческих проектов (~$750 USD)

Для коммерческого использования необходимо приобрести лицензию на:
https://www.astro.com/swisseph/swephinfo_e.htm

## Альтернативы

Если интеграция Swiss Ephemeris слишком сложна:
1. **AstrologyAPI** - облачный сервис расчетов
2. **Астрологические SaaS** - готовые решения
3. **Simplified algorithms** - текущая реализация (достаточна для MVP)

## Чеклист интеграции

- [ ] Скачать Swiss Ephemeris source
- [ ] Создать структуру папок
- [ ] Добавить .h и .c файлы в проект
- [ ] Создать Bridging Header
- [ ] Настроить Build Settings
- [ ] Скачать ephemeris data files
- [ ] Добавить data files в bundle
- [ ] Создать SwissEphemerisWrapper
- [ ] Обновить SwissEphemerisService
- [ ] Написать unit tests
- [ ] Валидировать расчеты
- [ ] Проверить лицензию
