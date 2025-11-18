# Claude Code Prompt: Реализация главного экрана AstroWise

## 🎯 ЦЕЛЬ ЗАДАЧИ

Разработать функциональный главный экран (Today Tab) iOS приложения AstroWise согласно подробной технической спецификации. Экран должен предоставлять пользователю персонализированный ежедневный контент с астрологическими прогнозами, рекомендациями и практическими советами.

---

## 📋 КОНТЕКСТ ПРОЕКТА

### Текущее состояние кодовой базы

Проект AstroWise находится на стадии MVP (~75% готовности):

**Реализовано:**
- ✅ Базовая архитектура: MVVM + Coordinator
- ✅ Модели данных: `BirthChart`, `Planet`, `Aspect`, `House`, `User`
- ✅ Сервисы:
  - `SwissEphemerisService` - астрологические расчеты
  - `EnhancedMockAstrologyService` - mock данные
  - `SubscriptionManager` - управление подписками
- ✅ Onboarding flow с вводом данных рождения
- ✅ Базовый расчет натальной карты
- ✅ Tab-based навигация (5 табов)

**Текущая проблема:**
Главный экран (Today Tab) имеет только базовую структуру с минимальным функционалом. Гороскоп отображается упрощенно, отсутствуют ключевые блоки контента.

**Файлы для работы:**
- `Features/Main/TodayView.swift` - главный view (требует доработки)
- `Features/Main/TodayViewModel.swift` - ViewModel (расширить)
- `Core/Models/BirthChart.swift` - модели данных
- `Core/Services/AstrologyServiceProtocol.swift` - протокол сервиса
- `Core/Services/EnhancedMockAstrologyService.swift` - mock реализация

---

## 🎨 ТРЕБОВАНИЯ К РЕАЛИЗАЦИИ

### 1. СТРУКТУРА ГЛАВНОГО ЭКРАНА

Экран должен содержать 6 ключевых блоков в порядке приоритета:

#### 1.1 Гороскоп дня (HIGHEST PRIORITY)
**Требования:**
- Полноценный текст 200-400 слов
- Персонализация на основе полной натальной карты
- Структурированные секции:
  - Персональное приветствие
  - Общее описание энергии дня (2-3 абзаца)
  - 💼 Карьера и финансы
  - ❤️ Любовь и отношения
  - ⚡ Энергия и самочувствие
  - 👥 Друзья и социум
  - ✨ Что делать сегодня (список)
  - ⚠️ Чего избегать (список)
  - ⏰ Лучшее время дня
  - 🍀 Счастливые цвета
  - 🔢 Счастливое число

**Технические детали:**
- Минимальная высота: достаточная для 200 слов
- Шрифт: 17pt для основного текста, 20pt для заголовков
- Возможность расшарить (screenshot или текст)
- Кнопка "Подробнее" для раскрытия полного контента
- Обновление: ежедневно в 00:01 по локальному времени

#### 1.2 Ключевые энергии сегодня (HIGH PRIORITY)
**Требования:**
- Horizontal ScrollView с 3-5 карточками
- Типы карточек:
  - Планетарные влияния (🔴 Марс в действии)
  - Важные аспекты (💫 Венера-Юпитер)
  - Ретроградность (⚠️ Меркурий замедляется)
- Размер карточки: 280pt ширина
- Обновление: каждые 6 часов

#### 1.3 Лунный календарь (HIGH PRIORITY)
**Требования:**
- Большая карточка с градиентным фоном
- Визуальное изображение фазы Луны (emoji)
- Информация:
  - Текущая фаза и знак (🌗 Убывающая Луна в Деве)
  - День лунного цикла
  - Рекомендации (✓ что делать)
  - Предостережения (✗ чего избегать)
  - Countdown до следующей фазы
  - Void of Course с точным временем
- Кнопка "Календарь на месяц" (navigation)

#### 1.4 Персональные транзиты (MEDIUM PRIORITY)
**Требования:**
- Scrollable лента карточек
- Каждая карточка содержит:
  - Заголовок транзита (⚡ ВАЖНЫЙ ТРАНЗИТ)
  - Описание (Юпитер входит в ваш 10-й дом)
  - Даты действия (📅 С 15 ноября по 20 декабря)
  - Сфера влияния (💼 Карьерный рост)
  - Что ожидать (bullet points)
  - Что делать (bullet points)
  - Кнопка "Подробный прогноз"
