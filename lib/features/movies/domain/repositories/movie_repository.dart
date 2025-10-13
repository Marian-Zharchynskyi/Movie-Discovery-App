import 'package:dartz/dartz.dart';
import 'package:movie_discovery_app/core/error/failures.dart';
import 'package:movie_discovery_app/features/movies/domain/entities/movie_entity.dart';
import 'package:movie_discovery_app/features/movies/domain/entities/video_entity.dart';
import 'package:movie_discovery_app/features/movies/domain/entities/review_entity.dart';

abstract class MovieRepository {
  Future<Either<Failure, List<MovieEntity>>> getPopularMovies({int page = 1});
  Future<Either<Failure, List<MovieEntity>>> getTopRatedMovies({int page = 1});
  Future<Either<Failure, MovieEntity>> getMovieDetails(int movieId);
  Future<Either<Failure, List<MovieEntity>>> searchMovies(String query, {int page = 1});
  Future<Either<Failure, List<VideoEntity>>> getMovieVideos(int movieId);
  Future<Either<Failure, List<ReviewEntity>>> getMovieReviews(int movieId, {int page = 1});
  Future<Either<Failure, List<MovieEntity>>> discoverMovies({
    int page = 1,
    List<int>? genreIds,
    int? year,
    double? minRating,
  });
}
