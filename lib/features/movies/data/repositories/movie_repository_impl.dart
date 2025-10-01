import 'package:dartz/dartz.dart';
import 'package:movie_discovery_app/core/error/exceptions.dart';
import 'package:movie_discovery_app/core/error/failures.dart';
import 'package:movie_discovery_app/features/movies/data/datasources/remote/movie_remote_data_source.dart';
import 'package:movie_discovery_app/features/movies/domain/entities/movie_entity.dart';
import 'package:movie_discovery_app/features/movies/domain/repositories/movie_repository.dart';

class MovieRepositoryImpl implements MovieRepository {
  final MovieRemoteDataSource remoteDataSource;

  MovieRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<MovieEntity>>> getPopularMovies() async {
    try {
      final movies = await remoteDataSource.getPopularMovies();
      return Right(movies);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, MovieEntity>> getMovieDetails(int movieId) async {
    try {
      final movie = await remoteDataSource.getMovieDetails(movieId);
      return Right(movie);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, List<MovieEntity>>> getTopRatedMovies() async {
    try {
      final movies = await remoteDataSource.getTopRatedMovies();
      return Right(movies);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, List<MovieEntity>>> searchMovies(String query) async {
    try {
      final movies = await remoteDataSource.searchMovies(query);
      return Right(movies);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }
}
