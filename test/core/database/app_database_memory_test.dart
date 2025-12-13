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
      const testUserId = 'test-user-123';
      await db.addToFavorites(FavoritesCompanion(
        id: const Value(42),
        userId: const Value(testUserId),
        title: const Value('Fav'),
        overview: const Value('O'),
        voteAverage: const Value(9.0),
        genreIdsJson: const Value('[]'),
        posterPath: const Value(null),
        backdropPath: const Value(null),
        releaseDate: const Value('2024-01-01'),
      ));

      expect(await db.isFavorite(42, testUserId), isTrue);
      final list = await db.getAllFavorites(testUserId);
      expect(list.map((e) => e.id), contains(42));

      final removed = await db.removeFromFavorites(42, testUserId);
      expect(removed, isTrue);
      expect(await db.isFavorite(42, testUserId), isFalse);
    });

    test('favorites are isolated per user', () async {
      const user1 = 'user-1';
      const user2 = 'user-2';
      
      await db.addToFavorites(FavoritesCompanion(
        id: const Value(100),
        userId: const Value(user1),
        title: const Value('User1 Fav'),
        overview: const Value('O'),
        voteAverage: const Value(8.0),
        genreIdsJson: const Value('[]'),
        posterPath: const Value(null),
        backdropPath: const Value(null),
        releaseDate: const Value('2024-01-01'),
      ));

      expect(await db.isFavorite(100, user1), isTrue);
      expect(await db.isFavorite(100, user2), isFalse);
      
      final user1Favorites = await db.getAllFavorites(user1);
      final user2Favorites = await db.getAllFavorites(user2);
      
      expect(user1Favorites.length, 1);
      expect(user2Favorites.length, 0);
    });
  });
}
