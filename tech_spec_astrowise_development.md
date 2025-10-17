# 📋 Техническое задание: Продолжение разработки AstroWise iOS

## 🎯 Executive Summary

### Текущее состояние проекта
**MVP готовность**: 75%  
**Кодовая база**: Рабочий прототип с базовым функционалом  
**Основной стек**: SwiftUI, Combine, StoreKit 2, SwissEphemeris  
**Критические проблемы**: Отсутствие backend интеграции, упрощенные астрологические расчеты

### Главная цель
Довести приложение до production-ready состояния для запуска в App Store в течение 6-8 недель с фокусом на монетизацию через подписки и качественный астрологический контент.

---

## 🚀 Phase 1: Critical Path to Launch (Недели 1-2)

### 1.1 App Store Setup & Compliance ⚡ PRIORITY: CRITICAL

**To-Do List:**
- [ ] Создать App Store Connect аккаунт
- [ ] Настроить Bundle ID и сертификаты
- [ ] Создать продукты подписок в App Store Connect
  - [ ] Free tier (ID: com.astrowise.free)
  - [ ] Pro tier (ID: com.astrowise.pro.monthly)
  - [ ] Guru tier (ID: com.astrowise.guru.monthly)
- [ ] Подготовить Privacy Policy
- [ ] Создать Terms of Service
- [ ] Настроить App Store страницу
- [ ] Подготовить скриншоты (6.5", 5.5")
- [ ] Создать App Preview видео
- [ ] Написать описание приложения (RU/EN)

**Definition of Done:**
✅ App Store Connect полностью настроен  
✅ Все legal документы готовы и размещены  
✅ Продукты подписок созданы и протестированы  
✅ Страница в App Store готова к review

---

### 1.2 StoreKit 2 Integration Fix ⚡ PRIORITY: CRITICAL

**Current Issue:** Демо-режим подписок, нет реальной интеграции

**To-Do List:**
```swift
// SubscriptionManager.swift
- [ ] Реализовать загрузку продуктов из App Store Connect
- [ ] Добавить валидацию покупок
- [ ] Реализовать restore purchases
- [ ] Добавить обработку transaction updates
- [ ] Интегрировать receipt validation
- [ ] Добавить fallback для offline режима
- [ ] Реализовать grace period для expired subscriptions
```

**Code Implementation Required:**
```swift
class SubscriptionManager: ObservableObject {
    // TODO: Implement real StoreKit 2
    - [ ] loadProducts() - загрузка из App Store
    - [ ] purchase(product:) - покупка подписки
    - [ ] restorePurchases() - восстановление
    - [ ] validateReceipt() - проверка чека
    - [ ] handleTransactionUpdate() - обработка изменений
    - [ ] checkSubscriptionStatus() - проверка статуса
}
```

**Definition of Done:**
✅ Реальные продукты загружаются из App Store  
✅ Покупка работает в TestFlight  
✅ Restore purchases функционирует  
✅ Валидация чеков работает  
✅ UI обновляется при изменении статуса подписки

---

### 1.3 UI Polish & Bug Fixes ⚡ PRIORITY: HIGH

**To-Do List:**
- [ ] Исправить iOS deployment target (26.0 → 16.0)
- [ ] Добавить App Icon
- [ ] Создать Launch Screen
- [ ] Исправить локализацию (RU/EN)
- [ ] Добавить loading states везде
- [ ] Улучшить error handling UI
- [ ] Оптимизировать перерисовки View
- [ ] Добавить haptic feedback
- [ ] Исправить keyboard avoidance

**Specific Bugs to Fix:**
```
1. [ ] Поиск городов работает только для популярных
   - Добавить fallback на ручной ввод координат
   - Улучшить UX при неудачном поиске

2. [ ] Пустые транзиты в гороскопах
   - Реализовать базовые транзиты
   - Добавить заглушки если нет данных

3. [ ] Статичные тексты гороскопов
   - Добавить вариативность текстов
   - Реализовать ротацию контента
```

