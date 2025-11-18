# Astrolog Test Suite

Comprehensive test coverage for the Astrolog iOS application.

## Test Structure

```
AstrologTests/
├── Services/                   # Unit tests for services
│   ├── SwissEphemerisServiceTests.swift
│   ├── SecureStorageServiceTests.swift
│   ├── KeychainServiceTests.swift
│   └── ...
├── ViewModels/                 # Unit tests for ViewModels
│   ├── AuthViewModelTests.swift
│   └── ...
├── Integration/                # Integration tests
│   ├── FirebaseIntegrationTests.swift
│   └── AstrologyServiceIntegrationTests.swift
└── README.md                   # This file

AstrologUITests/
├── OnboardingUITests.swift     # UI tests for onboarding flow
├── AuthUITests.swift           # UI tests for authentication
└── BirthChartUITests.swift     # UI tests for birth chart features
```

## Running Tests

### All Tests

```bash
xcodebuild -project Astrolog.xcodeproj \
  -scheme Astrolog \
  -destination 'platform=iOS Simulator,name=iPhone 15' \
  test
```

### Unit Tests Only

```bash
xcodebuild -project Astrolog.xcodeproj \
  -scheme Astrolog \
  -destination 'platform=iOS Simulator,name=iPhone 15' \
  -only-testing:AstrologTests \
  test
```

### UI Tests Only

```bash
xcodebuild -project Astrolog.xcodeproj \
  -scheme Astrolog \
  -destination 'platform=iOS Simulator,name=iPhone 15' \
  -only-testing:AstrologUITests \
  test
```

### Specific Test Suite

```bash
# Run only Firebase integration tests
xcodebuild -project Astrolog.xcodeproj \
  -scheme Astrolog \
  -destination 'platform=iOS Simulator,name=iPhone 15' \
  -only-testing:AstrologTests/FirebaseIntegrationTests \
  test
```

### Specific Test Method

```bash
xcodebuild -project Astrolog.xcodeproj \
  -scheme Astrolog \
  -destination 'platform=iOS Simulator,name=iPhone 15' \
  -only-testing:AstrologTests/SwissEphemerisServiceTests/testCalculateBirthChart \
  test
```

### In Xcode

1. Open `Astrolog.xcodeproj`
2. Press `Cmd + U` to run all tests
3. Or click the diamond icon next to test methods/suites to run specific tests

## Test Categories

### Unit Tests (AstrologTests/)

**Services** - Test core business logic:
- `SwissEphemerisServiceTests`: Astrology calculations
- `SecureStorageServiceTests`: Data encryption
- `KeychainServiceTests`: Secure storage
- `FirebaseServiceTests`: Firebase integration (mocked)

**ViewModels** - Test UI logic:
- `AuthViewModelTests`: Authentication validation
- `ChartViewModelTests`: Chart display logic
- `ProfileViewModelTests`: Profile management

### Integration Tests (AstrologTests/Integration/)

**Requires setup** - See setup instructions below.

- `FirebaseIntegrationTests`: Real Firebase operations
- `AstrologyServiceIntegrationTests`: End-to-end astrology calculations

### UI Tests (AstrologUITests/)

**Automated UI flows:**
- `OnboardingUITests`: User onboarding screens
- `AuthUITests`: Login/signup/password reset
- `BirthChartUITests`: Chart creation and display

## Integration Test Setup

Integration tests require additional configuration:

### Firebase Emulator (Recommended)

1. Install Firebase CLI:
```bash
npm install -g firebase-tools
```

2. Initialize Firebase in project:
```bash
cd Astrolog
firebase init emulators
# Select: Authentication, Firestore, Storage
```

3. Start emulators:
```bash
firebase emulators:start
```

4. Run tests with emulator:
```bash
# Set environment to use emulator
export FIREBASE_EMULATOR_HOST="localhost:9099"
xcodebuild test ...
```

### Firebase Test Project (Alternative)

1. Create separate Firebase project for testing
2. Download `GoogleService-Info-Test.plist`
3. Configure app to use test project in test environment
4. Run tests

## UI Test Configuration

UI tests use launch arguments to control app state:

- `--uitesting`: Enables UI testing mode
- `--reset-onboarding`: Clears onboarding completion flag
- `--start-at-auth`: Skips onboarding, starts at auth
- `--authenticated`: Mocks authenticated user
- `--no-birth-data`: Clears saved birth charts
- `--clear-keychain`: Removes keychain data

