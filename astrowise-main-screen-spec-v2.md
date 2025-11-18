# Техническое задание: Главный экран iOS приложения AstroWise

## Описание проекта

AstroWise — iOS приложение на SwiftUI для людей, интересующихся астрологией. Freemium модель (все основные функции доступны без подписки). 

**Главный экран должен СРАЗУ давать пользу:**
- ✅ Детальный персональный гороскоп
- ✅ Конкретные советы на сегодня  
- ✅ Рекомендации: что делать / чего избегать
- ✅ Описание энергий и влияния планет
- ✅ Практические подсказки для разных сфер жизни

**Ключевой принцип**: Никакой теории, никакого обучения — только практическая польза каждый день.

---

## I. Структура главного экрана (6 ключевых блоков)

### 1. ГОРОСКОП ДНЯ (Highest Priority) 

**Позиция**: Самый верх экрана, первое что видит пользователь

**Формат**: Полноценный гороскоп на 200-400 слов

**Содержание**:

```
🌟 Ваш гороскоп на 27 октября

[Персональное приветствие]
Доброе утро, Анна! Сегодня особенный день для вас.

[Общее описание энергии дня - 2-3 абзаца]
Венера в вашем 7-м доме создает благоприятную атмосферу 
для отношений. Это отличное время, чтобы провести вечер 
с любимым человеком или наладить контакт с кем-то важным. 
Вы будете чувствовать себя особенно привлекательно и 
харизматично.

Марс поддерживает ваши карьерные амбиции. Если вы давно 
думали о разговоре с руководством или о запуске нового 
проекта — действуйте сегодня. Энергия на вашей стороне.

[По сферам жизни]

💼 Карьера и финансы
Сегодня отличный день для переговоров и важных встреч. 
Ваши идеи будут услышаны. Избегайте импульсивных финансовых 
решений после 18:00.

❤️ Любовь и отношения  
Романтическая энергия на пике. Идеально для свидания или 
откровенного разговора. Партнер будет особенно внимателен 
к вашим словам.

⚡ Энергия и самочувствие
Высокий уровень энергии до обеда. Планируйте важные дела 
на первую половину дня. Вечером позвольте себе отдохнуть.

👥 Друзья и социум
Хороший день для знакомств. Кто-то из старых друзей может 
выйти на связь. Будьте открыты новым предложениям.

[Конкретные советы]
✨ Что делать сегодня:
• Назначьте важную встречу на утро
• Проведите время с партнером вечером  
• Займитесь творческим проектом
• Позвоните старому другу

⚠️ Чего избегать:
• Импульсивных покупок после 18:00
• Конфликтов с коллегами
• Серьезных финансовых решений в спешке

[Счастливые часы]
⏰ Лучшее время дня: 09:00-12:00, 19:00-21:00
🍀 Счастливые цвета: Зеленый, Золотой
🔢 Счастливое число: 7
```

**Персонализация**:
- На основе полной натальной карты (не только Солнце)
- Учитывает текущие транзиты планет
- Анализирует аспекты к натальной карте
- Адаптируется под часовой пояс пользователя

**Обновление**: Ежедневно в 00:01 по локальному времени

**Технические требования**:
- Минимум 200 слов, максимум 400 слов
- Structured content: секции четко разделены
- Удобочитаемый шрифт: 17pt для основного текста
- Возможность расшарить гороскоп (screenshot или текст)

---

### 2. КЛЮЧЕВЫЕ ЭНЕРГИИ СЕГОДНЯ (High Priority)

**Позиция**: Сразу после гороскопа

**Формат**: Horizontal scroll с 3-5 карточками энергий

**Типы карточек**:

#### A. Карточка планетарного влияния
```
🔴 Марс в действии
───────────────────
Сильная энергия для действий
и принятия решений

Влияние: До 31 октября
Сфера: Карьера, амбиции

[Подробнее →]
```

#### B. Карточка аспектов
```
💫 Венера-Юпитер
───────────────────
Гармоничный аспект приносит
удачу в отношениях

Пик: 14:00-18:00
Используй: Для важных встреч

[Подробнее →]
```

