import 'package:dartz/dartz.dart';
import 'package:movie_discovery_app/core/error/exceptions.dart';
import 'package:movie_discovery_app/core/error/failures.dart';
import 'package:movie_discovery_app/features/movies/data/datasources/local/movie_local_data_source.dart';
import 'package:movie_discovery_app/features/movies/data/datasources/remote/movie_remote_data_source.dart';
import 'package:movie_discovery_app/features/movies/data/datasources/local/review_local_data_source.dart';
import 'package:movie_discovery_app/features/movies/data/datasources/local/video_local_data_source.dart';
import 'package:movie_discovery_app/features/movies/domain/entities/movie_entity.dart';
import 'package:movie_discovery_app/features/movies/domain/entities/video_entity.dart';
import 'package:movie_discovery_app/features/movies/domain/entities/review_entity.dart';
import 'package:movie_discovery_app/features/movies/domain/repositories/movie_repository.dart';

class MovieRepositoryImpl implements MovieRepository {
  final MovieRemoteDataSource remoteDataSource;
  final MovieLocalDataSource localDataSource;
  final ReviewLocalDataSource? reviewLocalDataSource;
  final VideoLocalDataSource? videoLocalDataSource;

  MovieRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    this.reviewLocalDataSource,
    this.videoLocalDataSource,
  });

  @override
  Future<Either<Failure, List<MovieEntity>>> getPopularMovies({int page = 1}) async {
    List<MovieEntity> cached = const [];
    if (page == 1) {
      try {
        cached = await localDataSource.getCachedPopularMovies();
        if (cached.isNotEmpty) return Right(cached);
      } catch (_) {}
    }

    try {
      final movies = await remoteDataSource.getPopularMovies(page: page);
      if (page == 1) {
        await localDataSource.cachePopularMovies(movies);
      }
      return Right(movies);
    } on ServerException catch (e) {
      if (page == 1 && cached.isNotEmpty) return Right(cached);
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, MovieEntity>> getMovieDetails(int movieId) async {
    MovieEntity? cached;
    try {
      cached = await localDataSource.getCachedMovieById(movieId);
      if (cached != null) return Right(cached);
    } catch (_) {}

    try {
      final movie = await remoteDataSource.getMovieDetails(movieId);
      await localDataSource.cacheMovieDetails(movie);
      return Right(movie);
    } on ServerException catch (e) {
      if (cached != null) return Right(cached);
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, List<MovieEntity>>> getTopRatedMovies({int page = 1}) async {
    List<MovieEntity> cached = const [];
    if (page == 1) {
      try {
        cached = await localDataSource.getCachedTopRatedMovies();
        if (cached.isNotEmpty) return Right(cached);
      } catch (_) {}
    }

    try {
      final movies = await remoteDataSource.getTopRatedMovies(page: page);
      if (page == 1) {
        await localDataSource.cacheTopRatedMovies(movies);
      }
      return Right(movies);
    } on ServerException catch (e) {
      if (page == 1 && cached.isNotEmpty) return Right(cached);
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, List<MovieEntity>>> searchMovies(String query, {int page = 1}) async {
    if (page == 1) {
      try {
        final cached = await localDataSource.searchCachedMovies(query);
        if (cached.isNotEmpty) return Right(cached);
      } catch (_) {}
    }

    try {
      final movies = await remoteDataSource.searchMovies(query, page: page);
      return Right(movies);
    } on ServerException catch (e) {
      if (page == 1) {
        try {
          final cached = await localDataSource.searchCachedMovies(query);
          if (cached.isNotEmpty) return Right(cached);
        } catch (_) {}
      }
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, List<VideoEntity>>> getMovieVideos(int movieId) async {
    if (videoLocalDataSource != null) {
      try {
        final cached = await videoLocalDataSource!.getCachedVideos(movieId);
        if (cached.isNotEmpty) return Right(cached);
      } catch (_) {}
    }

    try {
      final videos = await remoteDataSource.getMovieVideos(movieId);
      if (videoLocalDataSource != null) {
        await videoLocalDataSource!.cacheVideos(movieId, videos);
      }
      return Right(videos);
    } on ServerException catch (e) {
      if (videoLocalDataSource != null) {
        try {
          final cached = await videoLocalDataSource!.getCachedVideos(movieId);
          if (cached.isNotEmpty) return Right(cached);
        } catch (_) {}
      }
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, List<ReviewEntity>>> getMovieReviews(int movieId, {int page = 1}) async {
    if (reviewLocalDataSource != null) {
      try {
        final cached = await reviewLocalDataSource!.getCachedReviews(movieId, page);
        if (cached.isNotEmpty) return Right(cached);
      } catch (_) {}
    }

    try {
      final reviews = await remoteDataSource.getMovieReviews(movieId, page: page);
      if (reviewLocalDataSource != null) {
        await reviewLocalDataSource!.cacheReviews(movieId, page, reviews);
      }
      return Right(reviews);
    } on ServerException catch (e) {
      if (reviewLocalDataSource != null) {
        try {
          final cached = await reviewLocalDataSource!.getCachedReviews(movieId, page);
          if (cached.isNotEmpty) return Right(cached);
        } catch (_) {}
      }
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, List<MovieEntity>>> discoverMovies({
    int page = 1,
    List<int>? genreIds,
    int? year,
    double? minRating,
  }) async {
    try {
      final movies = await remoteDataSource.discoverMovies(
        page: page,
        genreIds: genreIds,
        year: year,
        minRating: minRating,
      );
      return Right(movies);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }
}