- Сортировка по значимости

#### 1.5 Советы дня (MEDIUM PRIORITY)
**Требования:**
- Чередующиеся типы:
  - 💭 Аффирмация дня
  - 💡 Практический совет
  - 🎯 Challenge дня
- Кнопки: [Сохранить] [Поделиться]

#### 1.6 Быстрые действия (LOW PRIORITY)
**Требования:**
- Grid из 4 кнопок:
  - 🔮 Совместимость
  - 📅 Недельный прогноз
  - 🎴 Таро дня
  - 📖 Дневник
- Navigation к соответствующим экранам

---

## 🏗 АРХИТЕКТУРНЫЕ ТРЕБОВАНИЯ

### Структура кода

```
Features/Main/
├── Views/
│   ├── TodayView.swift              # Главный контейнер
│   ├── Components/
│   │   ├── HoroscopeCard.swift      # Карточка гороскопа
│   │   ├── EnergyCard.swift         # Карточка энергии
│   │   ├── MoonCalendarCard.swift   # Лунный календарь
│   │   ├── TransitCard.swift        # Карточка транзита
│   │   ├── AdviceCard.swift         # Карточка совета
│   │   └── QuickActionsGrid.swift   # Быстрые действия
├── ViewModels/
│   └── TodayViewModel.swift         # Бизнес-логика
└── Models/
    ├── DailyContent.swift           # Агрегатор контента
    ├── KeyEnergy.swift              # Модель энергии
    └── MoonData.swift               # Модель лунных данных
```

### Паттерны разработки

1. **MVVM Pattern:**
   - `TodayView` - чистый UI, никакой бизнес-логики
   - `TodayViewModel` - вся логика, асинхронные операции, state management
   - Используйте `@StateObject` для ViewModel
   - Используйте `@Published` для реактивности

2. **Dependency Injection:**
   ```swift
   class TodayViewModel: ObservableObject {
       private let astrologyService: AstrologyServiceProtocol
       
       init(astrologyService: AstrologyServiceProtocol = SwissEphemerisService()) {
           self.astrologyService = astrologyService
       }
   }
   ```

3. **Error Handling:**
   - Все async функции должны обрабатывать ошибки
   - Показывать пользователю понятные сообщения
   - Fallback на cached данные при сетевых ошибках

4. **State Management:**
   ```swift
   @Published var dailyHoroscope: DetailedHoroscope?
   @Published var keyEnergies: [KeyEnergy] = []
   @Published var moonData: MoonData?
   @Published var transits: [Transit] = []
   @Published var isLoading = false
   @Published var errorMessage: String?
   ```

---

## 📊 МОДЕЛИ ДАННЫХ

### Новые модели для создания

```swift
// Features/Main/Models/DetailedHoroscope.swift
struct DetailedHoroscope: Codable, Identifiable {
    let id: UUID
    let date: Date
    let greeting: String
    let generalForecast: String              // 2-3 параграфа
    let careerAndFinances: String
    let loveAndRelationships: String
    let healthAndEnergy: String
    let friendsAndSocial: String
    let todoList: [String]                   // Что делать
    let avoidList: [String]                  // Чего избегать
    let bestTimeRanges: [TimeRange]          // Лучшее время
    let luckyColors: [String]
    let luckyNumber: Int
}

// Features/Main/Models/KeyEnergy.swift
struct KeyEnergy: Codable, Identifiable {
    let id: UUID
    let type: EnergyType                     // planetary, aspect, retrograde
    let icon: String
    let title: String
    let description: String
    let duration: String
    let area: String                         // Сфера влияния
    let peakTime: String?
}

enum EnergyType: String, Codable {
    case planetary
    case aspect
    case retrograde
}

// Features/Main/Models/MoonData.swift
struct MoonData: Codable {
    let phase: MoonPhase
    let zodiacSign: ZodiacSign
    let dayOfCycle: Int
    let recommendations: [String]
    let warnings: [String]
    let nextPhase: NextPhaseInfo
    let voidOfCourse: TimeRange?
}

struct MoonPhase: Codable {
    let name: String                         // "Убывающая Луна"
    let emoji: String                        // "🌗"
}

struct NextPhaseInfo: Codable {
    let name: String
    let countdown: String                    // "5 дней 14 часов"
    let zodiacSign: String
    let description: String
}

struct TimeRange: Codable {
    let start: Date
    let end: Date
    
    func formatted() -> String {
        // Форматирование типа "15:30-19:00"
    }
}
```

