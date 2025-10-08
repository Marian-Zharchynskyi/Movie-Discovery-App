import 'package:dartz/dartz.dart';
import 'package:movie_discovery_app/core/error/exceptions.dart';
import 'package:movie_discovery_app/core/error/failures.dart';
import 'package:movie_discovery_app/features/movies/data/datasources/local/movie_local_data_source.dart';
import 'package:movie_discovery_app/features/movies/data/datasources/remote/movie_remote_data_source.dart';
import 'package:movie_discovery_app/features/movies/domain/entities/movie_entity.dart';
import 'package:movie_discovery_app/features/movies/domain/repositories/movie_repository.dart';

class MovieRepositoryImpl implements MovieRepository {
  final MovieRemoteDataSource remoteDataSource;
  final MovieLocalDataSource localDataSource;

  MovieRepositoryImpl({required this.remoteDataSource, required this.localDataSource});

  @override
  Future<Either<Failure, List<MovieEntity>>> getPopularMovies({int page = 1}) async {
    try {
      final movies = await remoteDataSource.getPopularMovies(page: page);
      // cache only first page
      if (page == 1) {
        await localDataSource.cachePopularMovies(movies);
      }
      return Right(movies);
    } on ServerException catch (e) {
      // fallback to cache only for first page
      if (page == 1) {
        try {
          final cached = await localDataSource.getCachedPopularMovies();
          if (cached.isNotEmpty) return Right(cached);
        } catch (_) {}
      }
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, MovieEntity>> getMovieDetails(int movieId) async {
    try {
      final movie = await remoteDataSource.getMovieDetails(movieId);
      await localDataSource.cacheMovieDetails(movie);
      return Right(movie);
    } on ServerException catch (e) {
      try {
        final cached = await localDataSource.getCachedMovieById(movieId);
        if (cached != null) return Right(cached);
      } catch (_) {}
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, List<MovieEntity>>> getTopRatedMovies({int page = 1}) async {
    try {
      final movies = await remoteDataSource.getTopRatedMovies(page: page);
      // cache only first page
      if (page == 1) {
        await localDataSource.cacheTopRatedMovies(movies);
      }
      return Right(movies);
    } on ServerException catch (e) {
      // fallback to cache only for first page
      if (page == 1) {
        try {
          final cached = await localDataSource.getCachedTopRatedMovies();
          if (cached.isNotEmpty) return Right(cached);
        } catch (_) {}
      }
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, List<MovieEntity>>> searchMovies(String query, {int page = 1}) async {
    try {
      final movies = await remoteDataSource.searchMovies(query, page: page);
      return Right(movies);
    } on ServerException catch (e) {
      // fallback to cache only for first page
      if (page == 1) {
        try {
          final cached = await localDataSource.searchCachedMovies(query);
          if (cached.isNotEmpty) return Right(cached);
        } catch (_) {}
      }
      return Left(ServerFailure(e.message));
    }
  }
}
