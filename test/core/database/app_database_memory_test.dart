import 'package:drift/drift.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movie_discovery_app/core/database/app_database.dart';

void main() {
  group('AppDatabase (in-memory)', () {
    late AppDatabase db;

    setUp(() {
      db = AppDatabase.memory();
    });

    tearDown(() async {
      await db.close();
    });

    test('upsertMovies and getMoviesByCategory', () async {
      await db.upsertMovies([
        MoviesCompanion(
          id: const Value(1),
          title: const Value('Movie 1'),
          overview: const Value('O'),
          voteAverage: const Value(7.5),
          category: const Value('popular'),
          genreIdsJson: const Value('[]'),
          posterPath: const Value(null),
          backdropPath: const Value(null),
          releaseDate: const Value('2024-01-01'),
        ),
      ]);

      final list = await db.getMoviesByCategory('popular');
      expect(list.length, 1);
      expect(list.first.title, 'Movie 1');
    });

    test('favorites CRUD', () async {
      await db.addToFavorites(FavoritesCompanion(
        id: const Value(42),
        title: const Value('Fav'),
        overview: const Value('O'),
        voteAverage: const Value(9.0),
        genreIdsJson: const Value('[]'),
        posterPath: const Value(null),
        backdropPath: const Value(null),
        releaseDate: const Value('2024-01-01'),
      ));

      expect(await db.isFavorite(42), isTrue);
      final list = await db.getAllFavorites();
      expect(list.map((e) => e.id), contains(42));

      final removed = await db.removeFromFavorites(42);
      expect(removed, isTrue);
      expect(await db.isFavorite(42), isFalse);
    });
  });
}
