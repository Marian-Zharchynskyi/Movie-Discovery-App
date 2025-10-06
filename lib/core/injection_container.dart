import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get_it/get_it.dart';
import 'package:movie_discovery_app/core/network/dio_config.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:movie_discovery_app/core/database/app_database.dart';

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

final sl = GetIt.instance;

Future<void> init() async {
  //! External
  await _initExternalDependencies();
  
  //! Features - will be added in next steps
  // await _initAuthFeature();
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
  
  // Register use cases
  sl.registerFactory(() => GetPopularMovies(sl()));
  sl.registerFactory(() => GetTopRatedMovies(sl()));
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
    return DioConfig.createDio(
      baseUrl: dotenv.env['TMDB_BASE_URL']!,
      apiKey: dotenv.env['TMDB_API_KEY'],
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      enableLogging: true,
      maxRetries: 3,
    );
  });

  // Drift database
  sl.registerLazySingleton<AppDatabase>(() => AppDatabase());
}