---

## 🔧 ТЕХНИЧЕСКИЕ ДЕТАЛИ РЕАЛИЗАЦИИ

### 1. TodayViewModel - Расширенная логика

```swift
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
    
    // MARK: - Private Properties
    private let astrologyService: AstrologyServiceProtocol
    private let userService: UserServiceProtocol
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    init(
        astrologyService: AstrologyServiceProtocol = SwissEphemerisService(),
        userService: UserServiceProtocol = UserService()
    ) {
        self.astrologyService = astrologyService
        self.userService = userService
    }
    
    // MARK: - Public Methods
    func loadTodayContent() async {
        isLoading = true
        errorMessage = nil
        
        do {
            // Параллельная загрузка всех блоков
            async let horoscope = loadDetailedHoroscope()
            async let energies = loadKeyEnergies()
            async let moon = loadMoonData()
            async let transits = loadPersonalTransits()
            async let advice = loadDailyAdvice()
            
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
            
        } catch {
            self.errorMessage = "Не удалось загрузить данные: \(error.localizedDescription)"
            // Попытка загрузить из кэша
            await loadCachedContent()
        }
        
        isLoading = false
    }
    
    func refreshContent() async {
        isRefreshing = true
        await loadTodayContent()
        isRefreshing = false
    }
    
    // MARK: - Private Methods
    private func loadDetailedHoroscope() async throws -> DetailedHoroscope {
        guard let birthData = try await userService.getBirthData() else {
            throw AstrologyError.missingBirthData
        }
        
        let chart = try await astrologyService.calculateBirthChart(from: birthData)
        let currentTransits = try await astrologyService.getCurrentTransits()
        
        return try await astrologyService.generateDetailedHoroscope(
            for: chart,
            transits: currentTransits,
            date: Date()
        )
    }
    
    private func loadKeyEnergies() async throws -> [KeyEnergy] {
        // Расчет текущих планетарных энергий
        let currentAspects = try await astrologyService.getCurrentAspects()
        let retrogradePlanets = try await astrologyService.getRetrogradePlanets()
        
        var energies: [KeyEnergy] = []
        
        // Добавить планетарные влияния
        energies.append(contentsOf: calculatePlanetaryEnergies())
        
        // Добавить важные аспекты
        energies.append(contentsOf: processAspects(currentAspects))
        
        // Добавить ретроградности
        energies.append(contentsOf: processRetrogrades(retrogradePlanets))
        
        // Сортировка по значимости и актуальности
        return energies.sorted { $0.significance > $1.significance }
    }
    
    private func loadMoonData() async throws -> MoonData {
        let moonPosition = try await astrologyService.getCurrentMoonPosition()
        let moonPhase = calculateMoonPhase()
        let voidOfCourse = try await calculateVoidOfCourse()
        
        return MoonData(
            phase: moonPhase,
            zodiacSign: moonPosition.zodiacSign,
            dayOfCycle: moonPosition.dayOfCycle,
            recommendations: generateMoonRecommendations(phase: moonPhase, sign: moonPosition.zodiacSign),
            warnings: generateMoonWarnings(phase: moonPhase),
            nextPhase: calculateNextPhase(from: moonPhase),
            voidOfCourse: voidOfCourse
        )
    }
    
    private func loadPersonalTransits() async throws -> [Transit] {
        guard let birthData = try await userService.getBirthData() else {
            return []
        }
        
        let chart = try await astrologyService.calculateBirthChart(from: birthData)
        let transits = try await astrologyService.calculatePersonalTransits(for: chart)
        
        // Фильтрация только значимых транзитов
        return transits
            .filter { $0.significance >= .medium }
            .sorted { $0.significance > $1.significance }
            .prefix(10)
            .map { $0 }
    }
    
    private func loadCachedContent() async {
        // Загрузка из Core Data или UserDefaults
        // Fallback для offline режима
    }
    
    // ... дополнительные helper методы
}
```