#### C. Карточка ретроградности
```
⚠️ Меркурий замедляется
───────────────────
Проверяйте детали,
перечитывайте сообщения

Начало: 5 ноября
Что делать: Резервные копии

[Подробнее →]
```

**Обновление**: Каждые 6 часов (при смене значимых аспектов)

---

### 3. ЛУННЫЙ КАЛЕНДАРЬ (High Priority)

**Позиция**: После энергий дня

**Содержание**:

```
🌗 Убывающая Луна в Деве
День 21 лунного цикла

━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📅 Рекомендации на сегодня:

✓ Завершайте начатые проекты
✓ Наводите порядок в делах и пространстве
✓ Анализируйте прошедший месяц
✓ Планируйте следующий цикл

✗ Не начинайте глобально новое
✗ Избегайте больших трат
✗ Отложите важные контракты

━━━━━━━━━━━━━━━━━━━━━━━━━━━━

⏳ До Новолуния: 5 дней 14 часов
🌑 Новолуние будет в Скорпионе
   → Время для глубоких изменений

━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🌙 Void of Course (холостой ход Луны):
Сегодня 15:30-19:00
В это время: отдыхайте, не принимайте 
важных решений

[Календарь на месяц →]
```

**Детали**:
- Визуальное изображение текущей фазы Луны
- Описание влияния знака Зодиака
- Практические рекомендации (не теория!)
- Void of Course с точным временем
- Countdown до следующей ключевой фазы

**Обновление**: В реальном времени при смене фазы/знака

---

### 4. ПЕРСОНАЛЬНЫЕ ТРАНЗИТЫ (Medium Priority)

**Позиция**: Scrollable лента

**Формат**: Список карточек с важными транзитами для пользователя

**Пример карточки**:

```
╔═══════════════════════════════════╗
║ ⚡ ВАЖНЫЙ ТРАНЗИТ                 ║
╠═══════════════════════════════════╣
║                                   ║
║ Юпитер входит в ваш 10-й дом     ║
║                                   ║
║ 📅 С 15 ноября по 20 декабря     ║
║                                   ║
║ 💼 Карьерный рост и признание    ║
║                                   ║
║ Ожидайте:                        ║
║ • Новые возможности на работе    ║
║ • Повышение или новые проекты    ║
║ • Рост профессиональной репутации║
║                                   ║
║ Что делать:                      ║
║ • Обновите резюме и портфолио    ║
║ • Заявляйте о своих достижениях  ║
║ • Не бойтесь брать большие задачи║
║                                   ║
║ [Подробный прогноз →]            ║
╚═══════════════════════════════════╝
```

**Типы транзитов**:
- Медленные планеты к натальным позициям
- Важные аспекты (соединение, оппозиция, квадрат, трин, секстиль)
- Прогрессии (для продвинутых пользователей)
- Солнечные/Лунные возвращения

**Сортировка**: По значимости и актуальности

**Обновление**: При формировании новых транзитов (обычно еженедельно)

---

### 5. СОВЕТЫ ДНЯ (Medium Priority)

**Позиция**: В ленте между транзитами

**Формат**: Чередующиеся типы карточек

#### A. Аффирмация дня
```
┌─────────────────────────────────┐
│ 💭 Настрой на день              │
├─────────────────────────────────┤
│                                 │
│ "Я открыт новым возможностям    │
│  и доверяю своей интуиции"      │
│                                 │
│ Сегодняшняя энергия поддерживает│
│ смелые решения и новые начинания│
│                                 │
│ [Сохранить] [Поделиться]        │
└─────────────────────────────────┘
```

#### B. Практический совет
```
┌─────────────────────────────────┐
│ 💡 Совет от звезд               │
├─────────────────────────────────┤
│                                 │
│ Сегодня благоприятное время     │
│ для важных переговоров          │
│                                 │
│ Лучшие часы: 10:00-13:00        │
│                                 │
│ Подготовьтесь заранее, будьте   │
│ уверены в своих аргументах      │
│                                 │
└─────────────────────────────────┘
```

