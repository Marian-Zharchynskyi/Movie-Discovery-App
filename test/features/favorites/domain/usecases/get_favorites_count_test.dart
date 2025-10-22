import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:movie_discovery_app/core/error/failures.dart';
import 'package:movie_discovery_app/features/favorites/domain/entities/favorite_movie_entity.dart';
import 'package:movie_discovery_app/features/favorites/domain/repositories/favorites_repository.dart';
import 'package:movie_discovery_app/features/favorites/domain/usecases/get_favorites_count.dart';

class MockFavoritesRepository extends Mock implements FavoritesRepository {}

void main() {
  late GetFavoritesCount usecase;
  late MockFavoritesRepository mockFavoritesRepository;

  setUp(() {
    mockFavoritesRepository = MockFavoritesRepository();
    usecase = GetFavoritesCount(mockFavoritesRepository);
  });

  test('should get favorites count from repository', () async {
    // arrange
    final tMovies = [
      FavoriteMovieEntity(
        id: 1,
        title: 'Movie 1',
        overview: 'Overview 1',
        voteAverage: 8.0,
        releaseDate: '2024-01-01',
        genreIds: const [28],
        dateAdded: DateTime.now(),
      ),
      FavoriteMovieEntity(
        id: 2,
        title: 'Movie 2',
        overview: 'Overview 2',
        voteAverage: 7.5,
        releaseDate: '2024-01-02',
        genreIds: const [18],
        dateAdded: DateTime.now(),
      ),
    ];
    when(() => mockFavoritesRepository.getFavoriteMovies())
        .thenAnswer((_) async => Right(tMovies));

    // act
    final result = await usecase();

    // assert
    expect(result, const Right(2));
    verify(() => mockFavoritesRepository.getFavoriteMovies()).called(1);
    verifyNoMoreInteractions(mockFavoritesRepository);
  });

  test('should return zero when no favorites', () async {
    // arrange
    when(() => mockFavoritesRepository.getFavoriteMovies())
        .thenAnswer((_) async => const Right([]));

    // act
    final result = await usecase();

    // assert
    expect(result, const Right(0));
  });

  test('should return CacheFailure when getting count fails', () async {
    // arrange
    const tFailure = CacheFailure('Failed to get count');
    when(() => mockFavoritesRepository.getFavoriteMovies())
        .thenAnswer((_) async => const Left(tFailure));

    // act
    final result = await usecase();

    // assert
    expect(result, const Left(tFailure));
  });
}