### 2. TodayView - Главный контейнер

```swift
struct TodayView: View {
    @StateObject private var viewModel = TodayViewModel()
    @State private var showShareSheet = false
    @State private var shareContent: ShareContent?
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // 1. Гороскоп дня
                    if let horoscope = viewModel.detailedHoroscope {
                        HoroscopeCard(
                            horoscope: horoscope,
                            onShare: { content in
                                shareContent = content
                                showShareSheet = true
                            }
                        )
                    }
                    
                    // 2. Ключевые энергии
                    if !viewModel.keyEnergies.isEmpty {
                        KeyEnergiesSection(energies: viewModel.keyEnergies)
                    }
                    
                    // 3. Лунный календарь
                    if let moonData = viewModel.moonData {
                        MoonCalendarCard(moonData: moonData)
                    }
                    
                    // 4. Персональные транзиты
                    if !viewModel.personalTransits.isEmpty {
                        PersonalTransitsSection(transits: viewModel.personalTransits)
                    }
                    
                    // 5. Советы дня
                    if let advice = viewModel.dailyAdvice {
                        AdviceCard(advice: advice)
                    }
                    
                    // 6. Быстрые действия
                    QuickActionsGrid()
                    
                    Spacer(minLength: 40)
                }
                .padding(.vertical, 16)
            }
            .navigationTitle("Сегодня")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        Task {
                            await viewModel.refreshContent()
                        }
                    }) {
                        Image(systemName: "arrow.clockwise")
                    }
                }
            }
            .refreshable {
                await viewModel.refreshContent()
            }
            .overlay {
                if viewModel.isLoading && viewModel.detailedHoroscope == nil {
                    LoadingView()
                }
            }
            .alert("Ошибка", isPresented: .constant(viewModel.errorMessage != nil)) {
                Button("OK") {
                    viewModel.errorMessage = nil
                }
            } message: {
                if let error = viewModel.errorMessage {
                    Text(error)
                }
            }
            .sheet(isPresented: $showShareSheet) {
                if let content = shareContent {
                    ShareSheet(content: content)
                }
            }
            .task {
                // Загрузка при первом появлении
                if viewModel.detailedHoroscope == nil {
                    await viewModel.loadTodayContent()
                }
            }
        }
    }
}
```

### 3. UI Components - Пример HoroscopeCard

