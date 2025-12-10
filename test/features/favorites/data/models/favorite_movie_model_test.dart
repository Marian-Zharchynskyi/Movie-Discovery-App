import 'package:flutter_test/flutter_test.dart';
import 'package:movie_discovery_app/features/favorites/data/models/favorite_movie_model.dart';
import 'package:movie_discovery_app/features/movies/domain/entities/movie_entity.dart';

void main() {
  group('FavoriteMovieModel', () {
    final tDateTime = DateTime(2024, 1, 15, 10, 30);
    final tFavoriteMovieModel = FavoriteMovieModel(
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

    group('fromMovieEntity', () {
      test('should create FavoriteMovieModel from MovieEntity', () {
        // arrange
        const movieEntity = MovieEntity(
          id: 1,
          title: 'Test Movie',
          overview: 'Test overview',
          posterPath: '/test.jpg',
          backdropPath: '/backdrop.jpg',
          voteAverage: 8.5,
          releaseDate: '2024-01-15',
          genreIds: [28, 12],
        );

        // act
        final result = FavoriteMovieModel.fromMovieEntity(movieEntity, tDateTime);

        // assert
        expect(result.id, movieEntity.id);
        expect(result.title, movieEntity.title);
        expect(result.overview, movieEntity.overview);
        expect(result.posterPath, movieEntity.posterPath);
        expect(result.backdropPath, movieEntity.backdropPath);
        expect(result.voteAverage, movieEntity.voteAverage);
        expect(result.releaseDate, movieEntity.releaseDate);
        expect(result.genreIds, movieEntity.genreIds);
        expect(result.dateAdded, tDateTime);
      });

      test('should handle null paths from MovieEntity', () {
        // arrange
        const movieEntity = MovieEntity(
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
        final result = FavoriteMovieModel.fromMovieEntity(movieEntity, tDateTime);

        // assert
        expect(result.posterPath, null);
        expect(result.backdropPath, null);
      });
    });

    group('fromJson', () {
      test('should return a valid FavoriteMovieModel from JSON', () {
        // arrange
        final json = {
          'id': 1,
          'title': 'Test Movie',
          'overview': 'Test overview',
          'poster_path': '/test.jpg',
          'backdrop_path': '/backdrop.jpg',
          'vote_average': 8.5,
          'release_date': '2024-01-15',
          'genre_ids': [28, 12],
          'date_added': tDateTime.toIso8601String(),
        };

        // act
        final result = FavoriteMovieModel.fromJson(json);

        // assert
        expect(result.id, 1);
        expect(result.title, 'Test Movie');
        expect(result.overview, 'Test overview');
        expect(result.posterPath, '/test.jpg');
        expect(result.backdropPath, '/backdrop.jpg');
        expect(result.voteAverage, 8.5);
        expect(result.releaseDate, '2024-01-15');
        expect(result.genreIds, [28, 12]);
        expect(result.dateAdded, tDateTime);
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
          'date_added': tDateTime.toIso8601String(),
        };

        // act
        final result = FavoriteMovieModel.fromJson(json);

        // assert
        expect(result.posterPath, null);
        expect(result.backdropPath, null);
      });

      test('should parse date correctly', () {
        // arrange
        final json = {
          'id': 1,
          'title': 'Test Movie',
          'overview': 'Test overview',
          'poster_path': '/test.jpg',
          'backdrop_path': '/backdrop.jpg',
          'vote_average': 8.0,
          'release_date': '2024-01-01',
          'genre_ids': [28],
          'date_added': '2024-03-15T14:30:00.000Z',
        };

        // act
        final result = FavoriteMovieModel.fromJson(json);

        // assert
        expect(result.dateAdded.year, 2024);
        expect(result.dateAdded.month, 3);
        expect(result.dateAdded.day, 15);
      });
    });

    group('toJson', () {
      test('should return a JSON map containing proper data', () {
        // act
        final result = tFavoriteMovieModel.toJson();

        // assert
        expect(result['id'], 1);
        expect(result['title'], 'Test Movie');
        expect(result['overview'], 'Test overview');
        expect(result['poster_path'], '/test.jpg');
        expect(result['backdrop_path'], '/backdrop.jpg');
        expect(result['vote_average'], 8.5);
        expect(result['release_date'], '2024-01-15');
        expect(result['genre_ids'], [28, 12]);
        expect(result['date_added'], tDateTime.toIso8601String());
      });

      test('should handle null paths in toJson', () {
        // arrange
        final favoriteMovieModel = FavoriteMovieModel(
          id: 1,
          title: 'Test Movie',
          overview: 'Test overview',
          posterPath: null,
          backdropPath: null,
          voteAverage: 7.0,
          releaseDate: '2024-01-01',
          genreIds: const [18],
          dateAdded: tDateTime,
        );

        // act
        final result = favoriteMovieModel.toJson();

        // assert
        expect(result['poster_path'], null);
        expect(result['backdrop_path'], null);
      });
    });

    group('fromJson and toJson', () {
      test('should maintain data integrity through serialization cycle', () {
        // arrange
        final json = tFavoriteMovieModel.toJson();

        // act
        final result = FavoriteMovieModel.fromJson(json);

        // assert
        expect(result.id, tFavoriteMovieModel.id);
        expect(result.title, tFavoriteMovieModel.title);
        expect(result.overview, tFavoriteMovieModel.overview);
        expect(result.posterPath, tFavoriteMovieModel.posterPath);
        expect(result.backdropPath, tFavoriteMovieModel.backdropPath);
        expect(result.voteAverage, tFavoriteMovieModel.voteAverage);
        expect(result.releaseDate, tFavoriteMovieModel.releaseDate);
        expect(result.genreIds, tFavoriteMovieModel.genreIds);
        expect(result.dateAdded, tFavoriteMovieModel.dateAdded);
      });
    });
  });
}
