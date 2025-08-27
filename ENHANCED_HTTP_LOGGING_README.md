# Enhanced HTTP Logging Interceptors & Google Auth JWT Implementation

This document describes the enhanced HTTP logging interceptors and Google Auth JWT functionality implemented in the Flutter calendar application.

## 🚀 Features

### 1. Enhanced HTTP Logging Interceptors

The application now includes comprehensive HTTP request/response logging with:

- **Detailed Request Logging**: Method, URL, headers, body, and operation context
- **Enhanced Response Logging**: Status codes, response time, headers, and body
- **Authentication Logging**: JWT tokens, access tokens, user details (masked for security)
- **Calendar-Specific Logging**: Specialized logging for calendar operations
- **Performance Metrics**: Request duration tracking with slow request warnings
- **Error Handling**: Comprehensive error logging with stack traces
- **Security**: Automatic masking of sensitive information in logs

### 2. Google Auth with Calendar Scopes

Enhanced Google Sign-In implementation with:

- **Calendar API Access**: Full read/write access to Google Calendar
- **JWT Token Management**: Automatic JWT token generation and refresh
- **Token Expiry Handling**: Smart token refresh before expiration
- **Multiple Calendar Scopes**: 
  - `https://www.googleapis.com/auth/calendar` (Full access)
  - `https://www.googleapis.com/auth/calendar.events` (Event management)
  - `https://www.googleapis.com/auth/calendar.readonly` (Read-only access)

### 3. HTTP Service Enhancements

The HTTP service now supports:

- **Multiple API Endpoints**: Google Calendar API, custom calendar API, user service
- **Automatic Token Management**: JWT and Google access token handling
- **Enhanced Error Handling**: Better error messages and logging
- **Performance Monitoring**: Request timing and performance metrics

## 📁 File Structure

```
lib/core/services/
├── logging_interceptor.dart      # Enhanced logging interceptor
├── http_service.dart            # Enhanced HTTP service
├── auth_service.dart            # Enhanced auth service with calendar scopes
└── calendar_service.dart        # New calendar service
```

## 🔧 Usage Examples

### 1. Basic HTTP Request with Enhanced Logging

```dart
import 'package:testt/core/services/http_service.dart';

final httpService = HttpService();

// Make a calendar request with automatic logging
final response = await httpService.makeCalendarRequest(
  operation: 'get_events',
  requestBody: {'date': '2024-01-01'},
  eventId: 'event123',
  userId: 'user456',
);
```

### 2. Google Calendar API Requests

```dart
import 'package:testt/core/services/calendar_service.dart';

final calendarService = CalendarService();

// Get user's calendars
final calendars = await calendarService.getUserCalendars();

// Create a new event
final newEvent = await calendarService.createCalendarEvent(
  calendarId: 'primary',
  summary: 'Team Meeting',
  description: 'Weekly team sync',
  startTime: DateTime.now().add(Duration(hours: 1)),
  endTime: DateTime.now().add(Duration(hours: 2)),
  location: 'Conference Room A',
  attendees: ['team@company.com'],
);
```

### 3. Custom Calendar API with JWT

```dart
// Use custom calendar API with JWT token
final result = await calendarService.makeCustomCalendarRequest(
  operation: 'sync_calendar',
  requestData: {'calendar_id': 'primary'},
  eventId: 'event789',
);
```

## 📊 Logging Output Examples

### Request Logging
```
🌐 HTTP REQUEST
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📋 Method: POST
🔗 URL: https://email-agent-backend-staging.onrender.com/calendar/manage
🎯 Operation: Calendar Request - get_events
⏰ Timestamp: 2024-01-15T10:30:00.000Z
📋 Headers:
   Content-Type: application/json
   X-Samantha-JWT: eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9...
   User-Agent: FlutterCalendarApp/1.0
📦 Request Body:
   {
     "operation": "get_events",
     "date": "2024-01-01"
   }
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

### Response Logging
```
✅ HTTP RESPONSE
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📊 Status: 200 OK
🎯 Operation: Calendar - get_events
⏱️ Duration: 245ms
⏰ Timestamp: 2024-01-15T10:30:00.245Z
📋 Response Headers:
   content-type: application/json
   server: nginx/1.18.0
📦 Response Body:
   {
     "success": true,
     "events": [
       {
         "id": "event123",
         "summary": "Team Meeting",
         "start": "2024-01-01T09:00:00Z"
       }
     ]
   }
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

### Authentication Logging
```
🔐 AUTHENTICATION DETAILS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🎯 Operation: Calendar Request - get_events
🆔 User ID: 123456789
📧 Email: user@example.com
🔑 JWT Token: eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9...
🎫 Access Token: ya29.a0AfH6SMC...
⏰ Timestamp: 2024-01-15T10:30:00.000Z
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

### Performance Metrics
```
⚡ PERFORMANCE METRIC
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🎯 Operation: Calendar Request - get_events
📋 Method: POST
🔗 URL: https://email-agent-backend-staging.onrender.com/calendar/manage
⏱️ Duration: 245ms
📊 Status: 200
⏰ Timestamp: 2024-01-15T10:30:00.245Z
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

## 🔐 Google Auth Configuration

### 1. Android Configuration

Add to `android/app/build.gradle`:
```gradle
defaultConfig {
    // ... other config
    manifestPlaceholders = [
        'appAuthRedirectScheme': 'com.example.testt'
    ]
}
```

### 2. iOS Configuration

