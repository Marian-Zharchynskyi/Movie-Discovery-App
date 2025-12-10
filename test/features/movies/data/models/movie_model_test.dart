import 'package:flutter_test/flutter_test.dart';
import 'package:movie_discovery_app/features/movies/data/models/movie_model.dart';

void main() {
  group('MovieModel', () {
    const tMovieModel = MovieModel(
      id: 1,
      title: 'Test Movie',
      overview: 'Test overview',
      posterPath: '/test.jpg',
      backdropPath: '/backdrop.jpg',
      voteAverage: 8.5,
      releaseDate: '2024-01-15',
      genreIds: [28, 12, 16],
    );

    group('fromJson', () {
      test('should return a valid MovieModel from JSON', () {
        // arrange
        final json = {
          'id': 1,
          'title': 'Test Movie',
          'overview': 'Test overview',
          'poster_path': '/test.jpg',
          'backdrop_path': '/backdrop.jpg',
          'vote_average': 8.5,
          'release_date': '2024-01-15',
          'genre_ids': [28, 12, 16],
        };

        // act
        final result = MovieModel.fromJson(json);

        // assert
        expect(result.id, 1);
        expect(result.title, 'Test Movie');
        expect(result.overview, 'Test overview');
        expect(result.posterPath, '/test.jpg');
        expect(result.backdropPath, '/backdrop.jpg');
        expect(result.voteAverage, 8.5);
        expect(result.releaseDate, '2024-01-15');
        expect(result.genreIds, [28, 12, 16]);
      });

      test('should handle null poster and backdrop paths', () {
        // arrange
        final json = {
          'id': 1,
          'title': 'Test Movie',
          'overview': 'Test overview',
          'poster_path': null,
          'backdrop_path': null,
          'vote_average': 7.0,
          'release_date': '2024-01-01',
          'genre_ids': [18],
        };

        // act
        final result = MovieModel.fromJson(json);

        // assert
        expect(result.posterPath, null);
        expect(result.backdropPath, null);
      });

      test('should handle missing release date', () {
        // arrange
        final json = {
          'id': 1,
          'title': 'Test Movie',
          'overview': 'Test overview',
          'poster_path': '/test.jpg',
          'backdrop_path': '/backdrop.jpg',
          'vote_average': 8.0,
          'genre_ids': [28],
        };

        // act
        final result = MovieModel.fromJson(json);

        // assert
        expect(result.releaseDate, '');
      });

      test('should handle integer vote average', () {
        // arrange
        final json = {
          'id': 1,
          'title': 'Test Movie',
          'overview': 'Test overview',
          'poster_path': '/test.jpg',
          'backdrop_path': '/backdrop.jpg',
          'vote_average': 8,
          'release_date': '2024-01-01',
          'genre_ids': [28],
        };

        // act
        final result = MovieModel.fromJson(json);

        // assert
        expect(result.voteAverage, 8.0);
      });

      test('should handle empty genre list', () {
        // arrange
        final json = {
          'id': 1,
          'title': 'Test Movie',
          'overview': 'Test overview',
          'poster_path': '/test.jpg',
          'backdrop_path': '/backdrop.jpg',
          'vote_average': 7.5,
          'release_date': '2024-01-01',
          'genre_ids': [],
        };

        // act
        final result = MovieModel.fromJson(json);

        // assert
        expect(result.genreIds, isEmpty);
      });
    });

    group('toJson', () {
      test('should return a JSON map containing proper data', () {
        // act
        final result = tMovieModel.toJson();

        // assert
        final expectedMap = {
          'id': 1,
          'title': 'Test Movie',
          'overview': 'Test overview',
          'poster_path': '/test.jpg',
          'backdrop_path': '/backdrop.jpg',
          'vote_average': 8.5,
          'release_date': '2024-01-15',
          'genre_ids': [28, 12, 16],
        };
        expect(result, expectedMap);
      });

      test('should handle null paths in toJson', () {
        // arrange
        const movieModel = MovieModel(
          id: 1,
          title: 'Test Movie',
          overview: 'Test overview',
          posterPath: null,
          backdropPath: null,
          voteAverage: 7.0,
          releaseDate: '2024-01-01',
          genreIds: [18],
        );

        // act
        final result = movieModel.toJson();

        // assert
        expect(result['poster_path'], null);
        expect(result['backdrop_path'], null);
      });
    });

    group('fromJson and toJson', () {
      test('should maintain data integrity through serialization cycle', () {
        // arrange
        final json = tMovieModel.toJson();

        // act
        final result = MovieModel.fromJson(json);

        // assert
        expect(result.id, tMovieModel.id);
        expect(result.title, tMovieModel.title);
        expect(result.overview, tMovieModel.overview);
        expect(result.posterPath, tMovieModel.posterPath);
        expect(result.backdropPath, tMovieModel.backdropPath);
        expect(result.voteAverage, tMovieModel.voteAverage);
        expect(result.releaseDate, tMovieModel.releaseDate);
        expect(result.genreIds, tMovieModel.genreIds);
      });
    });
  });
}
