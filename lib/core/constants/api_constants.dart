class ApiConstants {
  // Base URLs
  static const String emailAgentBaseUrl = 'https://email-agent-backend-staging.onrender.com';
  static const String userServiceBaseUrl = 'https://samantha-user-service.onrender.com';
  
  // Calendar endpoints
  static const String calendarManageEndpoint = '/calendar/manage';
  static const String calendarListEvents = 'list_events';
  static const String calendarCheckAvailability = 'check_availability';
  static const String calendarDraftEvent = 'draft_calendar_event';
  static const String calendarSendDraft = 'send_calendar_draft';
  static const String calendarUpdateEvent = 'update_event';
  static const String calendarDeleteEvent = 'delete_event';
  
  // Auth endpoints
  static const String authEndpoint = '/api/v1/auth/google';
  
  // Headers
  static const String contentTypeHeader = 'Content-Type';
  static const String applicationJson = 'application/json';
  static const String jwtHeader = 'X-Samantha-JWT';
  static const String deviceIdHeader = 'X-Device-Id';
  static const String userAgentHeader = 'User-Agent';
  static const String userAgentValue = 'TesttFlutterApp/1.0';
  
  // Timeouts
  static const int connectTimeout = 30; // seconds
  static const int receiveTimeout = 60; // seconds
}