```swift
struct HoroscopeCard: View {
    let horoscope: DetailedHoroscope
    let onShare: (ShareContent) -> Void
    
    @State private var isExpanded = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Заголовок
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("🌟 Ваш гороскоп на \(horoscope.date.formatted(.dateTime.day().month()))")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text(horoscope.greeting)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Button(action: { onShare(createShareContent()) }) {
                    Image(systemName: "square.and.arrow.up")
                        .font(.title3)
                        .foregroundColor(.purple)
                }
            }
            
            Divider()
            
            // Общий прогноз
            Text(horoscope.generalForecast)
                .font(.body)
                .lineSpacing(4)
            
            // Развернутый контент
            if isExpanded {
                VStack(alignment: .leading, spacing: 20) {
                    // Секции по сферам жизни
                    LifeAreaSection(
                        icon: "💼",
                        title: "Карьера и финансы",
                        content: horoscope.careerAndFinances
                    )
                    
                    LifeAreaSection(
                        icon: "❤️",
                        title: "Любовь и отношения",
                        content: horoscope.loveAndRelationships
                    )
                    
                    LifeAreaSection(
                        icon: "⚡",
                        title: "Энергия и самочувствие",
                        content: horoscope.healthAndEnergy
                    )
                    
                    LifeAreaSection(
                        icon: "👥",
                        title: "Друзья и социум",
                        content: horoscope.friendsAndSocial
                    )
                    
                    Divider()
                    
                    // Советы и предостережения
                    AdviceSection(
                        todoList: horoscope.todoList,
                        avoidList: horoscope.avoidList
                    )
                    
                    Divider()
                    
                    // Метаданные
                    MetadataSection(
                        timeRanges: horoscope.bestTimeRanges,
                        colors: horoscope.luckyColors,
                        number: horoscope.luckyNumber
                    )
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
            
            // Кнопка раскрытия
            Button(action: {
                withAnimation(.spring()) {
                    isExpanded.toggle()
                }
            }) {
                HStack {
                    Text(isExpanded ? "Свернуть" : "Подробнее")
                        .font(.subheadline.bold())
                    
                    Spacer()
                    
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                }
                .foregroundColor(.purple)
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.08), radius: 10, y: 5)
        )
        .padding(.horizontal, 16)
    }
    
    private func createShareContent() -> ShareContent {
        ShareContent(
            text: generateShareText(),
            image: captureCardAsImage()
        )
    }
}

// Helper view для секций сфер жизни
struct LifeAreaSection: View {
    let icon: String
    let title: String
    let content: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(icon)
                    .font(.title2)
                Text(title)
                    .font(.headline)
            }
            
            Text(content)
                .font(.body)
                .foregroundColor(.secondary)
        }
    }
}

struct AdviceSection: View {
    let todoList: [String]
    let avoidList: [String]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Что делать
            VStack(alignment: .leading, spacing: 8) {
                Text("✨ Что делать сегодня:")
                    .font(.subheadline.bold())
                
                ForEach(todoList, id: \.self) { item in
                    HStack(alignment: .top, spacing: 8) {
                        Text("•")
                        Text(item)
                            .font(.subheadline)
                    }
                }
            }
            
            // Чего избегать
            VStack(alignment: .leading, spacing: 8) {
                Text("⚠️ Чего избегать:")
                    .font(.subheadline.bold())
                
                ForEach(avoidList, id: \.self) { item in
                    HStack(alignment: .top, spacing: 8) {
                        Text("•")
                        Text(item)
                            .font(.subheadline)
                    }
                }
            }
        }
    }
}

struct MetadataSection: View {
    let timeRanges: [TimeRange]
    let colors: [String]
    let number: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("⏰")
                Text("Лучшее время:")
                    .font(.subheadline)
                
                Text(formatTimeRanges(timeRanges))
                    .font(.subheadline.bold())
            }
            
            HStack {
                Text("🍀")
                Text("Счастливые цвета:")
                    .font(.subheadline)
                
                Text(colors.joined(separator: ", "))
                    .font(.subheadline.bold())
            }
            
            HStack {
                Text("🔢")
                Text("Счастливое число:")
                    .font(.subheadline)
                
                Text("\(number)")
                    .font(.subheadline.bold())
            }
        }
        .foregroundColor(.secondary)
    }
    
    private func formatTimeRanges(_ ranges: [TimeRange]) -> String {
        ranges.map { $0.formatted() }.joined(separator: ", ")
    }
}
```

---

## ⚠️ CORNER CASES И ОБРАБОТКА ОШИБОК

### 1. Отсутствие данных рождения
```swift
guard let birthData = try await userService.getBirthData() else {
    // Показать placeholder с призывом добавить данные
    showBirthDataPrompt = true
    return
}
```

### 2. Сетевые ошибки
```swift
do {
    let content = try await loadFromAPI()
    cacheContent(content)
    return content
} catch {
    // Fallback на кэшированные данные
    if let cached = loadCachedContent() {
        return cached
    }
    // Показать понятную ошибку
    throw UserFacingError.networkUnavailable
}
```

### 3. Неполные данные рождения
```swift
if !birthData.isTimeExact {
    // Показать предупреждение
    showTimeWarning = true
    // Использовать noon time для расчетов
    adjustedBirthData = birthData.withNoonTime()
}
```

### 4. Timezone issues
```swift
// Всегда учитывать локальный timezone пользователя
let localDate = Date()
let userTimeZone = birthData.timeZone
let adjustedDate = localDate.convertedTo(timeZone: userTimeZone)
```

### 5. Expired subscriptions
```swift
if !subscriptionManager.hasAccess(to: .detailedTransits) {
    // Показать locked overlay с призывом к апгрейду
    showPremiumPrompt = true
    return limitedTransits
}
```

### 6. Empty states
```swift
if viewModel.personalTransits.isEmpty {
    EmptyStateView(
        icon: "sparkles",
        title: "Нет активных транзитов",
        message: "Сейчас спокойный период. Наслаждайтесь стабильностью!"
    )
}
```

