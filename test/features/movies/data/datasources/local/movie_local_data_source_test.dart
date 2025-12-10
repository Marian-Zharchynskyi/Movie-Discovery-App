import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:movie_discovery_app/core/database/app_database.dart';
import 'package:movie_discovery_app/core/error/exceptions.dart';
import 'package:movie_discovery_app/features/movies/data/datasources/local/movie_local_data_source.dart';
import 'package:movie_discovery_app/features/movies/data/models/movie_model.dart';

class MockAppDatabase extends Mock implements AppDatabase {}

class FakeMoviesCompanion extends Fake implements MoviesCompanion {}

void main() {
  late MovieLocalDataSourceImpl dataSource;
  late MockAppDatabase mockDatabase;

  setUpAll(() {
    registerFallbackValue(FakeMoviesCompanion());
  });

  setUp(() {
    mockDatabase = MockAppDatabase();
    dataSource = MovieLocalDataSourceImpl(db: mockDatabase);
  });

  const tMovieModel = MovieModel(
    id: 1,
    title: 'Test Movie',
    overview: 'Test overview',
    posterPath: '/test.jpg',
    backdropPath: '/backdrop.jpg',
    voteAverage: 8.0,
    releaseDate: '2024-01-01',
    genreIds: [28, 12],
  );

  final tMovieRow = MovieRow(
    id: 1,
    title: 'Test Movie',
    overview: 'Test overview',
    posterPath: '/test.jpg',
    backdropPath: '/backdrop.jpg',
    voteAverage: 8.0,
    releaseDate: '2024-01-01',
    genreIdsJson: jsonEncode([28, 12]),
    category: 'popular',
    cachedAt: DateTime.now(),
  );

  group('cachePopularMovies', () {
    test('should cache popular movies successfully', () async {
      // arrange
      when(() => mockDatabase.upsertMovies(any()))
          .thenAnswer((_) async => Future.value());

      // act
      await dataSource.cachePopularMovies([tMovieModel]);

      // assert
      verify(() => mockDatabase.upsertMovies(any())).called(1);
    });

    test('should throw CacheException when caching fails', () async {
      // arrange
      when(() => mockDatabase.upsertMovies(any()))
          .thenThrow(Exception('Database error'));

      // act & assert
      expect(
        () => dataSource.cachePopularMovies([tMovieModel]),
        throwsA(isA<CacheException>()),
      );
    });
  });

  group('cacheTopRatedMovies', () {
    test('should cache top rated movies successfully', () async {
      // arrange
      when(() => mockDatabase.upsertMovies(any()))
          .thenAnswer((_) async => Future.value());

      // act
      await dataSource.cacheTopRatedMovies([tMovieModel]);

      // assert
      verify(() => mockDatabase.upsertMovies(any())).called(1);
    });
  });

  group('cacheMovieDetails', () {
    test('should throw CacheException when caching details fails', () async {
      // arrange
      when(() => mockDatabase.upsertMovies(any()))
          .thenThrow(Exception('Insert error'));

      // act & assert
      expect(
        () => dataSource.cacheMovieDetails(tMovieModel),
        throwsA(isA<CacheException>()),
      );
    });
  });

  group('getCachedPopularMovies', () {
    test('should return cached popular movies', () async {
      // arrange
      when(() => mockDatabase.getMoviesByCategory(any()))
          .thenAnswer((_) async => [tMovieRow]);

      // act
      final result = await dataSource.getCachedPopularMovies();

      // assert
      expect(result, isA<List<MovieModel>>());
      expect(result.length, 1);
      expect(result[0].title, 'Test Movie');
      verify(() => mockDatabase.getMoviesByCategory('popular')).called(1);
    });

    test('should return empty list when no cached movies', () async {
      // arrange
      when(() => mockDatabase.getMoviesByCategory(any()))
          .thenAnswer((_) async => []);

      // act
      final result = await dataSource.getCachedPopularMovies();

      // assert
      expect(result, isEmpty);
    });

    test('should throw CacheException when retrieval fails', () async {
      // arrange
      when(() => mockDatabase.getMoviesByCategory(any()))
          .thenThrow(Exception('Query error'));

      // act & assert
      expect(
        () => dataSource.getCachedPopularMovies(),
        throwsA(isA<CacheException>()),
      );
    });
  });

  group('getCachedTopRatedMovies', () {
    test('should return cached top rated movies', () async {
      // arrange
      when(() => mockDatabase.getMoviesByCategory(any()))
          .thenAnswer((_) async => [tMovieRow]);

      // act
      final result = await dataSource.getCachedTopRatedMovies();

      // assert
      expect(result, isA<List<MovieModel>>());
      expect(result.length, 1);
      verify(() => mockDatabase.getMoviesByCategory('top_rated')).called(1);
    });
  });

  group('getCachedMovieById', () {
    const tMovieId = 1;

    test('should return cached movie by id', () async {
      // arrange
      when(() => mockDatabase.getMovieById(any()))
          .thenAnswer((_) async => tMovieRow);

      // act
      final result = await dataSource.getCachedMovieById(tMovieId);

      // assert
      expect(result, isA<MovieModel>());
      expect(result?.id, tMovieId);
      verify(() => mockDatabase.getMovieById(tMovieId)).called(1);
    });

    test('should return null when movie not found', () async {
      // arrange
      when(() => mockDatabase.getMovieById(any()))
          .thenAnswer((_) async => null);

      // act
      final result = await dataSource.getCachedMovieById(tMovieId);

      // assert
      expect(result, isNull);
    });

    test('should throw CacheException when retrieval fails', () async {
      // arrange
      when(() => mockDatabase.getMovieById(any()))
          .thenThrow(Exception('Query error'));

      // act & assert
      expect(
        () => dataSource.getCachedMovieById(tMovieId),
        throwsA(isA<CacheException>()),
      );
    });
  });

  group('searchCachedMovies', () {
    const tQuery = 'Test';

    test('should return search results from cache', () async {
      // arrange
      when(() => mockDatabase.searchMoviesByTitle(any()))
          .thenAnswer((_) async => [tMovieRow]);

      // act
      final result = await dataSource.searchCachedMovies(tQuery);

      // assert
      expect(result, isA<List<MovieModel>>());
      expect(result.length, 1);
      verify(() => mockDatabase.searchMoviesByTitle(tQuery)).called(1);
    });

    test('should return empty list when no matches', () async {
      // arrange
      when(() => mockDatabase.searchMoviesByTitle(any()))
          .thenAnswer((_) async => []);

      // act
      final result = await dataSource.searchCachedMovies(tQuery);

      // assert
      expect(result, isEmpty);
    });

    test('should throw CacheException when search fails', () async {
      // arrange
      when(() => mockDatabase.searchMoviesByTitle(any()))
          .thenThrow(Exception('Search error'));

      // act & assert
      expect(
        () => dataSource.searchCachedMovies(tQuery),
        throwsA(isA<CacheException>()),
      );
    });
  });
}
