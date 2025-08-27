# Clean Architecture with BLoC Implementation

This Flutter project has been revamped to follow Clean Architecture principles using BLoC for state management.

## Architecture Overview

The project follows a layered architecture with clear separation of concerns:

```
┌─────────────────────────────────────────────────────────────┐
│                    PRESENTATION LAYER                      │
├─────────────────────────────────────────────────────────────┤
│  • Screens (UI)                                            │
│  • BLoCs (State Management)                                │
│  • Widgets                                                 │
└─────────────────────────────────────────────────────────────┘
                                │
                                ▼
┌─────────────────────────────────────────────────────────────┐
│                     DOMAIN LAYER                           │
├─────────────────────────────────────────────────────────────┤
│  • Entities (Business Objects)                             │
│  • Use Cases (Business Logic)                              │
│  • Repository Interfaces                                   │
└─────────────────────────────────────────────────────────────┘
                                │
                                ▼
┌─────────────────────────────────────────────────────────────┐
│                      DATA LAYER                            │
├─────────────────────────────────────────────────────────────┤
│  • Repository Implementations                              │
│  • Data Sources (Remote & Local)                           │
│  • Data Models                                             │
└─────────────────────────────────────────────────────────────┘
```

## Project Structure

```
lib/
├── domain/                          # Domain Layer
│   ├── entities/                    # Business objects
│   │   ├── user.dart               # User entity
│   │   ├── calendar_event.dart     # Calendar event entity
│   │   └── failure.dart            # Error handling entities
│   ├── repositories/                # Repository interfaces
│   │   ├── auth_repository.dart    # Authentication repository contract
│   │   └── calendar_repository.dart # Calendar repository contract
│   └── usecases/                    # Business logic
│       ├── auth_usecases.dart      # Authentication use cases
│       └── calendar_usecases.dart  # Calendar use cases
├── data/                            # Data Layer
│   ├── models/                      # Data models (extend entities)
│   │   ├── user_model.dart         # User data model
│   │   └── calendar_event_model.dart # Calendar event data model
│   ├── datasources/                 # Data sources
│   │   ├── auth_remote_data_source.dart    # Remote auth data
│   │   ├── auth_local_data_source.dart     # Local auth data
│   │   └── calendar_remote_data_source.dart # Remote calendar data
│   └── repositories/                # Repository implementations
│       ├── auth_repository_impl.dart        # Auth repository impl
│       └── calendar_repository_impl.dart    # Calendar repository impl
├── presentation/                     # Presentation Layer
│   ├── blocs/                       # BLoC state management
│   │   ├── auth_bloc.dart          # Authentication BLoC
│   │   └── calendar_bloc.dart      # Calendar BLoC
│   └── screens/                     # UI screens
│       ├── auth_screen.dart         # Authentication screen
│       └── calendar_screen.dart     # Calendar screen
├── core/                            # Core functionality
│   └── di/                          # Dependency injection
│       └── injection_container.dart # GetIt configuration
└── main.dart                        # App entry point
```

## Key Components

### 1. Domain Layer

#### Entities
- **User**: Core user business object with id, email, name, photoUrl, and timestamps
- **CalendarEvent**: Calendar event business object with all event properties
- **Failure**: Error handling entities for different types of failures

#### Use Cases
- **Authentication Use Cases**:
  - `SignInWithGoogle`: Google sign-in functionality
  - `SignInWithEmail`: Email/password sign-in
  - `SignUpWithEmail`: User registration
  - `SignOut`: User logout
  - `GetCurrentUser`: Retrieve current user
  - `IsAuthenticated`: Check authentication status

- **Calendar Use Cases**:
  - `GetEvents`: Fetch all events
  - `GetEventsByDate`: Fetch events for specific date
  - `GetEventsByDateRange`: Fetch events within date range
  - `CreateEvent`: Create new event
  - `UpdateEvent`: Update existing event
  - `DeleteEvent`: Delete event
  - `GetEventById`: Fetch specific event

#### Repository Interfaces
- **AuthRepository**: Authentication operations contract
- **CalendarRepository**: Calendar operations contract

### 2. Data Layer

