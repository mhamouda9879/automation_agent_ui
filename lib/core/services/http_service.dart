import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';
import 'auth_service.dart';
import 'logging_interceptor.dart';

class HttpService {
  static final HttpService _instance = HttpService._internal();
  factory HttpService() => _instance;
  HttpService._internal();

  final AuthService _authService = AuthService();
  final http.Client _client = http.Client();
  final LoggingInterceptor _logger = LoggingInterceptor();

  // Configure timeout duration
  static const Duration _timeout = Duration(seconds: 30);

  // Enhanced calendar request with better logging
  Future<http.Response> makeCalendarRequest({
    required String operation,
    Map<String, dynamic>? requestBody,
    String? eventId,
    String? userId,
  }) async {
    final url = Uri.parse('${ApiConstants.emailAgentBaseUrl}${ApiConstants.calendarManageEndpoint}');
    final jwtToken = await _authService.getJwtToken();
    final authData = await _authService.getAuthData();
    
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'X-Samantha-JWT': jwtToken ?? '',
      'User-Agent': 'FlutterCalendarApp/1.0',
    };

    final body = jsonEncode(<String, dynamic>{
      'operation': operation,
      ...?requestBody,
    });

    // Log calendar operation specifically
    _logger.logCalendarOperation(
      operation: operation,
      method: 'POST',
      url: url,
      requestData: requestBody,
      userId: userId ?? authData?.user.id,
      eventId: eventId,
    );

    // Log authentication details
    _logger.logAuthDetails(
      operation: 'Calendar Request - $operation',
      jwtToken: jwtToken,
      accessToken: authData?.accessToken,
      userId: authData?.user.id,
      email: authData?.user.email,
    );

    final stopwatch = Stopwatch()..start();

