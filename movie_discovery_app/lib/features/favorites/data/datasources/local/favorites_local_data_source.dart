import 'package:movie_discovery_app/core/error/exceptions.dart';
import 'package:movie_discovery_app/features/favorites/data/datasources/local/drift/favorites_database.dart';
import 'package:movie_discovery_app/features/favorites/data/models/favorite_movie_model.dart';

abstract class FavoritesLocalDataSource {
  Future<List<FavoriteMovieModel>> getFavoriteMovies();
  Future<bool> addToFavorites(FavoriteMovieModel movie);
  Future<bool> removeFromFavorites(int movieId);
  Future<bool> isFavorite(int movieId);
}

class FavoritesLocalDataSourceImpl implements FavoritesLocalDataSource {
  final FavoritesDatabase database;

  FavoritesLocalDataSourceImpl({required this.database});

  @override
  Future<List<FavoriteMovieModel>> getFavoriteMovies() async {
    try {
      return await database.fetchFavoriteMovies();
    } catch (e) {
      throw CacheException('Failed to get favorite movies: $e');
    }
  }

  @override
  Future<bool> addToFavorites(FavoriteMovieModel movie) async {
    try {
      return await database.insertFavoriteMovie(movie);
    } catch (e) {
      throw CacheException('Failed to add movie to favorites: $e');
    }
  }

  @override
  Future<bool> removeFromFavorites(int movieId) async {
    try {
      return await database.deleteFavoriteMovie(movieId);
    } catch (e) {
      throw CacheException('Failed to remove movie from favorites: $e');
    }
  }

  @override
  Future<bool> isFavorite(int movieId) async {
    try {
      return await database.isFavoriteMovie(movieId);
    } catch (e) {
      throw CacheException('Failed to check if movie is favorite: $e');
    }
  }
}