#### C. Предупреждение
```
┌─────────────────────────────────┐
│ ⚠️ Будьте внимательны           │
├─────────────────────────────────┤
│                                 │
│ Меркурий образует напряженный   │
│ аспект с Сатурном               │
│                                 │
│ Возможны:                       │
│ • Задержки в коммуникации       │
│ • Технические сбои              │
│ • Недопонимания                 │
│                                 │
│ Решение: Перепроверяйте детали, │
│ делайте резервные копии         │
│                                 │
└─────────────────────────────────┘
```

**Обновление**: 2-3 раза в день в зависимости от астрологических событий

---

### 6. БЫСТРЫЕ ДЕЙСТВИЯ (Lower Priority)

**Позиция**: Фиксированная панель внизу или floating кнопки

**Формат**: 4 основных быстрых действия

```
┌────────┬────────┬────────┬────────┐
│  💕    │  ⭐    │  📅    │  🔮    │
│ Совме- │ Моя    │ Неделя │ Задать │
│ сти-   │ карта  │        │ вопрос │
│ мость  │        │        │        │
└────────┴────────┴────────┴────────┘
```

**Функции**:

1. **Совместимость** → Быстрая проверка с любым человеком
2. **Моя карта** → Переход к детальной натальной карте  
3. **Недельный прогноз** → Расширенный гороскоп на неделю
4. **Задать вопрос** → Хорарная астрология / AI-вопрос (premium)

---

## II. Визуальный дизайн и UX

### Цветовая схема

**Светлая тема**:
- Фон: #FFFFFF (чистый белый)
- Карточки: #F8F9FA (светло-серый)
- Акцент: #6C5CE7 (космический фиолетовый)
- Текст: #2D3436 (темно-серый)
- Вторичный текст: #636E72

**Темная тема**:
- Фон: #1A1D29 (глубокий темно-синий)
- Карточки: #252A3A (темно-фиолетовый)
- Акцент: #A29BFE (светло-фиолетовый)
- Текст: #FFFFFF
- Вторичный текст: #B2BAC2

### Типографика

```swift
// Заголовки
.font(.system(size: 28, weight: .bold, design: .rounded))

// Основной текст гороскопа
.font(.system(size: 17, weight: .regular, design: .default))
.lineSpacing(6)

// Заголовки карточек
.font(.system(size: 20, weight: .semibold, design: .rounded))

// Подзаголовки
.font(.system(size: 15, weight: .medium, design: .default))

// Метаинформация
.font(.system(size: 13, weight: .regular, design: .default))
```

### Spacing и Layout

```swift
// Отступы секций
VStack(spacing: 32)

// Padding карточек
.padding(20)

// Горизонтальные margins
.padding(.horizontal, 16)

// Corner radius
.cornerRadius(20) // Карточки
.cornerRadius(12) // Кнопки
```

### Анимации

```swift
// Появление карточек
.transition(.opacity.combined(with: .slide))
.animation(.spring(response: 0.6, dampingFraction: 0.8))

// Haptic feedback
let generator = UIImpactFeedbackGenerator(style: .medium)
generator.impactOccurred()

// Pull-to-refresh
.refreshable {
    await viewModel.refreshContent()
}
```

---

## III. Технические спецификации

### Архитектура

