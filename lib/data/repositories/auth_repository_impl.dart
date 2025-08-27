import 'package:dartz/dartz.dart';
import '../../domain/entities/failure.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';
import '../datasources/auth_local_data_source.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, User>> signInWithGoogle() async {
    try {
      final result = await remoteDataSource.signInWithGoogle();
      
      return result.fold(
        (failure) => Left(failure),
        (userModel) async {
          // Cache the user locally
          await localDataSource.cacheUser(userModel);
          return Right(userModel.toEntity());
        },
      );
    } catch (e) {
      return const Left(ServerFailure('Unexpected error during Google sign-in'));
    }
  }

  @override
  Future<Either<Failure, User>> signInWithEmail(String email, String password) async {
    try {
      final result = await remoteDataSource.signInWithEmail(email, password);
      
      final userModel = result.fold(
        (failure) => null,
        (user) => user,
      );
      
      if (userModel == null) {
        return const Left(ServerFailure('Failed to sign in with email'));
      }
      
      // Cache the user locally
      await localDataSource.cacheUser(userModel);
      return Right(userModel.toEntity());
    } catch (e) {
      return const Left(ServerFailure('Unexpected error during email sign-in'));
    }
  }

  @override
  Future<Either<Failure, User>> signUpWithEmail(String email, String password, String name) async {
    try {
      final result = await remoteDataSource.signUpWithEmail(email, password, name);
      
      final userModel = result.fold(
        (failure) => null,
        (user) => user,
      );
      
      if (userModel == null) {
        return const Left(ServerFailure('Failed to sign up with email'));
      }
      
      // Cache the user locally
      await localDataSource.cacheUser(userModel);
      return Right(userModel.toEntity());
    } catch (e) {
      return const Left(ServerFailure('Unexpected error during sign-up'));
    }
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      // Clear local cache
      await localDataSource.clearCache();
      
      // Sign out from remote
      final result = await remoteDataSource.signOut();
      return result;
    } catch (e) {
      return const Left(ServerFailure('Unexpected error during sign-out'));
    }
  }

  @override
  Future<Either<Failure, User?>> getCurrentUser() async {
    try {
      // First try to get from local cache
      final localResult = await localDataSource.getCachedUser();
      
      if (localResult.isRight()) {
        final user = localResult.getOrElse(() => null);
        if (user != null) {
          return Right(user.toEntity());
        }
      }
      
      // If not in local cache, try remote
      final remoteResult = await remoteDataSource.getCurrentUser();
      
      return remoteResult.fold(
        (failure) => Left(failure),
        (userModel) {
          if (userModel != null) {
            // Cache the user locally
            localDataSource.cacheUser(userModel);
            return Right(userModel.toEntity());
          }
          return const Right(null);
        },
      );
    } catch (e) {
      return const Left(ServerFailure('Unexpected error getting current user'));
    }
  }

  @override
  Future<Either<Failure, bool>> isAuthenticated() async {
    try {
      final userResult = await getCurrentUser();
      
      return userResult.fold(
        (failure) => Left(failure),
        (user) => Right(user != null),
      );
    } catch (e) {
      return const Left(ServerFailure('Unexpected error checking authentication'));
    }
  }
}
