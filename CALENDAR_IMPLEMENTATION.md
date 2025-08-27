# Calendar Implementation Documentation

## Overview

This Flutter project implements a comprehensive calendar system based on the android-agent calendar functionality. The system provides full CRUD operations for calendar events, availability checking, and a modern, responsive UI.

## Architecture

The project follows Clean Architecture principles with clear separation of concerns:

```
lib/
├── core/
│   ├── constants/          # API endpoints and configuration
│   ├── models/            # Data models and DTOs
│   ├── repositories/      # Data access layer
│   ├── services/          # Business logic and external services
│   └── providers/         # State management
├── presentation/
│   ├── screens/           # UI screens
│   └── widgets/           # Reusable UI components
```

## Key Components

### 1. Core Models (`lib/core/models/`)

- **CalendarEvent**: Main event model with all necessary fields
- **CalendarEventRequest**: Request DTO for API calls
- **CalendarEventResponse**: Response DTO for API calls
- **AvailabilityCheckRequest/Response**: For availability checking

### 2. Services (`lib/core/services/`)

- **AuthService**: Handles JWT tokens, device ID, and authentication
- **HttpService**: Manages HTTP requests with proper error handling and timeouts

### 3. Repository (`lib/core/repositories/`)

- **CalendarRepository**: Implements all calendar operations:
  - `listEvents()` - List calendar events with filtering
  - `checkAvailability()` - Check if user is free at specific times
  - `draftCalendarEvent()` - Create calendar event drafts
  - `sendCalendarDraft()` - Send approved calendar drafts
  - `updateEvent()` - Update existing events
  - `deleteEvent()` - Delete events
  - `getUpcomingEvents()` - Get events for next 7 days
  - `getTodayEvents()` - Get today's events

### 4. State Management (`lib/core/providers/`)

- **CalendarProvider**: Manages calendar state using Provider pattern
  - Loading states
  - Error handling
  - Event lists (all, today, upcoming)
  - CRUD operations

### 5. UI Components (`lib/presentation/`)

- **CalendarScreen**: Main calendar interface with tabs for Today, Upcoming, and All Events
- **CreateEventScreen**: Form for creating/editing events
- **EventDetailsScreen**: Detailed view of events with edit/delete options
- **CalendarEventCard**: Reusable event display component
- **CompactCalendarEventCard**: Compact version for list views

## API Integration

The system integrates with the same backend APIs used by the android-agent:

- **Base URL**: `https://email-agent-backend-staging.onrender.com`
- **Calendar Endpoint**: `/calendar/manage`
- **Authentication**: JWT tokens via `X-Samantha-JWT` header
- **Device ID**: Unique device identifier via `X-Device-Id` header

### API Operations

1. **List Events**
   ```dart
   POST /calendar/manage
   {
     "operation": "list_events",
     "max_results": 10,
     "time_min": "2024-01-01T00:00:00Z",
     "time_max": "2024-12-31T23:59:59Z"
   }
   ```

2. **Check Availability**
   ```dart
   POST /calendar/manage
   {
     "operation": "check_availability",
     "query": "Are you free tomorrow at 2 PM?"
   }
   ```

3. **Draft Event**
   ```dart
   POST /calendar/manage
   {
     "operation": "draft_calendar_event",
     "summary": "Team Meeting",
     "start_time": "2024-01-15T14:00:00Z",
     "end_time": "2024-01-15T15:00:00Z",
     "location": "Conference Room A",
     "description": "Weekly team sync",
     "attendees": ["john@example.com", "jane@example.com"],
     "all_day": false
   }
   ```

4. **Send Draft**
   ```dart
   POST /calendar/manage
   {
     "operation": "send_calendar_draft",
     "draft_id": "draft_123"
   }
   ```

5. **Update Event**
   ```dart
   POST /calendar/manage
   {
     "operation": "update_event",
     "event_id": "event_456",
     "summary": "Updated Meeting Title",
     "start_time": "2024-01-15T15:00:00Z"
   }
   ```

6. **Delete Event**
   ```dart
   POST /calendar/manage
   {
     "operation": "delete_event",
     "event_id": "event_456"
   }
   ```

