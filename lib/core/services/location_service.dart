import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;
import '../constants/hotel_constants.dart';
import '../models/hotel_models.dart';
import 'package:logger/logger.dart';

class LocationService {
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  final Logger _logger = Logger();
  final String _tag = HotelConstants.logTag;

  /// Get current location using GPS
  Future<LocationResult> getCurrentLocation() async {
    try {
      _logger.i('$_tag - Getting current location');
      
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _logger.w('$_tag - Location services are disabled');
        return const LocationResult(
          error: 'Location services are disabled. Please enable GPS.',
        );
      }

      // Check location permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _logger.w('$_tag - Location permissions denied');
          return const LocationResult(
            error: 'Location permissions denied',
          );
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _logger.w('$_tag - Location permissions permanently denied');
        return const LocationResult(
          error: 'Location permissions permanently denied. Please enable in settings.',
        );
      }

      // Get current position
      _logger.d('$_tag - Requesting current position');
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      _logger.i('$_tag - Current location obtained: ${position.latitude}, ${position.longitude}');
      
      return LocationResult(
        latitude: position.latitude,
        longitude: position.longitude,
      );
      
    } catch (e) {
      _logger.e('$_tag - Error getting current location: $e');
      return LocationResult(
        error: 'Error getting current location: $e',
      );
    }
  }

  /// Reverse geocode coordinates to get address
  Future<ReverseGeocodeResult> reverseGeocode(double latitude, double longitude) async {
    try {
      _logger.i('$_tag - Reverse geocoding coordinates: $latitude, $longitude');
      
      List<Placemark> placemarks = await placemarkFromCoordinates(latitude, longitude);
      
      if (placemarks.isEmpty) {
        _logger.w('$_tag - No placemarks found for coordinates');
        return const ReverseGeocodeResult(
          error: 'No address found for the given coordinates',
        );
      }

      // Convert placemarks to JSON format
      List<Map<String, dynamic>> results = placemarks.map((placemark) {
        return {
          'formatted_address': _formatAddress(placemark),
          'place_id': '${placemark.isoCountryCode}_${placemark.locality}_${placemark.thoroughfare}',
          'types': ['locality', 'political'],
          'address_components': [
            {
              'long_name': placemark.name ?? '',
              'short_name': placemark.name ?? '',
              'types': ['establishment']
            },
            {
              'long_name': placemark.thoroughfare ?? '',
              'short_name': placemark.thoroughfare ?? '',
              'types': ['route']
            },
            {
              'long_name': placemark.locality ?? '',
              'short_name': placemark.locality ?? '',
              'types': ['locality', 'political']
            },
            {
              'long_name': placemark.administrativeArea ?? '',
              'short_name': placemark.administrativeArea ?? '',
              'types': ['administrative_area_level_1', 'political']
            },
            {
              'long_name': placemark.country ?? '',
              'short_name': placemark.isoCountryCode ?? '',
              'types': ['country', 'political']
            },
          ],
        };
      }).toList();

      _logger.i('$_tag - Reverse geocoding successful: ${results.first['formatted_address']}');
      
      return ReverseGeocodeResult(results: results);
      
    } catch (e) {
      _logger.e('$_tag - Error in reverse geocoding: $e');
      return ReverseGeocodeResult(
        error: 'Error in reverse geocoding: $e',
      );
    }
  }

  /// Format address from placemark
  String _formatAddress(Placemark placemark) {
    List<String> addressParts = [];
    
    if (placemark.name != null && placemark.name!.isNotEmpty) {
      addressParts.add(placemark.name!);
    }
    
    if (placemark.thoroughfare != null && placemark.thoroughfare!.isNotEmpty) {
      addressParts.add(placemark.thoroughfare!);
    }
    
    if (placemark.locality != null && placemark.locality!.isNotEmpty) {
      addressParts.add(placemark.locality!);
    }
    
    if (placemark.administrativeArea != null && placemark.administrativeArea!.isNotEmpty) {
      addressParts.add(placemark.administrativeArea!);
    }
    
    if (placemark.country != null && placemark.country!.isNotEmpty) {
      addressParts.add(placemark.country!);
    }
    
    return addressParts.join(', ');
  }

  /// Get location from address string
  Future<LocationResult> getLocationFromAddress(String address) async {
    try {
      _logger.i('$_tag - Getting location from address: $address');
      
      List<Location> locations = await locationFromAddress(address);
      
      if (locations.isEmpty) {
        _logger.w('$_tag - No locations found for address: $address');
        return LocationResult(
          error: 'No location found for the given address',
        );
      }

      Location location = locations.first;
      _logger.i('$_tag - Location found: ${location.latitude}, ${location.longitude}');
      
      return LocationResult(
        latitude: location.latitude,
        longitude: location.longitude,
      );
      
    } catch (e) {
      _logger.e('$_tag - Error getting location from address: $e');
      return LocationResult(
        error: 'Error getting location from address: $e',
      );
    }
  }

  /// Calculate distance between two coordinates
  double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    return Geolocator.distanceBetween(lat1, lon1, lat2, lon2);
  }

  /// Check if location is within radius
  bool isWithinRadius(
    double centerLat, 
    double centerLon, 
    double targetLat, 
    double targetLon, 
    double radiusInMeters
  ) {
    double distance = calculateDistance(centerLat, centerLon, targetLat, targetLon);
    return distance <= radiusInMeters;
  }
}
