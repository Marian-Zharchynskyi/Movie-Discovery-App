import 'package:dartz/dartz.dart';
import 'package:movie_discovery_app/core/error/failures.dart';
import 'package:movie_discovery_app/features/favorites/domain/entities/favorite_movie_entity.dart';

abstract class FavoritesRepository {
  Future<Either<Failure, List<FavoriteMovieEntity>>> getFavoriteMovies(String userId);
  Future<Either<Failure, bool>> addToFavorites(FavoriteMovieEntity movie, String userId);
  Future<Either<Failure, bool>> removeFromFavorites(int movieId, String userId);
  Future<Either<Failure, bool>> isFavorite(int movieId, String userId);
}
