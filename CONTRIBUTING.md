# Contributing to Astrolog

Спасибо за интерес к разработке Astrolog! Этот документ поможет вам быстро начать работу над проектом.

## Table of Contents

- [Getting Started](#getting-started)
- [Project Structure](#project-structure)
- [Architecture](#architecture)
- [Development Workflow](#development-workflow)
- [Code Style](#code-style)
- [Testing](#testing)
- [Localization](#localization)
- [Security](#security)
- [Pull Request Process](#pull-request-process)

## Getting Started

### Prerequisites

- **Xcode:** 15.0+
- **iOS:** 16.0+ deployment target
- **Swift:** 5.9+
- **Firebase:** Account and project setup

### Initial Setup

1. **Clone the repository:**
```bash
git clone https://github.com/yourusername/astrolog.git
cd astrolog
```

2. **Open the project:**
```bash
open Astrolog.xcodeproj
```

3. **Configure Firebase:**
   - Download `GoogleService-Info.plist` from Firebase Console
   - Add to project root
   - **Never commit this file** (it's in `.gitignore`)

4. **Run the project:**
   - Select simulator (iPhone 15 recommended)
   - Press `Cmd + R` or click Run button

## Project Structure

```
Astrolog/
├── App/                        # Application entry point
│   ├── AstrologApp.swift      # Main app struct
│   ├── AppCoordinator.swift   # Navigation coordinator
│   └── ContentView.swift      # Root view
│
├── Core/                       # Core business logic
│   ├── Models/                # Data models
│   │   ├── User.swift
│   │   ├── BirthChart.swift
│   │   └── ...
│   │
│   ├── Services/              # Business services
│   │   ├── FirebaseService.swift
│   │   ├── SwissEphemerisService.swift
│   │   ├── SecureStorageService.swift
│   │   ├── KeychainService.swift
│   │   └── SSLPinningService.swift
│   │
│   ├── Components/            # Reusable UI components
│   │   ├── CosmicButton.swift
│   │   ├── CosmicCard.swift
│   │   ├── LanguagePickerView.swift
│   │   └── ...
│   │
│   ├── Theme/                 # Cosmic design system
│   │   ├── CosmicColors.swift
│   │   ├── CosmicTypography.swift
│   │   └── CosmicSpacing.swift
│   │
│   └── Localization/          # Internationalization
│       └── LocalizationManager.swift
│
├── Features/                   # Feature modules (MVVM)
│   ├── Auth/                  # Authentication
│   │   ├── AuthView.swift
│   │   ├── AuthViewModel.swift
│   │   └── ...
│   │
│   ├── Chart/                 # Birth chart display
│   │   ├── ChartView.swift
│   │   ├── ChartViewModel.swift
│   │   └── Components/
│   │
│   ├── Profile/               # User profile
│   │   ├── ProfileView.swift
│   │   ├── ProfileViewModel.swift
│   │   └── ...
│   │
│   └── ...                    # Other features
│
├── AstrologTests/             # Unit & Integration tests
│   ├── Services/
│   ├── ViewModels/
│   ├── Integration/
│   └── Localization/
│
└── AstrologUITests/           # UI automation tests
    ├── OnboardingUITests.swift
    ├── AuthUITests.swift
    └── BirthChartUITests.swift
```

## Architecture

### MVVM Pattern

We use **Model-View-ViewModel** architecture:

```swift
// Model (Core/Models/)
struct BirthChart: Codable {
    let id: String
    let planets: [Planet]
    let houses: [House]
}

// ViewModel (Features/*/ViewModel.swift)
@MainActor
final class ChartViewModel: ObservableObject {
    @Published var chart: BirthChart?
    @Published var isLoading = false

    private let astrologyService: AstrologyServiceProtocol

    func loadChart() async { ... }
}

// View (Features/*/View.swift)
struct ChartView: View {
    @StateObject private var viewModel = ChartViewModel()

    var body: some View {
        if viewModel.isLoading {
            ProgressView()
        } else if let chart = viewModel.chart {
            ChartDisplayView(chart: chart)
        }
    }
}
```

### Coordinator Pattern

Navigation is handled by coordinators:

```swift
@MainActor
final class AppCoordinator: ObservableObject {
    @Published var currentFlow: AppFlow = .onboarding

    func showAuth() {
        currentFlow = .auth
    }

    func completeAuth() {
        currentFlow = .main
    }
}
```

### Dependency Injection

All services use dependency injection:

```swift
// Default dependency
init(firebaseService: FirebaseService = .shared) { ... }

// Test dependency
let viewModel = AuthViewModel(firebaseService: MockFirebaseService())
```

## Development Workflow

### Feature Development

1. **Create feature branch:**
```bash
git checkout -b feature/user-profile-settings
```

2. **Develop feature:**
   - Follow MVVM pattern
   - Add unit tests
   - Update localization if needed
   - Test on simulator and device

3. **Run tests:**
```bash
xcodebuild test \
  -project Astrolog.xcodeproj \
  -scheme Astrolog \
  -destination 'platform=iOS Simulator,name=iPhone 15'
```

4. **Commit changes:**
```bash
git add .
git commit -m "feat: Add user profile settings screen"
```

5. **Push and create PR:**
```bash
git push origin feature/user-profile-settings
```

### Commit Message Format

Use [Conventional Commits](https://www.conventionalcommits.org/):

```
feat: Add new feature
fix: Fix bug
docs: Update documentation
style: Format code
refactor: Refactor code
test: Add tests
chore: Update build configuration
```

Examples:
```
feat: Add birth chart sharing functionality
fix: Correct planet position calculation
docs: Update CONTRIBUTING.md with architecture details
test: Add unit tests for SecureStorageService
```

## Code Style

### Swift Style Guide

Follow the [Swift API Design Guidelines](https://swift.org/documentation/api-design-guidelines/).

### Key Conventions

**Naming:**
```swift
// Types: PascalCase
class AuthViewModel { }
struct BirthData { }

// Properties/Methods: camelCase
var birthDate: Date
func calculateChart() { }

// Constants: camelCase
let apiBaseURL = "https://api.example.com"
```

**Spacing:**
```swift
// ✅ Good
func calculate(value: Double) -> Double {
    return value * 2
}

// ❌ Bad
func calculate( value: Double )->Double{
    return value*2
}
```

**SwiftUI:**
```swift
// Prefer @StateObject for ownership
@StateObject private var viewModel = ChartViewModel()

// Use @ObservedObject for passed objects
@ObservedObject var coordinator: AppCoordinator

// Keep views small and composable
var body: some View {
    VStack {
        headerView
        contentView
        footerView
    }
}

private var headerView: some View { ... }
private var contentView: some View { ... }
```

### SwiftLint

Run SwiftLint before committing:

```bash
swiftlint lint
swiftlint --fix  # Auto-fix issues
```

## Testing

### Test Structure

```
AstrologTests/
├── Services/              # Service layer tests
├── ViewModels/            # ViewModel tests
├── Integration/           # Integration tests
└── Localization/          # Localization tests
```

### Writing Tests

**Unit Test Example:**

```swift
import Testing
@testable import Astrolog

@Suite("SecureStorageService Tests")
struct SecureStorageServiceTests {

    @Test("Encrypt and decrypt birth data")
    func testEncryptDecrypt() throws {
        let service = SecureStorageService.shared
        let birthData = BirthData(...)

        // Store
        try service.storeBirthData(birthData)

        // Retrieve
        let retrieved = try service.retrieveBirthData()

        #expect(retrieved.date == birthData.date)
        #expect(retrieved.latitude == birthData.latitude)
    }
}
```

**UI Test Example:**

```swift
import XCTest

final class AuthUITests: XCTestCase {

    func testLoginFlow() {
        let app = XCUIApplication()
        app.launch()

        app.textFields["Email"].tap()
        app.textFields["Email"].typeText("test@example.com")

        app.secureTextFields.element.tap()
        app.secureTextFields.element.typeText("password123")

        app.buttons["Войти"].tap()

        XCTAssertTrue(app.tabBars.firstMatch.waitForExistence(timeout: 5))
    }
}
```

### Running Tests

```bash
# All tests
xcodebuild test -project Astrolog.xcodeproj -scheme Astrolog -destination 'platform=iOS Simulator,name=iPhone 15'

# Unit tests only
xcodebuild test -only-testing:AstrologTests

# Specific test suite
xcodebuild test -only-testing:AstrologTests/SecureStorageServiceTests

# UI tests only
xcodebuild test -only-testing:AstrologUITests
```

### Code Coverage

Enable code coverage in Xcode:
1. Edit Scheme → Test → Options
2. Check "Code Coverage"
3. Run tests
4. View coverage: Report Navigator → Coverage tab

Target: **70%+ coverage** for new code

## Localization

### Adding New Strings

1. **Add key to LocalizationKey enum:**

```swift
// Core/Localization/LocalizationManager.swift
enum LocalizationKey: String {
    case profileTitle = "profile.title"
    // ...
}
```

2. **Add translations to .strings files:**

```swift
// en.lproj/Localizable.strings
"profile.title" = "Profile";

// ru.lproj/Localizable.strings
"profile.title" = "Профиль";
```

3. **Use in code:**

```swift
// SwiftUI
Text(.profileTitle)

// String
let title = String(.profileTitle)
```

### Adding New Language

1. Create `{lang}.lproj/Localizable.strings`
2. Copy structure from `en.lproj/Localizable.strings`
3. Translate all strings
4. Add case to `AppLanguage` enum
5. Update `LanguagePickerView` if needed

See [Localization Tests](/AstrologTests/Localization/LocalizationTests.swift) for validation.

## Security

### Best Practices

**Sensitive Data:**
```swift
// ✅ Use SecureStorageService for birth data
try secureStorage.storeBirthData(birthData)

// ✅ Use KeychainService for API keys
try keychainService.store(apiKey, for: .astrologyAPI)

// ❌ Never store in UserDefaults
UserDefaults.standard.set(birthData, forKey: "birth_data")  // WRONG!
```

**API Keys:**
- Store in Keychain via `KeychainService`
- Use `.env` file for development (git-ignored)
- Never hardcode in source files

**Network Security:**
- SSL Pinning enabled via `SSLPinningService`
- Certificate hashes configured for production
- HTTPS only

**Privacy:**
- Privacy Manifest (`PrivacyInfo.xcprivacy`) describes all data collection
- No tracking enabled
- User consent required for notifications

### Security Checklist

- [ ] Encrypt all birth data with AES-GCM
- [ ] Store API keys in Keychain
- [ ] Use SSL pinning for all network requests
- [ ] Validate all user inputs
- [ ] Sanitize data before storage
- [ ] Request permissions before accessing sensitive data
- [ ] Update Privacy Manifest when adding new data collection

## Pull Request Process

### Before Submitting

1. **Run tests:**
```bash
xcodebuild test -project Astrolog.xcodeproj -scheme Astrolog -destination 'platform=iOS Simulator,name=iPhone 15'
```

2. **Run SwiftLint:**
```bash
swiftlint lint
```

3. **Update documentation:**
   - Update `README.md` if needed
   - Update `CHANGELOG.md`
   - Add comments to complex code

4. **Verify localization:**
   - Test in English and Russian
   - Add new localization keys

### PR Template

```markdown
## Description
Brief description of changes

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Breaking change
- [ ] Documentation update

## Checklist
- [ ] Tests added/updated
- [ ] Localization updated
- [ ] Documentation updated
- [ ] SwiftLint passing
- [ ] Code reviewed

## Screenshots (if UI changes)
[Add screenshots here]
```

### Review Process

1. Create PR with clear description
2. Request review from maintainers
3. Address review comments
4. Ensure CI passes
5. Merge when approved

## Resources

### Documentation

- [Swift Documentation](https://swift.org/documentation/)
- [SwiftUI Tutorials](https://developer.apple.com/tutorials/swiftui)
- [Firebase iOS Guide](https://firebase.google.com/docs/ios/setup)
- [Swiss Ephemeris Documentation](https://www.astro.com/swisseph/swephprg.htm)

### Project Documentation

- [MVP Progress](/MVP_PROGRESS.md) - Development progress tracking
- [Swiss Ephemeris Integration](/SWISS_EPHEMERIS_INTEGRATION.md) - Ephemeris setup guide
- [Ephemeris Status](/EPHEMERIS_STATUS.md) - Current ephemeris implementation status
- [Google Sign In Setup](/Features/Auth/GOOGLE_SIGNIN_SETUP.md) - Google OAuth setup
- [Test Suite README](/AstrologTests/README.md) - Testing guide

### Code Examples

- **Authentication:** `/Features/Auth/AuthView.swift`
- **Chart Display:** `/Features/Chart/ChartView.swift`
- **Cosmic Components:** `/Core/Components/`
- **Services:** `/Core/Services/`

## Questions?

- Open an issue on GitHub
- Check existing documentation
- Review code examples in the project

Thank you for contributing to Astrolog! 🌟
