import 'package:dartz/dartz.dart';
import 'package:movie_discovery_app/core/error/failures.dart';
import 'package:movie_discovery_app/features/movies/domain/entities/movie_entity.dart';

abstract class MovieRepository {
  Future<Either<Failure, List<MovieEntity>>> getPopularMovies({int page = 1});
  Future<Either<Failure, List<MovieEntity>>> getTopRatedMovies({int page = 1});
  Future<Either<Failure, MovieEntity>> getMovieDetails(int movieId);
  Future<Either<Failure, List<MovieEntity>>> searchMovies(String query, {int page = 1});
}
