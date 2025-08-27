import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

import '../models/auth_models.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final Logger _logger = Logger();

  AuthState _authState = AuthState();
  bool get isAuthenticated => _authState.isAuthenticated;
  User? get user => _authState.user;
  bool get isLoading => _authState.isLoading;
  String? get jwtToken => _authState.jwtToken;

  AuthProvider() {
    _initializeAuth();
  }

  // Initialize authentication
  Future<void> _initializeAuth() async {
    try {
      _logger.i('🔐 Initializing authentication...');
      
      // Configure Google Sign-In
      await _authService.configureGoogleSignIn();
      
      // Check if user is already signed in
      final isSignedIn = await _authService.isSignedIn();
      if (isSignedIn) {
        _logger.i('📱 User is already signed in, restoring session...');
        await _restoreSession();
      } else {
        _logger.i('📱 No existing session found');
        _setLoading(false);
      }
    } catch (error) {
      _logger.e('❌ Error initializing authentication: $error');
      _setLoading(false);
    }
  }

  // Restore user session from stored data
  Future<void> _restoreSession() async {
    try {
      final authData = await _authService.getAuthData();
      
      if (authData != null && !_authService.isTokenExpired(authData)) {
        _logger.i('✅ Session restored successfully');
        _authState = AuthState(
          isAuthenticated: true,
          user: authData.user,
          isLoading: false,
          idToken: authData.idToken,
          accessToken: authData.accessToken,
          serverAuthCode: authData.serverAuthCode,
          tokenExpiry: authData.tokenExpiry,
          jwtToken: authData.jwtToken,
        );
      } else {
        _logger.w('⚠️ Stored session is expired or invalid');
        if (authData != null) {
          await _authService.signOut();
        }
        _setLoading(false);
      }
    } catch (error) {
      _logger.e('❌ Error restoring session: $error');
      _setLoading(false);
    }
    
    notifyListeners();
  }

  // Sign in with Google
  Future<bool> signIn() async {
    try {
      _setLoading(true);
      _logger.i('🔐 Starting sign-in process...');

      final authData = await _authService.signIn();
      
      if (authData != null) {
        _authState = AuthState(
          isAuthenticated: true,
          user: authData.user,
          isLoading: false,
          idToken: authData.idToken,
          accessToken: authData.accessToken,
          serverAuthCode: authData.serverAuthCode,
          tokenExpiry: authData.tokenExpiry,
          jwtToken: authData.jwtToken,
        );
        
        _logger.i('✅ Sign-in successful');
        notifyListeners();
        return true;
      } else {
        _logger.w('⚠️ Sign-in was cancelled or failed');
        _setLoading(false);
        return false;
      }
    } catch (error) {
      _logger.e('❌ Error during sign-in: $error');
      _setLoading(false);
      return false;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      _logger.i('🚪 Starting sign-out process...');
      
      await _authService.signOut();
      
      _authState = AuthState();
      _logger.i('✅ Sign-out successful');
      
      notifyListeners();
    } catch (error) {
      _logger.e('❌ Error during sign-out: $error');
      rethrow;
    }
  }

  // Refresh Google access token
  Future<String?> refreshGoogleAccessToken() async {
    try {
      _logger.i('🔄 Refreshing Google access token...');
      
      final newAccessToken = await _authService.refreshGoogleAccessToken();
      
      if (newAccessToken != null) {
        // Update the stored auth data
        final currentAuthData = await _authService.getAuthData();
        if (currentAuthData != null) {
          _authState = _authState.copyWith(
            accessToken: newAccessToken,
          );
          notifyListeners();
        }
      }
      
      return newAccessToken;
    } catch (error) {
      _logger.e('❌ Error refreshing Google access token: $error');
      return null;
    }
  }

  // Get JWT token for API calls
  Future<String?> getJwtToken() async {
    try {
      // Check if current token is expired
      if (_authState.jwtToken != null && _authState.tokenExpiry != null) {
        final isExpired = DateTime.now().millisecondsSinceEpoch > _authState.tokenExpiry!;
        if (isExpired) {
          _logger.w('⚠️ JWT token is expired, attempting to refresh...');
          await refreshGoogleAccessToken();
        }
      }
      
      return _authState.jwtToken;
    } catch (error) {
      _logger.e('❌ Error getting JWT token: $error');
      return null;
    }
  }

  // Set loading state
  void _setLoading(bool loading) {
    _authState = _authState.copyWith(isLoading: loading);
    notifyListeners();
  }

  // Get current auth state
  AuthState get authState => _authState;
}