### 7. Loading states
```swift
// Показать skeleton loader во время загрузки
if viewModel.isLoading {
    HoroscopeCardSkeleton()
        .redacted(reason: .placeholder)
} else {
    HoroscopeCard(horoscope: viewModel.detailedHoroscope)
}
```

### 8. Date boundaries
```swift
// Обработка перехода через полночь
func shouldRefreshContent() -> Bool {
    guard let lastUpdate = lastContentUpdate else { return true }
    
    let calendar = Calendar.current
    return !calendar.isDate(lastUpdate, inSameDayAs: Date())
}
```

---

## 🧪 ТЕСТИРОВАНИЕ

### Unit Tests
```swift
// TodayViewModelTests.swift
@MainActor
class TodayViewModelTests: XCTestCase {
    var sut: TodayViewModel!
    var mockService: MockAstrologyService!
    
    override func setUp() async throws {
        mockService = MockAstrologyService()
        sut = TodayViewModel(astrologyService: mockService)
    }
    
    func testLoadTodayContent_Success() async throws {
        // Given
        mockService.horoscopeToReturn = .mock
        
        // When
        await sut.loadTodayContent()
        
        // Then
        XCTAssertNotNil(sut.detailedHoroscope)
        XCTAssertFalse(sut.isLoading)
        XCTAssertNil(sut.errorMessage)
    }
    
    func testLoadTodayContent_NetworkError_FallbackToCache() async throws {
        // Given
        mockService.shouldFail = true
        mockService.cachedHoroscope = .mock
        
        // When
        await sut.loadTodayContent()
        
        // Then
        XCTAssertNotNil(sut.detailedHoroscope)
        XCTAssertEqual(sut.detailedHoroscope, mockService.cachedHoroscope)
    }
    
    // ... дополнительные тесты
}
```

---

## 📝 ЧЕКЛИСТ ЗАВЕРШЕНИЯ

### Must Have (для MVP)
- [ ] Детальный гороскоп минимум 200 слов
- [ ] Персонализация на основе натальной карты
- [ ] 4 секции по сферам жизни
- [ ] Списки "что делать" и "чего избегать"
- [ ] Возможность расшарить гороскоп
- [ ] Блок ключевых энергий (3-5 карточек)
- [ ] Лунный календарь с фазой и рекомендациями
- [ ] Персональные транзиты (топ-10)
- [ ] Обработка всех error states
- [ ] Кэширование для offline режима

### Nice to Have (для следующих итераций)
- [ ] Анимации при раскрытии карточек
- [ ] Haptic feedback на действиях
- [ ] Dark mode оптимизация
- [ ] Accessibility labels
- [ ] Локализация (RU/EN)
- [ ] Analytics tracking
- [ ] Push notifications для важных транзитов
- [ ] Widget для главного экрана iOS

### Performance
- [ ] Lazy loading изображений
- [ ] Pagination для транзитов
- [ ] Debounce для refresh
- [ ] Memory leak tests
- [ ] Профилирование в Instruments

---

## 🚀 ПОЭТАПНЫЙ ПЛАН ВЫПОЛНЕНИЯ

### Фаза 1: Модели и сервисы (2-3 часа)
1. Создать модели данных:
   - `DetailedHoroscope.swift`
   - `KeyEnergy.swift`
   - `MoonData.swift`
   - `DailyAdvice.swift`

2. Расширить `AstrologyServiceProtocol`:
   ```swift
   func generateDetailedHoroscope(for chart: BirthChart, transits: [Transit], date: Date) async throws -> DetailedHoroscope
   func getCurrentAspects() async throws -> [Aspect]
   func getRetrogradePlanets() async throws -> [Planet]
   func getCurrentMoonPosition() async throws -> MoonPosition
   func calculatePersonalTransits(for chart: BirthChart) async throws -> [Transit]
   ```

3. Реализовать mock-версию в `EnhancedMockAstrologyService`

### Фаза 2: ViewModel (2-3 часа)
1. Расширить `TodayViewModel`:
   - Добавить все @Published свойства
   - Реализовать `loadTodayContent()`
   - Реализовать `loadDetailedHoroscope()`
   - Реализовать `loadKeyEnergies()`
   - Реализовать `loadMoonData()`
   - Реализовать `loadPersonalTransits()`
   - Добавить кэширование

