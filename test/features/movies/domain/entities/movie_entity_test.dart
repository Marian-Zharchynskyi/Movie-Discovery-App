import 'package:flutter_test/flutter_test.dart';
import 'package:movie_discovery_app/features/movies/domain/entities/movie_entity.dart';

void main() {
  group('MovieEntity', () {
    const tMovie = MovieEntity(
      id: 1,
      title: 'Test Movie',
      overview: 'Test overview',
      posterPath: '/test.jpg',
      backdropPath: '/backdrop.jpg',
      voteAverage: 8.5,
      releaseDate: '2024-01-15',
      genreIds: [28, 12],
    );

    test('should have correct properties', () {
      expect(tMovie.id, 1);
      expect(tMovie.title, 'Test Movie');
      expect(tMovie.overview, 'Test overview');
      expect(tMovie.posterPath, '/test.jpg');
      expect(tMovie.backdropPath, '/backdrop.jpg');
      expect(tMovie.voteAverage, 8.5);
      expect(tMovie.releaseDate, '2024-01-15');
      expect(tMovie.genreIds, [28, 12]);
    });

    test('fullPosterPath should return correct URL', () {
      expect(
        tMovie.fullPosterPath,
        'https://image.tmdb.org/t/p/w500/test.jpg',
      );
    });

    test('fullBackdropPath should return correct URL', () {
      expect(
        tMovie.fullBackdropPath,
        'https://image.tmdb.org/t/p/w1280/backdrop.jpg',
      );
    });

    test('fullPosterPath should return empty string when posterPath is null', () {
      const movieNoPoster = MovieEntity(
        id: 1,
        title: 'Test Movie',
        overview: 'Test overview',
        posterPath: null,
        voteAverage: 8.5,
        releaseDate: '2024-01-15',
        genreIds: [28, 12],
      );

      expect(movieNoPoster.fullPosterPath, '');
    });

    test('fullBackdropPath should return empty string when backdropPath is null', () {
      const movieNoBackdrop = MovieEntity(
        id: 1,
        title: 'Test Movie',
        overview: 'Test overview',
        posterPath: '/test.jpg',
        backdropPath: null,
        voteAverage: 8.5,
        releaseDate: '2024-01-15',
        genreIds: [28, 12],
      );

      expect(movieNoBackdrop.fullBackdropPath, '');
    });
  });
}
