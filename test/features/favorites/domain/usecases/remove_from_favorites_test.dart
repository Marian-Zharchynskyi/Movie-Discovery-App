import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:movie_discovery_app/core/error/failures.dart';
import 'package:movie_discovery_app/features/favorites/domain/repositories/favorites_repository.dart';
import 'package:movie_discovery_app/features/favorites/domain/usecases/remove_from_favorites.dart';

class MockFavoritesRepository extends Mock implements FavoritesRepository {}

void main() {
  late RemoveFromFavorites usecase;
  late MockFavoritesRepository mockFavoritesRepository;

  setUp(() {
    mockFavoritesRepository = MockFavoritesRepository();
    usecase = RemoveFromFavorites(mockFavoritesRepository);
  });

  const tMovieId = 1;

  test('should remove movie from favorites', () async {
    // arrange
    when(() => mockFavoritesRepository.removeFromFavorites(any()))
        .thenAnswer((_) async => const Right(true));

    // act
    final result = await usecase(tMovieId);

    // assert
    expect(result, const Right(true));
    verify(() => mockFavoritesRepository.removeFromFavorites(tMovieId)).called(1);
    verifyNoMoreInteractions(mockFavoritesRepository);
  });

  test('should return CacheFailure when removing from favorites fails', () async {
    // arrange
    const tFailure = CacheFailure('Failed to remove from favorites');
    when(() => mockFavoritesRepository.removeFromFavorites(any()))
        .thenAnswer((_) async => const Left(tFailure));

    // act
    final result = await usecase(tMovieId);

    // assert
    expect(result, const Left(tFailure));
    verify(() => mockFavoritesRepository.removeFromFavorites(tMovieId)).called(1);
  });

  test('should return false when movie is not in favorites', () async {
    // arrange
    when(() => mockFavoritesRepository.removeFromFavorites(any()))
        .thenAnswer((_) async => const Right(false));

    // act
    final result = await usecase(tMovieId);

    // assert
    expect(result, const Right(false));
    verify(() => mockFavoritesRepository.removeFromFavorites(tMovieId)).called(1);
  });
}
