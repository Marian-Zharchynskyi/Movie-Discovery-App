import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:movie_discovery_app/core/database/app_database.dart';
import 'package:movie_discovery_app/core/error/exceptions.dart';
import 'package:movie_discovery_app/features/favorites/data/datasources/local/favorites_local_data_source.dart';
import 'package:movie_discovery_app/features/favorites/data/models/favorite_movie_model.dart';

class MockAppDatabase extends Mock implements AppDatabase {}

class FakeFavoritesCompanion extends Fake implements FavoritesCompanion {}

void main() {
  late FavoritesLocalDataSourceImpl dataSource;
  late MockAppDatabase mockDatabase;

  setUpAll(() {
    registerFallbackValue(FakeFavoritesCompanion());
  });

  setUp(() {
    mockDatabase = MockAppDatabase();
    dataSource = FavoritesLocalDataSourceImpl(db: mockDatabase);
  });

  final tFavoriteMovie = FavoriteMovieModel(
    id: 1,
    title: 'Test Movie',
    overview: 'Test overview',
    posterPath: '/test.jpg',
    voteAverage: 8.0,
    releaseDate: '2024-01-01',
    genreIds: const [28, 12],
    dateAdded: DateTime(2024, 1, 1),
  );

  final tFavoriteRow = FavoriteRow(
    id: 1,
    title: 'Test Movie',
    overview: 'Test overview',
    posterPath: '/test.jpg',
    backdropPath: null,
    voteAverage: 8.0,
    releaseDate: '2024-01-01',
    genreIdsJson: '[28,12]',
    dateAdded: DateTime(2024, 1, 1),
  );

  group('addToFavorites', () {
    test('should add movie to favorites successfully', () async {
      // arrange
      when(() => mockDatabase.upsertFavorite(any()))
          .thenAnswer((_) async => 1);

      // act
      final result = await dataSource.addToFavorites(tFavoriteMovie);

      // assert
      expect(result, true);
      verify(() => mockDatabase.upsertFavorite(any())).called(1);
    });

    test('should throw CacheException when adding fails', () async {
      // arrange
      when(() => mockDatabase.upsertFavorite(any()))
          .thenThrow(Exception('Insert error'));

      // act & assert
      expect(
        () => dataSource.addToFavorites(tFavoriteMovie),
        throwsA(isA<CacheException>()),
      );
    });
  });

  group('removeFromFavorites', () {
    const tMovieId = 1;

    test('should remove movie from favorites successfully', () async {
      // arrange
      when(() => mockDatabase.removeFavorite(any()))
          .thenAnswer((_) async => 1);

      // act
      final result = await dataSource.removeFromFavorites(tMovieId);

      // assert
      expect(result, true);
      verify(() => mockDatabase.removeFavorite(tMovieId)).called(1);
    });

    test('should return false when movie not found', () async {
      // arrange
      when(() => mockDatabase.removeFavorite(any()))
          .thenAnswer((_) async => 0);

      // act
      final result = await dataSource.removeFromFavorites(tMovieId);

      // assert
      expect(result, false);
    });

    test('should throw CacheException when removal fails', () async {
      // arrange
      when(() => mockDatabase.removeFavorite(any()))
          .thenThrow(Exception('Delete error'));

      // act & assert
      expect(
        () => dataSource.removeFromFavorites(tMovieId),
        throwsA(isA<CacheException>()),
      );
    });
  });

  group('getFavoriteMovies', () {
    test('should return list of favorite movies', () async {
      // arrange
      when(() => mockDatabase.getAllFavorites())
          .thenAnswer((_) async => [tFavoriteRow]);

      // act
      final result = await dataSource.getFavoriteMovies();

      // assert
      expect(result, isA<List<FavoriteMovieModel>>());
      expect(result.length, 1);
      expect(result[0].title, 'Test Movie');
      verify(() => mockDatabase.getAllFavorites()).called(1);
    });

    test('should return empty list when no favorites', () async {
      // arrange
      when(() => mockDatabase.getAllFavorites())
          .thenAnswer((_) async => []);

      // act
      final result = await dataSource.getFavoriteMovies();

      // assert
      expect(result, isEmpty);
    });

    test('should throw CacheException when retrieval fails', () async {
      // arrange
      when(() => mockDatabase.getAllFavorites())
          .thenThrow(Exception('Query error'));

      // act & assert
      expect(
        () => dataSource.getFavoriteMovies(),
        throwsA(isA<CacheException>()),
      );
    });
  });

  group('isFavorite', () {
    const tMovieId = 1;

    test('should return true when movie is favorite', () async {
      // arrange
      when(() => mockDatabase.isFavoriteId(any()))
          .thenAnswer((_) async => true);

      // act
      final result = await dataSource.isFavorite(tMovieId);

      // assert
      expect(result, true);
      verify(() => mockDatabase.isFavoriteId(tMovieId)).called(1);
    });

    test('should return false when movie is not favorite', () async {
      // arrange
      when(() => mockDatabase.isFavoriteId(any()))
          .thenAnswer((_) async => false);

      // act
      final result = await dataSource.isFavorite(tMovieId);

      // assert
      expect(result, false);
    });

    test('should throw CacheException when check fails', () async {
      // arrange
      when(() => mockDatabase.isFavoriteId(any()))
          .thenThrow(Exception('Query error'));

      // act & assert
      expect(
        () => dataSource.isFavorite(tMovieId),
        throwsA(isA<CacheException>()),
      );
    });
  });
}