**Definition of Done:**
✅ Приложение запускается без крашей  
✅ Все основные user flows работают  
✅ UI выглядит профессионально  
✅ Нет критических багов

---

## 🔧 Phase 2: Core Improvements (Недели 3-4)

### 2.1 Astrological Calculations Enhancement 📊 PRIORITY: HIGH

**Current Issue:** Упрощенные формулы вместо полного SwissEphemeris API

**To-Do List:**
- [ ] Полная интеграция SwissEphemeris C library
- [ ] Реализовать Placidus house system
- [ ] Добавить расчет минорных аспектов
- [ ] Улучшить точность расчета Асцендента
- [ ] Добавить расчет арабских частей
- [ ] Реализовать прогрессии и дирекции

**Technical Implementation:**
```swift
// AstrologyService.swift improvements
- [ ] Создать Swift-C bridge для ephemeris
- [ ] Кэшировать ephemeris файлы локально
- [ ] Добавить background расчеты
- [ ] Оптимизировать производительность
```

**Definition of Done:**
✅ Точность расчетов соответствует профессиональным стандартам  
✅ Поддержка всех основных house systems  
✅ Расчеты выполняются быстро (<1 сек)  
✅ Unit тесты для всех расчетов

---

### 2.2 Chart Visualization 📈 PRIORITY: HIGH

**Current Issue:** Нет визуальной натальной карты

**To-Do List:**
- [ ] Создать круговую диаграмму натальной карты
- [ ] Реализовать отображение планет
- [ ] Добавить линии аспектов
- [ ] Показать дома и знаки
- [ ] Добавить интерактивность (zoom, tap)
- [ ] Экспорт карты как изображение

**SwiftUI Implementation:**
```swift
struct NatalChartView: View {
    // TODO: Implement
    - [ ] ChartWheel component
    - [ ] PlanetLayer
    - [ ] AspectLines
    - [ ] HouseNumbers
    - [ ] ZodiacWheel
    - [ ] Interactive gestures
}
```

**Libraries to Consider:**
- Swift Charts (Apple) - для базовой графики
- Core Graphics - для custom drawing
- SwiftUI Canvas - для отрисовки

**Definition of Done:**
✅ Карта отображается корректно  
✅ Все элементы видны и читаемы  
✅ Поддержка Light/Dark mode  
✅ Smooth animations  
✅ Экспорт в Photos

---

### 2.3 Content & Interpretations 📝 PRIORITY: MEDIUM

**Current Issue:** Mock тексты, нет персонализации

**To-Do List:**
- [ ] База данных интерпретаций (500+ текстов)
- [ ] Алгоритм комбинирования интерпретаций
- [ ] Персонализация по натальной карте
- [ ] Динамические ежедневные гороскопы
- [ ] AI-генерация уникальных текстов (опционально)

**Content Structure:**
```yaml
Interpretations needed:
- Planets in signs: 10 × 12 = 120 texts
- Planets in houses: 10 × 12 = 120 texts  
- Major aspects: 5 × 45 = 225 texts
- Daily horoscopes: 12 × 30 = 360 texts
- Compatibility: 144 базовых комбинаций
```

**Definition of Done:**
✅ Минимум 500 уникальных текстов  
✅ Тексты профессионального качества  
✅ Система комбинирования работает  
✅ Нет повторяющегося контента

---

## ☁️ Phase 3: Backend Integration (Недели 5-6)

### 3.1 Firebase Setup 🔥 PRIORITY: HIGH

**To-Do List:**
- [ ] Создать Firebase проект
- [ ] Настроить Authentication
  - [ ] Email/Password
  - [ ] Apple Sign In
  - [ ] Anonymous auth
- [ ] Firestore структура данных
- [ ] Security Rules
- [ ] Cloud Functions для бизнес-логики
- [ ] Storage для медиа файлов

