# Hotel Service Implementation

This document explains how to use the Flutter Hotel Service implementation, which follows the same architecture and functionality as the Java `HotelService.java`.

## Overview

The Hotel Service provides comprehensive hotel search functionality using SerpAPI's Google Hotels API, with support for:
- Location-based hotel searches (including current GPS location)
- Date range filtering
- Guest count specifications
- Price and rating filtering
- Hotel class filtering
- Local storage of search results
- Reverse geocoding and location services

## Architecture

The implementation follows Clean Architecture principles with the following layers:

```
lib/
├── core/
│   ├── constants/
│   │   └── hotel_constants.dart          # Configuration constants
│   ├── error/
│   │   └── failures.dart                 # Error handling classes
│   ├── models/
│   │   └── hotel_models.dart             # Data models
│   ├── repositories/
│   │   └── hotel_repository.dart         # Repository interface & implementation
│   └── services/
│       ├── hotel_service.dart            # Main hotel service
│       ├── location_service.dart         # GPS and location services
│       └── google_maps_service.dart      # Google Maps API integration
├── domain/
│   └── usecases/
│       └── hotel_usecases.dart           # Business logic use cases
└── presentation/
    ├── blocs/
    │   └── hotel_bloc.dart               # State management
    ├── pages/
    │   └── hotel_search_page.dart        # Main search page
    └── widgets/
        ├── hotel_search_form.dart         # Search form widget
        └── hotel_results_list.dart        # Results display widget
```

## Setup

### 1. Dependencies

Add the following dependencies to your `pubspec.yaml`:

```yaml
dependencies:
  # Location services
  geolocator: ^11.0.0
  geocoding: ^3.0.0
  
  # File storage
  path_provider: ^2.1.4
  
  # State management
  flutter_bloc: ^8.1.4
  bloc: ^8.1.3
  
  # Functional programming
  dartz: ^0.10.1
  
  # JSON serialization
  json_annotation: ^4.8.1
  equatable: ^2.0.5
  
  # Logging
  logger: ^2.0.2+1
```

### 2. API Keys

You need to configure the following API keys:

#### SerpAPI Key
In `lib/core/services/hotel_service.dart`:
```dart
static const String _serpApiKey = 'YOUR_ACTUAL_SERPAPI_KEY';
```

#### Google Maps API Key
In `lib/core/services/google_maps_service.dart`:
```dart
static const String _googleMapsApiKey = 'YOUR_ACTUAL_GOOGLE_MAPS_API_KEY';
```

### 3. Generate JSON Code

Run the following command to generate the JSON serialization code:
```bash
flutter packages pub run build_runner build
```

## Usage

### Basic Hotel Search

```dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:your_app/core/services/hotel_service.dart';

// Initialize the service
final hotelService = HotelService();
await hotelService.initialize();

// Search for hotels
final result = await hotelService.searchHotels(
  location: 'New York',
  checkInDate: '2024-01-15',
  checkOutDate: '2024-01-17',
  adults: 2,
  children: 1,
  currency: 'USD',
  country: 'us',
  maxResults: 20,
);

// Handle the result
if (result.fullDetails.containsKey('error')) {
  print('Error: ${result.fullDetails['error']}');
} else {
  print('Found ${result.summary.totalProperties} hotels');
  print('Search ID: ${result.summary.searchId}');
}
```

### Using Current Location

```dart
// Search using current GPS location
final result = await hotelService.searchHotels(
  location: 'current_location',  // Special keyword
  adults: 2,
  children: 0,
  currency: 'USD',
  country: 'us',
);
```

### Filtering Hotels by Rating

```dart
// Filter hotels from a previous search
final filterResult = await hotelService.filterHotelsByRating(
  'search_id_from_previous_search',
  4.0,  // Minimum rating
);

print('Found ${filterResult.summary.totalFiltered} hotels with rating >= 4.0');
```

### Using the BLoC Pattern

```dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:your_app/presentation/blocs/hotel_bloc.dart';

// In your widget
BlocProvider(
  create: (context) => HotelBloc(
    searchHotels: SearchHotels(HotelRepositoryImpl(HotelService())),
    // ... other use cases
  ),
  child: YourWidget(),
);

// Dispatch search event
context.read<HotelBloc>().add(SearchHotelsEvent(
  location: 'Paris',
  adults: 2,
  children: 0,
));

// Listen to state changes
BlocBuilder<HotelBloc, HotelState>(
  builder: (context, state) {
    if (state is HotelLoading) {
      return CircularProgressIndicator();
    } else if (state is HotelSearchSuccess) {
      return HotelResultsList(result: state.result);
    } else if (state is HotelError) {
      return Text('Error: ${state.message}');
    }
    return Container();
  },
);
```

## Features

### 1. Location Services
- **GPS Location**: Automatically detect current location
- **Reverse Geocoding**: Convert coordinates to readable addresses
- **Address Validation**: Validate and geocode address inputs

### 2. Hotel Search
- **Flexible Location**: Support for city names, hotel names, or coordinates
- **Date Handling**: Automatic default dates if not specified
- **Guest Management**: Support for adults and children
- **Currency Support**: Multiple currency options
- **Country Filtering**: Location-specific results
- **Sorting Options**: By relevance, price, rating, or distance
- **Hotel Class Filtering**: Budget to luxury options

### 3. Data Management
- **Local Storage**: Save search results to device
- **Search History**: Track all previous searches
- **Result Filtering**: Filter by rating, price, etc.
- **Data Persistence**: Results survive app restarts

### 4. Error Handling
- **Network Errors**: Handle API failures gracefully
- **Location Errors**: GPS permission and service issues
- **Validation Errors**: Input validation and error messages
- **Fallback Mechanisms**: Graceful degradation when services fail

## API Endpoints

The service integrates with:

1. **SerpAPI Google Hotels**: Main hotel search functionality
2. **Google Maps API**: Geocoding and reverse geocoding
3. **Device GPS**: Current location detection

## Configuration Options

### Hotel Constants
```dart
class HotelConstants {
  // Default values
  static const String defaultCurrency = 'USD';
  static const String defaultCountry = 'us';
  static const int defaultMaxResults = 20;
  static const int defaultAdults = 2;
  static const int defaultChildren = 0;
  
  // Sort options
  static const int sortByRelevance = 0;
  static const int sortByPrice = 1;
  static const int sortByRating = 2;
  static const int sortByDistance = 3;
  
  // Hotel class options
  static const int hotelClassBudget = 1;
  static const int hotelClassEconomy = 2;
  static const int hotelClassMidRange = 3;
  static const int hotelClassUpscale = 4;
  static const int hotelClassLuxury = 5;
}
```

## Error Handling

The service provides comprehensive error handling:

```dart
try {
  final result = await hotelService.searchHotels(...);
  // Handle success
} catch (e) {
  if (e is LocationFailure) {
    // Handle location-related errors
  } else if (e is NetworkFailure) {
    // Handle network errors
  } else if (e is ServerFailure) {
    // Handle API errors
  }
}
```

## Best Practices

1. **Initialize Service**: Always call `initialize()` before using the service
2. **Handle Errors**: Implement proper error handling for all operations
3. **Location Permissions**: Request location permissions before using GPS features
4. **API Rate Limiting**: Be mindful of API call limits
5. **Data Validation**: Validate user inputs before making API calls
6. **Offline Support**: Handle cases where network is unavailable

## Troubleshooting

### Common Issues

1. **Location Services Disabled**
   - Check if GPS is enabled
   - Request location permissions
   - Handle permission denial gracefully

2. **API Key Issues**
   - Verify SerpAPI key is valid
   - Check Google Maps API key configuration
   - Ensure API quotas are not exceeded

3. **Network Errors**
   - Check internet connectivity
   - Verify API endpoints are accessible
   - Implement retry mechanisms

4. **JSON Parsing Errors**
   - Run `flutter packages pub run build_runner build`
   - Check model definitions match API responses
   - Validate JSON structure

## Example Implementation

See the complete example in:
- `lib/presentation/pages/hotel_search_page.dart` - Main search page
- `lib/presentation/widgets/hotel_search_form.dart` - Search form
- `lib/presentation/widgets/hotel_results_list.dart` - Results display

## Contributing

When adding new features:
1. Follow the existing architecture patterns
2. Add proper error handling
3. Include unit tests
4. Update this documentation
5. Follow Flutter coding standards

## License

This implementation follows the same licensing terms as the original Java HotelService.
