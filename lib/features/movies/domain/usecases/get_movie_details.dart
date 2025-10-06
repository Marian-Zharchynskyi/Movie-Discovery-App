import 'package:dartz/dartz.dart';
import 'package:movie_discovery_app/core/error/failures.dart';
import 'package:movie_discovery_app/features/movies/domain/entities/movie_entity.dart';
import 'package:movie_discovery_app/features/movies/domain/repositories/movie_repository.dart';

class GetMovieDetails {
  final MovieRepository repository;
  GetMovieDetails(this.repository);

  Future<Either<Failure, MovieEntity>> call(int movieId) {
    return repository.getMovieDetails(movieId);
  }
}
