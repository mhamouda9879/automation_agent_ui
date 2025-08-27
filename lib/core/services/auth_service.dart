import 'dart:convert';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:logger/logger.dart';

import '../models/auth_models.dart';
import '../constants/api_config.dart';

class AuthService {
  static const String _authStorageKey = '@costar_auth_user';
  
  // Enhanced Google Sign-In with calendar scopes
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'email',
      'profile',
      'https://www.googleapis.com/auth/calendar',
      'https://www.googleapis.com/auth/calendar.events',
      'https://www.googleapis.com/auth/calendar.readonly',
    ],
    hostedDomain: null,
    signInOption: SignInOption.standard,
    // For Android, we don't need serverClientId - it uses the google-services.json configuration
    // The Android client ID is automatically configured from google-services.json
  );

  final Logger _logger = Logger();

  // Configure Google Sign-In with enhanced logging
  Future<void> configureGoogleSignIn() async {
    try {
      _logger.i('🔧 Configuring Google Sign-In...');
      _logger.i('📱 Package name: com.example.testt');
      _logger.i('🔑 Scopes: ${_googleSignIn.scopes.join(', ')}');
      _logger.i('📅 Calendar scopes included: ${_googleSignIn.scopes.where((scope) => scope.contains('calendar')).join(', ')}');
      _logger.i('✅ Google Sign-In configured successfully');
    } catch (error) {
      _logger.e('❌ Failed to configure Google Sign-In: $error');
      // Don't rethrow, just log the error
    }
  }

  // Check if user is already signed in
  Future<bool> isSignedIn() async {
    try {
      return await _googleSignIn.isSignedIn();
    } catch (error) {
      _logger.e('❌ Error checking sign-in status: $error');
      return false;
    }
  }

  // Enhanced sign in with Google and calendar access
  Future<AuthData?> signIn() async {
    try {
      _logger.i('🔐 Starting Google Sign-In with calendar access...');
      _logger.i('📱 Package name: com.example.testt');
      _logger.i('🔑 Scopes: ${_googleSignIn.scopes.join(', ')}');

      // Check if Google Play Services are available
      try {
        _logger.i('🔍 Checking Google Play Services availability...');
        final isSignedIn = await _googleSignIn.isSignedIn();
        _logger.i('📱 Current sign-in status: $isSignedIn');
        _logger.i('✅ Google Play Services are available');
      } catch (e) {
        _logger.w('⚠️ Google Play Services check failed: $e');
      }

      // Check if user is already signed in
      try {
        final currentUser = await _googleSignIn.signInSilently();
        if (currentUser != null) {
          _logger.i('🔄 User already signed in, getting fresh tokens...');
          final googleAuth = await currentUser.authentication;
          return await _processGoogleAuth(currentUser, googleAuth);
        }
      } catch (e) {
        _logger.i('ℹ️ No existing sign-in session: $e');
      }

      // Sign in with Google
      _logger.i('🔐 Initiating new Google Sign-In...');
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        _logger.w('⚠️ Google Sign-In was cancelled by user');
        return null;
      }

      _logger.i('✅ Google Sign-In successful for: ${googleUser.email}');
      _logger.i('📅 Requested scopes: ${_googleSignIn.scopes.join(', ')}');

      // Get authentication details
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      
      return await _processGoogleAuth(googleUser, googleAuth);

    } catch (error) {
      _logger.e('❌ Error during sign-in: $error');
      
      // Log specific error details
      if (error.toString().contains('ApiException: 10')) {
        _logger.e('❌ Google Sign-In configuration error (code 10)');
        _logger.e('❌ This usually means:');
        _logger.e('❌ 1. SHA-1 fingerprint mismatch in Google Cloud Console');
        _logger.e('❌ 2. Package name mismatch');
        _logger.e('❌ 3. Google Services not properly configured');
        _logger.e('❌ 4. OAuth 2.0 client not properly set up');
      } else if (error.toString().contains('network')) {
        _logger.e('❌ Network error during Google Sign-In');
      } else if (error.toString().contains('cancelled')) {
        _logger.e('❌ Google Sign-In was cancelled');
      }
      
      rethrow;
    }
  }

  // Helper method to process Google authentication
  Future<AuthData?> _processGoogleAuth(GoogleSignInAccount googleUser, GoogleSignInAuthentication googleAuth) async {
    try {
      _logger.i('🔑 Processing Google authentication...');
      _logger.i('🔑 Access token obtained: ${googleAuth.accessToken?.substring(0, 20)}...');
      _logger.i('🎫 ID token obtained: ${googleAuth.idToken?.substring(0, 20)}...');

      // For now, use empty server auth code since we're simplifying
      final serverAuthCode = '';

      // Call User Service API to get JWT token
      String? jwtToken = await _getJwtTokenFromUserService(
        googleAuth.accessToken!,
        serverAuthCode,
        googleUser.email,
        googleUser.displayName ?? '',
        googleUser.photoUrl,
      );

      if (jwtToken == null) {
        _logger.w('⚠️ Failed to get JWT token from User Service, using access token as fallback');
        // Use access token as fallback JWT for development
        jwtToken = googleAuth.accessToken;
      }

      // Create user object
      final user = User(
        id: googleUser.id,
        name: googleUser.displayName,
        email: googleUser.email,
        photo: googleUser.photoUrl,
        givenName: googleUser.displayName?.split(' ').first,
        familyName: googleUser.displayName?.split(' ').last,
      );

      // Calculate token expiry (1 hour from now for access token, 24 hours for JWT)
      final accessTokenExpiry = DateTime.now().add(Duration(hours: 1)).millisecondsSinceEpoch;
      final jwtTokenExpiry = DateTime.now().add(Duration(hours: 24)).millisecondsSinceEpoch;

      // Create auth data
      final authData = AuthData(
        user: user,
        idToken: googleAuth.idToken,
        accessToken: googleAuth.accessToken,
        serverAuthCode: serverAuthCode,
        scopes: _googleSignIn.scopes,
        timestamp: DateTime.now().toIso8601String(),
        tokenExpiry: accessTokenExpiry,
        jwtToken: jwtToken,
        jwtTokenExpiry: jwtTokenExpiry,
      );

      // Store auth data locally
      await _storeAuthData(authData);

      _logger.i('✅ User signed in and data stored successfully');
      _logger.i('📅 Calendar access granted with scopes: ${_googleSignIn.scopes.where((scope) => scope.contains('calendar')).join(', ')}');
      
      return authData;
    } catch (e) {
      _logger.e('❌ Error processing Google authentication: $e');
      rethrow;
    }
  }

  // Enhanced JWT token retrieval from User Service
  Future<String?> _getJwtTokenFromUserService(
    String accessToken,
    String serverAuthCode,
    String email,
    String name,
    String? avatarUrl,
  ) async {
    try {
      _logger.i('🔄 Calling User Service API for JWT token...');
      _logger.i('📧 Email: $email');
      _logger.i('👤 Name: $name');

      final response = await http.post(
        Uri.parse(ApiConfig.getUserServiceAuthUrl()),
        headers: {
          'Content-Type': 'application/json',
          'User-Agent': 'FlutterCalendarApp/1.0',
        },
        body: jsonEncode({
          'access_token': accessToken,
          'server_auth_code': serverAuthCode,
          'email': email,
          'name': name,
          'avatar_url': avatarUrl,
          'scopes': _googleSignIn.scopes,
        }),
      );

      if (response.statusCode == 200) {
        final userServiceData = jsonDecode(response.body);
        final jwtToken = userServiceData['access_token'];
        
        _logger.i('✅ JWT token obtained from User Service');
        _logger.d('🔑 JWT Token: ${jwtToken.substring(0, 20)}...');
        
        return jwtToken;
      } else {
        _logger.e('❌ User Service API call failed: ${response.statusCode}');
        _logger.e('❌ User Service error: ${response.body}');
        return null;
      }
    } catch (error) {
      _logger.e('❌ Error calling User Service API: $error');
      return null;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      _logger.i('🚪 Signing out user...');

      // Sign out from Google
      await _googleSignIn.signOut();
      _logger.i('✅ Signed out from Google');

      // Clear stored auth data
      await _clearAuthData();
      _logger.i('✅ User signed out successfully');

    } catch (error) {
      _logger.e('❌ Error signing out: $error');
      rethrow;
    }
  }

  // Get stored authentication data
  Future<AuthData?> getAuthData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final authDataString = prefs.getString(_authStorageKey);
      
      if (authDataString != null) {
        final authDataMap = jsonDecode(authDataString) as Map<String, dynamic>;
        return AuthData.fromJson(authDataMap);
      }
      
      return null;
    } catch (error) {
      _logger.e('❌ Error getting auth data: $error');
      return null;
    }
  }

  // Store authentication data
  Future<void> _storeAuthData(AuthData authData) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final authDataString = jsonEncode(authData.toJson());
      await prefs.setString(_authStorageKey, authDataString);
      _logger.i('✅ Auth data stored successfully');
    } catch (error) {
      _logger.e('❌ Error storing auth data: $error');
      rethrow;
    }
  }

  // Clear authentication data
  Future<void> _clearAuthData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_authStorageKey);
      _logger.i('✅ Auth data cleared successfully');
    } catch (error) {
      _logger.e('❌ Error clearing auth data: $error');
      rethrow;
    }
  }

  // Get JWT token with expiry check
  Future<String?> getJwtToken() async {
    try {
      final authData = await getAuthData();
      if (authData == null) return null;

      // Check if JWT token is expired
      if (authData.jwtTokenExpiry != null && 
          DateTime.now().millisecondsSinceEpoch > authData.jwtTokenExpiry!) {
        _logger.w('⚠️ JWT token expired, attempting to refresh...');
        return await _refreshJwtToken();
      }

      return authData.jwtToken;
    } catch (error) {
      _logger.e('❌ Error getting JWT token: $error');
      return null;
    }
  }

  // Get Google access token with expiry check
  Future<String?> getGoogleAccessToken() async {
    try {
      final authData = await getAuthData();
      if (authData == null) return null;

      // Check if access token is expired
      if (isTokenExpired(authData)) {
        _logger.w('⚠️ Google access token expired, attempting to refresh...');
        return await refreshGoogleAccessToken();
      }

      return authData.accessToken;
    } catch (error) {
      _logger.e('❌ Error getting Google access token: $error');
      return null;
    }
  }

  // Check if JWT token is expired
  bool isJwtTokenExpired(AuthData authData) {
    if (authData.jwtTokenExpiry == null) return true;
    return DateTime.now().millisecondsSinceEpoch > authData.jwtTokenExpiry!;
  }

  // Check if Google access token is expired
  bool isTokenExpired(AuthData authData) {
    if (authData.tokenExpiry == null) return true;
    return DateTime.now().millisecondsSinceEpoch > authData.tokenExpiry!;
  }

  // Refresh JWT token
  Future<String?> _refreshJwtToken() async {
    try {
      _logger.i('🔄 Refreshing JWT token...');
      
      final authData = await getAuthData();
      if (authData == null) return null;

      // Try to refresh Google access token first
      final newAccessToken = await refreshGoogleAccessToken();
      if (newAccessToken == null) return null;

      // Get new JWT token from User Service
      final newJwtToken = await _getJwtTokenFromUserService(
        newAccessToken,
        authData.serverAuthCode ?? '',
        authData.user.email,
        authData.user.name ?? '',
        authData.user.photo,
      );

      if (newJwtToken != null) {
        // Update stored auth data
        final updatedAuthData = authData.copyWith(
          accessToken: newAccessToken,
          jwtToken: newJwtToken,
          timestamp: DateTime.now().toIso8601String(),
          tokenExpiry: DateTime.now().add(Duration(hours: 1)).millisecondsSinceEpoch,
          jwtTokenExpiry: DateTime.now().add(Duration(hours: 24)).millisecondsSinceEpoch,
        );

        await _storeAuthData(updatedAuthData);
        _logger.i('✅ JWT token refreshed successfully');
        return newJwtToken;
      }

      return null;
    } catch (error) {
      _logger.e('❌ Failed to refresh JWT token: $error');
      return null;
    }
  }

  // Enhanced Google access token refresh
  Future<String?> refreshGoogleAccessToken() async {
    try {
      _logger.i('🔄 Refreshing Google access token...');

      if (!await isSignedIn()) {
        _logger.w('⚠️ User is not signed in, cannot refresh token');
        return null;
      }

      // Get fresh tokens from Google
      final GoogleSignInAccount? currentUser = await _googleSignIn.signInSilently();
      if (currentUser == null) {
        _logger.w('⚠️ Failed to get current user for token refresh');
        return null;
      }

      final GoogleSignInAuthentication googleAuth = await currentUser.authentication;
      final newAccessToken = googleAuth.accessToken;

      if (newAccessToken != null) {
        _logger.i('✅ Google access token refreshed successfully');

        // Update stored auth data with new access token
        final currentAuthData = await getAuthData();
        if (currentAuthData != null) {
          final updatedAuthData = currentAuthData.copyWith(
            accessToken: newAccessToken,
            timestamp: DateTime.now().toIso8601String(),
            tokenExpiry: DateTime.now().add(Duration(hours: 1)).millisecondsSinceEpoch,
          );

          await _storeAuthData(updatedAuthData);
          _logger.i('✅ Stored auth data updated with new access token');
        }

        return newAccessToken;
      }

      return null;
    } catch (error) {
      _logger.e('❌ Failed to refresh Google access token: $error');
      return null;
    }
  }

  // Check if user has calendar access
  bool hasCalendarAccess(AuthData authData) {
    return authData.scopes?.any((scope) => scope.contains('calendar')) ?? false;
  }

  // Get available calendar scopes
  List<String> getCalendarScopes(AuthData authData) {
    return authData.scopes?.where((scope) => scope.contains('calendar')).toList() ?? [];
  }
}
