import 'package:dartz/dartz.dart';
import '../../domain/entities/failure.dart';
import '../../domain/entities/user.dart';
import '../models/user_model.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/logging_interceptor.dart';

abstract class AuthRemoteDataSource {
  Future<Either<Failure, UserModel>> signInWithGoogle();
  Future<Either<Failure, UserModel>> signInWithEmail(String email, String password);
  Future<Either<Failure, UserModel>> signUpWithEmail(String email, String password, String name);
  Future<Either<Failure, void>> signOut();
  Future<Either<Failure, UserModel?>> getCurrentUser();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final AuthService _authService = AuthService();
  final LoggingInterceptor _logger = LoggingInterceptor();

  @override
  Future<Either<Failure, UserModel>> signInWithGoogle() async {
    try {
      _logger.logAuthDetails(
        operation: 'Google Sign-In Attempt',
        userId: null,
        email: null,
      );

      // Use real Google Sign-In service
      final authData = await _authService.signIn();
      
      if (authData == null) {
        _logger.logError(
          error: 'Google Sign-In was cancelled or failed',
          operation: 'Google Sign-In',
        );
        return const Left(AuthFailure('Google Sign-In was cancelled'));
      }

      // Convert AuthData to UserModel
      final user = UserModel(
        id: authData.user.id,
        email: authData.user.email,
        name: authData.user.name,
        photoUrl: authData.user.photo,
        createdAt: DateTime.now(),
      );

      _logger.logAuthDetails(
        operation: 'Google Sign-In Success',
        userId: user.id,
        email: user.email,
        jwtToken: authData.jwtToken,
        accessToken: authData.accessToken,
      );

      _logger.logger.i('✅ Google Sign-In successful for user: ${user.email}');
      _logger.logger.i('📅 Calendar scopes granted: ${authData.scopes?.where((scope) => scope.contains('calendar')).join(', ')}');

      return Right(user);
    } catch (e) {
      _logger.logError(
        error: e.toString(),
        operation: 'Google Sign-In',
        stackTrace: StackTrace.current,
      );
      
      if (e.toString().contains('network')) {
        return const Left(NetworkFailure('Network error during Google Sign-In'));
      } else if (e.toString().contains('cancelled')) {
        return const Left(AuthFailure('Google Sign-In was cancelled'));
      } else {
        return Left(ServerFailure('Failed to sign in with Google: ${e.toString()}'));
      }
    }
  }

  @override
  Future<Either<Failure, UserModel>> signInWithEmail(String email, String password) async {
    try {
      _logger.logAuthDetails(
        operation: 'Email Sign-In Attempt',
        email: email,
      );

      if (email.isEmpty || password.isEmpty) {
        return const Left(ValidationFailure('Email and password are required'));
      }
      
      // TODO: Implement real email/password authentication
      // For now, return error as this is not implemented
      _logger.logError(
        error: 'Email/password authentication not implemented',
        operation: 'Email Sign-In',
      );
      
      return const Left(AuthFailure('Email/password authentication not yet implemented'));
    } catch (e) {
      _logger.logError(
        error: e.toString(),
        operation: 'Email Sign-In',
        stackTrace: StackTrace.current,
      );
      return const Left(ServerFailure('Failed to sign in with email'));
    }
  }

  @override
  Future<Either<Failure, UserModel>> signUpWithEmail(String email, String password, String name) async {
    try {
      _logger.logAuthDetails(
        operation: 'Email Sign-Up Attempt',
        email: email,
      );

      if (email.isEmpty || password.isEmpty || name.isEmpty) {
        return const Left(ValidationFailure('All fields are required'));
      }
      
      // TODO: Implement real email/password signup
      // For now, return error as this is not implemented
      _logger.logError(
        error: 'Email/password signup not implemented',
        operation: 'Email Sign-Up',
      );
      
      return const Left(AuthFailure('Email/password signup not yet implemented'));
    } catch (e) {
      _logger.logError(
        error: e.toString(),
        operation: 'Email Sign-Up',
        stackTrace: StackTrace.current,
      );
      return const Left(ServerFailure('Failed to create account'));
    }
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      _logger.logAuthDetails(
        operation: 'Sign-Out Attempt',
      );

      // Use real sign-out service
      await _authService.signOut();
      
      _logger.logAuthDetails(
        operation: 'Sign-Out Success',
      );

      _logger.logger.i('✅ User signed out successfully');
      return const Right(null);
    } catch (e) {
      _logger.logError(
        error: e.toString(),
        operation: 'Sign-Out',
        stackTrace: StackTrace.current,
      );
      return const Left(ServerFailure('Failed to sign out'));
    }
  }

  @override
  Future<Either<Failure, UserModel?>> getCurrentUser() async {
    try {
      _logger.logAuthDetails(
        operation: 'Get Current User Attempt',
      );

      // Use real auth service to get current user
      final authData = await _authService.getAuthData();
      
      if (authData == null) {
        _logger.logAuthDetails(
          operation: 'Get Current User - No User Found',
        );
        return const Right(null);
      }

      // Check if tokens are expired
      if (_authService.isTokenExpired(authData)) {
        _logger.logAuthDetails(
          operation: 'Get Current User - Token Expired',
          userId: authData.user.id,
          email: authData.user.email,
        );
        
        // Try to refresh tokens
        final refreshSuccess = await _authService.refreshGoogleAccessToken();
        if (refreshSuccess == null) {
          _logger.logError(
            error: 'Failed to refresh expired tokens',
            operation: 'Get Current User - Token Refresh',
          );
          return const Right(null); // User needs to sign in again
        }
      }

      // Convert AuthData to UserModel
      final user = UserModel(
        id: authData.user.id,
        email: authData.user.email,
        name: authData.user.name,
        photoUrl: authData.user.photo,
        createdAt: DateTime.now(),
      );

      _logger.logAuthDetails(
        operation: 'Get Current User - Success',
        userId: user.id,
        email: user.email,
        jwtToken: authData.jwtToken,
        accessToken: authData.accessToken,
      );

      _logger.logger.i('✅ Current user retrieved: ${user.email}');
      return Right(user);
    } catch (e) {
      _logger.logError(
        error: e.toString(),
        operation: 'Get Current User',
        stackTrace: StackTrace.current,
      );
      return const Left(ServerFailure('Failed to get current user'));
    }
  }
}
