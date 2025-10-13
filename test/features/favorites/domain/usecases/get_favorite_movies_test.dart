import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:movie_discovery_app/core/error/failures.dart';
import 'package:movie_discovery_app/features/favorites/domain/entities/favorite_movie_entity.dart';
import 'package:movie_discovery_app/features/favorites/domain/repositories/favorites_repository.dart';
import 'package:movie_discovery_app/features/favorites/domain/usecases/get_favorite_movies.dart';

class MockFavoritesRepository extends Mock implements FavoritesRepository {}

void main() {
  late GetFavoriteMovies usecase;
  late MockFavoritesRepository mockFavoritesRepository;

  setUp(() {
    mockFavoritesRepository = MockFavoritesRepository();
    usecase = GetFavoriteMovies(mockFavoritesRepository);
  });

  final tFavoriteMovies = [
    FavoriteMovieEntity(
      id: 1,
      title: 'Test Movie 1',
      overview: 'Test overview 1',
      posterPath: '/test1.jpg',
      voteAverage: 8.0,
      releaseDate: '2024-01-01',
      genreIds: const [28, 12],
      dateAdded: DateTime(2024, 1, 1),
    ),
    FavoriteMovieEntity(
      id: 2,
      title: 'Test Movie 2',
      overview: 'Test overview 2',
      posterPath: '/test2.jpg',
      voteAverage: 7.5,
      releaseDate: '2024-01-02',
      genreIds: const [18, 35],
      dateAdded: DateTime(2024, 1, 2),
    ),
  ];

  test('should get all favorite movies', () async {
    // arrange
    when(() => mockFavoritesRepository.getFavoriteMovies())
        .thenAnswer((_) async => Right(tFavoriteMovies));

    // act
    final result = await usecase();

    // assert
    expect(result, Right(tFavoriteMovies));
    verify(() => mockFavoritesRepository.getFavoriteMovies()).called(1);
    verifyNoMoreInteractions(mockFavoritesRepository);
  });

  test('should return empty list when no favorites exist', () async {
    // arrange
    when(() => mockFavoritesRepository.getFavoriteMovies())
        .thenAnswer((_) async => const Right(<FavoriteMovieEntity>[]));

    // act
    final result = await usecase();

    // assert
    expect(result, const Right(<FavoriteMovieEntity>[]));
    verify(() => mockFavoritesRepository.getFavoriteMovies()).called(1);
  });

  test('should return CacheFailure when getting favorites fails', () async {
    // arrange
    const tFailure = CacheFailure('Failed to get favorites');
    when(() => mockFavoritesRepository.getFavoriteMovies())
        .thenAnswer((_) async => const Left(tFailure));

    // act
    final result = await usecase();

    // assert
    expect(result, const Left(tFailure));
    verify(() => mockFavoritesRepository.getFavoriteMovies()).called(1);
  });
}