Example:
```swift
app.launchArguments = ["--uitesting", "--start-at-auth"]
```

Handle in `AstrologApp.swift`:
```swift
init() {
    if CommandLine.arguments.contains("--uitesting") {
        // Setup test environment
    }
    if CommandLine.arguments.contains("--reset-onboarding") {
        UserDefaults.standard.set(false, forKey: "onboarding_completed")
    }
}
```

## Code Coverage

### Generate Coverage Report

```bash
xcodebuild -project Astrolog.xcodeproj \
  -scheme Astrolog \
  -destination 'platform=iOS Simulator,name=iPhone 15' \
  -enableCodeCoverage YES \
  test
```

### View in Xcode

1. Run tests with coverage: `Cmd + U`
2. Open Report Navigator: `Cmd + 9`
3. Select latest test run
4. Click "Coverage" tab
5. View coverage by file

### Export Coverage

```bash
# Using xcov (requires xcov gem)
gem install xcov
xcov --scheme Astrolog --minimum_coverage_percentage 70
```

## Test Tagging

Tests use tags for organization:

```swift
@Suite("My Test Suite", .tags(.integration, .firebase))
```

Available tags:
- `.integration`: Integration tests (requires setup)
- `.firebase`: Firebase-dependent tests
- `.astrology`: Astrology calculation tests
- `.auth`: Authentication tests
- `.firestore`: Firestore tests

Run tests by tag (requires custom test plan):
```bash
# Create test plan with tag filters
# Run specific tags only
```

## Best Practices

### Writing Tests

1. **Arrange-Act-Assert**: Structure tests clearly
2. **Independent**: Each test should be isolated
3. **Deterministic**: Tests should not be flaky
4. **Fast**: Unit tests should complete quickly
5. **Meaningful**: Test names should describe what's tested

### Test Data

- Use realistic test data
- Create helper functions for common data creation
- Clean up after integration tests

### Mocking

- Mock external dependencies in unit tests
- Use real services in integration tests
- Consider Firebase emulator for predictable state

## Continuous Integration

### GitHub Actions Example

```yaml
name: Run Tests

on: [push, pull_request]

jobs:
  test:
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v3

      - name: Select Xcode
        run: sudo xcode-select -s /Applications/Xcode_15.0.app

      - name: Run Unit Tests
        run: |
          xcodebuild test \
            -project Astrolog.xcodeproj \
            -scheme Astrolog \
            -destination 'platform=iOS Simulator,name=iPhone 15' \
            -only-testing:AstrologTests \
            -enableCodeCoverage YES

      - name: Run UI Tests
        run: |
          xcodebuild test \
            -project Astrolog.xcodeproj \
            -scheme Astrolog \
            -destination 'platform=iOS Simulator,name=iPhone 15' \
            -only-testing:AstrologUITests
```

## Troubleshooting

### Tests Fail to Launch

- Ensure simulator is available
- Check Xcode version compatibility
- Verify project scheme is shared

### UI Tests Timing Out

- Increase timeout values
- Check for accessibility identifiers
- Ensure app state is correct

### Integration Tests Failing

- Verify Firebase emulator is running
- Check network connectivity
- Review Firebase security rules

### Flaky Tests

- Add appropriate wait conditions
- Use `XCTAssertTrue(element.waitForExistence(timeout: 5))`
- Avoid hardcoded sleep() calls

## Performance Testing

Monitor test performance:

```bash
# Run with timing
xcodebuild test ... | xcpretty --report html
```

Slow tests (>1s) should be optimized or moved to integration tests.

## Future Improvements

- [ ] Snapshot testing for UI components
- [ ] API contract tests
- [ ] Security testing (penetration tests)
- [ ] Load testing for calculations
- [ ] Accessibility testing automation
- [ ] Test data factories
- [ ] Shared test utilities module

## Resources

- [Swift Testing Documentation](https://developer.apple.com/documentation/testing)
- [XCTest Documentation](https://developer.apple.com/documentation/xctest)
- [Firebase Test Lab](https://firebase.google.com/docs/test-lab)
- [UI Testing in Xcode](https://developer.apple.com/library/archive/documentation/DeveloperTools/Conceptual/testing_with_xcode/chapters/09-ui_testing.html)
