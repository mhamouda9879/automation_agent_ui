import 'package:flutter/foundation.dart';
import '../models/calendar_event.dart';
import '../repositories/calendar_repository.dart';

class CalendarProvider extends ChangeNotifier {
  final CalendarRepository _repository = CalendarRepository();
  
  // State variables
  List<CalendarEvent> _events = [];
  List<CalendarEvent> _todayEvents = [];
  List<CalendarEvent> _upcomingEvents = [];
  bool _isLoading = false;
  String? _error;
  String? _lastDraftId;

  // Getters
  List<CalendarEvent> get events => _events;
  List<CalendarEvent> get todayEvents => _todayEvents;
  List<CalendarEvent> get upcomingEvents => _upcomingEvents;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get lastDraftId => _lastDraftId;

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // Set error
  void _setError(String error) {
    _error = error;
    _isLoading = false;
    notifyListeners();
  }

  // Load all events
  Future<void> loadEvents({DateTime? timeMin, DateTime? timeMax, int maxResults = 10}) async {
    try {
      _setLoading(true);
      _error = null;
      
      _events = await _repository.listEvents(
        timeMin: timeMin,
        timeMax: timeMax,
        maxResults: maxResults,
      );
      
      _setLoading(false);
    } catch (e) {
      _setError('Failed to load events: $e');
    }
  }

  // Load today's events
  Future<void> loadTodayEvents() async {
    try {
      _setLoading(true);
      _error = null;
      
      _todayEvents = await _repository.getTodayEvents();
      
      _setLoading(false);
    } catch (e) {
      _setError('Failed to load today\'s events: $e');
    }
  }

  // Load upcoming events
  Future<void> loadUpcomingEvents({int maxResults = 10}) async {
    try {
      _setLoading(true);
      _error = null;
      
      _upcomingEvents = await _repository.getUpcomingEvents(maxResults: maxResults);
      
      _setLoading(false);
    } catch (e) {
      _setError('Failed to load upcoming events: $e');
    }
  }

  // Check availability
  Future<AvailabilityCheckResponse?> checkAvailability(String query) async {
    try {
      _setLoading(true);
      _error = null;
      
      final response = await _repository.checkAvailability(query);
      
      _setLoading(false);
      return response;
    } catch (e) {
      _setError('Failed to check availability: $e');
      return null;
    }
  }

  // Draft calendar event
  Future<bool> draftEvent({
    required String summary,
    required DateTime startTime,
    required DateTime endTime,
    String? location,
    String? description,
    List<String>? attendees,
    bool allDay = false,
  }) async {
    try {
      _setLoading(true);
      _error = null;
      
      final draftId = await _repository.draftCalendarEvent(
        summary: summary,
        startTime: startTime,
        endTime: endTime,
        location: location,
        description: description,
        attendees: attendees,
        allDay: allDay,
      );
      
      _lastDraftId = draftId;
      _setLoading(false);
      
      // Refresh events after drafting
      await loadEvents();
      
      return true;
    } catch (e) {
      _setError('Failed to draft event: $e');
      return false;
    }
  }

  // Send calendar draft
  Future<bool> sendDraft(String draftId) async {
    try {
      _setLoading(true);
      _error = null;
      
      final success = await _repository.sendCalendarDraft(draftId);
      
      if (success) {
        _lastDraftId = null; // Clear draft ID after sending
        // Refresh events after sending
        await loadEvents();
      }
      
      _setLoading(false);
      return success;
    } catch (e) {
      _setError('Failed to send draft: $e');
      return false;
    }
  }

  // Update event
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
      _setLoading(true);
      _error = null;
      
      final success = await _repository.updateEvent(
        eventId: eventId,
        summary: summary,
        startTime: startTime,
        endTime: endTime,
        location: location,
        description: description,
        attendees: attendees,
        allDay: allDay,
      );
      
      if (success) {
        // Refresh events after updating
        await loadEvents();
      }
      
      _setLoading(false);
      return success;
    } catch (e) {
      _setError('Failed to update event: $e');
      return false;
    }
  }

  // Delete event
  Future<bool> deleteEvent(String eventId) async {
    try {
      _setLoading(true);
      _error = null;
      
      final success = await _repository.deleteEvent(eventId);
      
      if (success) {
        // Remove event from local lists
        _events.removeWhere((event) => event.id == eventId);
        _todayEvents.removeWhere((event) => event.id == eventId);
        _upcomingEvents.removeWhere((event) => event.id == eventId);
        notifyListeners();
      }
      
      _setLoading(false);
      return success;
    } catch (e) {
      _setError('Failed to delete event: $e');
      return false;
    }
  }

  // Refresh all data
  Future<void> refreshAll() async {
    await Future.wait([
      loadEvents(),
      loadTodayEvents(),
      loadUpcomingEvents(),
    ]);
  }

  // Get event by ID
  CalendarEvent? getEventById(String id) {
    try {
      return _events.firstWhere((event) => event.id == id);
    } catch (e) {
      return null;
    }
  }

  // Get events for a specific date
  List<CalendarEvent> getEventsForDate(DateTime date) {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    
    return _events.where((event) {
      return event.startTime.isAfter(startOfDay) && 
             event.startTime.isBefore(endOfDay);
    }).toList();
  }

  // Get events for a specific time range
  List<CalendarEvent> getEventsForTimeRange(DateTime start, DateTime end) {
    return _events.where((event) {
      return (event.startTime.isAfter(start) && event.startTime.isBefore(end)) ||
             (event.endTime.isAfter(start) && event.endTime.isBefore(end)) ||
             (event.startTime.isBefore(start) && event.endTime.isAfter(end));
    }).toList();
  }

  // Clear all data
  void clearData() {
    _events.clear();
    _todayEvents.clear();
    _upcomingEvents.clear();
    _lastDraftId = null;
    _error = null;
    _isLoading = false;
    notifyListeners();
  }
}
