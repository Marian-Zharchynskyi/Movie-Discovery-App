import 'package:dartz/dartz.dart';
import 'package:movie_discovery_app/core/error/failures.dart';
import 'package:movie_discovery_app/features/favorites/domain/repositories/favorites_repository.dart';

class RemoveFromFavorites {
  final FavoritesRepository repository;

  RemoveFromFavorites(this.repository);

  Future<Either<Failure, bool>> call(int movieId) async {
    return await repository.removeFromFavorites(movieId);
  }
}