```swift
// MARK: - Main View
struct TodayView: View {
    @StateObject private var viewModel = TodayViewModel()
    @Environment(\.scenePhase) var scenePhase
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 32) {
                // 1. Гороскоп дня
                if let horoscope = viewModel.dailyHoroscope {
                    DailyHoroscopeCard(horoscope: horoscope)
                        .transition(.opacity)
                }
                
                // 2. Ключевые энергии
                if !viewModel.keyEnergies.isEmpty {
                    KeyEnergiesScroll(energies: viewModel.keyEnergies)
                }
                
                // 3. Лунный календарь
                if let moon = viewModel.moonData {
                    MoonCalendarCard(moon: moon)
                }
                
                // 4. Персональные транзиты и советы
                ForEach(viewModel.feedItems) { item in
                    FeedItemView(item: item)
                        .id(item.id)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 20)
        }
        .refreshable {
            await viewModel.refresh()
        }
        .onChange(of: scenePhase) { newPhase in
            if newPhase == .active {
                Task {
                    await viewModel.checkForUpdates()
                }
            }
        }
        .task {
            await viewModel.loadInitialData()
        }
    }
}

// MARK: - ViewModel
@MainActor
class TodayViewModel: ObservableObject {
    @Published var dailyHoroscope: DailyHoroscope?
    @Published var keyEnergies: [KeyEnergy] = []
    @Published var moonData: MoonData?
    @Published var feedItems: [FeedItem] = []
    @Published var isLoading = false
    
    private let astrologyService: AstrologyService
    private let cacheService: CacheService
    
    func loadInitialData() async {
        // Сначала загружаем из кэша
        await loadFromCache()
        
        // Затем обновляем с сервера
        await refresh()
    }
    
    func refresh() async {
        isLoading = true
        defer { isLoading = false }
        
        async let horoscope = astrologyService.fetchDailyHoroscope()
        async let energies = astrologyService.fetchKeyEnergies()
        async let moon = astrologyService.fetchMoonData()
        async let transits = astrologyService.fetchPersonalTransits()
        
        do {
            let (h, e, m, t) = try await (horoscope, energies, moon, transits)
            
            self.dailyHoroscope = h
            self.keyEnergies = e
            self.moonData = m
            self.feedItems = buildFeed(transits: t)
            
            // Сохраняем в кэш
            await cacheService.save(horoscope: h, energies: e, moon: m)
        } catch {
            // Handle error
            print("Error refreshing: \(error)")
        }
    }
    
    private func buildFeed(transits: [Transit]) -> [FeedItem] {
        var items: [FeedItem] = []
        
        // Транзиты
        items.append(contentsOf: transits.map { .transit($0) })
        
        // Советы дня (вставляем между транзитами)
        if let advice = generateDailyAdvice() {
            items.insert(.advice(advice), at: 1)
        }
        
        // Аффирмация
        if let affirmation = generateAffirmation() {
            items.insert(.affirmation(affirmation), at: 2)
        }
        
        return items
    }
}

// MARK: - Models
struct DailyHoroscope: Codable, Identifiable {
    let id: UUID
    let date: Date
    let greeting: String
    let overview: String // 2-3 абзаца
    let career: String
    let love: String
    let health: String
    let social: String
    let toDo: [String]
    let toAvoid: [String]
    let luckyHours: [TimeRange]
    let luckyColors: [String]
    let luckyNumber: Int
}

struct KeyEnergy: Codable, Identifiable {
    let id: UUID
    let type: EnergyType // planet, aspect, retrograde
    let title: String
    let description: String
    let duration: String
    let area: String
    let advice: String?
}

struct MoonData: Codable {
    let phase: MoonPhase
    let zodiacSign: ZodiacSign
    let dayOfCycle: Int
    let recommendations: [String]
    let warnings: [String]
    let voidOfCourse: TimeRange?
    let nextPhase: NextPhaseInfo
}

struct Transit: Codable, Identifiable {
    let id: UUID
    let planet: Planet
    let house: Int
    let aspect: Aspect?
    let startDate: Date
    let endDate: Date
    let title: String
    let description: String
    let expectations: [String]
    let advice: [String]
}

enum FeedItem: Identifiable {
    case transit(Transit)
    case advice(DailyAdvice)
    case affirmation(Affirmation)
    case warning(Warning)
    
    var id: UUID {
        switch self {
        case .transit(let t): return t.id
        case .advice(let a): return a.id
        case .affirmation(let a): return a.id
        case .warning(let w): return w.id
        }
    }
}
```

### Кэширование

