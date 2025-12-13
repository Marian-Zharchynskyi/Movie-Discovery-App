import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:movie_discovery_app/core/error/failures.dart';
import 'package:movie_discovery_app/features/favorites/domain/entities/favorite_movie_entity.dart';
import 'package:movie_discovery_app/features/favorites/domain/usecases/add_to_favorites.dart';
import 'package:movie_discovery_app/features/favorites/domain/usecases/get_favorite_movies.dart';
import 'package:movie_discovery_app/features/favorites/domain/usecases/is_favorite.dart';
import 'package:movie_discovery_app/features/favorites/domain/usecases/remove_from_favorites.dart';
import 'package:movie_discovery_app/features/favorites/presentation/providers/favorites_cubit.dart';

class MockGetFavoriteMovies extends Mock implements GetFavoriteMovies {}
class MockAddToFavorites extends Mock implements AddToFavorites {}
class MockRemoveFromFavorites extends Mock implements RemoveFromFavorites {}
class MockIsFavorite extends Mock implements IsFavorite {}

void main() {
  late FavoritesNotifier favoritesNotifier;
  late MockGetFavoriteMovies mockGetFavoriteMovies;
  late MockAddToFavorites mockAddToFavorites;
  late MockRemoveFromFavorites mockRemoveFromFavorites;
  late MockIsFavorite mockIsFavorite;

  setUp(() {
    mockGetFavoriteMovies = MockGetFavoriteMovies();
    mockAddToFavorites = MockAddToFavorites();
    mockRemoveFromFavorites = MockRemoveFromFavorites();
    mockIsFavorite = MockIsFavorite();

    favoritesNotifier = FavoritesNotifier(
      getFavoriteMovies: mockGetFavoriteMovies,
      addToFavorites: mockAddToFavorites,
      removeFromFavorites: mockRemoveFromFavorites,
      isFavorite: mockIsFavorite,
    );
  });

  setUpAll(() {
    registerFallbackValue(FavoriteMovieEntity(
      id: 0,
      title: '',
      overview: '',
      posterPath: null,
      voteAverage: 0,
      releaseDate: '',
      genreIds: const [],
      dateAdded: DateTime.now(),
    ));
  });

  tearDown(() {
    favoritesNotifier.dispose();
  });

  const tUserId = 'test-user-123';

  final tMovie = FavoriteMovieEntity(
    id: 1,
    title: 'Test Movie',
    overview: 'Test overview',
    posterPath: '/test.jpg',
    voteAverage: 8.5,
    releaseDate: '2024-01-15',
    genreIds: const [28, 12],
    dateAdded: DateTime(2024, 1, 15),
  );

  final tMovieList = [tMovie];

  void setUserIdForNotifier() {
    favoritesNotifier.setUserId(tUserId);
  }

  group('FavoritesNotifier', () {
    test('initial state should be empty', () {
      expect(favoritesNotifier.state.favoriteMovies, isEmpty);
      expect(favoritesNotifier.state.isLoading, false);
      expect(favoritesNotifier.state.error, null);
    });

    group('loadFavoriteMovies', () {
      test('should load favorite movies successfully', () async {
        // arrange
        when(() => mockGetFavoriteMovies(any()))
            .thenAnswer((_) async => Right(tMovieList));
        setUserIdForNotifier();

        // act
        await favoritesNotifier.loadFavoriteMovies();

        // assert
        expect(favoritesNotifier.state.favoriteMovies, tMovieList);
        expect(favoritesNotifier.state.isLoading, false);
        expect(favoritesNotifier.state.error, null);
        verify(() => mockGetFavoriteMovies(tUserId)).called(greaterThanOrEqualTo(1));
      });

      test('should update state with error when loading fails', () async {
        // arrange
        const tFailure = CacheFailure('Failed to load favorites');
        when(() => mockGetFavoriteMovies(any()))
            .thenAnswer((_) async => const Left(tFailure));
        setUserIdForNotifier();

        // act
        await favoritesNotifier.loadFavoriteMovies();

        // assert
        expect(favoritesNotifier.state.favoriteMovies, isEmpty);
        expect(favoritesNotifier.state.isLoading, false);
        expect(favoritesNotifier.state.error, 'Failed to load favorites');
      });

      test('should return empty list when no userId', () async {
        // act
        await favoritesNotifier.loadFavoriteMovies();

        // assert
        expect(favoritesNotifier.state.favoriteMovies, isEmpty);
        expect(favoritesNotifier.state.isLoading, false);
        verifyNever(() => mockGetFavoriteMovies(any()));
      });
    });

    group('addMovieToFavorites', () {
      test('should add movie to favorites successfully', () async {
        // arrange
        when(() => mockAddToFavorites(any(), any()))
            .thenAnswer((_) async => const Right(true));
        setUserIdForNotifier();

        // act
        final result = await favoritesNotifier.addMovieToFavorites(tMovie);

        // assert
        expect(result, true);
        expect(favoritesNotifier.state.favoriteMovies, contains(tMovie));
        expect(favoritesNotifier.state.isLoading, false);
        verify(() => mockAddToFavorites(tMovie, tUserId)).called(1);
      });

      test('should not add duplicate movie', () async {
        // arrange
        when(() => mockAddToFavorites(any(), any()))
            .thenAnswer((_) async => const Right(true));
        setUserIdForNotifier();

        // act
        await favoritesNotifier.addMovieToFavorites(tMovie);
        final result = await favoritesNotifier.addMovieToFavorites(tMovie);

        // assert
        expect(result, true);
        expect(favoritesNotifier.state.favoriteMovies.length, 1);
      });

      test('should return false when adding fails', () async {
        // arrange
        const tFailure = CacheFailure('Failed to add');
        when(() => mockAddToFavorites(any(), any()))
            .thenAnswer((_) async => const Left(tFailure));
        setUserIdForNotifier();

        // act
        final result = await favoritesNotifier.addMovieToFavorites(tMovie);

        // assert
        expect(result, false);
        expect(favoritesNotifier.state.error, 'Failed to add');
      });

      test('should return false when no userId', () async {
        // act
        final result = await favoritesNotifier.addMovieToFavorites(tMovie);

        // assert
        expect(result, false);
        verifyNever(() => mockAddToFavorites(any(), any()));
      });
    });

    group('removeFromFavorites', () {
      test('should remove movie from favorites successfully', () async {
        // arrange
        when(() => mockGetFavoriteMovies(any()))
            .thenAnswer((_) async => Right(tMovieList));
        when(() => mockRemoveFromFavorites(any(), any()))
            .thenAnswer((_) async => const Right(true));
        setUserIdForNotifier();

        await favoritesNotifier.loadFavoriteMovies();

        // act
        final result = await favoritesNotifier.removeFromFavorites(1);

        // assert
        expect(result, true);
        expect(favoritesNotifier.state.favoriteMovies, isEmpty);
        verify(() => mockRemoveFromFavorites(1, tUserId)).called(1);
      });

      test('should return false when removal fails', () async {
        // arrange
        const tFailure = CacheFailure('Failed to remove');
        when(() => mockRemoveFromFavorites(any(), any()))
            .thenAnswer((_) async => const Left(tFailure));
        setUserIdForNotifier();

        // act
        final result = await favoritesNotifier.removeFromFavorites(1);

        // assert
        expect(result, false);
        expect(favoritesNotifier.state.error, 'Failed to remove');
      });

      test('should return false when no userId', () async {
        // act
        final result = await favoritesNotifier.removeFromFavorites(1);

        // assert
        expect(result, false);
        verifyNever(() => mockRemoveFromFavorites(any(), any()));
      });
    });

    group('isFavorite', () {
      test('should return true when movie is favorite', () async {
        // arrange
        when(() => mockIsFavorite(any(), any()))
            .thenAnswer((_) async => const Right(true));
        setUserIdForNotifier();

        // act
        final result = await favoritesNotifier.isFavorite(1);

        // assert
        expect(result, true);
        verify(() => mockIsFavorite(1, tUserId)).called(1);
      });

      test('should return false when movie is not favorite', () async {
        // arrange
        when(() => mockIsFavorite(any(), any()))
            .thenAnswer((_) async => const Right(false));
        setUserIdForNotifier();

        // act
        final result = await favoritesNotifier.isFavorite(1);

        // assert
        expect(result, false);
      });

      test('should return false on failure', () async {
        // arrange
        const tFailure = CacheFailure('Failed to check');
        when(() => mockIsFavorite(any(), any()))
            .thenAnswer((_) async => const Left(tFailure));
        setUserIdForNotifier();

        // act
        final result = await favoritesNotifier.isFavorite(1);

        // assert
        expect(result, false);
      });

      test('should return false when no userId', () async {
        // act
        final result = await favoritesNotifier.isFavorite(1);

        // assert
        expect(result, false);
        verifyNever(() => mockIsFavorite(any(), any()));
      });
    });

    group('getFavoriteMovie', () {
      test('should return movie when it exists', () async {
        // arrange
        when(() => mockGetFavoriteMovies(any()))
            .thenAnswer((_) async => Right(tMovieList));
        setUserIdForNotifier();
        await favoritesNotifier.loadFavoriteMovies();

        // act
        final result = favoritesNotifier.getFavoriteMovie(1);

        // assert
        expect(result, tMovie);
      });

      test('should return null when movie does not exist', () {
        // act
        final result = favoritesNotifier.getFavoriteMovie(999);

        // assert
        expect(result, null);
      });
    });

    group('toggleFavorite', () {
      test('should add movie when not in favorites', () async {
        // arrange
        when(() => mockAddToFavorites(any(), any()))
            .thenAnswer((_) async => const Right(true));
        setUserIdForNotifier();

        // act
        final result = await favoritesNotifier.toggleFavorite(tMovie);

        // assert
        expect(result, true);
        expect(favoritesNotifier.state.favoriteMovies, contains(tMovie));
      });

      test('should remove movie when already in favorites', () async {
        // arrange
        when(() => mockAddToFavorites(any(), any()))
            .thenAnswer((_) async => const Right(true));
        when(() => mockRemoveFromFavorites(any(), any()))
            .thenAnswer((_) async => const Right(true));
        setUserIdForNotifier();

        await favoritesNotifier.addMovieToFavorites(tMovie);

        // act
        final result = await favoritesNotifier.toggleFavorite(tMovie);

        // assert
        expect(result, true);
        expect(favoritesNotifier.state.favoriteMovies, isEmpty);
      });
    });
  });
}