**Data Structure Design:**
```typescript
// Firestore collections
users/
  userId/
    - email
    - createdAt
    - subscription
    - birthData (encrypted)
    
birthCharts/
  userId/
    - chartData
    - calculatedAt
    - interpretations
    
horoscopes/
  date/
    sign/
      - dailyText
      - luckyNumbers
      - compatibility
```

**Definition of Done:**
✅ Firebase проект создан и настроен  
✅ Auth работает со всеми провайдерами  
✅ Данные сохраняются в Firestore  
✅ Security rules протестированы  
✅ Backup стратегия определена

---

### 3.2 Sync & Offline Mode 🔄 PRIORITY: MEDIUM

**To-Do List:**
- [ ] Offline-first архитектура
- [ ] Синхронизация с Firebase
- [ ] Conflict resolution
- [ ] Background sync
- [ ] Cache management

**Implementation:**
```swift
class DataRepository {
    // TODO: Implement
    - [ ] Local cache (Core Data)
    - [ ] Remote sync (Firebase)
    - [ ] Conflict resolution
    - [ ] Retry logic
    - [ ] Queue for offline actions
}
```

**Definition of Done:**
✅ Приложение работает offline  
✅ Данные синхронизируются при подключении  
✅ Конфликты разрешаются корректно  
✅ Нет потери данных

---

## 🚦 Phase 4: Growth Features (Недели 7-8)

### 4.1 Social Features 👥 PRIORITY: MEDIUM

**To-Do List:**
- [ ] QR код для добавления друзей
- [ ] Расчет совместимости
- [ ] Сравнение натальных карт
- [ ] Sharing механизмы
- [ ] Уведомления о друзьях

**Technical Requirements:**
```swift
// Social features
- [ ] QR generation/scanning
- [ ] Friend requests system
- [ ] Compatibility calculator
- [ ] Chart comparison view
- [ ] Activity feed
```

**Definition of Done:**
✅ Можно добавлять друзей через QR  
✅ Совместимость рассчитывается корректно  
✅ UI для сравнения карт работает  
✅ Privacy соблюдается

---

### 4.2 Meditation & Audio 🧘 PRIORITY: LOW

**To-Do List:**
- [ ] Интеграция AVAudioPlayer
- [ ] Загрузка аудио из Firebase Storage
- [ ] Background playback
- [ ] Meditation timer
- [ ] Progress tracking

**Definition of Done:**
✅ Аудио воспроизводится без проблем  
✅ Background mode работает  
✅ Прогресс сохраняется  
✅ UI интуитивен

---

### 4.3 Push Notifications 🔔 PRIORITY: MEDIUM

**To-Do List:**
- [ ] OneSignal интеграция
- [ ] Notification permissions
- [ ] Daily horoscope notifications
- [ ] Transit alerts
- [ ] Friend activity notifications

**Definition of Done:**
✅ Уведомления доставляются  
✅ Можно настроить предпочтения  
✅ Deep links работают  
✅ Не спамим пользователей

---

## 📊 Success Metrics & KPIs

### Launch Criteria (Minimum Viable Product)
- ✅ Приложение не крашится
- ✅ Подписки работают и оплачиваются  
- ✅ Базовые функции доступны
- ✅ App Store Review пройден
- ✅ Минимум 100 beta тестеров

### Target Metrics (First Month)
- 📈 1,000+ downloads
- 💳 5% conversion to paid
- ⭐ 4.0+ App Store rating
- 🔄 40% D7 retention
- 💰 $1,000+ MRR

---

## 🛠 Development Workflow

### Daily Tasks Priority
1. **Morning**: Критические баги
2. **Day**: Новые функции по плану
3. **Evening**: Тестирование и документация

### Code Review Checklist
- [ ] Нет force unwrap (!)
- [ ] Memory leaks проверены
- [ ] @StateObject vs @ObservedObject корректны
- [ ] Async/await правильно используется
- [ ] Localization keys добавлены
- [ ] Accessibility labels установлены

