import 'package:dartz/dartz.dart';
import 'package:movie_discovery_app/core/error/failures.dart';
import 'package:movie_discovery_app/features/favorites/domain/entities/favorite_movie_entity.dart';
import 'package:movie_discovery_app/features/favorites/domain/repositories/favorites_repository.dart';

class AddToFavorites {
  final FavoritesRepository repository;

  AddToFavorites(this.repository);

  Future<Either<Failure, bool>> call(FavoriteMovieEntity movie) async {
    return await repository.addToFavorites(movie);
  }
}
