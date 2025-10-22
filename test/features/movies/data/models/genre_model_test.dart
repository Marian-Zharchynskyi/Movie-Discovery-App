import 'package:flutter_test/flutter_test.dart';
import 'package:movie_discovery_app/features/movies/data/models/genre_model.dart';

void main() {
  group('GenreModel', () {
    group('getGenreName', () {
      test('should return correct genre name for valid id', () {
        expect(GenreModel.getGenreName(28), 'Action');
        expect(GenreModel.getGenreName(12), 'Adventure');
        expect(GenreModel.getGenreName(16), 'Animation');
        expect(GenreModel.getGenreName(35), 'Comedy');
        expect(GenreModel.getGenreName(80), 'Crime');
        expect(GenreModel.getGenreName(18), 'Drama');
      });

      test('should return Unknown for invalid genre id', () {
        expect(GenreModel.getGenreName(999), 'Unknown');
        expect(GenreModel.getGenreName(0), 'Unknown');
        expect(GenreModel.getGenreName(-1), 'Unknown');
      });

      test('should return correct names for all defined genres', () {
        expect(GenreModel.getGenreName(10751), 'Family');
        expect(GenreModel.getGenreName(14), 'Fantasy');
        expect(GenreModel.getGenreName(36), 'History');
        expect(GenreModel.getGenreName(27), 'Horror');
        expect(GenreModel.getGenreName(10402), 'Music');
        expect(GenreModel.getGenreName(9648), 'Mystery');
        expect(GenreModel.getGenreName(10749), 'Romance');
        expect(GenreModel.getGenreName(878), 'Science Fiction');
        expect(GenreModel.getGenreName(10770), 'TV Movie');
        expect(GenreModel.getGenreName(53), 'Thriller');
        expect(GenreModel.getGenreName(10752), 'War');
        expect(GenreModel.getGenreName(37), 'Western');
      });
    });

    group('getGenreNames', () {
      test('should return list of genre names for valid ids', () {
        final result = GenreModel.getGenreNames([28, 12, 16]);
        expect(result, ['Action', 'Adventure', 'Animation']);
      });

      test('should return Unknown for invalid ids in list', () {
        final result = GenreModel.getGenreNames([28, 999, 12]);
        expect(result, ['Action', 'Unknown', 'Adventure']);
      });

      test('should return empty list for empty input', () {
        final result = GenreModel.getGenreNames([]);
        expect(result, isEmpty);
      });

      test('should handle list with only invalid ids', () {
        final result = GenreModel.getGenreNames([999, 0, -1]);
        expect(result, ['Unknown', 'Unknown', 'Unknown']);
      });

      test('should handle mixed valid and invalid ids', () {
        final result = GenreModel.getGenreNames([28, 999, 18, 0, 35]);
        expect(result, ['Action', 'Unknown', 'Drama', 'Unknown', 'Comedy']);
      });
    });

    group('genres map', () {
      test('should contain all expected genre entries', () {
        expect(GenreModel.genres.length, 18);
        expect(GenreModel.genres.containsKey(28), true);
        expect(GenreModel.genres.containsKey(12), true);
        expect(GenreModel.genres.containsKey(16), true);
      });

      test('should have correct values for keys', () {
        expect(GenreModel.genres[28], 'Action');
        expect(GenreModel.genres[18], 'Drama');
        expect(GenreModel.genres[878], 'Science Fiction');
      });
    });
  });
}