```swift
actor CacheService {
    private let cache = NSCache<NSString, CachedData>()
    private let fileManager = FileManager.default
    private let cacheDirectory: URL
    
    init() {
        let paths = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)
        cacheDirectory = paths[0].appendingPathComponent("AstroCache")
        try? fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
    }
    
    func fetch<T: Codable>(
        key: String,
        maxAge: TimeInterval,
        loader: () async throws -> T
    ) async throws -> T {
        // 1. Проверяем memory cache
        if let cached = cache.object(forKey: key as NSString) as? CachedData,
           Date().timeIntervalSince(cached.timestamp) < maxAge {
            return try JSONDecoder().decode(T.self, from: cached.data)
        }
        
        // 2. Проверяем disk cache
        let fileURL = cacheDirectory.appendingPathComponent(key)
        if fileManager.fileExists(atPath: fileURL.path),
           let data = try? Data(contentsOf: fileURL),
           let cached = try? JSONDecoder().decode(CachedData.self, from: data),
           Date().timeIntervalSince(cached.timestamp) < maxAge {
            
            // Восстанавливаем в memory cache
            cache.setObject(cached as NSObject, forKey: key as NSString)
            return try JSONDecoder().decode(T.self, from: cached.data)
        }
        
        // 3. Загружаем свежие данные
        let freshData = try await loader()
        let encoded = try JSONEncoder().encode(freshData)
        let cached = CachedData(timestamp: Date(), data: encoded)
        
        // Сохраняем в оба кэша
        cache.setObject(cached as NSObject, forKey: key as NSString)
        try? JSONEncoder().encode(cached).write(to: fileURL)
        
        return freshData
    }
}

struct CachedData: Codable {
    let timestamp: Date
    let data: Data
}
```

### Частота обновлений

| Контент | Частота | TTL кэша | Когда обновлять |
|---------|---------|----------|-----------------|
| Ежедневный гороскоп | 1 раз в день | 24 часа | 00:01 local time |
| Ключевые энергии | Каждые 6 часов | 6 часов | При смене аспектов |
| Лунные данные | Каждые 3 часа | 3 часа | При смене фазы/знака |
| Транзиты | Еженедельно | 7 дней | При новых транзитах |
| Советы дня | Ежедневно | 24 часа | 00:01 local time |

### Background Updates

```swift
import BackgroundTasks

class BackgroundUpdateManager {
    static let shared = BackgroundUpdateManager()
    static let taskIdentifier = "com.astrowise.refresh"
    
    func registerBackgroundTask() {
        BGTaskScheduler.shared.register(
            forTaskWithIdentifier: Self.taskIdentifier,
            using: nil
        ) { task in
            self.handleBackgroundRefresh(task: task as! BGAppRefreshTask)
        }
    }
    
    func scheduleBackgroundRefresh() {
        let request = BGAppRefreshTaskRequest(identifier: Self.taskIdentifier)
        
        // Следующее обновление в полночь
        var components = Calendar.current.dateComponents([.year, .month, .day], from: Date())
        components.hour = 0
        components.minute = 1
        components.day! += 1
        
        request.earliestBeginDate = Calendar.current.date(from: components)
        
        do {
            try BGTaskScheduler.shared.submit(request)
        } catch {
            print("Could not schedule background refresh: \(error)")
        }
    }
    
    private func handleBackgroundRefresh(task: BGAppRefreshTask) {
        // Устанавливаем deadline
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        
        let operation = BlockOperation {
            // Обновляем гороскоп и кэш
            Task {
                await self.refreshHoroscope()
                
                // Отправляем push-уведомление
                self.sendDailyNotification()
                
                task.setTaskCompleted(success: true)
            }
        }
        
        task.expirationHandler = {
            queue.cancelAllOperations()
        }
        
        queue.addOperation(operation)
        
        // Планируем следующее обновление
        scheduleBackgroundRefresh()
    }
    
    private func sendDailyNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Ваш гороскоп готов ✨"
        content.body = "Узнайте, что приготовили для вас звезды сегодня"
        content.sound = .default
        
        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: nil
        )
        
        UNUserNotificationCenter.current().add(request)
    }
}
```

---

## IV. Монетизация (Freemium без ограничений)

### Free Tier (все пользователи)

✅ **Полный доступ**:
- Ежедневный детальный гороскоп
- Лунный календарь с рекомендациями
- Ключевые энергии дня
- Базовые транзиты
- Советы и аффирмации
- Быстрая совместимость (5 проверок в месяц)
- Просмотр натальной карты

