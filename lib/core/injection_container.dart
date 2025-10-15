import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:movie_discovery_app/core/network/dio_config.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:movie_discovery_app/core/services/mock_auth_api.dart';
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
import 'package:movie_discovery_app/features/auth/domain/usecases/get_stored_token.dart';

import 'package:movie_discovery_app/features/favorites/data/datasources/local/favorites_local_data_source.dart';
import 'package:movie_discovery_app/features/favorites/data/repositories/favorites_repository_impl.dart';
import 'package:movie_discovery_app/features/favorites/domain/repositories/favorites_repository.dart';
import 'package:movie_discovery_app/features/favorites/domain/usecases/add_to_favorites.dart';
import 'package:movie_discovery_app/features/favorites/domain/usecases/get_favorite_movies.dart';
import 'package:movie_discovery_app/features/favorites/domain/usecases/is_favorite.dart';
import 'package:movie_discovery_app/features/favorites/domain/usecases/remove_from_favorites.dart';
import 'package:movie_discovery_app/features/favorites/domain/usecases/get_favorites_count.dart';
import 'package:movie_discovery_app/features/movies/data/datasources/remote/movie_remote_data_source.dart';
import 'package:movie_discovery_app/features/movies/data/datasources/local/movie_local_data_source.dart';
import 'package:movie_discovery_app/features/movies/data/repositories/movie_repository_impl.dart';
import 'package:movie_discovery_app/features/movies/domain/repositories/movie_repository.dart';
import 'package:movie_discovery_app/features/movies/domain/usecases/get_popular_movies.dart';
import 'package:movie_discovery_app/features/movies/domain/usecases/get_top_rated_movies.dart';
import 'package:movie_discovery_app/features/movies/domain/usecases/get_movie_details.dart';
import 'package:movie_discovery_app/features/movies/domain/usecases/get_movie_videos.dart';
import 'package:movie_discovery_app/features/movies/domain/usecases/get_movie_reviews.dart';
import 'package:movie_discovery_app/features/movies/domain/usecases/discover_movies.dart';
import 'package:movie_discovery_app/features/movies/domain/usecases/search_movies.dart';

// Profile feature
import 'package:movie_discovery_app/features/profile/data/datasources/profile_local_data_source.dart';
import 'package:movie_discovery_app/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:movie_discovery_app/features/profile/domain/repositories/profile_repository.dart';
import 'package:movie_discovery_app/features/profile/domain/usecases/get_profile.dart';
import 'package:movie_discovery_app/features/profile/domain/usecases/get_theme_mode.dart';
import 'package:movie_discovery_app/features/profile/domain/usecases/set_theme_mode.dart';
import 'package:movie_discovery_app/features/profile/domain/usecases/get_locale_code.dart';
import 'package:movie_discovery_app/features/profile/domain/usecases/set_locale_code.dart';

final sl = GetIt.instance;

Future<void> init() async {
  //! External
  await _initExternalDependencies();
  
  //! Features - will be added in next steps
  await _initAuthFeature();
  await _initProfileFeature();
}

Future<void> _initExternalDependencies() async {
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
  // FirebaseFirestore
  sl.registerLazySingleton<FirebaseFirestore>(() => FirebaseFirestore.instance);
  
  // Secure Storage
  sl.registerLazySingleton<FlutterSecureStorage>(() => const FlutterSecureStorage());
  
  // Drift database
  sl.registerLazySingleton<AppDatabase>(() => AppDatabase());
  
  // Register Dio with interceptors
  sl.registerLazySingleton<Dio>(() {
     return DioConfig.createDio(
      baseUrl: dotenv.env['TMDB_BASE_URL'] ?? 'https://api.themoviedb.org/3',
      apiKey: dotenv.env['TMDB_API_KEY'],
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      enableLogging: false,
      maxRetries: 3,
    );
  });
  
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
  
  // Register repositories
  sl.registerLazySingleton<MovieRepository>(
    () => MovieRepositoryImpl(remoteDataSource: sl(), localDataSource: sl()),
  );
  sl.registerLazySingleton<FavoritesRepository>(
    () => FavoritesRepositoryImpl(localDataSource: sl()),
  );
  
  // Register use cases
  sl.registerFactory(() => GetPopularMovies(sl()));
  sl.registerFactory(() => GetTopRatedMovies(sl()));
  sl.registerFactory(() => GetMovieDetails(sl()));
  sl.registerFactory(() => GetMovieVideos(sl()));
  sl.registerFactory(() => GetMovieReviews(sl()));
  sl.registerFactory(() => DiscoverMovies(sl()));
  sl.registerFactory(() => SearchMovies(sl()));
  sl.registerFactory(() => GetFavoriteMovies(sl()));
  sl.registerFactory(() => AddToFavorites(sl()));
  sl.registerFactory(() => RemoveFromFavorites(sl()));
  sl.registerFactory(() => IsFavorite(sl()));
  sl.registerFactory(() => GetFavoritesCount(sl()));
}

Future<void> _initAuthFeature() async {
  // Mock Auth API (optional - can switch between Firebase and Mock)
  sl.registerLazySingleton<MockAuthApi>(() => MockAuthApi());
  
  // Data sources
  // Use Firebase implementation as the primary auth provider
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(firebaseAuth: sl(), firestore: sl()),
  );
  
  sl.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(secureStorage: sl()),
  );

  // Repository
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
      mockAuthApi: sl(),
    ),
  );

  // Use cases
  sl.registerFactory(() => SignIn(sl()));
  sl.registerFactory(() => SignUp(sl()));
  sl.registerFactory(() => SignOut(sl()));
  sl.registerFactory(() => GetCurrentUser(sl()));
  sl.registerFactory(() => GetStoredToken(sl()));
}

Future<void> _initProfileFeature() async {
  // Data source
  sl.registerLazySingleton<ProfileLocalDataSource>(
    () => ProfileLocalDataSourceImpl(prefs: sl()),
  );

  // Repository
  sl.registerLazySingleton<ProfileRepository>(
    () => ProfileRepositoryImpl(
      authRepository: sl(),
      localDataSource: sl(),
    ),
  );

  // Use cases
  sl.registerFactory(() => GetProfile(sl()));
  sl.registerFactory(() => GetThemeMode(sl()));
  sl.registerFactory(() => SetThemeMode(sl()));
  sl.registerFactory(() => GetLocaleCode(sl()));
  sl.registerFactory(() => SetLocaleCode(sl()));
}