Add to `ios/Runner/Info.plist`:
```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleURLName</key>
        <string>com.example.testt</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>com.example.testt</string>
        </array>
    </dict>
</array>
```

### 3. Google Cloud Console

1. Enable Google Calendar API
2. Configure OAuth 2.0 credentials
3. Add authorized redirect URIs:
   - `com.example.testt:/oauth2redirect`
   - `com.example.testt:/oauth2redirect/`

## 🛠️ Configuration Options

### Logging Levels

```dart
import 'package:testt/core/services/logging_interceptor.dart';

final logger = LoggingInterceptor();

// Set logging level
logger.setLogLevel(Level.debug);    // All logs
logger.setLogLevel(Level.info);     // Info and above
logger.setLogLevel(Level.warning);  // Warnings and errors only
logger.setLogLevel(Level.error);    // Errors only
```

### HTTP Timeouts

```dart
// Configure timeout in HttpService
static const Duration _timeout = Duration(seconds: 30);
```

## 🔒 Security Features

### Token Masking

All sensitive tokens are automatically masked in logs:
- JWT tokens: `eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9...`
- Access tokens: `ya29.a0AfH6SMC...`
- API keys: `sk-12345678...`

### Header Sanitization

Sensitive headers are automatically sanitized:
- `Authorization`
- `Cookie`
- `X-API-Key`
- `X-Samantha-JWT`
- `X-Auth-Token`

## 📱 Calendar Operations

### Available Calendar Scopes

1. **Full Calendar Access**: `https://www.googleapis.com/auth/calendar`
2. **Event Management**: `https://www.googleapis.com/auth/calendar.events`
3. **Read-Only Access**: `https://www.googleapis.com/auth/calendar.readonly`

### Calendar API Endpoints

- **List Calendars**: `GET /users/me/calendarList`
- **Get Events**: `GET /calendars/{calendarId}/events`
- **Create Event**: `POST /calendars/{calendarId}/events`
- **Update Event**: `PATCH /calendars/{calendarId}/events/{eventId}`
- **Delete Event**: `DELETE /calendars/{calendarId}/events/{eventId}`

## 🚨 Error Handling

### Network Errors
- Connection failures
- Timeout handling
- Retry logic

### Authentication Errors
- Token expiration
- Invalid credentials
- Scope permission issues

### API Errors
- HTTP status codes
- Error message parsing
- User-friendly error messages

## 📈 Performance Monitoring

### Metrics Tracked
- Request duration
- Response times
- Slow request detection (>5 seconds)
- Success/failure rates

### Performance Warnings
```
🐌 PERFORMANCE METRIC
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🎯 Operation: Calendar Request - get_events
📋 Method: POST
🔗 URL: https://email-agent-backend-staging.onrender.com/calendar/manage
⏱️ Duration: 7500ms
📊 Status: 200
⏰ Timestamp: 2024-01-15T10:30:07.500Z
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

## 🔄 Token Refresh

### Automatic Refresh
- JWT tokens refresh 24 hours before expiry
- Google access tokens refresh 1 hour before expiry
- Seamless token management

### Manual Refresh
```dart
final authService = AuthService();

// Refresh tokens if needed
final success = await authService.refreshTokensIfNeeded();

// Check calendar access
final hasAccess = await calendarService.checkCalendarAccess();
```

## 📝 Best Practices

### 1. Logging
- Use appropriate log levels
- Include operation context
- Monitor performance metrics
- Review logs regularly

### 2. Security
- Never log sensitive tokens in plain text
- Use HTTPS for all API calls
- Implement proper token expiration
- Regular security audits

### 3. Performance
- Monitor request durations
- Set appropriate timeouts
- Implement retry logic
- Cache frequently accessed data

### 4. Error Handling
- Log all errors with context
- Provide user-friendly messages
- Implement graceful degradation
- Monitor error rates

## 🧪 Testing

### Unit Tests
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:testt/core/services/logging_interceptor.dart';

void main() {
  group('LoggingInterceptor', () {
    test('should log requests correctly', () {
      final interceptor = LoggingInterceptor();
      // Test implementation
    });
  });
}
```

### Integration Tests
```dart
import 'package:integration_test/integration_test.dart';
import 'package:testt/core/services/calendar_service.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Calendar Integration', () {
    testWidgets('should authenticate and fetch calendars', (tester) async {
      // Test implementation
    });
  });
}
```

## 🚀 Getting Started

1. **Install Dependencies**: Ensure all required packages are in `pubspec.yaml`
2. **Configure Google Auth**: Set up OAuth 2.0 credentials
3. **Initialize Services**: Call `configureGoogleSignIn()` on app startup
4. **Handle Authentication**: Implement sign-in flow
5. **Make API Calls**: Use the enhanced services for calendar operations
6. **Monitor Logs**: Review logging output for debugging and monitoring

## 📚 Additional Resources

- [Google Calendar API Documentation](https://developers.google.com/calendar/api)
- [Google Sign-In Flutter Plugin](https://pub.dev/packages/google_sign_in)
- [Flutter HTTP Package](https://pub.dev/packages/http)
- [Logger Package](https://pub.dev/packages/logger)

## 🤝 Contributing

When contributing to this implementation:

1. Follow the existing logging patterns
2. Maintain security best practices
3. Add comprehensive error handling
4. Include performance monitoring
5. Update this documentation

## 📄 License

This implementation is part of the testt Flutter application and follows the project's licensing terms.