## Features

### 1. Event Management
- ✅ Create new calendar events
- ✅ Edit existing events
- ✅ Delete events
- ✅ All-day event support
- ✅ Location and description
- ✅ Attendee management

### 2. Smart Scheduling
- ✅ Availability checking
- ✅ Time conflict detection
- ✅ Flexible date/time selection
- ✅ Duration calculation

### 3. User Experience
- ✅ Modern dark theme UI
- ✅ Responsive design
- ✅ Tabbed interface (Today, Upcoming, All Events)
- ✅ Pull-to-refresh
- ✅ Loading states and error handling
- ✅ Form validation

### 4. Data Management
- ✅ Local state management
- ✅ Real-time updates
- ✅ Offline support (local state)
- ✅ Efficient data filtering

## Usage

### 1. Getting Started

1. **Install Dependencies**
   ```bash
   flutter pub get
   ```

2. **Generate Code** (if models change)
   ```bash
   flutter packages pub run build_runner build
   ```

3. **Run the App**
   ```bash
   flutter run
   ```

### 2. Using the Calendar

1. **View Events**: Navigate to the Calendar tab to see all events
2. **Create Event**: Tap the + button to create a new event
3. **Edit Event**: Tap on an event card and select Edit
4. **Delete Event**: Use the delete button or menu option
5. **Check Availability**: Use the availability checking feature

### 3. Event Creation

1. Fill in the event title (required)
2. Set start and end dates/times
3. Choose all-day or specific time
4. Add location (optional)
5. Add description (optional)
6. Add attendees (comma-separated emails)
7. Save the event

## Configuration

### Environment Variables

The app uses the following configuration:

```dart
// API Configuration
static const String emailAgentBaseUrl = 'https://email-agent-backend-staging.onrender.com';
static const String userServiceBaseUrl = 'https://samantha-user-service.onrender.com';

// Headers
static const String jwtHeader = 'X-Samantha-JWT';
static const String deviceIdHeader = 'X-Device-Id';

// Timeouts
static const int connectTimeout = 30; // seconds
static const int receiveTimeout = 60; // seconds
```

### Authentication

The app supports JWT-based authentication:

1. **JWT Token**: Stored in SharedPreferences
2. **Device ID**: Automatically generated and stored
3. **Headers**: Automatically added to all API requests

## Error Handling

The system includes comprehensive error handling:

- **Network Errors**: Connection timeouts, network failures
- **API Errors**: Server errors, validation failures
- **User Errors**: Invalid input, missing required fields
- **State Errors**: Loading failures, data corruption

## Performance Considerations

- **Lazy Loading**: Events loaded on-demand
- **Efficient Filtering**: Date-based filtering for performance
- **State Management**: Minimal re-renders with Provider
- **Image Optimization**: Efficient icon and image handling

## Testing

The system is designed for easy testing:

- **Provider Testing**: Mock providers for testing
- **Repository Testing**: Mock repositories for API testing
- **Widget Testing**: Isolated component testing
- **Integration Testing**: Full flow testing

## Future Enhancements

1. **Calendar View**: Month/week/day calendar views
2. **Recurring Events**: Support for recurring meetings
3. **Notifications**: Push notifications for upcoming events
4. **Sync**: Real-time sync with Google Calendar
5. **Offline Mode**: Full offline event management
6. **Attachments**: File and link attachments
7. **Reminders**: Custom reminder settings

## Troubleshooting

### Common Issues

1. **API Connection Failed**
   - Check internet connection
   - Verify API endpoints are accessible
   - Check authentication tokens

2. **Events Not Loading**
   - Refresh the screen
   - Check error messages
   - Verify API responses

3. **Authentication Issues**
   - Clear app data
   - Re-authenticate
   - Check JWT token validity

### Debug Information

Enable debug logging by setting:

```dart
// In development
const bool isDebugMode = true;
```

## Contributing

When contributing to the calendar system:

1. Follow the existing architecture patterns
2. Add proper error handling
3. Include unit tests for new functionality
4. Update documentation
5. Follow Flutter best practices

## License

This calendar implementation is part of the testt Flutter project and follows the project's licensing terms.
