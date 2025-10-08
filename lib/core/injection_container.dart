import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:movie_discovery_app/core/network/dio_config.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:movie_discovery_app/core/database/app_database.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:movie_discovery_app/core/preferences/user_preferences.dart';

import 'package:movie_discovery_app/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:movie_discovery_app/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:movie_discovery_app/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:movie_discovery_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:movie_discovery_app/features/auth/domain/usecases/get_current_user.dart';
import 'package:movie_discovery_app/features/auth/domain/usecases/sign_in.dart';
import 'package:movie_discovery_app/features/auth/domain/usecases/sign_out.dart';
import 'package:movie_discovery_app/features/auth/domain/usecases/sign_up.dart';

import 'package:movie_discovery_app/features/favorites/data/datasources/local/favorites_local_data_source.dart';
import 'package:movie_discovery_app/features/favorites/data/repositories/favorites_repository_impl.dart';
import 'package:movie_discovery_app/features/favorites/domain/repositories/favorites_repository.dart';
import 'package:movie_discovery_app/features/favorites/domain/usecases/add_to_favorites.dart';
import 'package:movie_discovery_app/features/favorites/domain/usecases/get_favorite_movies.dart';
import 'package:movie_discovery_app/features/favorites/domain/usecases/is_favorite.dart';
import 'package:movie_discovery_app/features/favorites/domain/usecases/remove_from_favorites.dart';
import 'package:movie_discovery_app/features/movies/data/datasources/remote/movie_remote_data_source.dart';
import 'package:movie_discovery_app/features/movies/data/datasources/local/movie_local_data_source.dart';
import 'package:movie_discovery_app/features/movies/data/repositories/movie_repository_impl.dart';
import 'package:movie_discovery_app/features/movies/domain/repositories/movie_repository.dart';
import 'package:movie_discovery_app/features/movies/domain/usecases/get_popular_movies.dart';
import 'package:movie_discovery_app/features/movies/domain/usecases/get_top_rated_movies.dart';
import 'package:movie_discovery_app/features/movies/domain/usecases/get_movie_details.dart';

final sl = GetIt.instance;

Future<void> init() async {
  //! External
  await _initExternalDependencies();
  
  //! Features - will be added in next steps
  await _initAuthFeature();
  // await _initMoviesFeature();
  // await _initFavoritesFeature();
  // await _initProfileFeature();
}

Future<void> _initExternalDependencies() async {
  // Register environment variables
  await dotenv.load(fileName: ".env");

  // Register SharedPreferences
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton<SharedPreferences>(() => sharedPreferences);

  // Hive for user preferences
  await Hive.initFlutter();
  final userPrefsBox = await Hive.openBox(UserPreferences.boxName);
  sl.registerLazySingleton<UserPreferences>(() => UserPreferences(userPrefsBox));
  
  // FirebaseAuth
  sl.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);
  
  // Secure Storage
  sl.registerLazySingleton<FlutterSecureStorage>(() => const FlutterSecureStorage());
  
  // Register use cases
  sl.registerFactory(() => GetPopularMovies(sl()));
  sl.registerFactory(() => GetTopRatedMovies(sl()));
  sl.registerFactory(() => GetMovieDetails(sl()));
  sl.registerFactory(() => GetFavoriteMovies(sl()));
  sl.registerFactory(() => AddToFavorites(sl()));
  sl.registerFactory(() => RemoveFromFavorites(sl()));
  sl.registerFactory(() => IsFavorite(sl()));
  
  // Register repositories
  sl.registerLazySingleton<MovieRepository>(
    () => MovieRepositoryImpl(remoteDataSource: sl(), localDataSource: sl()),
  );
  sl.registerLazySingleton<FavoritesRepository>(
    () => FavoritesRepositoryImpl(localDataSource: sl()),
  );
  
  // Register data sources
  sl.registerLazySingleton<MovieRemoteDataSource>(
    () => MovieRemoteDataSourceImpl(client: sl()),
  );
  sl.registerLazySingleton<MovieLocalDataSource>(
    () => MovieLocalDataSourceImpl(db: sl()),
  );
  sl.registerLazySingleton<FavoritesLocalDataSource>(
    () => FavoritesLocalDataSourceImpl(db: sl()),
  );
  
  // Register Dio with interceptors
  sl.registerLazySingleton<Dio>(() {
    // Read networking config from .env (required)
    final enableLoggingStr = dotenv.env['ENABLE_HTTP_LOGS']!;
    final connectTimeoutMsStr = dotenv.env['DIO_CONNECT_TIMEOUT_MS']!;
    final receiveTimeoutMsStr = dotenv.env['DIO_RECEIVE_TIMEOUT_MS']!;
    final retriesStr = dotenv.env['RETRIES_MAX']!;

    final enableLogging = enableLoggingStr.toLowerCase() == 'true';
    final connectTimeoutMs = int.parse(connectTimeoutMsStr);
    final receiveTimeoutMs = int.parse(receiveTimeoutMsStr);
    final maxRetries = int.parse(retriesStr);

    return DioConfig.createDio(
      baseUrl: dotenv.env['TMDB_BASE_URL']!,
      apiKey: dotenv.env['TMDB_API_KEY'],
      connectTimeout: Duration(milliseconds: connectTimeoutMs),
      receiveTimeout: Duration(milliseconds: receiveTimeoutMs),
      enableLogging: enableLogging,
      maxRetries: maxRetries,
    );
  });

  // Drift database
  sl.registerLazySingleton<AppDatabase>(() => AppDatabase());
}

Future<void> _initAuthFeature() async {
  // Data sources
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(firebaseAuth: sl()),
  );
  sl.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(secureStorage: sl()),
  );

  // Repository
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remoteDataSource: sl(), localDataSource: sl()),
  );

  // Use cases
  sl.registerFactory(() => SignIn(sl()));
  sl.registerFactory(() => SignUp(sl()));
  sl.registerFactory(() => SignOut(sl()));
  sl.registerFactory(() => GetCurrentUser(sl()));
}
