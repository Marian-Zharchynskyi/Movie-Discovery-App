import 'package:dartz/dartz.dart';
import 'package:movie_discovery_app/core/error/failures.dart';
import 'package:movie_discovery_app/features/movies/domain/entities/movie_entity.dart';
import 'package:movie_discovery_app/features/movies/domain/repositories/movie_repository.dart';

class DiscoverMovies {
  final MovieRepository repository;

  DiscoverMovies(this.repository);

  Future<Either<Failure, List<MovieEntity>>> call({
    int page = 1,
    List<int>? genreIds,
    int? year,
    double? minRating,
  }) async {
    return await repository.discoverMovies(
      page: page,
      genreIds: genreIds,
      year: year,
      minRating: minRating,
    );
  }
}