### Premium ($9.99/месяц)

⭐ **Расширенный доступ**:
- Недельный прогноз (детальный на 7 дней)
- Месячный прогноз
- Неограниченная совместимость
- Детальные транзиты (с градусами и орбисами)
- История гороскопов (архив)
- Персональные push-уведомления о важных транзитах
- Экспорт карты в PDF
- Без рекламы

### Premium+ ($19.99/месяц)

🌟 **VIP-доступ**:
- Всё из Premium
- AI-астролог (10 вопросов в месяц)
- Хорарная астрология (ответы на вопросы)
- Прогрессии и дирекции
- Солнечные возвращения (годовой прогноз)
- Синастрия (детальный анализ отношений)
- Приоритетная поддержка

### Размещение Premium

**Ненавязчивый banner** в конце главного экрана:

```
╔════════════════════════════════════╗
║ ✨ Хотите больше?                  ║
║                                    ║
║ Получите недельный прогноз,        ║
║ детальные транзиты и персональные  ║
║ уведомления                        ║
║                                    ║
║ [Попробовать Premium бесплатно] →  ║
║                                    ║
║ 7 дней бесплатно, затем $9.99/мес ║
╚════════════════════════════════════╝
```

**Soft paywall** при достижении лимита:

```
╔════════════════════════════════════╗
║ Вы использовали все 5 бесплатных   ║
║ проверок совместимости в этом      ║
║ месяце                             ║
║                                    ║
║ Premium дает неограниченный доступ ║
║ ко всем проверкам совместимости    ║
║                                    ║
║ [Перейти на Premium]               ║
║ [Напомнить через неделю]           ║
╚════════════════════════════════════╝
```

---

## V. SwiftUI компоненты

### Гороскоп дня

```swift
struct DailyHoroscopeCard: View {
    let horoscope: DailyHoroscope
    @State private var isExpanded = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Заголовок
            VStack(alignment: .leading, spacing: 8) {
                Text("🌟 Ваш гороскоп на \(horoscope.date.formatted())")
                    .font(.title2.bold())
                
                Text(horoscope.greeting)
                    .font(.title3)
                    .foregroundColor(.secondary)
            }
            
            Divider()
            
            // Общий обзор
            Text(horoscope.overview)
                .font(.body)
                .lineSpacing(6)
                .fixedSize(horizontal: false, vertical: true)
            
            // По сферам
            VStack(alignment: .leading, spacing: 16) {
                SphereSection(
                    icon: "💼",
                    title: "Карьера и финансы",
                    content: horoscope.career
                )
                
                SphereSection(
                    icon: "❤️",
                    title: "Любовь и отношения",
                    content: horoscope.love
                )
                
                SphereSection(
                    icon: "⚡",
                    title: "Энергия и самочувствие",
                    content: horoscope.health
                )
                
                SphereSection(
                    icon: "👥",
                    title: "Друзья и социум",
                    content: horoscope.social
                )
            }
            
            Divider()
            
            // Что делать
            VStack(alignment: .leading, spacing: 12) {
                Text("✨ Что делать сегодня:")
                    .font(.headline)
                
                ForEach(horoscope.toDo, id: \.self) { item in
                    HStack(alignment: .top, spacing: 8) {
                        Text("•")
                        Text(item)
                    }
                }
            }
            
            // Чего избегать
            VStack(alignment: .leading, spacing: 12) {
                Text("⚠️ Чего избегать:")
                    .font(.headline)
                
                ForEach(horoscope.toAvoid, id: \.self) { item in
                    HStack(alignment: .top, spacing: 8) {
                        Text("•")
                        Text(item)
                    }
                }
            }
            
            Divider()
            
            // Счастливые элементы
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("⏰ Лучшее время:")
                    Text(horoscope.luckyHours.formatted())
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    Text("🍀 Счастливые цвета:")
                    Text(horoscope.luckyColors.joined(separator: ", "))
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    Text("🔢 Счастливое число:")
                    Text("\(horoscope.luckyNumber)")
                        .foregroundColor(.secondary)
                }
            }
            .font(.subheadline)
            
            // Кнопки действий
            HStack(spacing: 12) {
                Button(action: shareHoroscope) {
                    Label("Поделиться", systemImage: "square.and.arrow.up")
                }
                .buttonStyle(.bordered)
                
                Spacer()
                
                Button(action: saveToFavorites) {
                    Label("Сохранить", systemImage: "bookmark")
                }
                .buttonStyle(.bordered)
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.secondarySystemBackground))
                .shadow(color: .black.opacity(0.05), radius: 10)
        )
    }
    
    private func shareHoroscope() {
        // Share sheet
    }
    
    private func saveToFavorites() {
        // Save to Core Data
    }
}

struct SphereSection: View {
    let icon: String
    let title: String
    let content: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(icon)
                Text(title)
                    .font(.headline)
            }
            
            Text(content)
                .font(.body)
                .lineSpacing(4)
        }
    }
}
```