### Testing Strategy
```yaml
Unit Tests:
  - Astrological calculations
  - Data models
  - Business logic
  
UI Tests:
  - Onboarding flow
  - Purchase flow
  - Main user journeys
  
Manual Testing:
  - Device compatibility (iPhone SE - iPhone 15 Pro Max)
  - iOS versions (16.0+)
  - Network conditions
  - Subscription scenarios
```

---

## 🚨 Risk Mitigation

### Technical Risks
| Risk | Impact | Mitigation |
|------|--------|------------|
| App Store Rejection | HIGH | Review guidelines, test thoroughly |
| Payment Issues | HIGH | Implement fallbacks, test edge cases |
| Performance Problems | MEDIUM | Profile regularly, optimize |
| Data Loss | HIGH | Regular backups, testing |

### Business Risks
| Risk | Impact | Mitigation |
|------|--------|------------|
| Low Conversion | HIGH | A/B test pricing, improve onboarding |
| Poor Retention | HIGH | Improve content, add features |
| Negative Reviews | MEDIUM | Quick support, regular updates |

---

## 📅 Timeline & Milestones

### Week 1-2: Foundation
- ✓ Fix critical bugs
- ✓ StoreKit integration
- ✓ App Store setup

### Week 3-4: Core Features  
- ✓ Improve calculations
- ✓ Add chart visualization
- ✓ Content enhancement

### Week 5-6: Backend
- ✓ Firebase integration
- ✓ User authentication
- ✓ Data sync

### Week 7-8: Polish
- ✓ Final testing
- ✓ Performance optimization
- ✓ App Store submission

---

## 🎯 Definition of Done (Overall Project)

### Functional Requirements ✅
- [ ] All user stories implemented
- [ ] No critical bugs
- [ ] Performance acceptable (<3s load)
- [ ] Offline mode works
- [ ] Subscriptions process payments

### Non-Functional Requirements ✅
- [ ] Code coverage >60%
- [ ] Documentation complete
- [ ] Accessibility WCAG 2.1 AA
- [ ] Localization RU/EN
- [ ] Privacy compliant

### Business Requirements ✅
- [ ] App Store approved
- [ ] Analytics integrated
- [ ] Support system ready
- [ ] Marketing materials prepared
- [ ] Legal documents published

---

## 🔥 Quick Start for Development

### Immediate Next Steps (Today)
```bash
# 1. Fix deployment target
sed -i '' 's/IPHONEOS_DEPLOYMENT_TARGET = 26.0/IPHONEOS_DEPLOYMENT_TARGET = 16.0/g' Astrolog.xcodeproj/project.pbxproj

# 2. Create App Store Connect products
open https://appstoreconnect.apple.com

# 3. Start fixing critical bugs
git checkout -b fix/critical-bugs

# 4. Test on real device
xcodebuild -scheme Astrolog -destination 'platform=iOS' test
```

### Daily Development Routine
1. Check crash reports
2. Fix 1-2 critical bugs  
3. Implement 1 feature
4. Write/update tests
5. Test on device
6. Commit with clear message

---

## 📞 Support & Resources

### Key Resources
- [App Store Review Guidelines](https://developer.apple.com/app-store/review/guidelines/)
- [StoreKit 2 Documentation](https://developer.apple.com/storekit/)
- [Firebase iOS Setup](https://firebase.google.com/docs/ios/setup)
- [SwissEphemeris Documentation](http://www.astro.com/swisseph/)

### When Stuck
1. Check Apple Developer Forums
2. Review similar apps
3. Simplify the feature
4. Add to backlog if not critical

---

## ✅ Success Criteria

**Приложение готово к запуску когда:**
1. Все критические функции работают
2. Подписки обрабатываются корректно
3. Нет крашей на основных устройствах
4. App Store Review guidelines соблюдены
5. Минимум 50 beta тестеров дали позитивный фидбек

**Приоритет**: Лучше запустить с меньшим функционалом, но стабильное приложение, чем пытаться сделать все сразу.

---

*Последнее обновление: Октябрь 2025*
*Версия документа: 1.0*
