# Google Sign In Integration Guide

## Prerequisites

1. Firebase project configured with Google Sign In enabled
2. Xcode project

## Setup Steps

### 1. Add GoogleSignIn SDK

**Option A: Swift Package Manager (Recommended)**
```
1. In Xcode: File → Add Packages
2. Enter URL: https://github.com/google/GoogleSignIn-iOS
3. Select version: 7.0.0 or later
4. Add to target: Astrolog
```

**Option B: CocoaPods**
```ruby
pod 'GoogleSignIn', '~> 7.0'
```

### 2. Download Google-Service-Info.plist

1. Go to Firebase Console → Project Settings
2. Download `GoogleService-Info.plist`
3. Add to Xcode project root
4. Ensure "Copy items if needed" is checked
5. Add to Astrolog target

### 3. Configure URL Schemes

1. Open Xcode project
2. Select Astrolog target
3. Go to Info tab
4. Expand URL Types section
5. Add new URL scheme:
   - Identifier: `com.googleusercontent.apps.YOUR_CLIENT_ID`
   - URL Scheme: Copy REVERSED_CLIENT_ID from GoogleService-Info.plist

### 4. Update Info.plist

Add the following to `Info.plist`:

```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleTypeRole</key>
        <string>Editor</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>REVERSED_CLIENT_ID_FROM_GOOGLE_SERVICE_INFO</string>
        </array>
    </dict>
</array>
```

### 5. Enable Google Sign In in Firebase

1. Go to Firebase Console
2. Authentication → Sign-in method
3. Enable Google provider
4. Add support email

### 6. Update Code

**Uncomment the following files:**

1. `Features/Auth/GoogleSignInButton.swift` - Uncomment production implementation
2. `Core/Services/FirebaseService.swift` - Uncomment `signInWithGoogle` method
3. `Features/Auth/AuthViewModel.swift` - Add `handleSignInWithGoogle` method
4. `Features/Auth/AuthView.swift` - Uncomment GoogleSignInButton

**Add to AuthViewModel.swift:**
```swift
func handleSignInWithGoogle(result: Result<GoogleSignInResult, Error>) async {
    isLoading = true
    errorMessage = nil

    switch result {
    case .success(let googleResult):
        do {
            try await firebaseService.signInWithGoogle(result: googleResult)
        } catch {
            errorMessage = "Не удалось войти через Google: \(error.localizedDescription)"
            showError = true
        }
    case .failure(let error):
        errorMessage = "Ошибка Google Sign In: \(error.localizedDescription)"
        showError = true
    }

    isLoading = false
}
```

### 7. Test

1. Run app in simulator or device
2. Tap "Sign in with Google"
3. Select Google account
4. Verify authentication works

## Troubleshooting

### Error: "Unable to configure Google App ID"
- Ensure GoogleService-Info.plist is added correctly
- Check that file is in Astrolog target

### Error: "Invalid client ID"
- Verify URL scheme matches REVERSED_CLIENT_ID
- Check Firebase Console has correct Bundle ID

### Error: "The operation couldn't be completed"
- Ensure Google Sign In is enabled in Firebase Console
- Check that support email is configured

## Resources

- [Google Sign In Documentation](https://developers.google.com/identity/sign-in/ios)
- [Firebase Auth with Google](https://firebase.google.com/docs/auth/ios/google-signin)
- [GoogleSignIn-iOS GitHub](https://github.com/google/GoogleSignIn-iOS)
