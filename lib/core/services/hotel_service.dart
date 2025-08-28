import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:logger/logger.dart';
import '../constants/hotel_constants.dart';
import '../models/hotel_models.dart';
import 'location_service.dart';
import 'google_maps_service.dart';

class HotelService {
  static final HotelService _instance = HotelService._internal();
  factory HotelService() => _instance;
  HotelService._internal();

  final Logger _logger = Logger();
  final String _tag = HotelConstants.logTag;
  
  final http.Client _httpClient = http.Client();
  final LocationService _locationService = LocationService();
  final GoogleMapsService _googleMapsService = GoogleMapsService();
  
  Directory? _hotelsDir;
  
  // You would need to add your SerpAPI key to your configuration
  static const String _serpApiKey = 'YOUR_SERPAPI_KEY_HERE';

  /// Initialize the service
  Future<void> initialize() async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      _hotelsDir = Directory('${appDir.path}/${HotelConstants.hotelsStorageDir}');
      
      if (!await _hotelsDir!.exists()) {
        await _hotelsDir!.create(recursive: true);
      }
      
      _logger.i('$_tag - Hotel service initialized');
    } catch (e) {
      _logger.e('$_tag - Error initializing hotel service: $e');
    }
  }

  /// Search for hotels using SerpAPI's Google Hotels API
  Future<HotelSearchResult> searchHotels({
    required String location,
    String? checkInDate,
    String? checkOutDate,
    int adults = HotelConstants.defaultAdults,
    int children = HotelConstants.defaultChildren,
    String currency = HotelConstants.defaultCurrency,
    String country = HotelConstants.defaultCountry,
    int? sortBy,
    List<int>? hotelClass,
    int maxResults = HotelConstants.defaultMaxResults,
  }) async {
    try {
      _logger.i('$_tag - searchHotels() method called');
      _logger.i('$_tag - Parameters received:');
      _logger.i('$_tag - Location: $location');
      _logger.i('$_tag - Dates: ${checkInDate ?? 'null'} to ${checkOutDate ?? 'null'}');
      _logger.i('$_tag - Guests: $adults adults, $children children');
      _logger.i('$_tag - Currency: $currency, Country: $country');
      
      // Handle current_location case
      String searchLocation = location;
      if (location == 'current_location') {
        _logger.i('$_tag - Handling current_location request');
        try {
          // Get current GPS coordinates using LocationService
          LocationResult locationResult = await _locationService.getCurrentLocation();
          if (locationResult.error != null) {
            return HotelSearchResult(
              summary: HotelSearchSummary(
                searchId: '',
                totalProperties: 0,
                location: '',
                dates: '',
                guests: '',
                searchType: 'hotels',
                searchParameters: {},
              ),
              fullDetails: {'error': 'Unable to get current location: ${locationResult.error}'},
            );
          }
          
          double latitude = locationResult.latitude!;
          double longitude = locationResult.longitude!;
          
          // Reverse geocode to get address using GoogleMapsService
          ReverseGeocodeResult reverseGeoResult = await _googleMapsService.reverseGeocode(latitude, longitude);
          if (reverseGeoResult.error != null) {
            _logger.w('$_tag - Reverse geocoding failed, using coordinates: ${reverseGeoResult.error}');
            // Fallback to coordinates if reverse geocoding fails
            searchLocation = '$latitude,$longitude';
          } else {
            // Extract address from reverse geocoding result
            if (reverseGeoResult.results != null && reverseGeoResult.results!.isNotEmpty) {
              String address = reverseGeoResult.results!.first['formatted_address'] ?? '';
              searchLocation = address;
              _logger.i('$_tag - Current location resolved to: $searchLocation');
            } else {
              // Fallback to coordinates if no results
              searchLocation = '$latitude,$longitude';
              _logger.w('$_tag - No reverse geocoding results, using coordinates: $searchLocation');
            }
          }
        } catch (e) {
          _logger.e('$_tag - Error handling current_location: $e');
          return HotelSearchResult(
            summary: HotelSearchSummary(
              searchId: '',
              totalProperties: 0,
              location: '',
              dates: '',
              guests: '',
              searchType: 'hotels',
              searchParameters: {},
            ),
            fullDetails: {'error': 'Error handling current location: $e'},
          );
        }
      }
      
      // Handle optional check-in and check-out dates
      String searchCheckInDate = checkInDate ?? '';
      String searchCheckOutDate = checkOutDate ?? '';
      
      if (checkInDate == null || checkInDate?.trim().isEmpty == true) {
        // Set default check-in date to tomorrow
        DateTime tomorrow = DateTime.now().add(const Duration(days: 1));
        searchCheckInDate = DateFormat(HotelConstants.dateFormat).format(tomorrow);
        _logger.i('$_tag - No check-in date provided, using default: $searchCheckInDate');
      }
      
      if (checkOutDate == null || checkOutDate?.trim().isEmpty == true) {
        // Set default check-out date to day after check-in
        try {
          DateTime checkIn = DateFormat(HotelConstants.dateFormat).parse(searchCheckInDate);
          DateTime checkOut = checkIn.add(const Duration(days: 1));
          searchCheckOutDate = DateFormat(HotelConstants.dateFormat).format(checkOut);
          _logger.i('$_tag - No check-out date provided, using default: $searchCheckOutDate');
        } catch (e) {
          _logger.w('$_tag - Error calculating default check-out date, using 2 days from now');
          DateTime twoDaysFromNow = DateTime.now().add(const Duration(days: 2));
          searchCheckOutDate = DateFormat(HotelConstants.dateFormat).format(twoDaysFromNow);
        }
      }
      
      // Validate SerpAPI key
      if (_serpApiKey == 'YOUR_SERPAPI_KEY_HERE') {
        return HotelSearchResult(
          summary: HotelSearchSummary(
            searchId: '',
            totalProperties: 0,
            location: '',
            dates: '',
            guests: '',
            searchType: 'hotels',
            searchParameters: {},
          ),
          fullDetails: {'error': HotelConstants.errorNoSerpApiKey},
        );
      }
      
      // Build request URL
      final queryParams = <String, String>{
        'engine': HotelConstants.googleHotelsEngine,
        'api_key': _serpApiKey,
        'q': searchLocation,
        'check_in_date': searchCheckInDate,
        'check_out_date': searchCheckOutDate,
        'adults': adults.toString(),
        'children': children.toString(),
        'currency': currency,
        'gl': country,
      };
      
      if (sortBy != null) {
        queryParams['sort_by'] = sortBy.toString();
      }
      
      if (hotelClass != null && hotelClass.isNotEmpty) {
        queryParams['hotel_class'] = hotelClass.join(',');
      }
      
      final uri = Uri.parse('${HotelConstants.serpapiBaseUrl}?${Uri(queryParameters: queryParams).query}');
      
      String url = uri.toString();
      _logger.d('$_tag - SerpAPI request URL: $url');
      
      // Make API request
      final response = await _httpClient.get(
        uri,
        headers: {'Content-Type': 'application/json'},
      ).timeout(HotelConstants.connectTimeout);
      
      if (response.statusCode != 200) {
        throw HttpException('Unexpected response code: ${response.statusCode}');
      }
      
      String responseBody = response.body;
      _logger.d('$_tag - SerpAPI response received');
      
      Map<String, dynamic> hotelData = json.decode(responseBody);
      
      // Create search identifier
      String searchId = searchLocation.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '_') 
        + '_$searchCheckInDate\_$searchCheckOutDate'
        + '_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}';
      
      // Process and store hotel results
      Map<String, dynamic> processedResults = {};
      
      // Search metadata
      Map<String, dynamic> searchMetadata = {
        'search_id': searchId,
        'location': searchLocation,
        'original_location_request': location,
        'check_in_date': searchCheckInDate,
        'check_out_date': searchCheckOutDate,
        'guests': {
          'adults': adults,
          'children': children,
        },
        'search_type': 'hotels',
        'currency': currency,
        'filters': {
          'sort_by': sortBy,
          if (hotelClass != null) 'hotel_class': hotelClass,
        },
        'search_timestamp': DateFormat(HotelConstants.timestampFormat).format(DateTime.now()),
      };
      
      if (searchCheckInDate != checkInDate || searchCheckOutDate != checkOutDate) {
        searchMetadata['original_dates_request'] = {
          'check_in_date': checkInDate,
          'check_out_date': checkOutDate,
        };
      }
      
      processedResults['search_metadata'] = searchMetadata;
      
      // Extract and limit hotel results
      List<dynamic>? properties = hotelData['properties'];
      if (properties != null) {
        int limit = properties.length < maxResults ? properties.length : maxResults;
        processedResults['properties'] = properties.take(limit).toList();
      } else {
        processedResults['properties'] = <dynamic>[];
      }
      
      // Add additional data
      processedResults['search_information'] = hotelData['search_information'];
      processedResults['brands'] = hotelData['brands'];
      processedResults['serpapi_pagination'] = hotelData['serpapi_pagination'];
      
      // Save results to file
      if (_hotelsDir != null) {
        File resultFile = File('${_hotelsDir!.path}/$searchId.json');
        try {
          await resultFile.writeAsString(json.encode(processedResults));
          _logger.d('$_tag - Hotel search results saved to: ${resultFile.path}');
        } catch (e) {
          _logger.w('$_tag - Could not save results to file: $e');
        }
      }
      
      // Calculate price range
      List<dynamic> propertiesForPricing = processedResults['properties'] ?? [];
      Map<String, dynamic>? priceRange;
      if (propertiesForPricing.isNotEmpty) {
        double minPrice = double.maxFinite;
        double maxPrice = double.negativeInfinity;
        bool hasPrices = false;
        
        for (var property in propertiesForPricing) {
          Map<String, dynamic>? ratePerNight = property['rate_per_night'];
          if (ratePerNight != null) {
            double? extractedLowest = ratePerNight['extracted_lowest']?.toDouble();
            if (extractedLowest != null && extractedLowest > 0) {
              minPrice = minPrice < extractedLowest ? minPrice : extractedLowest;
              maxPrice = maxPrice > extractedLowest ? maxPrice : extractedLowest;
              hasPrices = true;
            }
          }
        }
        
        if (hasPrices) {
          priceRange = {
            'min_price': minPrice,
            'max_price': maxPrice,
            'currency': currency,
          };
        }
      }
      
      // Build summary for tool call response
      Map<String, dynamic> summary = {
        'search_id': searchId,
        'total_properties': propertiesForPricing.length,
        'location': searchLocation,
        'dates': '$searchCheckInDate to $searchCheckOutDate',
        'guests': '$adults adults${children > 0 ? ', $children children' : ''}',
        'price_range': priceRange,
        'search_type': 'hotels',
        'search_parameters': searchMetadata,
      };
      
      if (searchLocation != location) {
        summary['original_location_request'] = location;
      }
      
      if (searchCheckInDate != checkInDate || searchCheckOutDate != checkOutDate) {
        summary['original_dates_request'] = {
          'check_in_date': checkInDate,
          'check_out_date': checkOutDate,
        };
      }
      
      // Return result with both summary and full details
      return HotelSearchResult(
        summary: HotelSearchSummary.fromJson(summary),
        fullDetails: processedResults,
      );
      
    } catch (e) {
      _logger.e('$_tag - Error during hotel search: $e');
      return HotelSearchResult(
        summary: HotelSearchSummary(
          searchId: '',
          totalProperties: 0,
          location: '',
          dates: '',
          guests: '',
          searchType: 'hotels',
          searchParameters: {},
        ),
        fullDetails: {'error': 'Error during hotel search: $e'},
      );
    }
  }

  /// Get detailed information about a specific hotel search
  Future<String> getHotelDetails(String searchId) async {
    try {
      if (_hotelsDir == null) {
        return 'Hotel service not initialized';
      }
      
      File resultFile = File('${_hotelsDir!.path}/$searchId.json');
      
      if (!await resultFile.exists()) {
        return 'No hotel search found with ID: $searchId';
      }
      
      String content = await resultFile.readAsString();
      return content;
      
    } catch (e) {
      _logger.e('$_tag - Error reading hotel data for $searchId: $e');
      return 'Error reading hotel data for $searchId: $e';
    }
  }

  /// Filter hotels from a search by minimum rating
  Future<HotelFilterResult> filterHotelsByRating(String searchId, double minRating) async {
    try {
      _logger.i('$_tag - filterHotelsByRating() method called');
      _logger.i('$_tag - Parameters received:');
      _logger.i('$_tag - Search ID: $searchId');
      _logger.i('$_tag - Minimum Rating: $minRating');
      
      String hotelDataStr = await getHotelDetails(searchId);
      if (hotelDataStr.startsWith('No hotel search found') || hotelDataStr.startsWith('Error')) {
        return HotelFilterResult(
          summary: HotelSearchSummary(
            searchId: searchId,
            totalProperties: 0,
            location: '',
            dates: '',
            guests: '',
            searchType: 'hotels',
            searchParameters: {},
          ),
          fullDetails: {'error': hotelDataStr},
        );
      }
      
      Map<String, dynamic> hotelData = json.decode(hotelDataStr);
      List<dynamic>? properties = hotelData['properties'];
      
      List<dynamic> filteredProperties = [];
      
      // Filter properties by rating
      if (properties != null) {
        for (var property in properties) {
          double rating = (property['overall_rating'] ?? 0).toDouble();
          if (rating >= minRating) {
            filteredProperties.add(property);
          }
        }
      }
      
      // Build full details result
      Map<String, dynamic> fullDetails = {
        'search_id': searchId,
        'filters_applied': {
          'min_rating': minRating,
        },
        'filtered_properties': filteredProperties,
        'total_filtered': filteredProperties.length,
      };
      
      // Build summary result
      Map<String, dynamic> summary = {
        'search_id': searchId,
        'total_filtered': filteredProperties.length,
        'filters_applied': {
          'min_rating': minRating,
        },
      };
      
      // Return result with both summary and full details
      return HotelFilterResult(
        summary: HotelSearchSummary.fromJson(summary),
        fullDetails: fullDetails,
      );
      
    } catch (e) {
      _logger.e('$_tag - Error filtering hotels by rating for $searchId: $e');
      return HotelFilterResult(
        summary: HotelSearchSummary(
          searchId: searchId,
          totalProperties: 0,
          location: '',
          dates: '',
          guests: '',
          searchType: 'hotels',
          searchParameters: {},
        ),
        fullDetails: {'error': 'Error processing hotel data for $searchId: $e'},
      );
    }
  }

  /// Get all stored hotel searches
  Future<List<String>> getAllHotelSearchIds() async {
    try {
      if (_hotelsDir == null) {
        return [];
      }
      
      List<FileSystemEntity> files = _hotelsDir!.listSync();
      List<String> searchIds = [];
      
      for (var file in files) {
        if (file is File && file.path.endsWith('.json')) {
          String fileName = file.path.split('/').last;
          String searchId = fileName.replaceAll('.json', '');
          searchIds.add(searchId);
        }
      }
      
      return searchIds;
    } catch (e) {
      _logger.e('$_tag - Error getting hotel search IDs: $e');
      return [];
    }
  }

  /// Delete a specific hotel search
  Future<bool> deleteHotelSearch(String searchId) async {
    try {
      if (_hotelsDir == null) {
        return false;
      }
      
      File resultFile = File('${_hotelsDir!.path}/$searchId.json');
      
      if (await resultFile.exists()) {
        await resultFile.delete();
        _logger.i('$_tag - Deleted hotel search: $searchId');
        return true;
      }
      
      return false;
    } catch (e) {
      _logger.e('$_tag - Error deleting hotel search $searchId: $e');
      return false;
    }
  }

  /// Clear all stored hotel searches
  Future<bool> clearAllHotelSearches() async {
    try {
      if (_hotelsDir == null) {
        return false;
      }
      
      List<FileSystemEntity> files = _hotelsDir!.listSync();
      
      for (var file in files) {
        if (file is File && file.path.endsWith('.json')) {
          await file.delete();
        }
      }
      
      _logger.i('$_tag - Cleared all hotel searches');
      return true;
    } catch (e) {
      _logger.e('$_tag - Error clearing hotel searches: $e');
      return false;
    }
  }
}
