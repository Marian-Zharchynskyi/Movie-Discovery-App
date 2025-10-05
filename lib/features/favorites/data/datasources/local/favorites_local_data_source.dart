import 'dart:convert';
import 'package:movie_discovery_app/core/error/exceptions.dart';
import 'package:movie_discovery_app/features/favorites/data/models/favorite_movie_model.dart';
import 'package:movie_discovery_app/core/database/app_database.dart';
import 'package:drift/drift.dart' as drift;

abstract class FavoritesLocalDataSource {
  Future<List<FavoriteMovieModel>> getFavoriteMovies();
  Future<bool> addToFavorites(FavoriteMovieModel movie);
  Future<bool> removeFromFavorites(int movieId);
  Future<bool> isFavorite(int movieId);
}

class FavoritesLocalDataSourceImpl implements FavoritesLocalDataSource {
  final AppDatabase db;

  FavoritesLocalDataSourceImpl({required this.db});

  @override
  Future<List<FavoriteMovieModel>> getFavoriteMovies() async {
    try {
      final rows = await db.getAllFavorites();
      return rows.map((r) {
        final genreIds = (jsonDecode(r.genreIdsJson) as List).map((e) => e as int).toList();
        return FavoriteMovieModel(
          id: r.id,
          title: r.title,
          overview: r.overview,
          posterPath: r.posterPath,
          backdropPath: r.backdropPath,
          voteAverage: r.voteAverage,
          releaseDate: r.releaseDate,
          genreIds: genreIds,
          dateAdded: r.dateAdded,
        );
      }).toList(growable: false);
    } catch (e) {
      throw CacheException('Failed to get favorite movies: $e');
    }
  }

  @override
  Future<bool> addToFavorites(FavoriteMovieModel movie) async {
    try {
      final entry = FavoritesCompanion(
        id: drift.Value(movie.id),
        title: drift.Value(movie.title),
        overview: drift.Value(movie.overview),
        posterPath: drift.Value(movie.posterPath),
        backdropPath: drift.Value(movie.backdropPath),
        voteAverage: drift.Value(movie.voteAverage),
        releaseDate: drift.Value(movie.releaseDate),
        genreIdsJson: drift.Value(jsonEncode(movie.genreIds)),
        dateAdded: drift.Value(movie.dateAdded),
      );
      await db.upsertFavorite(entry);
      return true;
    } catch (e) {
      throw CacheException('Failed to add movie to favorites: $e');
    }
  }

  @override
  Future<bool> removeFromFavorites(int movieId) async {
    try {
      final removed = await db.removeFavorite(movieId);
      return removed > 0;
    } catch (e) {
      throw CacheException('Failed to remove movie from favorites: $e');
    }
  }

  @override
  Future<bool> isFavorite(int movieId) async {
    try {
      return await db.isFavoriteId(movieId);
    } catch (e) {
      throw CacheException('Failed to check if movie is favorite: $e');
    }
  }
}
