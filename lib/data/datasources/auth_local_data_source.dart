import 'package:dartz/dartz.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/failure.dart';
import '../models/user_model.dart';

abstract class AuthLocalDataSource {
  Future<Either<Failure, void>> cacheUser(UserModel user);
  Future<Either<Failure, UserModel?>> getCachedUser();
  Future<Either<Failure, void>> clearCache();
  Future<Either<Failure, void>> cacheToken(String token);
  Future<Either<Failure, String?>> getCachedToken();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  static const String _userKey = 'cached_user';
  static const String _tokenKey = 'auth_token';

  @override
  Future<Either<Failure, void>> cacheUser(UserModel user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = user.toJson();
      await prefs.setString(_userKey, userJson.toString());
      return const Right(null);
    } catch (e) {
      return const Left(CacheFailure('Failed to cache user'));
    }
  }

  @override
  Future<Either<Failure, UserModel?>> getCachedUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJsonString = prefs.getString(_userKey);
      
      if (userJsonString == null) {
        return const Right(null);
      }
      
      // Parse the JSON string back to a map
      final userJson = Map<String, dynamic>.from(
        userJsonString as Map<String, dynamic>
      );
      
      final user = UserModel.fromJson(userJson);
      return Right(user);
    } catch (e) {
      return const Left(CacheFailure('Failed to get cached user'));
    }
  }

  @override
  Future<Either<Failure, void>> clearCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_userKey);
      await prefs.remove(_tokenKey);
      return const Right(null);
    } catch (e) {
      return const Left(CacheFailure('Failed to clear cache'));
    }
  }

  @override
  Future<Either<Failure, void>> cacheToken(String token) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_tokenKey, token);
      return const Right(null);
    } catch (e) {
      return const Left(CacheFailure('Failed to cache token'));
    }
  }

  @override
  Future<Either<Failure, String?>> getCachedToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(_tokenKey);
      return Right(token);
    } catch (e) {
      return const Left(CacheFailure('Failed to get cached token'));
    }
  }
}
