import 'package:logger/logger.dart';
import 'http_service.dart';
import 'auth_service.dart';
import '../models/auth_models.dart';

class CalendarService {
  static final CalendarService _instance = CalendarService._internal();
  factory CalendarService() => _instance;
  CalendarService._internal();

  final HttpService _httpService = HttpService();
  final AuthService _authService = AuthService();
  final Logger _logger = Logger();

  // Get user's calendar list from Google Calendar API
  Future<Map<String, dynamic>> getUserCalendars() async {
    try {
      _logger.i('📅 Fetching user calendars from Google Calendar API...');
      
      final response = await _httpService.makeGoogleCalendarRequest(
        endpoint: '/users/me/calendarList',
        method: 'GET',
      );

      if (_httpService.isSuccessResponse(response)) {
        final data = _httpService.handleResponse(response);
        _logger.i('✅ Successfully fetched ${data['items']?.length ?? 0} calendars');
        return data;
      } else {
        throw Exception('Failed to fetch calendars: ${_httpService.getErrorMessage(response)}');
      }
    } catch (e) {
      _logger.e('❌ Error fetching user calendars: $e');
      rethrow;
    }
  }

  // Get events from a specific calendar
  Future<Map<String, dynamic>> getCalendarEvents({
    required String calendarId,
    DateTime? timeMin,
    DateTime? timeMax,
    int? maxResults,
  }) async {
    try {
      _logger.i('📅 Fetching events from calendar: $calendarId');
      
      final queryParams = <String, String>{
        'timeMin': (timeMin ?? DateTime.now()).toIso8601String(),
        'maxResults': (maxResults ?? 50).toString(),
      };
      
      if (timeMax != null) {
        queryParams['timeMax'] = timeMax.toIso8601String();
      }

      final endpoint = '/calendars/${Uri.encodeComponent(calendarId)}/events?${Uri(queryParameters: queryParams).query}';
      
      final response = await _httpService.makeGoogleCalendarRequest(
        endpoint: endpoint,
        method: 'GET',
      );

      if (_httpService.isSuccessResponse(response)) {
        final data = _httpService.handleResponse(response);
        _logger.i('✅ Successfully fetched ${data['items']?.length ?? 0} events from calendar: $calendarId');
        return data;
      } else {
        throw Exception('Failed to fetch events: ${_httpService.getErrorMessage(response)}');
      }
    } catch (e) {
      _logger.e('❌ Error fetching calendar events: $e');
      rethrow;
    }
  }

  // Create a new calendar event
  Future<Map<String, dynamic>> createCalendarEvent({
    required String calendarId,
    required String summary,
    required String description,
    required DateTime startTime,
    required DateTime endTime,
    String? location,
    List<String>? attendees,
  }) async {
    try {
      _logger.i('📅 Creating new calendar event: $summary');
      
      final eventData = {
        'summary': summary,
        'description': description,
        'start': {
          'dateTime': startTime.toIso8601String(),
          'timeZone': 'UTC',
        },
        'end': {
          'dateTime': endTime.toIso8601String(),
          'timeZone': 'UTC',
        },
        if (location != null) 'location': location,
        if (attendees != null) 'attendees': attendees.map((email) => {'email': email}).toList(),
      };

      final response = await _httpService.makeGoogleCalendarRequest(
        endpoint: '/calendars/${Uri.encodeComponent(calendarId)}/events',
        method: 'POST',
        requestBody: eventData,
        eventId: 'new',
      );

      if (_httpService.isSuccessResponse(response)) {
        final data = _httpService.handleResponse(response);
        _logger.i('✅ Successfully created calendar event: ${data['id']}');
        return data;
      } else {
        throw Exception('Failed to create event: ${_httpService.getErrorMessage(response)}');
      }
    } catch (e) {
      _logger.e('❌ Error creating calendar event: $e');
      rethrow;
    }
  }

