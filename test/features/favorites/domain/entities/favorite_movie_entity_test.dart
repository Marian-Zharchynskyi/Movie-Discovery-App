import 'package:flutter_test/flutter_test.dart';
import 'package:movie_discovery_app/features/favorites/domain/entities/favorite_movie_entity.dart';

void main() {
  group('FavoriteMovieEntity', () {
    final tDateTime = DateTime(2024, 1, 15, 10, 30);

    test('should create FavoriteMovieEntity with all fields', () {
      // arrange & act
      final favoriteMovie = FavoriteMovieEntity(
        id: 1,
        title: 'Test Movie',
        overview: 'Test overview',
        posterPath: '/test.jpg',
        backdropPath: '/backdrop.jpg',
        voteAverage: 8.5,
        releaseDate: '2024-01-15',
        genreIds: const [28, 12],
        dateAdded: tDateTime,
      );

      // assert
      expect(favoriteMovie.id, 1);
      expect(favoriteMovie.title, 'Test Movie');
      expect(favoriteMovie.overview, 'Test overview');
      expect(favoriteMovie.posterPath, '/test.jpg');
      expect(favoriteMovie.backdropPath, '/backdrop.jpg');
      expect(favoriteMovie.voteAverage, 8.5);
      expect(favoriteMovie.releaseDate, '2024-01-15');
      expect(favoriteMovie.genreIds, [28, 12]);
      expect(favoriteMovie.dateAdded, tDateTime);
    });

    test('should create FavoriteMovieEntity without poster and backdrop', () {
      // arrange & act
      final favoriteMovie = FavoriteMovieEntity(
        id: 1,
        title: 'Test Movie',
        overview: 'Test overview',
        voteAverage: 7.0,
        releaseDate: '2024-01-01',
        genreIds: const [18],
        dateAdded: tDateTime,
      );

      // assert
      expect(favoriteMovie.posterPath, null);
      expect(favoriteMovie.backdropPath, null);
    });

    test('should extend MovieEntity', () {
      // arrange & act
      final favoriteMovie = FavoriteMovieEntity(
        id: 1,
        title: 'Test Movie',
        overview: 'Test overview',
        voteAverage: 8.0,
        releaseDate: '2024-01-01',
        genreIds: const [28],
        dateAdded: tDateTime,
      );

      // assert - should have MovieEntity properties
      expect(favoriteMovie.id, 1);
      expect(favoriteMovie.title, 'Test Movie');
      expect(favoriteMovie.overview, 'Test overview');
      expect(favoriteMovie.voteAverage, 8.0);
    });

    test('should store dateAdded correctly', () {
      // arrange
      final now = DateTime.now();
      final favoriteMovie = FavoriteMovieEntity(
        id: 1,
        title: 'Test Movie',
        overview: 'Test overview',
        voteAverage: 8.0,
        releaseDate: '2024-01-01',
        genreIds: const [28],
        dateAdded: now,
      );

      // assert
      expect(favoriteMovie.dateAdded, now);
      expect(favoriteMovie.dateAdded.year, now.year);
      expect(favoriteMovie.dateAdded.month, now.month);
      expect(favoriteMovie.dateAdded.day, now.day);
    });

    test('should handle empty genre list', () {
      // arrange & act
      final favoriteMovie = FavoriteMovieEntity(
        id: 1,
        title: 'Test Movie',
        overview: 'Test overview',
        voteAverage: 7.5,
        releaseDate: '2024-01-01',
        genreIds: const [],
        dateAdded: tDateTime,
      );

      // assert
      expect(favoriteMovie.genreIds, isEmpty);
    });
  });
}
