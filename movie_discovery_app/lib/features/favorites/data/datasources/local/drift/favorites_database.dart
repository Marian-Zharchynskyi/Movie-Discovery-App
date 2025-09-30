import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:movie_discovery_app/features/favorites/data/models/favorite_movie_model.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'favorites_database.g.dart';

class IntListConverter extends TypeConverter<List<int>, String> {
  const IntListConverter();

  @override
  List<int> fromSql(String fromDb) {
    if (fromDb.isEmpty) {
      return const [];
    }

    final decoded = jsonDecode(fromDb) as List<dynamic>;
    return decoded.map((value) => value as int).toList();
  }

  @override
  String toSql(List<int> value) {
    if (value.isEmpty) {
      return '[]';
    }

    return jsonEncode(value);
  }
}

class FavoriteMovies extends Table {
  IntColumn get id => integer()();

  TextColumn get title => text()();

  TextColumn get overview => text()();

  TextColumn get posterPath => text().nullable()();

  TextColumn get backdropPath => text().nullable()();

  RealColumn get voteAverage => real()();

  TextColumn get releaseDate => text()();

  TextColumn get genreIds => text().map(const IntListConverter())();

  DateTimeColumn get dateAdded => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(tables: [FavoriteMovies])
class FavoritesDatabase extends _$FavoritesDatabase {
  FavoritesDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  static LazyDatabase _openConnection() {
    return LazyDatabase(() async {
      final directory = await getApplicationDocumentsDirectory();
      final file = File(p.join(directory.path, 'favorites.db'));
      return NativeDatabase.createInBackground(file);
    });
  }

  Future<List<FavoriteMovieModel>> fetchFavoriteMovies() async {
    final query = select(favoriteMovies)
      ..orderBy([(tbl) => OrderingTerm.desc(tbl.dateAdded)]);
    final rows = await query.get();
    return rows.map((row) => _mapToModel(row)).toList();
  }

  Future<bool> insertFavoriteMovie(FavoriteMovieModel movie) async {
    final existing = await (select(favoriteMovies)
          ..where((tbl) => tbl.id.equals(movie.id)))
        .getSingleOrNull();

    if (existing != null) {
      return false;
    }

    await into(favoriteMovies).insert(
      FavoriteMoviesCompanion.insert(
        id: Value(movie.id),
        title: movie.title,
        overview: movie.overview,
        posterPath: Value(movie.posterPath),
        backdropPath: Value(movie.backdropPath),
        voteAverage: movie.voteAverage,
        releaseDate: movie.releaseDate,
        genreIds: movie.genreIds,
        dateAdded: movie.dateAdded,
      ),
    );

    return true;
  }

  Future<bool> deleteFavoriteMovie(int movieId) async {
    final affectedRows = await (delete(favoriteMovies)
          ..where((tbl) => tbl.id.equals(movieId)))
        .go();
    return affectedRows > 0;
  }

  Future<bool> isFavoriteMovie(int movieId) async {
    final result = await (select(favoriteMovies)
          ..where((tbl) => tbl.id.equals(movieId)))
        .getSingleOrNull();
    return result != null;
  }

  FavoriteMovieModel _mapToModel(FavoriteMovie data) {
    return FavoriteMovieModel(
      id: data.id,
      title: data.title,
      overview: data.overview,
      posterPath: data.posterPath,
      backdropPath: data.backdropPath,
      voteAverage: data.voteAverage,
      releaseDate: data.releaseDate,
      genreIds: data.genreIds,
      dateAdded: data.dateAdded,
    );
  }
}
