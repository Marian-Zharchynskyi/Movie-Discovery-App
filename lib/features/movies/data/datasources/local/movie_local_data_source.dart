import 'dart:convert';

import 'package:movie_discovery_app/core/database/app_database.dart';
import 'package:movie_discovery_app/core/error/exceptions.dart';
import 'package:movie_discovery_app/features/movies/data/models/movie_model.dart';
import 'package:drift/drift.dart' as drift;

abstract class MovieLocalDataSource {
  Future<void> cachePopularMovies(List<MovieModel> movies);
  Future<void> cacheTopRatedMovies(List<MovieModel> movies);
  Future<void> cacheMovieDetails(MovieModel movie);

  Future<List<MovieModel>> getCachedPopularMovies();
  Future<List<MovieModel>> getCachedTopRatedMovies();
  Future<MovieModel?> getCachedMovieById(int movieId);
  Future<List<MovieModel>> searchCachedMovies(String query);
}

class MovieLocalDataSourceImpl implements MovieLocalDataSource {
  static const String _popular = 'popular';
  static const String _topRated = 'top_rated';

  final AppDatabase db;

  MovieLocalDataSourceImpl({required this.db});

  @override
  Future<void> cachePopularMovies(List<MovieModel> movies) async {
    await _cacheMovies(movies, _popular);
  }

  @override
  Future<void> cacheTopRatedMovies(List<MovieModel> movies) async {
    await _cacheMovies(movies, _topRated);
  }

  @override
  Future<void> cacheMovieDetails(MovieModel movie) async {
    try {
      final entry = _toCompanion(movie, category: '');
      await db.into(db.movies).insertOnConflictUpdate(entry);
    } catch (e) {
      throw CacheException('Failed to cache movie details: $e');
    }
  }

  @override
  Future<List<MovieModel>> getCachedPopularMovies() async {
    return _getByCategory(_popular);
  }

  @override
  Future<List<MovieModel>> getCachedTopRatedMovies() async {
    return _getByCategory(_topRated);
  }

  @override
  Future<MovieModel?> getCachedMovieById(int movieId) async {
    try {
      final row = await db.getMovieById(movieId);
      if (row == null) return null;
      return _fromRow(row);
    } catch (e) {
      throw CacheException('Failed to get cached movie: $e');
    }
  }

  @override
  Future<List<MovieModel>> searchCachedMovies(String query) async {
    try {
      final rows = await db.searchMoviesByTitle(query);
      return rows.map(_fromRow).toList(growable: false);
    } catch (e) {
      throw CacheException('Failed to search cached movies: $e');
    }
  }

  Future<void> _cacheMovies(List<MovieModel> movies, String category) async {
    try {
      final entries = movies.map((m) => _toCompanion(m, category: category)).toList();
      await db.upsertMovies(entries);
    } catch (e) {
      throw CacheException('Failed to cache movies: $e');
    }
  }

  Future<List<MovieModel>> _getByCategory(String category) async {
    try {
      final rows = await db.getMoviesByCategory(category);
      return rows.map(_fromRow).toList(growable: false);
    } catch (e) {
      throw CacheException('Failed to get cached movies: $e');
    }
  }

  MoviesCompanion _toCompanion(MovieModel m, {required String category}) {
    return MoviesCompanion(
      id: drift.Value(m.id),
      title: drift.Value(m.title),
      overview: drift.Value(m.overview),
      posterPath: drift.Value(m.posterPath),
      backdropPath: drift.Value(m.backdropPath),
      voteAverage: drift.Value(m.voteAverage),
      releaseDate: drift.Value(m.releaseDate),
      genreIdsJson: drift.Value(jsonEncode(m.genreIds)),
      category: drift.Value(category),
      cachedAt: drift.Value(DateTime.now()),
    );
  }

  MovieModel _fromRow(MovieRow r) {
    final genreIds = (jsonDecode(r.genreIdsJson) as List).map((e) => e as int).toList();
    return MovieModel(
      id: r.id,
      title: r.title,
      overview: r.overview,
      posterPath: r.posterPath,
      backdropPath: r.backdropPath,
      voteAverage: r.voteAverage,
      releaseDate: r.releaseDate,
      genreIds: genreIds,
    );
  }
}
