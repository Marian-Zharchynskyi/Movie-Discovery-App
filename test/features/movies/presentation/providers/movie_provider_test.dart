import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:movie_discovery_app/core/error/failures.dart';
import 'package:movie_discovery_app/features/movies/domain/entities/movie_entity.dart';
import 'package:movie_discovery_app/features/movies/domain/usecases/get_popular_movies.dart';
import 'package:movie_discovery_app/features/movies/presentation/providers/movie_provider.dart';

class MockGetPopularMovies extends Mock implements GetPopularMovies {}

void main() {
  late MovieNotifier movieNotifier;
  late MockGetPopularMovies mockGetPopularMovies;

  setUp(() {
    mockGetPopularMovies = MockGetPopularMovies();
    movieNotifier = MovieNotifier(mockGetPopularMovies);
  });

  tearDown(() {
    movieNotifier.dispose();
  });

  const tMovieList = [
    MovieEntity(
      id: 1,
      title: 'Test Movie 1',
      overview: 'Test overview 1',
      posterPath: '/test1.jpg',
      voteAverage: 8.5,
      releaseDate: '2024-01-15',
      genreIds: [28, 12],
    ),
    MovieEntity(
      id: 2,
      title: 'Test Movie 2',
      overview: 'Test overview 2',
      posterPath: '/test2.jpg',
      voteAverage: 7.5,
      releaseDate: '2024-02-20',
      genreIds: [18],
    ),
  ];

  group('MovieNotifier', () {
    test('initial state should be correct', () {
      expect(movieNotifier.state.isLoading, false);
      expect(movieNotifier.state.movies, isEmpty);
      expect(movieNotifier.state.currentPage, 1);
      expect(movieNotifier.state.hasMorePages, true);
      expect(movieNotifier.state.errorMessage, null);
    });

    group('fetchPopularMovies', () {
      test('should fetch popular movies successfully', () async {
        // arrange
        when(() => mockGetPopularMovies(page: any(named: 'page')))
            .thenAnswer((_) async => const Right(tMovieList));

        // act
        await movieNotifier.fetchPopularMovies();

        // assert
        expect(movieNotifier.state.isLoading, false);
        expect(movieNotifier.state.movies, tMovieList);
        expect(movieNotifier.state.currentPage, 1);
        expect(movieNotifier.state.errorMessage, null);
        verify(() => mockGetPopularMovies(page: 1)).called(1);
      });

      test('should update hasMorePages based on result length', () async {
        // arrange - less than 20 movies means no more pages
        const shortList = [
          MovieEntity(
            id: 1,
            title: 'Test Movie',
            overview: 'Test',
            posterPath: '/test.jpg',
            voteAverage: 8.0,
            releaseDate: '2024-01-01',
            genreIds: [28],
          ),
        ];
        when(() => mockGetPopularMovies(page: any(named: 'page')))
            .thenAnswer((_) async => const Right(shortList));

        // act
        await movieNotifier.fetchPopularMovies();

        // assert
        expect(movieNotifier.state.hasMorePages, false);
      });

      test('should set error message when fetch fails', () async {
        // arrange
        const tFailure = ServerFailure('Network error');
        when(() => mockGetPopularMovies(page: any(named: 'page')))
            .thenAnswer((_) async => const Left(tFailure));

        // act
        await movieNotifier.fetchPopularMovies();

        // assert
        expect(movieNotifier.state.isLoading, false);
        expect(movieNotifier.state.errorMessage, 'Network error');
        expect(movieNotifier.state.movies, isEmpty);
      });

      test('should reset state when fetching', () async {
        // arrange
        when(() => mockGetPopularMovies(page: any(named: 'page')))
            .thenAnswer((_) async => const Right(tMovieList));

        // Load some movies first
        await movieNotifier.fetchPopularMovies();

        // act - fetch again
        await movieNotifier.fetchPopularMovies();

        // assert
        expect(movieNotifier.state.currentPage, 1);
        expect(movieNotifier.state.movies.length, 2);
      });
    });

    group('loadMoreMovies', () {
      test('should load more movies successfully', () async {
        // arrange: first page returns >= 20 items so hasMorePages = true
        final initialTwenty = List<MovieEntity>.generate(20, (i) => MovieEntity(
              id: i + 1,
              title: 'Movie ${i + 1}',
              overview: 'Overview ${i + 1}',
              posterPath: '/p${i + 1}.jpg',
              voteAverage: 7.0,
              releaseDate: '2024-01-01',
              genreIds: const [28],
            ));
        when(() => mockGetPopularMovies(page: 1))
            .thenAnswer((_) async => Right(initialTwenty));

        // Load initial movies
        await movieNotifier.fetchPopularMovies();

        const moreMovies = [
          MovieEntity(
            id: 3,
            title: 'Test Movie 3',
            overview: 'Test overview 3',
            posterPath: '/test3.jpg',
            voteAverage: 9.0,
            releaseDate: '2024-03-10',
            genreIds: [35],
          ),
        ];

        when(() => mockGetPopularMovies(page: 2))
            .thenAnswer((_) async => const Right(moreMovies));

        // act
        await movieNotifier.loadMoreMovies();

        // assert
        expect(movieNotifier.state.isLoadingMore, false);
        expect(movieNotifier.state.movies.length, initialTwenty.length + moreMovies.length);
        expect(movieNotifier.state.currentPage, 2);
        verify(() => mockGetPopularMovies(page: 2)).called(1);
      });

      test('should not load when already loading', () async {
        // arrange: first page returns >= 20 items so hasMorePages = true
        final initialTwenty = List<MovieEntity>.generate(20, (i) => MovieEntity(
              id: i + 1,
              title: 'Movie ${i + 1}',
              overview: 'Overview ${i + 1}',
              posterPath: '/p${i + 1}.jpg',
              voteAverage: 7.0,
              releaseDate: '2024-01-01',
              genreIds: const [28],
            ));
        when(() => mockGetPopularMovies(page: 1))
            .thenAnswer((_) async => Right(initialTwenty));

        await movieNotifier.fetchPopularMovies();

        // Simulate loading state (slow page 2)
        when(() => mockGetPopularMovies(page: 2))
            .thenAnswer((_) async {
          await Future.delayed(const Duration(milliseconds: 100));
          return const Right(tMovieList);
        });

        // act - call loadMoreMovies twice quickly
        final future1 = movieNotifier.loadMoreMovies();
        final future2 = movieNotifier.loadMoreMovies();

        await Future.wait([future1, future2]);

        // assert - should only call once
        verify(() => mockGetPopularMovies(page: 2)).called(1);
      });

      test('should not load when no more pages', () async {
        // arrange
        const shortList = [
          MovieEntity(
            id: 1,
            title: 'Test Movie',
            overview: 'Test',
            posterPath: '/test.jpg',
            voteAverage: 8.0,
            releaseDate: '2024-01-01',
            genreIds: [28],
          ),
        ];
        when(() => mockGetPopularMovies(page: any(named: 'page')))
            .thenAnswer((_) async => const Right(shortList));

        await movieNotifier.fetchPopularMovies();

        // act
        await movieNotifier.loadMoreMovies();

        // assert - should not call for page 2
        verifyNever(() => mockGetPopularMovies(page: 2));
      });

      test('should set error message when loading more fails', () async {
        // arrange: first page returns >= 20 items so hasMorePages = true
        final initialTwenty = List<MovieEntity>.generate(20, (i) => MovieEntity(
              id: i + 1,
              title: 'Movie ${i + 1}',
              overview: 'Overview ${i + 1}',
              posterPath: '/p${i + 1}.jpg',
              voteAverage: 7.0,
              releaseDate: '2024-01-01',
              genreIds: const [28],
            ));
        when(() => mockGetPopularMovies(page: 1))
            .thenAnswer((_) async => Right(initialTwenty));
        when(() => mockGetPopularMovies(page: 2))
            .thenAnswer((_) async => const Left(ServerFailure('Network error')));

        await movieNotifier.fetchPopularMovies();

        // act
        await movieNotifier.loadMoreMovies();

        // assert
        expect(movieNotifier.state.isLoadingMore, false);
        expect(movieNotifier.state.errorMessage, 'Network error');
        expect(movieNotifier.state.movies.length, initialTwenty.length); // Original movies still there
      });

      test('should update hasMorePages when loading more', () async {
        // arrange
        when(() => mockGetPopularMovies(page: 1))
            .thenAnswer((_) async => const Right(tMovieList));

        const shortList = [
          MovieEntity(
            id: 3,
            title: 'Test Movie 3',
            overview: 'Test',
            posterPath: '/test3.jpg',
            voteAverage: 8.0,
            releaseDate: '2024-01-01',
            genreIds: [28],
          ),
        ];

        when(() => mockGetPopularMovies(page: 2))
            .thenAnswer((_) async => const Right(shortList));

        await movieNotifier.fetchPopularMovies();

        // act
        await movieNotifier.loadMoreMovies();

        // assert
        expect(movieNotifier.state.hasMorePages, false);
      });
    });
  });
}
