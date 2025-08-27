class ApiConfig {
  // User Service API
  static const String userServiceBaseUrl = 'https://samantha-user-service.onrender.com';
  static const String userServiceAuthEndpoint = '/api/v1/auth/google/server-auth';
  static const String contactsSearchEndpoint = '/api/v1/contacts/search';
  static const String contactsEndpoint = '/api/v1/contacts';
  static const String contactsBulkEndpoint = '/api/v1/contacts/bulk';

  // Email Agent Backend
  static const String emailAgentBaseUrl = 'https://email-agent-backend-staging.onrender.com';
  static const String emailEndpoint = '/emails/manage';
  static const String calendarEndpoint = '/calendar/manage';
  static const String whatsappEndpoint = '/whatsapp/manage';
  static const String whatsappConnectEndpoint = '/whatsapp-connect';
  static const String whatsappStatusEndpoint = '/check-whatsapp-connection';
  static const String whatsappSyncContactsEndpoint = '/whatsapp/sync-contacts';
  static const String whatsappLogoutEndpoint = '/whatsapp-logout';

  // Deep Research Backend
  static const String deepResearchBaseUrl = 'https://manus-production.up.railway.app';

  // External Tools Backend
  static const String externalToolsBaseUrl = 'https://costar-external-tools-production.up.railway.app';

  // Get full URL for a specific endpoint
  static String getApiUrl(String service, [String? endpoint]) {
    switch (service) {
      case 'USER_SERVICE':
        return endpoint != null ? '$userServiceBaseUrl$endpoint' : userServiceBaseUrl;
      case 'EMAIL_AGENT':
        return endpoint != null ? '$emailAgentBaseUrl$endpoint' : emailAgentBaseUrl;
      case 'DEEP_RESEARCH':
        return deepResearchBaseUrl;
      case 'EXTERNAL_TOOLS':
        return externalToolsBaseUrl;
      default:
        throw ArgumentError('Unknown service: $service');
    }
  }

  // Get User Service authentication URL
  static String getUserServiceAuthUrl() {
    return getApiUrl('USER_SERVICE', userServiceAuthEndpoint);
  }

  // Get Email Agent endpoints
  static String getEmailAgentUrl(String endpoint) {
    return getApiUrl('EMAIL_AGENT', endpoint);
  }

  // Get Contacts endpoints
  static String getContactsSearchUrl(String userEmail) {
    return getApiUrl('USER_SERVICE', '$contactsSearchEndpoint/$userEmail');
  }

  static String getContactsUrl() {
    return getApiUrl('USER_SERVICE', contactsEndpoint);
  }

  static String getContactsBulkUrl() {
    return getApiUrl('USER_SERVICE', contactsBulkEndpoint);
  }

  // Get WhatsApp endpoints
  static String getWhatsAppAgentUrl(String endpoint) {
    return getApiUrl('EMAIL_AGENT', endpoint);
  }

  // Get Deep Research URL
  static String getDeepResearchUrl() {
    return getApiUrl('DEEP_RESEARCH');
  }

  // Get External Tools URL
  static String getExternalToolsUrl() {
    return getApiUrl('EXTERNAL_TOOLS');
  }
}
