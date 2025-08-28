import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/hotel_constants.dart';
import '../models/hotel_models.dart';
import 'package:logger/logger.dart';

class GoogleMapsService {
  static final GoogleMapsService _instance = GoogleMapsService._internal();
  factory GoogleMapsService() => _instance;
  GoogleMapsService._internal();

  final Logger _logger = Logger();
  final String _tag = HotelConstants.logTag;
  
  // You would need to add your Google Maps API key to your configuration
  static const String _googleMapsApiKey = 'YOUR_GOOGLE_MAPS_API_KEY_HERE';
  static const String _googleMapsBaseUrl = 'https://maps.googleapis.com/maps/api';

  /// Reverse geocode coordinates to get address
  Future<ReverseGeocodeResult> reverseGeocode(double latitude, double longitude) async {
    try {
      _logger.i('$_tag - Google Maps reverse geocoding: $latitude, $longitude');
      
      if (_googleMapsApiKey == 'YOUR_GOOGLE_MAPS_API_KEY_HERE') {
        _logger.w('$_tag - Google Maps API key not configured, using fallback');
        return const ReverseGeocodeResult(
          error: 'Google Maps API key not configured',
        );
      }

      final url = Uri.parse(
        '$_googleMapsBaseUrl/geocode/json?latlng=$latitude,$longitude&key=$_googleMapsApiKey'
      );

      final response = await http.get(url).timeout(HotelConstants.connectTimeout);
      
      if (response.statusCode != 200) {
        _logger.e('$_tag - Google Maps API error: ${response.statusCode}');
        return ReverseGeocodeResult(
          error: 'Google Maps API error: ${response.statusCode}',
        );
      }

      final data = json.decode(response.body);
      
      if (data['status'] != 'OK') {
        _logger.w('$_tag - Google Maps API status: ${data['status']}');
        return ReverseGeocodeResult(
          error: 'Google Maps API status: ${data['status']}',
        );
      }

      final results = data['results'] as List<dynamic>;
      
      if (results.isEmpty) {
        _logger.w('$_tag - No results from Google Maps API');
        return const ReverseGeocodeResult(
          error: 'No results from Google Maps API',
        );
      }

      _logger.i('$_tag - Google Maps reverse geocoding successful');
      
      return ReverseGeocodeResult(
        results: results.cast<Map<String, dynamic>>(),
      );
      
    } catch (e) {
      _logger.e('$_tag - Error in Google Maps reverse geocoding: $e');
      return ReverseGeocodeResult(
        error: 'Error in Google Maps reverse geocoding: $e',
      );
    }
  }

  /// Geocode address to get coordinates
  Future<LocationResult> geocodeAddress(String address) async {
    try {
      _logger.i('$_tag - Google Maps geocoding address: $address');
      
      if (_googleMapsApiKey == 'YOUR_GOOGLE_MAPS_API_KEY_HERE') {
        _logger.w('$_tag - Google Maps API key not configured, using fallback');
        return const LocationResult(
          error: 'Google Maps API key not configured',
        );
      }

      final encodedAddress = Uri.encodeComponent(address);
      final url = Uri.parse(
        '$_googleMapsBaseUrl/geocode/json?address=$encodedAddress&key=$_googleMapsApiKey'
      );

      final response = await http.get(url).timeout(HotelConstants.connectTimeout);
      
      if (response.statusCode != 200) {
        _logger.e('$_tag - Google Maps API error: ${response.statusCode}');
        return LocationResult(
          error: 'Google Maps API error: ${response.statusCode}',
        );
      }

      final data = json.decode(response.body);
      
      if (data['status'] != 'OK') {
        _logger.w('$_tag - Google Maps API status: ${data['status']}');
        return LocationResult(
          error: 'Google Maps API status: ${data['status']}',
        );
      }

      final results = data['results'] as List<dynamic>;
      
      if (results.isEmpty) {
        _logger.w('$_tag - No results from Google Maps API');
        return const LocationResult(
          error: 'No results from Google Maps API',
        );
      }

      final firstResult = results.first;
      final geometry = firstResult['geometry'];
      final location = geometry['location'];
      
      final latitude = location['lat'] as double;
      final longitude = location['lng'] as double;

      _logger.i('$_tag - Google Maps geocoding successful: $latitude, $longitude');
      
      return LocationResult(
        latitude: latitude,
        longitude: longitude,
      );
      
    } catch (e) {
      _logger.e('$_tag - Error in Google Maps geocoding: $e');
      return LocationResult(
        error: 'Error in Google Maps geocoding: $e',
      );
    }
  }

  /// Get place details
  Future<Map<String, dynamic>?> getPlaceDetails(String placeId) async {
    try {
      _logger.i('$_tag - Google Maps getting place details: $placeId');
      
      if (_googleMapsApiKey == 'YOUR_GOOGLE_MAPS_API_KEY_HERE') {
        _logger.w('$_tag - Google Maps API key not configured');
        return null;
      }

      final url = Uri.parse(
        '$_googleMapsBaseUrl/place/details/json?place_id=$placeId&key=$_googleMapsApiKey'
      );

      final response = await http.get(url).timeout(HotelConstants.connectTimeout);
      
      if (response.statusCode != 200) {
        _logger.e('$_tag - Google Maps API error: ${response.statusCode}');
        return null;
      }

      final data = json.decode(response.body);
      
      if (data['status'] != 'OK') {
        _logger.w('$_tag - Google Maps API status: ${data['status']}');
        return null;
      }

      _logger.i('$_tag - Google Maps place details successful');
      
      return data['result'] as Map<String, dynamic>;
      
    } catch (e) {
      _logger.e('$_tag - Error getting Google Maps place details: $e');
      return null;
    }
  }

  /// Search for places
  Future<List<Map<String, dynamic>>> searchPlaces(String query, {String? location}) async {
    try {
      _logger.i('$_tag - Google Maps searching places: $query');
      
      if (_googleMapsApiKey == 'YOUR_GOOGLE_MAPS_API_KEY_HERE') {
        _logger.w('$_tag - Google Maps API key not configured');
        return [];
      }

      String urlString = '$_googleMapsBaseUrl/place/textsearch/json?query=${Uri.encodeComponent(query)}&key=$_googleMapsApiKey';
      
      if (location != null) {
        urlString += '&location=${Uri.encodeComponent(location)}';
      }

      final url = Uri.parse(urlString);

      final response = await http.get(url).timeout(HotelConstants.connectTimeout);
      
      if (response.statusCode != 200) {
        _logger.e('$_tag - Google Maps API error: ${response.statusCode}');
        return [];
      }

      final data = json.decode(response.body);
      
      if (data['status'] != 'OK') {
        _logger.w('$_tag - Google Maps API status: ${data['status']}');
        return [];
      }

      final results = data['results'] as List<dynamic>;
      
      _logger.i('$_tag - Google Maps search successful: ${results.length} results');
      
      return results.cast<Map<String, dynamic>>();
      
    } catch (e) {
      _logger.e('$_tag - Error searching Google Maps places: $e');
      return [];
    }
  }
}
