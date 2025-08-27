import 'dart:convert';
import 'package:logger/logger.dart';

class LoggingInterceptor {
  static final LoggingInterceptor _instance = LoggingInterceptor._internal();
  factory LoggingInterceptor() => _instance;
  LoggingInterceptor._internal();

  final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 8,
      lineLength: 120,
      colors: true,
      printEmojis: true,
      printTime: true,
    ),
  );

  // Enhanced HTTP request logging with more details
  void logRequest({
    required String method,
    required Uri url,
    required Map<String, String> headers,
    dynamic body,
    String? operation,
  }) {
    _logger.i('🌐 HTTP REQUEST');
    _logger.i('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    _logger.i('📋 Method: $method');
    _logger.i('🔗 URL: ${url.toString()}');
    _logger.i('🎯 Operation: ${operation ?? 'N/A'}');
    _logger.i('⏰ Timestamp: ${DateTime.now().toIso8601String()}');
    _logger.i('📋 Headers:');
    _logHeaders(headers);
    if (body != null) {
      _logger.i('📦 Request Body:');
      _logBody(body);
    }
    _logger.i('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  }

  // Enhanced HTTP response logging with better formatting
  void logResponse({
    required int statusCode,
    required Map<String, String> headers,
    required String body,
    required Duration duration,
    String? operation,
  }) {
    final isSuccess = statusCode >= 200 && statusCode < 300;
    final emoji = isSuccess ? '✅' : '❌';
    final level = isSuccess ? Level.info : Level.error;
    
    _logger.log(level, '$emoji HTTP RESPONSE');
    _logger.log(level, '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    _logger.log(level, '📊 Status: $statusCode ${_getStatusText(statusCode)}');
    _logger.log(level, '🎯 Operation: ${operation ?? 'N/A'}');
    _logger.log(level, '⏱️ Duration: ${duration.inMilliseconds}ms');
    _logger.log(level, '⏰ Timestamp: ${DateTime.now().toIso8601String()}');
    _logger.log(level, '📋 Response Headers:');
    _logHeaders(headers);
    _logger.log(level, '📦 Response Body:');
    _logBody(body);
    _logger.log(level, '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  }

  // Enhanced error logging with stack traces
  void logError({
    required String error,
    required String operation,
    StackTrace? stackTrace,
    String? url,
    String? method,
  }) {
    _logger.e('❌ HTTP ERROR');
    _logger.e('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    _logger.e('🎯 Operation: $operation');
    if (url != null) _logger.e('🔗 URL: $url');
    if (method != null) _logger.e('📋 Method: $method');
    _logger.e('❌ Error: $error');
    _logger.e('⏰ Timestamp: ${DateTime.now().toIso8601String()}');
    if (stackTrace != null) {
      _logger.e('📚 Stack Trace:');
      _logger.e(stackTrace.toString());
    }
    _logger.e('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  }

  // Enhanced timeout logging
  void logTimeout({
    required String operation,
    required Duration timeout,
    String? url,
    String? method,
  }) {
    _logger.w('⏰ HTTP TIMEOUT');
    _logger.w('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    _logger.w('🎯 Operation: $operation');
    if (url != null) _logger.w('🔗 URL: $url');
    if (method != null) _logger.w('📋 Method: $method');
    _logger.w('⏱️ Timeout: ${timeout.inSeconds}s');
    _logger.w('⏰ Timestamp: ${DateTime.now().toIso8601String()}');
    _logger.w('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  }

  // Enhanced connection error logging
  void logConnectionError({
    required String error,
    required String operation,
    String? url,
    String? method,
  }) {
    _logger.e('🔌 NETWORK ERROR');
    _logger.e('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    _logger.e('🎯 Operation: $operation');
    if (url != null) _logger.e('🔗 URL: $url');
    if (method != null) _logger.e('📋 Method: $method');
    _logger.e('❌ Error: $error');
    _logger.e('⏰ Timestamp: ${DateTime.now().toIso8601String()}');
    _logger.e('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  }

  // Log authentication details specifically
  void logAuthDetails({
    required String operation,
    String? jwtToken,
    String? accessToken,
    String? userId,
    String? email,
  }) {
    _logger.i('🔐 AUTHENTICATION DETAILS');
    _logger.i('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    _logger.i('🎯 Operation: $operation');
    if (userId != null) _logger.i('🆔 User ID: $userId');
    if (email != null) _logger.i('📧 Email: $email');
    if (jwtToken != null) _logger.i('🔑 JWT Token: ${_maskToken(jwtToken)}');
    if (accessToken != null) _logger.i('🎫 Access Token: ${_maskToken(accessToken)}');
    _logger.i('⏰ Timestamp: ${DateTime.now().toIso8601String()}');
    _logger.i('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  }

  // Log calendar-specific operations
  void logCalendarOperation({
    required String operation,
    required String method,
    required Uri url,
    Map<String, dynamic>? requestData,
    String? userId,
    String? eventId,
  }) {
    _logger.i('📅 CALENDAR OPERATION');
    _logger.i('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    _logger.i('🎯 Operation: $operation');
    _logger.i('📋 Method: $method');
    _logger.i('🔗 URL: ${url.toString()}');
    if (userId != null) _logger.i('👤 User ID: $userId');
    if (eventId != null) _logger.i('📝 Event ID: $eventId');
    if (requestData != null) {
      _logger.i('📦 Request Data:');
      _logBody(requestData);
    }
    _logger.i('⏰ Timestamp: ${DateTime.now().toIso8601String()}');
    _logger.i('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  }

  // Helper method to log headers in a formatted way
  void _logHeaders(Map<String, String> headers) {
    final sanitized = _sanitizeHeaders(headers);
    for (final entry in sanitized.entries) {
      _logger.i('   ${entry.key}: ${entry.value}');
    }
  }

  // Helper method to log body in a formatted way
  void _logBody(dynamic body) {
    if (body == null) {
      _logger.i('   null');
      return;
    }
    
    try {
      String formattedBody;
      if (body is String) {
        // Try to parse and pretty-print JSON
        final json = jsonDecode(body);
        formattedBody = const JsonEncoder.withIndent('   ').convert(json);
      } else if (body is Map) {
        formattedBody = const JsonEncoder.withIndent('   ').convert(body);
      } else {
        formattedBody = body.toString();
      }
      
      // Split by lines and add indentation
      final lines = formattedBody.split('\n');
      for (final line in lines) {
        _logger.i('   $line');
      }
    } catch (e) {
      _logger.i('   ${body.toString()}');
    }
  }

  // Get human-readable status text
  String _getStatusText(int statusCode) {
    switch (statusCode) {
      case 200: return 'OK';
      case 201: return 'Created';
      case 204: return 'No Content';
      case 400: return 'Bad Request';
      case 401: return 'Unauthorized';
      case 403: return 'Forbidden';
      case 404: return 'Not Found';
      case 500: return 'Internal Server Error';
      case 502: return 'Bad Gateway';
      case 503: return 'Service Unavailable';
      default: return 'Unknown';
    }
  }

  // Mask sensitive tokens for logging
  String _maskToken(String token) {
    if (token.length <= 16) return '***';
    return '${token.substring(0, 8)}...${token.substring(token.length - 8)}';
  }

  // Sanitize headers to remove sensitive information
  Map<String, String> _sanitizeHeaders(Map<String, String> headers) {
    final sanitized = Map<String, String>.from(headers);
    
    // Remove or mask sensitive headers
    const sensitiveKeys = [
      'authorization', 
      'cookie', 
      'x-api-key', 
      'token',
      'x-samantha-jwt',
      'x-auth-token'
    ];
    
    for (final key in sensitiveKeys) {
      if (sanitized.containsKey(key)) {
        final value = sanitized[key]!;
        if (value.isNotEmpty) {
          sanitized[key] = _maskToken(value);
        }
      }
    }
    
    return sanitized;
  }

  // Enable/disable logging
  void setLogLevel(Level level) {
    Logger.level = level;
  }

  // Get current logger instance
  Logger get logger => _logger;

  // Log performance metrics
  void logPerformance({
    required String operation,
    required Duration duration,
    required String method,
    required Uri url,
    int? statusCode,
  }) {
    final isSlow = duration.inMilliseconds > 5000; // 5 seconds threshold
    final emoji = isSlow ? '🐌' : '⚡';
    final level = isSlow ? Level.warning : Level.info;
    
    _logger.log(level, '$emoji PERFORMANCE METRIC');
    _logger.log(level, '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    _logger.log(level, '🎯 Operation: $operation');
    _logger.log(level, '📋 Method: $method');
    _logger.log(level, '🔗 URL: ${url.toString()}');
    _logger.log(level, '⏱️ Duration: ${duration.inMilliseconds}ms');
    if (statusCode != null) _logger.log(level, '📊 Status: $statusCode');
    _logger.log(level, '⏰ Timestamp: ${DateTime.now().toIso8601String()}');
    _logger.log(level, '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  }
}