### Ключевые энергии (Horizontal Scroll)

```swift
struct KeyEnergiesScroll: View {
    let energies: [KeyEnergy]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("⚡ Ключевые энергии сегодня")
                .font(.title2.bold())
                .padding(.horizontal, 16)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(energies) { energy in
                        EnergyCard(energy: energy)
                    }
                }
                .padding(.horizontal, 16)
            }
        }
    }
}

struct EnergyCard: View {
    let energy: KeyEnergy
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Иконка и заголовок
            HStack {
                Text(energy.icon)
                    .font(.system(size: 32))
                
                VStack(alignment: .leading) {
                    Text(energy.title)
                        .font(.headline)
                    
                    Text(energy.type.displayName)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            // Описание
            Text(energy.description)
                .font(.body)
                .lineLimit(3)
                .fixedSize(horizontal: false, vertical: true)
            
            Divider()
            
            // Метаданные
            VStack(alignment: .leading, spacing: 4) {
                Label(energy.duration, systemImage: "clock")
                    .font(.caption)
                
                Label(energy.area, systemImage: "star")
                    .font(.caption)
            }
            .foregroundColor(.secondary)
            
            // CTA
            Button(action: {}) {
                HStack {
                    Text("Подробнее")
                    Image(systemName: "arrow.right")
                }
                .font(.subheadline.bold())
            }
            .buttonStyle(.borderless)
        }
        .frame(width: 280)
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.tertiarySystemBackground))
                .shadow(color: .black.opacity(0.05), radius: 5)
        )
    }
}
```

### Лунный календарь

```swift
struct MoonCalendarCard: View {
    let moon: MoonData
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Заголовок с фазой
            HStack {
                Text(moon.phase.emoji)
                    .font(.system(size: 56))
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(moon.phase.name) в \(moon.zodiacSign.name)")
                        .font(.title2.bold())
                    
                    Text("День \(moon.dayOfCycle) лунного цикла")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            
            Divider()
            
            // Рекомендации
            VStack(alignment: .leading, spacing: 12) {
                Text("📅 Рекомендации на сегодня:")
                    .font(.headline)
                
                ForEach(moon.recommendations, id: \.self) { rec in
                    HStack(alignment: .top, spacing: 8) {
                        Text("✓")
                            .foregroundColor(.green)
                        Text(rec)
                    }
                }
            }
            
            // Что не делать
            if !moon.warnings.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    ForEach(moon.warnings, id: \.self) { warning in
                        HStack(alignment: .top, spacing: 8) {
                            Text("✗")
                                .foregroundColor(.red)
                            Text(warning)
                        }
                    }
                }
            }
            
            Divider()
            
            // Countdown до следующей фазы
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("⏳ До \(moon.nextPhase.name):")
                    Spacer()
                    Text(moon.nextPhase.countdown)
                        .foregroundColor(.secondary)
                }
                
                Text("🌑 \(moon.nextPhase.name) будет в \(moon.nextPhase.zodiacSign)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            // Void of Course
            if let voc = moon.voidOfCourse {
                Divider()
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("🌙 Void of Course (холостой ход Луны):")
                        .font(.subheadline.bold())
                    
                    Text("Сегодня \(voc.formatted())")
                        .foregroundColor(.orange)
                    
                    Text("В это время: отдыхайте, не принимайте важных решений")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            // Кнопка к месячному календарю
            Button(action: {}) {
                HStack {
                    Text("Календарь на месяц")
                    Spacer()
                    Image(systemName: "arrow.right")
                }
            }
            .buttonStyle(.bordered)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.purple.opacity(0.1),
                            Color.blue.opacity(0.1)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: .black.opacity(0.05), radius: 10)
        )
    }
}
```

