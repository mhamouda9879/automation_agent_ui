# Google Sign-In Troubleshooting Guide

## Error: `ApiException: 10`

The error `com.google.android.gms.common.api.ApiException: 10` indicates a configuration problem with Google Sign-In. Here's how to fix it:

## 🔍 What Error Code 10 Means

Error code 10 typically indicates one of these issues:
1. **SHA-1 fingerprint mismatch** in Google Cloud Console
2. **Package name mismatch** between your app and Google Cloud Console
3. **Google Services not properly configured**
4. **OAuth 2.0 client not properly set up**

## ✅ Configuration Checklist

### 1. Google Cloud Console Setup

1. **Go to [Google Cloud Console](https://console.cloud.google.com/)**
2. **Select your project**: `project-x-e092d`
3. **Enable APIs**:
   - Google Sign-In API
   - Google Calendar API
4. **Go to Credentials** → **OAuth 2.0 Client IDs**

### 2. Android OAuth Client Configuration

Your current configuration shows:
```json
{
  "client_id": "1049931181927-70kvh4g0g1icjeo2fi8951lvnbkkr454.apps.googleusercontent.com",
  "client_type": 3,
  "android_info": {
    "package_name": "com.example.testt",
    "certificate_hash": "35A52719D12B740E0A3A4AB1A1059B324122DA71"
  }
}
```

**Verify these match exactly:**
- ✅ Package name: `com.example.testt` ✓
- ✅ SHA-1: `35A52719D12B740E0A3A4AB1A1059B324122DA71` ✓

### 3. SHA-1 Fingerprint Verification

Run this command to get your current SHA-1:
```bash
cd android && ./gradlew signingReport
```

**Expected output:**
```
SHA1: 35:A5:27:19:D1:2B:74:0E:0A:3A:4A:B1:A1:05:9B:32:41:22:DA:71
```

### 4. Package Name Verification

Check your `android/app/build.gradle.kts`:
```kotlin
defaultConfig {
    applicationId = "com.example.testt"  // Must match exactly
}
```

### 5. Google Services Configuration

Your `google-services.json` should be in:
```
android/app/google-services.json
```

## 🛠️ Fix Steps

### Step 1: Update Google Cloud Console

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Navigate to **APIs & Services** → **Credentials**
3. Find your Android OAuth 2.0 client
4. **Update the SHA-1 fingerprint** if it doesn't match
5. **Verify package name** matches exactly

### Step 2: Download Updated google-services.json

1. After updating the configuration
2. **Download the new `google-services.json`**
3. **Replace** the existing file in `android/app/`
4. **Clean and rebuild** your project

### Step 3: Clean and Rebuild

```bash
# Clean the project
flutter clean

# Get dependencies
flutter pub get

# Clean Android build
cd android && ./gradlew clean

# Rebuild
flutter run
```

## 🔧 Alternative Solutions

### Option 1: Use Web Client ID

If Android client continues to fail, try using the web client ID:

```dart
final GoogleSignIn _googleSignIn = GoogleSignIn(
  scopes: [
    'email',
    'profile',
    'https://www.googleapis.com/auth/calendar',
  ],
  serverClientId: '1049931181927-70kvh4g0g1icjeo2fi8951lvnbkkr454.apps.googleusercontent.com',
);
```

### Option 2: Check Google Play Services

Ensure Google Play Services is up to date on your device/emulator.

### Option 3: Verify Internet Connection

Google Sign-In requires internet access.

## 📱 Testing

### Test on Physical Device

1. **Use a physical Android device** instead of emulator
2. **Ensure Google Play Services is installed and updated**
3. **Sign in with a Google account** on the device

### Test on Emulator

1. **Use Google Play Services emulator**
2. **Sign in with Google account** in emulator settings
3. **Ensure emulator has internet access**

## 🚨 Common Issues

### Issue 1: SHA-1 Mismatch
**Symptoms**: Error code 10
**Solution**: Update SHA-1 in Google Cloud Console

### Issue 2: Package Name Mismatch
**Symptoms**: Error code 10
**Solution**: Verify package name in build.gradle.kts matches Google Cloud Console

### Issue 3: Missing google-services.json
**Symptoms**: Build errors
**Solution**: Download and place google-services.json in android/app/

### Issue 4: Google Play Services Not Available
**Symptoms**: Various Google API errors
**Solution**: Update Google Play Services on device/emulator

## 📋 Debug Information

### Current Configuration
- **Project ID**: `project-x-e092d`
- **Package Name**: `com.example.testt`
- **SHA-1**: `35A52719D12B740E0A3A4AB1A1059B324122DA71`
- **Client ID**: `1049931181927-70kvh4g0g1icjeo2fi8951lvnbkkr454.apps.googleusercontent.com`

### Files to Check
1. `android/app/google-services.json`
2. `android/app/build.gradle.kts`
3. `android/app/src/main/AndroidManifest.xml`
4. `lib/core/services/auth_service.dart`

## 🔍 Debug Logging

The enhanced logging will show:
- ✅ Configuration details
- ✅ Google Play Services status
- ✅ Sign-in process steps
- ❌ Detailed error information
- 🔍 Troubleshooting hints

## 📞 Getting Help

If the issue persists:

1. **Check the logs** for detailed error information
2. **Verify all configuration steps** above
3. **Test on different devices/emulators**
4. **Check Google Cloud Console** for any error messages
5. **Ensure all APIs are enabled** in Google Cloud Console

## 🎯 Quick Fix Summary

1. **Verify SHA-1** in Google Cloud Console matches your app
2. **Check package name** matches exactly
3. **Download fresh** `google-services.json`
4. **Clean and rebuild** project
5. **Test on physical device** with Google Play Services

The enhanced logging will help identify exactly where the configuration is failing.
