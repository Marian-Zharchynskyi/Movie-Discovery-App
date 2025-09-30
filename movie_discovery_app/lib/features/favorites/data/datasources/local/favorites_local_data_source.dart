import 'dart:convert';
import 'package:movie_discovery_app/core/error/exceptions.dart';
import 'package:movie_discovery_app/features/favorites/data/models/favorite_movie_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class FavoritesLocalDataSource {
  Future<List<FavoriteMovieModel>> getFavoriteMovies();
  Future<bool> addToFavorites(FavoriteMovieModel movie);
  Future<bool> removeFromFavorites(int movieId);
  Future<bool> isFavorite(int movieId);
}

class FavoritesLocalDataSourceImpl implements FavoritesLocalDataSource {
  static const String _favoritesKey = 'favorite_movies';
  final SharedPreferences sharedPreferences;

  FavoritesLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<List<FavoriteMovieModel>> getFavoriteMovies() async {
    try {
      final jsonString = sharedPreferences.getString(_favoritesKey);
      if (jsonString != null) {
        final List<dynamic> jsonList = json.decode(jsonString);
        return jsonList
            .map((json) => FavoriteMovieModel.fromJson(json))
            .toList();
      }
      return [];
    } catch (e) {
      throw CacheException('Failed to get favorite movies: $e');
    }
  }

  @override
  Future<bool> addToFavorites(FavoriteMovieModel movie) async {
    try {
      final favorites = await getFavoriteMovies();

      // Check if movie is already in favorites
      if (favorites.any((fav) => fav.id == movie.id)) {
        return false; // Already exists
      }

      favorites.add(movie);
      final jsonString = json.encode(favorites.map((fav) => fav.toJson()).toList());
      return await sharedPreferences.setString(_favoritesKey, jsonString);
    } catch (e) {
      throw CacheException('Failed to add movie to favorites: $e');
    }
  }

  @override
  Future<bool> removeFromFavorites(int movieId) async {
    try {
      final favorites = await getFavoriteMovies();
      final initialLength = favorites.length;

      favorites.removeWhere((fav) => fav.id == movieId);

      if (favorites.length == initialLength) {
        return false; // Movie wasn't in favorites
      }

      final jsonString = json.encode(favorites.map((fav) => fav.toJson()).toList());
      return await sharedPreferences.setString(_favoritesKey, jsonString);
    } catch (e) {
      throw CacheException('Failed to remove movie from favorites: $e');
    }
  }

  @override
  Future<bool> isFavorite(int movieId) async {
    try {
      final favorites = await getFavoriteMovies();
      return favorites.any((fav) => fav.id == movieId);
    } catch (e) {
      throw CacheException('Failed to check if movie is favorite: $e');
    }
  }
}
