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
import 'package:movie_discovery_app/features/movies/data/datasources/local/review_local_data_source.dart';
import 'package:movie_discovery_app/features/movies/data/datasources/local/video_local_data_source.dart';
import 'package:movie_discovery_app/features/movies/data/repositories/movie_repository_impl.dart';
import 'package:movie_discovery_app/features/movies/domain/repositories/movie_repository.dart';
import 'package:movie_discovery_app/features/movies/domain/usecases/get_popular_movies.dart';
import 'package:movie_discovery_app/features/movies/domain/usecases/get_top_rated_movies.dart';
import 'package:movie_discovery_app/features/movies/domain/usecases/get_movie_details.dart';
import 'package:movie_discovery_app/features/movies/domain/usecases/get_movie_videos.dart';
import 'package:movie_discovery_app/features/movies/domain/usecases/get_movie_reviews.dart';
import 'package:movie_discovery_app/features/movies/domain/usecases/discover_movies.dart';
import 'package:movie_discovery_app/features/movies/domain/usecases/search_movies.dart';

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
  await _initExternalDependencies();
  await _initAuthFeature();
  await _initProfileFeature();
}

Future<void> _initExternalDependencies() async {
  await dotenv.load(fileName: ".env");

  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton<SharedPreferences>(() => sharedPreferences);

  await Hive.initFlutter();
  final userPrefsBox = await Hive.openBox(UserPreferences.boxName);
  sl.registerLazySingleton<UserPreferences>(() => UserPreferences(userPrefsBox));
  
  sl.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);
  sl.registerLazySingleton<FirebaseFirestore>(() => FirebaseFirestore.instance);
  
  sl.registerLazySingleton<FlutterSecureStorage>(() => const FlutterSecureStorage());
  
  sl.registerLazySingleton<AppDatabase>(() => AppDatabase());
  
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
  
  sl.registerLazySingleton<MovieRemoteDataSource>(
    () => MovieRemoteDataSourceImpl(client: sl()),
  );
  sl.registerLazySingleton<MovieLocalDataSource>(
    () => MovieLocalDataSourceImpl(db: sl()),
  );
  sl.registerLazySingleton<ReviewLocalDataSource>(
    () => ReviewLocalDataSourceImpl(),
  );
  sl.registerLazySingleton<VideoLocalDataSource>(
    () => VideoLocalDataSourceImpl(),
  );
  sl.registerLazySingleton<FavoritesLocalDataSource>(
    () => FavoritesLocalDataSourceImpl(db: sl()),
  );
  
  sl.registerLazySingleton<MovieRepository>(
    () => MovieRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
      reviewLocalDataSource: sl(),
      videoLocalDataSource: sl(),
    ),
  );
  sl.registerLazySingleton<FavoritesRepository>(
    () => FavoritesRepositoryImpl(localDataSource: sl()),
  );
  
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
  sl.registerLazySingleton<MockAuthApi>(() => MockAuthApi());
  
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(firebaseAuth: sl(), firestore: sl()),
  );
  
  sl.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(secureStorage: sl()),
  );

  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
      mockAuthApi: sl(),
    ),
  );

  sl.registerFactory(() => SignIn(sl()));
  sl.registerFactory(() => SignUp(sl()));
  sl.registerFactory(() => SignOut(sl()));
  sl.registerFactory(() => GetCurrentUser(sl()));
  sl.registerFactory(() => GetStoredToken(sl()));
}

Future<void> _initProfileFeature() async {
  sl.registerLazySingleton<ProfileLocalDataSource>(
    () => ProfileLocalDataSourceImpl(prefs: sl()),
  );

  sl.registerLazySingleton<ProfileRepository>(
    () => ProfileRepositoryImpl(
      authRepository: sl(),
      localDataSource: sl(),
    ),
  );

  sl.registerFactory(() => GetProfile(sl()));
  sl.registerFactory(() => GetThemeMode(sl()));
  sl.registerFactory(() => SetThemeMode(sl()));
  sl.registerFactory(() => GetLocaleCode(sl()));
  sl.registerFactory(() => SetLocaleCode(sl()));
}
