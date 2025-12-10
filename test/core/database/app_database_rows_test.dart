import 'package:flutter_test/flutter_test.dart';
import 'package:movie_discovery_app/core/database/app_database.dart';

void main() {
  group('AppDatabase POJO rows', () {
    test('FavoriteRow holds values', () {
      final row = FavoriteRow(
        id: 1,
        title: 'Title',
        overview: 'Overview',
        posterPath: 'p.jpg',
        backdropPath: 'b.jpg',
        voteAverage: 8.5,
        releaseDate: '2024-01-01',
        genreIdsJson: '[28,12]',
        dateAdded: DateTime(2024, 1, 1),
      );

      expect(row.id, 1);
      expect(row.title, 'Title');
      expect(row.voteAverage, 8.5);
    });

    test('MovieRow holds values', () {
      final row = MovieRow(
        id: 2,
        title: 'M',
        overview: 'O',
        posterPath: null,
        backdropPath: null,
        voteAverage: 7.0,
        releaseDate: '2023-01-01',
        genreIdsJson: '[]',
        category: 'popular',
        cachedAt: DateTime(2023, 1, 1),
      );

      expect(row.category, 'popular');
      expect(row.cachedAt.year, 2023);
    });
  });
}
