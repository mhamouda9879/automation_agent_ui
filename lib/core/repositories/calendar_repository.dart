import 'dart:convert';
import '../models/calendar_event.dart';
import '../services/http_service.dart';
import '../constants/api_constants.dart';

class CalendarRepository {
  final HttpService _httpService = HttpService();

  // List calendar events
  Future<List<CalendarEvent>> listEvents({
    DateTime? timeMin,
    DateTime? timeMax,
    int maxResults = 3,
  }) async {
    try {
      final requestBody = <String, dynamic>{
        'max_results': maxResults,
      };

      if (timeMin != null) {
        requestBody['time_min'] = timeMin.toIso8601String();
      }
      if (timeMax != null) {
        requestBody['time_max'] = timeMax.toIso8601String();
      }

      final response = await _httpService.makeCalendarRequest(
        operation: ApiConstants.calendarListEvents,
        requestBody: requestBody,
      );

      final responseData = _httpService.handleResponse(response);
      final calendarResponse = CalendarEventResponse.fromJson(responseData);

      if (calendarResponse.success && calendarResponse.events != null) {
        return calendarResponse.events!;
      } else {
        throw Exception(calendarResponse.message ?? 'Failed to list events');
      }
    } catch (e) {
      throw Exception('Failed to list events: $e');
    }
  }

  // Check availability
  Future<AvailabilityCheckResponse> checkAvailability(String query) async {
    try {
      final requestBody = <String, dynamic>{
        'query': query,
      };

      final response = await _httpService.makeCalendarRequest(
        operation: ApiConstants.calendarCheckAvailability,
        requestBody: requestBody,
      );

      final responseData = _httpService.handleResponse(response);
      return AvailabilityCheckResponse.fromJson(responseData);
    } catch (e) {
      throw Exception('Failed to check availability: $e');
    }
  }

  // Draft calendar event
  Future<String> draftCalendarEvent({
    required String summary,
    required DateTime startTime,
    required DateTime endTime,
    String? location,
    String? description,
    List<String>? attendees,
    bool allDay = false,
  }) async {
    try {
      final requestBody = <String, dynamic>{
        'summary': summary,
        'start_time': startTime.toIso8601String(),
        'end_time': endTime.toIso8601String(),
        'all_day': allDay,
      };

      if (location != null) {
        requestBody['location'] = location;
      }
      if (description != null) {
        requestBody['description'] = description;
      }
      if (attendees != null && attendees.isNotEmpty) {
        requestBody['attendees'] = attendees;
      }

      final response = await _httpService.makeCalendarRequest(
        operation: ApiConstants.calendarDraftEvent,
        requestBody: requestBody,
      );

      final responseData = _httpService.handleResponse(response);
      final calendarResponse = CalendarEventResponse.fromJson(responseData);

      if (calendarResponse.success && calendarResponse.draftId != null) {
        return calendarResponse.draftId!;
      } else {
        throw Exception(calendarResponse.message ?? 'Failed to draft calendar event');
      }
    } catch (e) {
      throw Exception('Failed to draft calendar event: $e');
    }
  }

  // Send calendar draft
  Future<bool> sendCalendarDraft(String draftId) async {
    try {
      final requestBody = <String, dynamic>{
        'draft_id': draftId,
      };

      final response = await _httpService.makeCalendarRequest(
        operation: ApiConstants.calendarSendDraft,
        requestBody: requestBody,
      );

      final responseData = _httpService.handleResponse(response);
      final calendarResponse = CalendarEventResponse.fromJson(responseData);

      return calendarResponse.success;
    } catch (e) {
      throw Exception('Failed to send calendar draft: $e');
    }
  }

  // Update calendar event
  Future<bool> updateEvent({
    required String eventId,
    String? summary,
    DateTime? startTime,
    DateTime? endTime,
    String? location,
    String? description,
    List<String>? attendees,
    bool? allDay,
  }) async {
    try {
      final requestBody = <String, dynamic>{
        'event_id': eventId,
      };

      if (summary != null) {
        requestBody['summary'] = summary;
      }
      if (startTime != null) {
        requestBody['start_time'] = startTime.toIso8601String();
      }
      if (endTime != null) {
        requestBody['end_time'] = endTime.toIso8601String();
      }
      if (location != null) {
        requestBody['location'] = location;
      }
      if (description != null) {
        requestBody['description'] = description;
      }
      if (attendees != null) {
        requestBody['attendees'] = attendees;
      }
      if (allDay != null) {
        requestBody['all_day'] = allDay;
      }

      final response = await _httpService.makeCalendarRequest(
        operation: ApiConstants.calendarUpdateEvent,
        requestBody: requestBody,
      );

      final responseData = _httpService.handleResponse(response);
      final calendarResponse = CalendarEventResponse.fromJson(responseData);

      return calendarResponse.success;
    } catch (e) {
      throw Exception('Failed to update event: $e');
    }
  }

  // Delete calendar event
  Future<bool> deleteEvent(String eventId) async {
    try {
      final requestBody = <String, dynamic>{
        'event_id': eventId,
      };

      final response = await _httpService.makeCalendarRequest(
        operation: ApiConstants.calendarDeleteEvent,
        requestBody: requestBody,
      );

      final responseData = _httpService.handleResponse(response);
      final calendarResponse = CalendarEventResponse.fromJson(responseData);

      return calendarResponse.success;
    } catch (e) {
      throw Exception('Failed to delete event: $e');
    }
  }

  // Get upcoming events (next 7 days)
  Future<List<CalendarEvent>> getUpcomingEvents({int maxResults = 10}) async {
    final now = DateTime.now();
    final nextWeek = now.add(const Duration(days: 7));
    
    return listEvents(
      timeMin: now,
      timeMax: nextWeek,
      maxResults: maxResults,
    );
  }

  // Get today's events
  Future<List<CalendarEvent>> getTodayEvents() async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    
    return listEvents(
      timeMin: startOfDay,
      timeMax: endOfDay,
      maxResults: 20,
    );
  }
}