    try {
      final response = await _client
          .post(
            url,
            headers: headers,
            body: body,
          )
          .timeout(_timeout);

      stopwatch.stop();

      // Log response with enhanced details
      _logger.logResponse(
        statusCode: response.statusCode,
        headers: response.headers,
        body: response.body,
        duration: stopwatch.elapsed,
        operation: 'Calendar - $operation',
      );

      // Log performance metrics
      _logger.logPerformance(
        operation: 'Calendar Request - $operation',
        duration: stopwatch.elapsed,
        method: 'POST',
        url: url,
        statusCode: response.statusCode,
      );

      return response;
    } catch (e) {
      stopwatch.stop();

      if (e is SocketException) {
        _logger.logConnectionError(
          error: 'Unable to connect to server',
          operation: 'Calendar Request - $operation',
          url: url.toString(),
          method: 'POST',
        );
        throw HttpException('Network error: Unable to connect to server');
      } else if (e is TimeoutException) {
        _logger.logTimeout(
          operation: 'Calendar Request - $operation',
          timeout: _timeout,
          url: url.toString(),
          method: 'POST',
        );
        throw HttpException('Request timeout: Server took too long to respond');
      } else {
        _logger.logError(
          error: e.toString(),
          operation: 'Calendar Request - $operation',
          url: url.toString(),
          method: 'POST',
        );
        throw HttpException('HTTP request failed: $e');
      }
    }
  }

  // Enhanced user service request with better logging
  Future<http.Response> makeUserServiceRequest({
    required String endpoint,
    Map<String, dynamic>? requestBody,
    String method = 'GET',
    String? userId,
  }) async {
    final url = Uri.parse('${ApiConstants.userServiceBaseUrl}$endpoint');
    final jwtToken = await _authService.getJwtToken();
    final authData = await _authService.getAuthData();
    
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'X-Samantha-JWT': jwtToken ?? '',
      'User-Agent': 'FlutterCalendarApp/1.0',
    };

    final body = requestBody != null ? jsonEncode(requestBody) : null;

    // Log request with enhanced details
    _logger.logRequest(
      method: method,
      url: url,
      headers: headers,
      body: body,
      operation: 'User Service - $method $endpoint',
    );

    // Log authentication details
    _logger.logAuthDetails(
      operation: 'User Service Request - $method $endpoint',
      jwtToken: jwtToken,
      accessToken: authData?.accessToken,
      userId: userId ?? authData?.user.id,
      email: authData?.user.email,
    );

    final stopwatch = Stopwatch()..start();

    try {
      http.Response response;
      
      switch (method.toUpperCase()) {
        case 'GET':
          response = await _client
              .get(url, headers: headers)
              .timeout(_timeout);
          break;
        case 'POST':
          response = await _client
              .post(
                url,
                headers: headers,
                body: body,
              )
              .timeout(_timeout);
          break;
        case 'PUT':
          response = await _client
              .put(
                url,
                headers: headers,
                body: body,
              )
              .timeout(_timeout);
          break;
        case 'DELETE':
          response = await _client
              .delete(url, headers: headers)
              .timeout(_timeout);
          break;
        default:
          throw HttpException('Unsupported HTTP method: $method');
      }

      stopwatch.stop();

      // Log response with enhanced details
      _logger.logResponse(
        statusCode: response.statusCode,
        headers: response.headers,
        body: response.body,
        duration: stopwatch.elapsed,
        operation: 'User Service - $method $endpoint',
      );

      // Log performance metrics
      _logger.logPerformance(
        operation: 'User Service Request - $method $endpoint',
        duration: stopwatch.elapsed,
        method: method,
        url: url,
        statusCode: response.statusCode,
      );

      return response;
    } catch (e) {
      stopwatch.stop();

      if (e is SocketException) {
        _logger.logConnectionError(
          error: 'Unable to connect to server',
          operation: 'User Service - $method $endpoint',
          url: url.toString(),
          method: method,
        );
        throw HttpException('Network error: Unable to connect to server');
      } else if (e is TimeoutException) {
        _logger.logTimeout(
          operation: 'User Service - $method $endpoint',
          timeout: _timeout,
          url: url.toString(),
          method: method,
        );
        throw HttpException('Request timeout: Server took too long to respond');
      } else {
        _logger.logError(
          error: e.toString(),
          operation: 'User Service - $method $endpoint',
          url: url.toString(),
          method: method,
        );
        throw HttpException('HTTP request failed: $e');
      }
    }
  }

  // New method for Google Calendar API requests
  Future<http.Response> makeGoogleCalendarRequest({
    required String endpoint,
    Map<String, dynamic>? requestBody,
    String method = 'GET',
    String? eventId,
    String? userId,
  }) async {
    final url = Uri.parse('https://www.googleapis.com/calendar/v3$endpoint');
    final authData = await _authService.getAuthData();
    
    if (authData?.accessToken == null) {
      throw HttpException('No valid Google access token available');
    }

    final headers = <String, String>{
      'Authorization': 'Bearer ${authData!.accessToken}',
      'Content-Type': 'application/json',
      'User-Agent': 'FlutterCalendarApp/1.0',
    };

    final body = requestBody != null ? jsonEncode(requestBody) : null;

    // Log Google Calendar operation
    _logger.logCalendarOperation(
      operation: 'Google Calendar - $method $endpoint',
      method: method,
      url: url,
      requestData: requestBody,
      userId: userId ?? authData.user.id,
      eventId: eventId,
    );

    // Log authentication details
    _logger.logAuthDetails(
      operation: 'Google Calendar Request - $method $endpoint',
      accessToken: authData.accessToken,
      userId: authData.user.id,
      email: authData.user.email,
    );

    final stopwatch = Stopwatch()..start();

    try {
      http.Response response;
      
      switch (method.toUpperCase()) {
        case 'GET':
          response = await _client
              .get(url, headers: headers)
              .timeout(_timeout);
          break;
        case 'POST':
          response = await _client
              .post(
                url,
                headers: headers,
                body: body,
              )
              .timeout(_timeout);
          break;
        case 'PUT':
          response = await _client
              .put(
                url,
                headers: headers,
                body: body,
              )
              .timeout(_timeout);
          break;
        case 'DELETE':
          response = await _client
              .delete(url, headers: headers)
              .timeout(_timeout);
          break;
        case 'PATCH':
          response = await _client
              .patch(
                url,
                headers: headers,
                body: body,
              )
              .timeout(_timeout);
          break;
        default:
          throw HttpException('Unsupported HTTP method: $method');
      }

      stopwatch.stop();

      // Log response with enhanced details
      _logger.logResponse(
        statusCode: response.statusCode,
        headers: response.headers,
        body: response.body,
        duration: stopwatch.elapsed,
        operation: 'Google Calendar - $method $endpoint',
      );

      // Log performance metrics
      _logger.logPerformance(
        operation: 'Google Calendar Request - $method $endpoint',
        duration: stopwatch.elapsed,
        method: method,
        url: url,
        statusCode: response.statusCode,
      );

      return response;
    } catch (e) {
      stopwatch.stop();

      if (e is SocketException) {
        _logger.logConnectionError(
          error: 'Unable to connect to Google Calendar API',
          operation: 'Google Calendar - $method $endpoint',
          url: url.toString(),
          method: method,
        );
        throw HttpException('Network error: Unable to connect to Google Calendar API');
      } else if (e is TimeoutException) {
        _logger.logTimeout(
          operation: 'Google Calendar - $method $endpoint',
          timeout: _timeout,
          url: url.toString(),
          method: method,
        );
        throw HttpException('Request timeout: Google Calendar API took too long to respond');
      } else {
        _logger.logError(
          error: e.toString(),
          operation: 'Google Calendar - $method $endpoint',
          url: url.toString(),
          method: method,
        );
        throw HttpException('Google Calendar API request failed: $e');
      }
    }
  }

  // Handle HTTP response and parse JSON with better error handling
  Map<String, dynamic> handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      try {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } catch (e) {
        _logger.logError(
          error: 'Invalid JSON response: $e',
          operation: 'Response Parsing',
          url: response.request?.url.toString(),
          method: response.request?.method,
        );
        throw HttpException('Invalid JSON response: $e');
      }
    } else {
      String errorMessage;
      try {
        final errorBody = jsonDecode(response.body) as Map<String, dynamic>;
        errorMessage = errorBody['message'] ?? 'Unknown error';
      } catch (e) {
        errorMessage = 'HTTP ${response.statusCode}: ${response.reasonPhrase}';
      }
      
      _logger.logError(
        error: errorMessage,
        operation: 'HTTP Error Response',
        url: response.request?.url.toString(),
        method: response.request?.method,
      );
      
      throw HttpException(errorMessage);
    }
  }

  // Check if response indicates success
  bool isSuccessResponse(http.Response response) {
    return response.statusCode >= 200 && response.statusCode < 300;
  }

  // Get error message from response
  String getErrorMessage(http.Response response) {
    try {
      final errorBody = jsonDecode(response.body) as Map<String, dynamic>;
      return errorBody['message'] ?? 'HTTP ${response.statusCode}';
    } catch (e) {
      return 'HTTP ${response.statusCode}: ${response.reasonPhrase}';
    }
  }

  // Dispose resources
  void dispose() {
    _client.close();
  }
}

class TimeoutException implements Exception {
  final String message;
  TimeoutException(this.message);
  
  @override
  String toString() => message;
}

class HttpException implements Exception {
  final String message;
  HttpException(this.message);
  
  @override
  String toString() => message;
}