  // Update an existing calendar event
  Future<Map<String, dynamic>> updateCalendarEvent({
    required String calendarId,
    required String eventId,
    String? summary,
    String? description,
    DateTime? startTime,
    DateTime? endTime,
    String? location,
    List<String>? attendees,
  }) async {
    try {
      _logger.i('📅 Updating calendar event: $eventId');
      
      final eventData = <String, dynamic>{};
      if (summary != null) eventData['summary'] = summary;
      if (description != null) eventData['description'] = description;
      if (startTime != null) {
        eventData['start'] = {
          'dateTime': startTime.toIso8601String(),
          'timeZone': 'UTC',
        };
      }
      if (endTime != null) {
        eventData['end'] = {
          'dateTime': endTime.toIso8601String(),
          'timeZone': 'UTC',
        };
      }
      if (location != null) eventData['location'] = location;
      if (attendees != null) {
        eventData['attendees'] = attendees.map((email) => {'email': email}).toList();
      }

      final response = await _httpService.makeGoogleCalendarRequest(
        endpoint: '/calendars/${Uri.encodeComponent(calendarId)}/events/${Uri.encodeComponent(eventId)}',
        method: 'PATCH',
        requestBody: eventData,
        eventId: eventId,
      );

      if (_httpService.isSuccessResponse(response)) {
        final data = _httpService.handleResponse(response);
        _logger.i('✅ Successfully updated calendar event: $eventId');
        return data;
      } else {
        throw Exception('Failed to update event: ${_httpService.getErrorMessage(response)}');
      }
    } catch (e) {
      _logger.e('❌ Error updating calendar event: $e');
      rethrow;
    }
  }

  // Delete a calendar event
  Future<bool> deleteCalendarEvent({
    required String calendarId,
    required String eventId,
  }) async {
    try {
      _logger.i('📅 Deleting calendar event: $eventId');
      
      final response = await _httpService.makeGoogleCalendarRequest(
        endpoint: '/calendars/${Uri.encodeComponent(calendarId)}/events/${Uri.encodeComponent(eventId)}',
        method: 'DELETE',
        eventId: eventId,
      );

      if (response.statusCode == 204) {
        _logger.i('✅ Successfully deleted calendar event: $eventId');
        return true;
      } else {
        throw Exception('Failed to delete event: ${_httpService.getErrorMessage(response)}');
      }
    } catch (e) {
      _logger.e('❌ Error deleting calendar event: $e');
      rethrow;
    }
  }

  // Use the custom calendar API with JWT token
  Future<Map<String, dynamic>> makeCustomCalendarRequest({
    required String operation,
    Map<String, dynamic>? requestData,
    String? eventId,
  }) async {
    try {
      _logger.i('📅 Making custom calendar request: $operation');
      
      final authData = await _authService.getAuthData();
      if (authData == null) {
        throw Exception('User not authenticated');
      }

      final response = await _httpService.makeCalendarRequest(
        operation: operation,
        requestBody: requestData,
        eventId: eventId,
        userId: authData.user.id,
      );

      if (_httpService.isSuccessResponse(response)) {
        final data = _httpService.handleResponse(response);
        _logger.i('✅ Custom calendar request successful: $operation');
        return data;
      } else {
        throw Exception('Custom calendar request failed: ${_httpService.getErrorMessage(response)}');
      }
    } catch (e) {
      _logger.e('❌ Error in custom calendar request: $e');
      rethrow;
    }
  }

  // Check calendar access permissions
  Future<bool> checkCalendarAccess() async {
    try {
      final authData = await _authService.getAuthData();
      if (authData == null) return false;

      final hasAccess = _authService.hasCalendarAccess(authData);
      final calendarScopes = _authService.getCalendarScopes(authData);
      
      _logger.i('📅 Calendar access check: $hasAccess');
      _logger.i('📅 Available calendar scopes: ${calendarScopes.join(', ')}');
      
      return hasAccess;
    } catch (e) {
      _logger.e('❌ Error checking calendar access: $e');
      return false;
    }
  }

  // Refresh authentication tokens if needed
  Future<bool> refreshTokensIfNeeded() async {
    try {
      final authData = await _authService.getAuthData();
      if (authData == null) return false;

      bool needsRefresh = false;

      // Check if JWT token is expired
      if (_authService.isJwtTokenExpired(authData)) {
        _logger.i('🔄 JWT token expired, refreshing...');
        needsRefresh = true;
      }

      // Check if Google access token is expired
      if (_authService.isTokenExpired(authData)) {
        _logger.i('🔄 Google access token expired, refreshing...');
        needsRefresh = true;
      }

      if (needsRefresh) {
        final newJwtToken = await _authService.getJwtToken();
        final newAccessToken = await _authService.getGoogleAccessToken();
        
        if (newJwtToken != null && newAccessToken != null) {
          _logger.i('✅ Tokens refreshed successfully');
          return true;
        } else {
          _logger.e('❌ Failed to refresh tokens');
          return false;
        }
      }

      return true;
    } catch (e) {
      _logger.e('❌ Error refreshing tokens: $e');
      return false;
    }
  }
}
