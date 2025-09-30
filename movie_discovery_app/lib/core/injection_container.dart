import 'package:dio/dio.dart';
import 'package:movie_discovery_app/core/network/dio_config.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get_it/get_it.dart';

import 'package:movie_discovery_app/features/movies/data/datasources/remote/movie_remote_data_source.dart';
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
  
  // Register use cases
  sl.registerFactory(() => GetPopularMovies(sl()));
  sl.registerFactory(() => GetTopRatedMovies(sl()));
  
  // Register repositories
  sl.registerLazySingleton<MovieRepository>(
    () => MovieRepositoryImpl(remoteDataSource: sl()),
  );
  
  // Register data sources
  sl.registerLazySingleton<MovieRemoteDataSource>(
    () => MovieRemoteDataSourceImpl(client: sl()),
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

  // Database and storage initialization can be added here later
}
