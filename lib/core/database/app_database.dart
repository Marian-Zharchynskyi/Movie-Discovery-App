import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'app_database.g.dart';

class Movies extends Table {
  IntColumn get id => integer()();
  TextColumn get title => text()();
  TextColumn get overview => text()();
  TextColumn get posterPath => text().nullable()();
  TextColumn get backdropPath => text().nullable()();
  RealColumn get voteAverage => real()();
  TextColumn get releaseDate => text().withDefault(const Constant(''))();
  // Store genreIds as a JSON string to keep schema simple
  TextColumn get genreIdsJson => text().withDefault(const Constant('[]'))();
  // Category to distinguish lists like popular / top_rated
  TextColumn get category => text().withDefault(const Constant(''))();
  DateTimeColumn get cachedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id, category};
}

// Separate table for user favorites, includes dateAdded
class Favorites extends Table {
  IntColumn get id => integer()();
  TextColumn get title => text()();
  TextColumn get overview => text()();
  TextColumn get posterPath => text().nullable()();
  TextColumn get backdropPath => text().nullable()();
  RealColumn get voteAverage => real()();
  TextColumn get releaseDate => text().withDefault(const Constant(''))();
  TextColumn get genreIdsJson => text().withDefault(const Constant('[]'))();
  DateTimeColumn get dateAdded => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(tables: [Movies, Favorites])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());
  // Testing constructors
  AppDatabase.forTesting(super.e);
  factory AppDatabase.memory() => AppDatabase.forTesting(NativeDatabase.memory());

  @override
  int get schemaVersion => 1;

  Future<void> upsertMovies(List<MoviesCompanion> entries) async {
    await batch((b) {
      b.insertAllOnConflictUpdate(movies, entries);
    });
  }

  Future<List<MovieRow>> getMoviesByCategory(String category) async {
    final query = (select(movies)..where((tbl) => tbl.category.equals(category)))
      ..orderBy([(t) => OrderingTerm(expression: t.cachedAt, mode: OrderingMode.desc)]);
    final rows = await query.get();
    return rows
        .map((r) => MovieRow(
              id: r.id,
              title: r.title,
              overview: r.overview,
              posterPath: r.posterPath,
              backdropPath: r.backdropPath,
              voteAverage: r.voteAverage,
              releaseDate: r.releaseDate,
              genreIdsJson: r.genreIdsJson,
              category: r.category,
              cachedAt: r.cachedAt,
            ))
        .toList();
  }

  // Movies
  Future<MovieRow?> getMovieById(int id) async {
    try {
      final q = select(movies)..where((t) => t.id.equals(id));
      final row = await q.getSingleOrNull();
      if (row == null) return null;
      return MovieRow(
        id: row.id,
        title: row.title,
        overview: row.overview,
        posterPath: row.posterPath,
        backdropPath: row.backdropPath,
        voteAverage: row.voteAverage,
        releaseDate: row.releaseDate,
        genreIdsJson: row.genreIdsJson,
        category: row.category,
        cachedAt: row.cachedAt,
      );
    } catch (e) {
      throw Exception('Failed to get movie by id: $e');
    }
  }

  // Favorites
  Future<void> addToFavorites(FavoritesCompanion favorite) async {
    try {
      await into(favorites).insert(favorite, mode: InsertMode.replace);
    } catch (e) {
      throw Exception('Failed to add to favorites: $e');
    }
  }

  Future<bool> removeFromFavorites(int movieId) async {
    try {
      final deleted = await (delete(favorites)..where((t) => t.id.equals(movieId))).go();
      return deleted > 0;
    } catch (e) {
      throw Exception('Failed to remove from favorites: $e');
    }
  }

  Future<bool> isFavorite(int movieId) async {
    try {
      final favorite = await (select(favorites)..where((t) => t.id.equals(movieId))).getSingleOrNull();
      return favorite != null;
    } catch (e) {
      throw Exception('Failed to check if favorite: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getFavoriteMovies() async {
    try {
      final query = select(favorites)
        ..orderBy([(t) => OrderingTerm.desc(t.dateAdded)]);
      
      final results = await query.get();
      return results.map((row) => row.toJson()).toList();
    } catch (e) {
      throw Exception('Failed to get favorite movies: $e');
    }
  }

  Future<List<MovieRow>> searchMoviesByTitle(String queryStr) async {
    final q = select(movies)
      ..where((t) => t.title.like('%${queryStr.replaceAll('%', r'\%')}%'));
    final rows = await q.get();
    return rows
        .map((r) => MovieRow(
              id: r.id,
              title: r.title,
              overview: r.overview,
              posterPath: r.posterPath,
              backdropPath: r.backdropPath,
              voteAverage: r.voteAverage,
              releaseDate: r.releaseDate,
              genreIdsJson: r.genreIdsJson,
              category: r.category,
              cachedAt: r.cachedAt,
            ))
        .toList();
  }

  // Favorites API
  Future<void> upsertFavorite(FavoritesCompanion entry) async {
    await into(favorites).insertOnConflictUpdate(entry);
  }

  Future<int> removeFavorite(int id) async {
    return (delete(favorites)..where((t) => t.id.equals(id))).go();
  }

  Future<bool> isFavoriteId(int id) async {
    final q = select(favorites)..where((t) => t.id.equals(id));
    return (await q.getSingleOrNull()) != null;
  }

  Future<List<FavoriteRow>> getAllFavorites() async {
    final rows = await (select(favorites)
          ..orderBy([(t) => OrderingTerm(expression: t.dateAdded, mode: OrderingMode.desc)]))
        .get();
    return rows
        .map((r) => FavoriteRow(
              id: r.id,
              title: r.title,
              overview: r.overview,
              posterPath: r.posterPath,
              backdropPath: r.backdropPath,
              voteAverage: r.voteAverage,
              releaseDate: r.releaseDate,
              genreIdsJson: r.genreIdsJson,
              dateAdded: r.dateAdded,
            ))
        .toList(growable: false);
  }
}

// Simple POJO row to keep mapping logic outside of generated classes
class FavoriteRow {
  final int id;
  final String title;
  final String overview;
  final String? posterPath;
  final String? backdropPath;
  final double voteAverage;
  final String releaseDate;
  final String genreIdsJson;
  final DateTime dateAdded;

  FavoriteRow({
    required this.id,
    required this.title,
    required this.overview,
    this.posterPath,
    this.backdropPath,
    required this.voteAverage,
    required this.releaseDate,
    required this.genreIdsJson,
    required this.dateAdded,
  });
}

class MovieRow {
  final int id;
  final String title;
  final String overview;
  final String? posterPath;
  final String? backdropPath;
  final double voteAverage;
  final String releaseDate;
  final String genreIdsJson;
  final String category;
  final DateTime cachedAt;

  MovieRow({
    required this.id,
    required this.title,
    required this.overview,
    required this.posterPath,
    required this.backdropPath,
    required this.voteAverage,
    required this.releaseDate,
    required this.genreIdsJson,
    required this.category,
    required this.cachedAt,
  });
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'app.db'));
    return NativeDatabase.createInBackground(file);
  });
}
