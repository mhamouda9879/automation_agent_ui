import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/datasources/auth_remote_data_source.dart';
import '../../data/datasources/auth_local_data_source.dart';
import '../../data/datasources/calendar_remote_data_source.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../data/repositories/calendar_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/calendar_repository.dart';
import '../../domain/usecases/auth_usecases.dart';
import '../../domain/usecases/calendar_usecases.dart';
import '../../presentation/blocs/auth_bloc.dart';
import '../../presentation/blocs/calendar_bloc.dart';
import '../services/auth_service.dart';
import '../services/http_service.dart';
import '../services/calendar_service.dart';
import '../services/logging_interceptor.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Services
  sl.registerLazySingleton<AuthService>(() => AuthService());
  sl.registerLazySingleton<HttpService>(() => HttpService());
  sl.registerLazySingleton<CalendarService>(() => CalendarService());
  sl.registerLazySingleton<LoggingInterceptor>(() => LoggingInterceptor());

  // Blocs
  sl.registerFactory(
    () => AuthBloc(
      signInWithGoogle: sl(),
      signInWithEmail: sl(),
      signUpWithEmail: sl(),
      signOut: sl(),
      getCurrentUser: sl(),
      isAuthenticated: sl(),
    ),
  );

  sl.registerFactory(
    () => CalendarBloc(
      getEvents: sl(),
      getEventsByDate: sl(),
      getEventsByDateRange: sl(),
      createEventUseCase: sl(),
      updateEventUseCase: sl(),
      deleteEventUseCase: sl(),
      getEventByIdUseCase: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => SignInWithGoogle(sl()));
  sl.registerLazySingleton(() => SignInWithEmail(sl()));
  sl.registerLazySingleton(() => SignUpWithEmail(sl()));
  sl.registerLazySingleton(() => SignOut(sl()));
  sl.registerLazySingleton(() => GetCurrentUser(sl()));
  sl.registerLazySingleton(() => IsAuthenticated(sl()));

  sl.registerLazySingleton(() => GetEvents(sl()));
  sl.registerLazySingleton(() => GetEventsByDate(sl()));
  sl.registerLazySingleton(() => GetEventsByDateRange(sl()));
  sl.registerLazySingleton(() => CreateEventUseCase(sl()));
  sl.registerLazySingleton(() => UpdateEventUseCase(sl()));
  sl.registerLazySingleton(() => DeleteEventUseCase(sl()));
  sl.registerLazySingleton(() => GetEventByIdUseCase(sl()));

  // Repository
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
    ),
  );

  sl.registerLazySingleton<CalendarRepository>(
    () => CalendarRepositoryImpl(
      remoteDataSource: sl(),
    ),
  );

  // Data sources
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(),
  );

  sl.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(),
  );

  sl.registerLazySingleton<CalendarRemoteDataSource>(
    () => CalendarRemoteDataSourceImpl(),
  );

  // External
  sl.registerSingletonAsync<SharedPreferences>(
    () => SharedPreferences.getInstance(),
  );
}