2. Обработка ошибок и edge cases

### Фаза 3: UI Components (4-5 часов)
1. Создать `HoroscopeCard`:
   - Layout с collapsible content
   - Секции по сферам жизни
   - Советы и предостережения
   - Метаданные
   - Share functionality

2. Создать `KeyEnergiesSection`:
   - Horizontal ScrollView
   - `EnergyCard` компонент
   - Типы карточек

3. Создать `MoonCalendarCard`:
   - Фаза и знак
   - Рекомендации
   - Countdown
   - Void of Course

4. Создать `PersonalTransitsSection`:
   - `TransitCard` компонент
   - Scrollable лента

5. Создать `AdviceCard`:
   - Аффирмации
   - Практические советы
   - Challenges

6. Создать `QuickActionsGrid`

### Фаза 4: Интеграция (1-2 часа)
1. Обновить `TodayView`:
   - Добавить все компоненты
   - Настроить навигацию
   - Добавить refresh control
   - Loading states

2. Настроить navigation к другим экранам

### Фаза 5: Тестирование и полировка (2-3 часа)
1. Unit tests для ViewModel
2. UI tests для основных сценариев
3. Проверка на разных размерах экранов
4. Dark mode тестирование
5. Performance profiling

---

## 🎯 КРИТЕРИИ ПРИЕМКИ

### Функциональность
✅ Пользователь видит детальный персонализированный гороскоп (200+ слов)
✅ Гороскоп разделен на секции по сферам жизни
✅ Есть конкретные советы "что делать" и "чего избегать"
✅ Отображаются 3-5 ключевых энергий дня
✅ Лунный календарь показывает текущую фазу и рекомендации
✅ Персональные транзиты отсортированы по важности
✅ Возможность поделиться гороскопом
✅ Pull-to-refresh работает корректно

### UX
✅ Загрузка контента занимает < 3 секунд
✅ Показываются skeleton loaders во время загрузки
✅ Понятные сообщения об ошибках
✅ Graceful degradation при отсутствии сети
✅ Smooth анимации при раскрытии/сворачивании
✅ Приятный визуальный дизайн

### Технические
✅ Нет memory leaks
✅ Код следует MVVM паттерну
✅ Покрытие unit tests > 70%
✅ Нет force unwraps (!)
✅ Proper error handling
✅ Thread-safe операции

---

## 💡 ДОПОЛНИТЕЛЬНЫЕ РЕКОМЕНДАЦИИ

1. **Используй существующий код:** Не переписывай `SwissEphemerisService` с нуля - расширь его новыми методами

2. **Mock данные сначала:** Начни с mock-реализации для быстрого прототипирования UI

3. **Incremental approach:** Реализуй по одному блоку за раз, тестируй, затем переходи к следующему

4. **Reusable components:** Создавай переиспользуемые компоненты (например, `SectionHeader`, `InfoRow`)

5. **Consistent styling:** Используй единый `DesignSystem` для colors, fonts, spacing

6. **Logging:** Добавь логирование для отладки астрологических расчетов

7. **Performance:** Профилируй после каждой фазы, оптимизируй при необходимости

---

## 📞 ВОПРОСЫ ДЛЯ УТОЧНЕНИЯ

Перед началом разработки уточни:

1. Какой должен быть fallback, если SwissEphemeris недоступен?
2. Нужна ли локализация для первой версии или только RU?
3. Какие транзиты считаются "значимыми" (orb, типы аспектов)?
4. Как часто обновлять ключевые энергии (6 часов - финально)?
5. Нужны ли push-уведомления для daily refresh?

---

**Финальная инструкция для Claude Code:**

Следуй этому плану поэтапно. Начни с Фазы 1 (модели и сервисы), создай PR, дай мне на ревью. После одобрения переходи к Фазе 2. Коммить небольшими логическими частями. Если возникнут вопросы или неясности - останавливайся и задавай вопросы, не делай предположений о бизнес-логике.

При реализации астрологических расчетов консультируйся с существующим кодом `SwissEphemerisService` и `EnhancedMockAstrologyService` - там уже есть паттерны для работы с планетами, аспектами и домами.

**Начинай!** 🚀
