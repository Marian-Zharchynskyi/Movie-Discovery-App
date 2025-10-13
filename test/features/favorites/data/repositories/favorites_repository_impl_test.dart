import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:movie_discovery_app/core/error/exceptions.dart';
import 'package:movie_discovery_app/core/error/failures.dart';
import 'package:movie_discovery_app/features/favorites/data/datasources/local/favorites_local_data_source.dart';
import 'package:movie_discovery_app/features/favorites/data/models/favorite_movie_model.dart';
import 'package:movie_discovery_app/features/favorites/data/repositories/favorites_repository_impl.dart';
import 'package:movie_discovery_app/features/favorites/domain/entities/favorite_movie_entity.dart';

class MockFavoritesLocalDataSource extends Mock implements FavoritesLocalDataSource {}

void main() {
  late FavoritesRepositoryImpl repository;
  late MockFavoritesLocalDataSource mockLocalDataSource;

  setUp(() {
    mockLocalDataSource = MockFavoritesLocalDataSource();
    repository = FavoritesRepositoryImpl(localDataSource: mockLocalDataSource);
  });

  final tFavoriteMovies = [
    FavoriteMovieModel(
      id: 1,
      title: 'Test Movie',
      overview: 'Test overview',
      posterPath: '/test.jpg',
      voteAverage: 8.0,
      releaseDate: '2024-01-01',
      genreIds: const [28, 12],
      dateAdded: DateTime(2024, 1, 1),
    ),
  ];

  final tFavoriteMovie = FavoriteMovieEntity(
    id: 1,
    title: 'Test Movie',
    overview: 'Test overview',
    posterPath: '/test.jpg',
    voteAverage: 8.0,
    releaseDate: '2024-01-01',
    genreIds: const [28, 12],
    dateAdded: DateTime(2024, 1, 1),
  );

  setUpAll(() {
    registerFallbackValue(FavoriteMovieModel(
      id: 1,
      title: 'Test',
      overview: 'Test',
      voteAverage: 0,
      releaseDate: '2024-01-01',
      genreIds: const [],
      dateAdded: DateTime(2024, 1, 1),
    ));
  });

  group('getFavoriteMovies', () {
    test('should return list of favorite movies from local data source', () async {
      // arrange
      when(() => mockLocalDataSource.getFavoriteMovies())
          .thenAnswer((_) async => tFavoriteMovies);

      // act
      final result = await repository.getFavoriteMovies();

      // assert
      expect(result, Right(tFavoriteMovies));
      verify(() => mockLocalDataSource.getFavoriteMovies()).called(1);
      verifyNoMoreInteractions(mockLocalDataSource);
    });

    test('should return CacheFailure when local data source throws exception', () async {
      // arrange
      when(() => mockLocalDataSource.getFavoriteMovies())
          .thenThrow(CacheException('Failed to get favorites'));

      // act
      final result = await repository.getFavoriteMovies();

      // assert
      expect(result, const Left(CacheFailure('Failed to get favorites')));
      verify(() => mockLocalDataSource.getFavoriteMovies()).called(1);
    });
  });

  group('addToFavorites', () {
    test('should add movie to favorites successfully', () async {
      // arrange
      when(() => mockLocalDataSource.addToFavorites(any()))
          .thenAnswer((_) async => true);

      // act
      final result = await repository.addToFavorites(tFavoriteMovie);

      // assert
      expect(result, const Right(true));
      verify(() => mockLocalDataSource.addToFavorites(any())).called(1);
    });

    test('should return CacheFailure when adding to favorites fails', () async {
      // arrange
      when(() => mockLocalDataSource.addToFavorites(any()))
          .thenThrow(CacheException('Failed to add to favorites'));

      // act
      final result = await repository.addToFavorites(tFavoriteMovie);

      // assert
      expect(result, const Left(CacheFailure('Failed to add to favorites')));
      verify(() => mockLocalDataSource.addToFavorites(any())).called(1);
    });
  });

  group('removeFromFavorites', () {
    const tMovieId = 1;

    test('should remove movie from favorites successfully', () async {
      // arrange
      when(() => mockLocalDataSource.removeFromFavorites(any()))
          .thenAnswer((_) async => true);

      // act
      final result = await repository.removeFromFavorites(tMovieId);

      // assert
      expect(result, const Right(true));
      verify(() => mockLocalDataSource.removeFromFavorites(tMovieId)).called(1);
    });

    test('should return CacheFailure when removing from favorites fails', () async {
      // arrange
      when(() => mockLocalDataSource.removeFromFavorites(any()))
          .thenThrow(CacheException('Failed to remove from favorites'));

      // act
      final result = await repository.removeFromFavorites(tMovieId);

      // assert
      expect(result, const Left(CacheFailure('Failed to remove from favorites')));
      verify(() => mockLocalDataSource.removeFromFavorites(tMovieId)).called(1);
    });
  });

  group('isFavorite', () {
    const tMovieId = 1;

    test('should return true when movie is in favorites', () async {
      // arrange
      when(() => mockLocalDataSource.isFavorite(any()))
          .thenAnswer((_) async => true);

      // act
      final result = await repository.isFavorite(tMovieId);

      // assert
      expect(result, const Right(true));
      verify(() => mockLocalDataSource.isFavorite(tMovieId)).called(1);
    });

    test('should return false when movie is not in favorites', () async {
      // arrange
      when(() => mockLocalDataSource.isFavorite(any()))
          .thenAnswer((_) async => false);

      // act
      final result = await repository.isFavorite(tMovieId);

      // assert
      expect(result, const Right(false));
      verify(() => mockLocalDataSource.isFavorite(tMovieId)).called(1);
    });

    test('should return CacheFailure when checking favorite status fails', () async {
      // arrange
      when(() => mockLocalDataSource.isFavorite(any()))
          .thenThrow(CacheException('Failed to check favorite status'));

      // act
      final result = await repository.isFavorite(tMovieId);

      // assert
      expect(result, const Left(CacheFailure('Failed to check favorite status')));
      verify(() => mockLocalDataSource.isFavorite(tMovieId)).called(1);
    });
  });
}
