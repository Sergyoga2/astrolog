# 🔥 Firebase Setup Instructions

## ✅ Completed Steps
- [x] Firebase project `astrolog-59ac3` created
- [x] iOS app added with Bundle ID `Astrolog.Astrolog`
- [x] GoogleService-Info.plist downloaded and added to project

## 🚀 Next Steps to Complete

### 1. Authentication Setup
Go to [Firebase Console](https://console.firebase.google.com/project/astrolog-59ac3/authentication/providers)

**Enable Sign-in Methods:**
- ✅ Anonymous (for guest access)
- ✅ Email/Password (for user accounts)
- 🔄 Apple Sign-In (recommended for iOS)

### 2. Firestore Database Setup
Go to [Firestore Console](https://console.firebase.google.com/project/astrolog-59ac3/firestore)

1. **Create Database**
   - Mode: **Start in test mode** (for development)
   - Location: **europe-west1** (closest to Russia)

2. **Apply Security Rules**
   - Copy content from `firestore.rules` file
   - Paste into Rules tab in Firebase Console

### 3. Storage Setup
Go to [Storage Console](https://console.firebase.google.com/project/astrolog-59ac3/storage)

1. **Create Storage Bucket**
   - Start in **test mode**
   - Same location: **europe-west1**

2. **Apply Storage Rules**
   - Copy content from `storage.rules` file
   - Paste into Rules tab in Storage Console

### 4. Test the Integration

Run the app and navigate to `AuthTestView` to test:

```swift
// Test anonymous sign-in
try await firebaseService.signInAnonymously()

// Test data persistence
let testChart = BirthChart(...)
try await dataRepository.saveBirthChart(testChart)
```

### 5. Production Configuration

When ready for production:

1. **Firestore Rules**: Change to production mode
2. **Authentication**: Set up email verification
3. **Storage**: Implement file size limits
4. **Monitoring**: Enable Firebase Performance Monitoring

## 🔧 Security Rules Applied

The project includes:
- **User data isolation** (users can only access their own data)
- **Birth chart privacy** (encrypted and user-specific)
- **Read-only horoscope data** for all authenticated users
- **File upload limits** (5MB for images, 10MB for user data)

## 📱 Bundle Configuration

Make sure your Xcode project has:
- ✅ Bundle ID: `Astrolog.Astrolog`
- ✅ GoogleService-Info.plist added to project bundle
- ✅ Firebase SDK integrated via SPM

## 🧪 Testing Checklist

- [ ] Anonymous authentication works
- [ ] User registration with email/password works
- [ ] Birth chart data saves to Firestore
- [ ] Offline data persists locally
- [ ] Online sync works when connection restored
- [ ] Security rules prevent unauthorized access

## 📊 Project URLs

- **Console**: https://console.firebase.google.com/project/astrolog-59ac3
- **Authentication**: https://console.firebase.google.com/project/astrolog-59ac3/authentication
- **Firestore**: https://console.firebase.google.com/project/astrolog-59ac3/firestore
- **Storage**: https://console.firebase.google.com/project/astrolog-59ac3/storage