# Authentication System for Calendar App

## Overview

This app now includes a complete authentication system that handles JWT tokens required by the calendar API. The system includes:

- **Authentication Screen**: A dedicated login screen for users
- **JWT Token Management**: Automatic storage and retrieval of JWT tokens
- **Protected API Calls**: All calendar API requests now include the required JWT token
- **State Management**: Authentication state is managed throughout the app using Provider

## How It Works

### 1. Authentication Flow

1. **App Launch**: The app checks if a JWT token exists
2. **No Token**: User is redirected to the authentication screen
3. **Sign In**: User clicks "Sign In with Google" (currently uses mock authentication)
4. **Token Storage**: JWT token is stored securely using SharedPreferences
5. **API Access**: All subsequent API calls include the JWT token in headers

### 2. JWT Token Headers

The app automatically adds the following headers to all calendar API requests:

```
X-Samantha-JWT: <your_jwt_token>
X-Device-Id: <unique_device_identifier>
Content-Type: application/json
User-Agent: TesttFlutterApp/1.0
```

### 3. Current Implementation (Development Mode)

For development purposes, the app uses a mock JWT token. This allows you to test the API integration without setting up Google OAuth.

**⚠️ Important**: The mock token is for development only. In production, you must implement real Google OAuth authentication.

## Files Structure

```
lib/
├── core/
│   ├── providers/
│   │   └── auth_provider.dart          # Authentication state management
│   ├── services/
│   │   └── auth_service.dart           # JWT token storage and retrieval
│   └── constants/
│       └── api_constants.dart          # API endpoints and header constants
├── presentation/
│   └── screens/
│       ├── auth_screen.dart            # Login screen
│       └── calendar_screen.dart        # Main calendar screen (now protected)
└── main.dart                           # App entry point with auth wrapper
```

## API Integration

### Calendar API Endpoints

All calendar operations now work with proper authentication:

- `list_events` - List calendar events
- `check_availability` - Check time availability
- `draft_calendar_event` - Create event draft
- `send_calendar_draft` - Send event draft
- `update_event` - Update existing event
- `delete_event` - Delete event

### Example API Request

```dart
// The repository automatically includes JWT token
final events = await calendarRepository.listEvents(
  maxResults: 10,
  timeMin: DateTime.now(),
  timeMax: DateTime.now().add(Duration(days: 7)),
);
```

## Production Setup

To use this in production, you need to:

1. **Add Google OAuth Dependencies**:
   ```yaml
   dependencies:
     google_sign_in: ^6.1.0
     googleapis: ^11.0.0
   ```

2. **Configure Google OAuth**:
   - Set up OAuth 2.0 credentials in Google Cloud Console
   - Add your app's bundle ID and SHA-1 fingerprint
   - Configure the `google-services.json` (Android) and `GoogleService-Info.plist` (iOS)

3. **Update Authentication**:
   - Replace mock authentication in `AuthProvider` with real Google OAuth
   - Handle token refresh and expiration
   - Implement proper error handling for authentication failures

## Testing

### Current Status

✅ **Working**:
- Mock authentication flow
- JWT token storage and retrieval
- Protected API calls with JWT headers
- Authentication state management
- User interface for login/logout

🔄 **To Test**:
- Run the app and verify the authentication screen appears
- Sign in and verify you're redirected to the calendar
- Check the console logs for JWT token headers in API requests
- Verify the user email is displayed in the calendar screen

### Debug Information

The app logs authentication information to help with debugging:

```
🔐 Auth Headers: {Content-Type: application/json, User-Agent: TesttFlutterApp/1.0, X-Device-Id: flutter_1234567890_123, X-Samantha-JWT: mock_jwt_token_for_development_only_1234567890}
🔑 JWT Token: mock_jwt_token_for_development_only_1234567890
```

## Troubleshooting

### Common Issues

1. **401 Unauthorized**: Check if JWT token is being sent in headers
2. **Token Not Found**: Verify authentication flow completed successfully
3. **API Calls Failing**: Check console logs for authentication headers

### Debug Steps

1. Check if user is authenticated: `authProvider.isAuthenticated`
2. Verify JWT token exists: `authProvider.getAuthHeaders()`
3. Check console logs for authentication header information
4. Verify the token is being sent with API requests

## Next Steps

1. **Test the current implementation** with mock authentication
2. **Verify API calls work** with the JWT token
3. **Implement real Google OAuth** for production use
4. **Add token refresh logic** for expired tokens
5. **Implement proper error handling** for authentication failures

## Support

If you encounter issues:

1. Check the console logs for authentication information
2. Verify the JWT token is being stored correctly
3. Ensure the authentication flow completes successfully
4. Check that API requests include the required headers