---

## VI. Roadmap разработки

### Спринт 1: Foundation (Недели 1-2)
- [ ] Setup проекта с Clean Architecture
- [ ] Интеграция Swiss Ephemeris
- [ ] Базовые модели данных
- [ ] Onboarding с вводом данных рождения
- [ ] Расчет натальной карты

### Спринт 2: Главный контент (Недели 3-4)
- [ ] **Генерация детального ежедневного гороскопа** (приоритет!)
- [ ] Блок ключевых энергий
- [ ] Лунный календарь с расчетами
- [ ] Кэширование и offline-режим

### Спринт 3: Персонализация (Недели 5-6)
- [ ] Расчет персональных транзитов
- [ ] Система советов дня
- [ ] Аффирмации на основе карты
- [ ] Предупреждения о сложных аспектах

### Спринт 4: Дополнительные функции (Недели 7-8)
- [ ] Совместимость
- [ ] Недельный прогноз (Premium)
- [ ] Быстрые действия
- [ ] Push-уведомления

### Спринт 5: Полировка (Недели 9-10)
- [ ] UI/UX оптимизация
- [ ] Анимации и transitions
- [ ] Accessibility
- [ ] Performance tuning

### Спринт 6: Launch (Недели 11-12)
- [ ] Beta-тестирование
- [ ] Исправление багов
- [ ] App Store оптимизация
- [ ] Soft launch

---

## VII. Метрики успеха

### Engagement
- **Daily Active Users**: Цель 40%+ от всех пользователей
- **Время в приложении**: Цель 4-6 минут в день
- **Открытия гороскопа**: Цель 85%+ пользователей читают гороскоп
- **Retention D7**: Цель 45%+

### Content Quality
- **Полнота прочтения гороскопа**: Цель 70%+ дочитывают до конца
- **Sharing rate**: Цель 15% пользователей делятся гороскопом
- **Return rate**: Цель 2+ открытия приложения в день

### Monetization
- **Free-to-Premium conversion**: Цель 6-8%
- **Trial completion**: Цель 35%+ завершают trial и оплачивают
- **Monthly churn**: Цель <7%

---

## VIII. Итоговые рекомендации

### Обязательно для MVP:

1. **Детальный персонализированный гороскоп** — минимум 200 слов, по всем сферам жизни
2. **Конкретные советы** — что делать/чего избегать
3. **Лунный календарь** — с практическими рекомендациями
4. **Ключевые энергии дня** — важные планетарные влияния
5. **Персональные транзиты** — что происходит в карте пользователя

### Критически важно:

- ✅ **НИКАКОГО обучения** — только практическая польза
- ✅ **Детальный контент** — не 2 предложения, а полноценный гороскоп
- ✅ **Персонализация** — на основе полной натальной карты, не только Солнца
- ✅ **Конкретика** — точные советы, не общие фразы
- ✅ **Ежедневная ценность** — пользователь должен хотеть возвращаться каждый день

### Чего избегать:

- ❌ Теории и объяснений терминов
- ❌ Коротких гороскопов (2-3 предложения)
- ❌ Общих фраз без персонализации
- ❌ Перегрузки техническими деталями
- ❌ Образовательного контента

---

**Главный принцип**: Каждый день пользователь открывает приложение и сразу получает **конкретную пользу** — что его ждет сегодня, что делать, чего избегать, в какое время лучше действовать. Это не учебник астрологии — это **ежедневный гид по жизни на основе звезд**.
