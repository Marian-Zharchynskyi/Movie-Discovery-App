import 'package:dartz/dartz.dart';
import 'package:movie_discovery_app/core/error/failures.dart';
import 'package:movie_discovery_app/features/movies/domain/entities/review_entity.dart';
import 'package:movie_discovery_app/features/movies/domain/repositories/movie_repository.dart';

class GetMovieReviews {
  final MovieRepository repository;

  GetMovieReviews(this.repository);

  Future<Either<Failure, List<ReviewEntity>>> call(int movieId, {int page = 1}) async {
    return await repository.getMovieReviews(movieId, page: page);
  }
}
