class HotelConstants {
  // SerpAPI Configuration
  static const String serpapiBaseUrl = 'https://serpapi.com/search.json';
  static const String googleHotelsEngine = 'google_hotels';
  
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
  
  // Storage
  static const String hotelsStorageDir = 'hotels';
  
  // Date formats
  static const String dateFormat = 'yyyy-MM-dd';
  static const String timestampFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ";
  
  // Error messages
  static const String errorNoSerpApiKey = 'SerpAPI key not configured. Please set SERPAPI_KEY in configuration.';
  static const String errorLocationNotFound = 'Unable to get current location';
  static const String errorReverseGeocodingFailed = 'Reverse geocoding failed';
  static const String errorNetworkError = 'Network error occurred';
  static const String errorJsonParsing = 'JSON parsing error occurred';
  static const String errorUnexpected = 'Unexpected error occurred';
  
  // Log tags
  static const String logTag = '🏨 HOTEL SERVICE';
  
  // Timeouts
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration readTimeout = Duration(seconds: 30);
  static const Duration writeTimeout = Duration(seconds: 30);
}
