# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**AstroWise** is an iOS astrology application built with Swift and SwiftUI, targeting iOS 16.0+. The app provides birth chart calculations, daily forecasts, social compatibility features, meditation library, and subscription-based monetization.

## Architecture

### Core Design Patterns
- **MVVM**: View-to-ViewModel binding with ObservableObject
- **Coordinator Pattern**: Navigation handled by dedicated coordinators
- **Repository Pattern**: Data access abstraction layer
- **Dependency Injection**: Mandatory for all services
- **Stateless Views**: All state managed in ViewModels

### Project Structure
```
├── App/                    # Application entry point, main coordinator
├── Core/                   # Business logic, models, services, themes
│   ├── Models/            # Data models (BirthChart, User, etc.)
│   ├── Services/          # Business services (SwissEphemeris, Subscription)
│   ├── Components/        # Reusable UI components
│   └── Theme/             # Cosmic theme and view modifiers
├── Features/              # Feature-based modules
│   ├── Onboarding/        # User onboarding flow
│   ├── Chart/             # Birth chart display and calculation
│   ├── Profile/           # User profile and settings
│   ├── Main/              # Home/today view
│   └── Subscription/      # Premium features management
├── AstrologTests/         # Unit tests
└── AstrologUITests/       # UI automation tests
```

## Development Commands

### Building and Running
```bash
# Build the project
xcodebuild -project Astrolog.xcodeproj -scheme Astrolog -configuration Debug build

# Run tests
xcodebuild -project Astrolog.xcodeproj -scheme Astrolog -destination 'platform=iOS Simulator,name=iPhone 15' test

# Run specific test
xcodebuild -project Astrolog.xcodeproj -scheme Astrolog -destination 'platform=iOS Simulator,name=iPhone 15' -only-testing:AstrologTests/TestClassName/testMethodName test
```

### Opening in Xcode
```bash
open Astrolog.xcodeproj
```

### SwiftLint (if configured)
```bash
swiftlint lint
swiftlint --fix
```

## Key Dependencies

### Core Libraries
- **SwissEphemeris**: Swiss Ephemeris C library (v0.0.99) for precise astrology calculations
- **SwiftUI/UIKit**: Native iOS UI frameworks
- **Combine**: Reactive programming for data binding
- **Foundation**: Core iOS framework

### Planned Integrations
- **Charts**: Apple Charts framework for data visualization
- **Lottie**: Vector animations for enhanced UI
- **Core Data + CloudKit**: Local storage with iCloud sync
- **RevenueCat/StoreKit 2**: Subscription management
- **OneSignal/FCM**: Push notifications

## Astrology Calculation Flow

1. **Primary**: SwissEphemeris library via bridging header
2. **Fallback**: AstrologyAPI for cloud-based calculations
3. **Mock**: Enhanced mock service for development/testing

The `AstrologyServiceProtocol` abstracts the calculation backend, allowing seamless switching between implementations.

## Navigation Architecture

- `AppCoordinator`: Main app flow coordinator (onboarding → main → subscription)
- `OnboardingCoordinator`: Handles user setup flow
- All navigation state managed through `@Published` properties
- Deep linking support for notifications and social features

## Code Style Guidelines

- **Naming**: camelCase for variables/methods, PascalCase for types
- **Localization**: No hardcoded strings; use `.lproj` files (en/ru/es)
- **SwiftLint**: Strict mode compliance required
- **Documentation**: Update CHANGELOG.md for public API changes

## Testing Strategy

- **Unit Tests**: All service layer logic in `AstrologTests/`
- **UI Tests**: User flow validation in `AstrologUITests/`
- **Required**: All tests must pass before commits
- **Architecture**: Test ViewModels and Services, not Views directly

## Security Requirements

- **Birth Data**: Encrypted on-device and in cloud storage
- **Secrets**: Keychain storage for credentials, .env for development keys
- **API**: SSL pinning for all network endpoints
- **Privacy**: Full iOS privacy compliance (location, notifications)

## Development Workflows

### Feature Development
1. Draft user flow documentation
2. Create feature module in `Features/`
3. Implement MVVM components (View → ViewModel → Service)
4. Add unit tests for business logic
5. Update coordinator for navigation
6. Run full test suite

### Astrology Features
- Always use SwissEphemeris as primary calculation method
- Implement AstrologyAPI fallback for network-dependent features
- Mock services available for rapid prototyping
- All birth chart data must be validated and sanitized

### Release Process
- Fastlane automation for builds and screenshots
- TestFlight for beta testing
- App Store Connect for production releases
- Lokalise workflow for string localization

## Important Files
- `Core/Services/SwissEphemerisService.swift`: Primary astrology calculations
- `App/AppCoordinator.swift`: Main navigation coordinator
- `Core/Models/BirthChart.swift`: Core data model for birth charts
- Individual feature ViewModels follow naming pattern: `{Feature}ViewModel.swift`

## Development Notes
- Minimum iOS 16.0 deployment target
- SwiftUI-first approach with UIKit bridging where needed
- Offline-first architecture with cloud sync capabilities
- Subscription tiers: Free → PRO → GURU with progressive feature unlocking