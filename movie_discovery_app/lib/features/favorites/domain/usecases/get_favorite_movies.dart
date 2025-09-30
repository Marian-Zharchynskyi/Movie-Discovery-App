import 'package:dartz/dartz.dart';
import 'package:movie_discovery_app/core/error/failures.dart';
import 'package:movie_discovery_app/features/favorites/domain/entities/favorite_movie_entity.dart';
import 'package:movie_discovery_app/features/favorites/domain/repositories/favorites_repository.dart';

class GetFavoriteMovies {
  final FavoritesRepository repository;

  GetFavoriteMovies(this.repository);

  Future<Either<Failure, List<FavoriteMovieEntity>>> call() async {
    return await repository.getFavoriteMovies();
  }
}