#### Data Sources
- **Remote Data Sources**: Handle API calls and external services
- **Local Data Sources**: Handle local storage (SharedPreferences, SQLite, etc.)

#### Repository Implementations
- Implement the domain repository interfaces
- Coordinate between remote and local data sources
- Handle data transformation between models and entities

### 3. Presentation Layer

#### BLoCs
- **AuthBloc**: Manages authentication state and events
- **CalendarBloc**: Manages calendar state and events

#### Screens
- **AuthScreen**: Authentication UI with sign-in/sign-up forms
- **CalendarScreen**: Calendar UI with event management

## Dependencies

The project uses the following key packages:

```yaml
dependencies:
  flutter_bloc: ^8.1.4      # BLoC state management
  bloc: ^8.1.3              # BLoC core
  equatable: ^2.0.5         # Value equality
  dartz: ^0.10.1            # Functional programming
  get_it: ^7.6.7            # Dependency injection
  shared_preferences: ^2.5.3 # Local storage
  http: ^1.1.0              # HTTP requests
  intl: ^0.19.0             # Internationalization
```

## State Management

### BLoC Pattern
The project uses BLoC (Business Logic Component) for state management:

1. **Events**: User actions that trigger state changes
2. **States**: Immutable representations of the current UI state
3. **BLoCs**: Handle business logic and emit new states

### Example: AuthBloc
```dart
// Events
class SignInWithGooglePressed extends AuthEvent {}
class SignInWithEmailPressed extends AuthEvent {
  final String email;
  final String password;
}

// States
class AuthInitial extends AuthState {}
class AuthLoading extends AuthState {}
class Authenticated extends AuthState {
  final User user;
}
class Unauthenticated extends AuthState {}
class AuthError extends AuthState {
  final String message;
}
```

## Error Handling

The project implements a comprehensive error handling strategy:

1. **Failure Entities**: Different types of failures (Server, Network, Auth, Validation, Cache)
2. **Either Type**: Uses `dartz` package for functional error handling
3. **Error States**: UI states that display error messages with retry options

## Dependency Injection

Uses GetIt for dependency injection:

```dart
final sl = GetIt.instance;

Future<void> init() async {
  // Register BLoCs
  sl.registerFactory(() => AuthBloc(...));
  
  // Register Use Cases
  sl.registerLazySingleton(() => SignInWithGoogle(sl()));
  
  // Register Repositories
  sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(...));
  
  // Register Data Sources
  sl.registerLazySingleton<AuthRemoteDataSource>(() => AuthRemoteDataSourceImpl());
}
```

## Getting Started

1. **Install Dependencies**:
   ```bash
   flutter pub get
   ```

2. **Generate Code** (for JSON serialization):
   ```bash
   flutter packages pub run build_runner build
   ```

3. **Run the App**:
   ```bash
   flutter run
   ```

## Benefits of This Architecture

1. **Separation of Concerns**: Clear boundaries between layers
2. **Testability**: Easy to unit test business logic and UI separately
3. **Maintainability**: Changes in one layer don't affect others
4. **Scalability**: Easy to add new features and modify existing ones
5. **Dependency Inversion**: High-level modules don't depend on low-level modules
6. **Single Responsibility**: Each class has one reason to change

## Testing Strategy

The clean architecture makes testing straightforward:

1. **Unit Tests**: Test use cases and business logic
2. **Repository Tests**: Test data layer with mocked data sources
3. **BLoC Tests**: Test state management logic
4. **Widget Tests**: Test UI components
5. **Integration Tests**: Test complete user flows

## Future Enhancements

1. **Local Database**: Implement SQLite for offline data persistence
2. **Caching Strategy**: Add intelligent caching for better performance
3. **Real-time Updates**: Implement WebSocket connections for live data
4. **Push Notifications**: Add notification system for event reminders
5. **Offline Support**: Implement offline-first architecture
6. **Analytics**: Add user behavior tracking and analytics

## Contributing

When adding new features:

1. Start with the domain layer (entities, use cases, repository interfaces)
2. Implement the data layer (models, data sources, repositories)
3. Create the presentation layer (BLoCs, screens)
4. Update dependency injection
5. Add tests for all layers

This architecture ensures that the codebase remains clean, maintainable, and scalable as the project grows.
