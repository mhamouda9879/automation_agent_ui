import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';

import '../constants/api_config.dart';
import '../models/auth_models.dart';

class ApiService {
  final Logger _logger = Logger();

  // Make an authenticated API request with JWT token
  Future<http.Response> authenticatedRequest(
    String url,
    String jwtToken, {
    String method = 'GET',
    Map<String, String>? headers,
    Object? body,
  }) async {
    try {
      final requestHeaders = <String, String>{
        'Content-Type': 'application/json',
        'X-Samantha-JWT': jwtToken, // Same header as android-agent
        ...?headers,
      };

      _logger.i('🌐 Making authenticated request to: $url');
      _logger.d('🔑 Using JWT token: ${jwtToken.substring(0, 20)}...');

      http.Response response;
      
      switch (method.toUpperCase()) {
        case 'GET':
          response = await http.get(
            Uri.parse(url),
            headers: requestHeaders,
          );
          break;
        case 'POST':
          response = await http.post(
            Uri.parse(url),
            headers: requestHeaders,
            body: body is String ? body : jsonEncode(body),
          );
          break;
        case 'PUT':
          response = await http.put(
            Uri.parse(url),
            headers: requestHeaders,
            body: body is String ? body : jsonEncode(body),
          );
          break;
        case 'DELETE':
          response = await http.delete(
            Uri.parse(url),
            headers: requestHeaders,
            body: body is String ? body : jsonEncode(body),
          );
          break;
        default:
          throw ArgumentError('Unsupported HTTP method: $method');
      }

      _logger.i('✅ API request completed: ${response.statusCode}');
      
      if (response.statusCode >= 400) {
        _logger.w('⚠️ API request failed: ${response.statusCode} - ${response.body}');
      }

      return response;
    } catch (error) {
      _logger.e('❌ Error making API request: $error');
      rethrow;
    }
  }

  // Example: Get contacts for authenticated user
  Future<List<Map<String, dynamic>>?> getContacts(String jwtToken) async {
    try {
      final response = await authenticatedRequest(
        ApiConfig.getContactsUrl(),
        jwtToken,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is Map<String, dynamic> && data.containsKey('contacts')) {
          final contacts = data['contacts'] as List;
          return contacts.cast<Map<String, dynamic>>();
        }
      }

      return null;
    } catch (error) {
      _logger.e('❌ Error getting contacts: $error');
      return null;
    }
  }

  // Example: Search contacts
  Future<List<Map<String, dynamic>>?> searchContacts(
    String jwtToken,
    String userEmail,
    String query,
  ) async {
    try {
      final searchUrl = '${ApiConfig.getContactsSearchUrl(userEmail)}?q=$query';
      
      final response = await authenticatedRequest(
        searchUrl,
        jwtToken,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is Map<String, dynamic> && data.containsKey('contacts')) {
          final contacts = data['contacts'] as List;
          return contacts.cast<Map<String, dynamic>>();
        }
      }

      return null;
    } catch (error) {
      _logger.e('❌ Error searching contacts: $error');
      return null;
    }
  }

  // Example: Send email through Email Agent
  Future<bool> sendEmail(
    String jwtToken,
    Map<String, dynamic> emailData,
  ) async {
    try {
      final response = await authenticatedRequest(
        ApiConfig.getEmailAgentUrl(ApiConfig.emailEndpoint),
        jwtToken,
        method: 'POST',
        body: emailData,
      );

      return response.statusCode == 200;
    } catch (error) {
      _logger.e('❌ Error sending email: $error');
      return false;
    }
  }

  // Example: Get WhatsApp connection status
  Future<Map<String, dynamic>?> getWhatsAppStatus(String jwtToken) async {
    try {
      final response = await authenticatedRequest(
        ApiConfig.getWhatsAppAgentUrl(ApiConfig.whatsappStatusEndpoint),
        jwtToken,
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }

      return null;
    } catch (error) {
      _logger.e('❌ Error getting WhatsApp status: $error');
      return null;
    }
  }

  // Example: Make a deep research request
  Future<Map<String, dynamic>?> makeDeepResearchRequest(
    String jwtToken,
    Map<String, dynamic> researchData,
  ) async {
    try {
      final response = await authenticatedRequest(
        '${ApiConfig.getDeepResearchUrl()}/research',
        jwtToken,
        method: 'POST',
        body: researchData,
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }

      return null;
    } catch (error) {
      _logger.e('❌ Error making deep research request: $error');
      return null;
    }
  }

  // Test API connectivity
  Future<bool> testApiConnection(String jwtToken) async {
    try {
      // Try to make a simple request to test connectivity
      final response = await authenticatedRequest(
        '${ApiConfig.getApiUrl('USER_SERVICE')}/health',
        jwtToken,
      );

      return response.statusCode == 200;
    } catch (error) {
      _logger.e('❌ API connection test failed: $error');
      return false;
    }
  }
}
