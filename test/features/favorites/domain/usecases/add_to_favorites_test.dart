import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:movie_discovery_app/core/error/failures.dart';
import 'package:movie_discovery_app/features/favorites/domain/entities/favorite_movie_entity.dart';
import 'package:movie_discovery_app/features/favorites/domain/repositories/favorites_repository.dart';
import 'package:movie_discovery_app/features/favorites/domain/usecases/add_to_favorites.dart';

class MockFavoritesRepository extends Mock implements FavoritesRepository {}

void main() {
  late AddToFavorites usecase;
  late MockFavoritesRepository mockFavoritesRepository;

  setUp(() {
    mockFavoritesRepository = MockFavoritesRepository();
    usecase = AddToFavorites(mockFavoritesRepository);
  });

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
    registerFallbackValue(tFavoriteMovie);
  });

  test('should add movie to favorites', () async {
    // arrange
    when(() => mockFavoritesRepository.addToFavorites(any()))
        .thenAnswer((_) async => const Right(true));

    // act
    final result = await usecase(tFavoriteMovie);

    // assert
    expect(result, const Right(true));
    verify(() => mockFavoritesRepository.addToFavorites(tFavoriteMovie)).called(1);
    verifyNoMoreInteractions(mockFavoritesRepository);
  });

  test('should return CacheFailure when adding to favorites fails', () async {
    // arrange
    const tFailure = CacheFailure('Failed to add to favorites');
    when(() => mockFavoritesRepository.addToFavorites(any()))
        .thenAnswer((_) async => const Left(tFailure));

    // act
    final result = await usecase(tFavoriteMovie);

    // assert
    expect(result, const Left(tFailure));
    verify(() => mockFavoritesRepository.addToFavorites(tFavoriteMovie)).called(1);
  });

  test('should return false when movie is already in favorites', () async {
    // arrange
    when(() => mockFavoritesRepository.addToFavorites(any()))
        .thenAnswer((_) async => const Right(false));

    // act
    final result = await usecase(tFavoriteMovie);

    // assert
    expect(result, const Right(false));
    verify(() => mockFavoritesRepository.addToFavorites(tFavoriteMovie)).called(1);
  });
}
