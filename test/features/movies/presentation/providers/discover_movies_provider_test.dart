import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:movie_discovery_app/core/error/failures.dart';
import 'package:movie_discovery_app/features/movies/domain/entities/movie_entity.dart';
import 'package:movie_discovery_app/features/movies/domain/usecases/discover_movies.dart';
import 'package:movie_discovery_app/features/movies/presentation/providers/discover_movies_provider.dart';
import 'package:movie_discovery_app/features/movies/domain/repositories/movie_repository.dart';
import 'package:movie_discovery_app/features/movies/domain/entities/video_entity.dart';
import 'package:movie_discovery_app/features/movies/domain/entities/review_entity.dart';

class FakeMovieRepository implements MovieRepository {
  @override
  Future<Either<Failure, List<MovieEntity>>> discoverMovies({int page = 1, List<int>? genreIds, int? year, double? minRating}) async {
    if (genreIds?.contains(999) ?? false) return const Left(ServerFailure('filter error'));
    final movies = List.generate(20, (i) => MovieEntity(
          id: i + (page - 1) * 20,
          title: 'M$page-$i',
          overview: '',
          posterPath: null,
          voteAverage: 7.0,
          releaseDate: '2024-01-01',
          genreIds: const [28],
        ));
    return Right(movies);
  }

  // Unused below
  @override
  Future<Either<Failure, List<MovieEntity>>> getPopularMovies({int page = 1}) async => Right(const []);
  @override
  Future<Either<Failure, List<MovieEntity>>> getTopRatedMovies({int page = 1}) async => Right(const []);
  @override
  Future<Either<Failure, MovieEntity>> getMovieDetails(int movieId) async => const Left(ServerFailure('x'));
  @override
  Future<Either<Failure, List<MovieEntity>>> searchMovies(String query, {int page = 1}) async => Right(const []);
  @override
  Future<Either<Failure, List<VideoEntity>>> getMovieVideos(int movieId) async => const Left(ServerFailure('x'));
  @override
  Future<Either<Failure, List<ReviewEntity>>> getMovieReviews(int movieId, {int page = 1}) async => const Left(ServerFailure('x'));
}

void main() {
  test('fetchMovies applies filters and updates state', () async {
    final container = ProviderContainer(overrides: [
      discoverMoviesUseCaseProvider.overrideWith((ref) => DiscoverMovies(FakeMovieRepository())),
    ]);
    addTearDown(container.dispose);

    final notifier = container.read(discoverMoviesProvider.notifier);
    await notifier.fetchMovies(genreIds: const [28], year: 2024, minRating: 7.0);

    final state = container.read(discoverMoviesProvider);
    expect(state.isLoading, false);
    expect(state.movies.length, 20);
    expect(state.selectedGenres, [28]);
    expect(state.selectedYear, 2024);
    expect(state.selectedMinRating, 7.0);
  });

  test('loadMoreMovies paginates and appends results', () async {
    final container = ProviderContainer(overrides: [
      discoverMoviesUseCaseProvider.overrideWith((ref) => DiscoverMovies(FakeMovieRepository())),
    ]);
    addTearDown(container.dispose);

    final notifier = container.read(discoverMoviesProvider.notifier);
    await notifier.fetchMovies();
    await notifier.loadMoreMovies();

    final state = container.read(discoverMoviesProvider);
    expect(state.currentPage, 2);
    expect(state.movies.length, 40);
    expect(state.isLoadingMore, false);
  });

  test('fetchMovies sets error on failure', () async {
    final container = ProviderContainer(overrides: [
      discoverMoviesUseCaseProvider.overrideWith((ref) => DiscoverMovies(FakeMovieRepository())),
    ]);
    addTearDown(container.dispose);

    final notifier = container.read(discoverMoviesProvider.notifier);
    await notifier.fetchMovies(genreIds: const [999]);

    final state = container.read(discoverMoviesProvider);
    expect(state.errorMessage, 'filter error');
    expect(state.movies, isEmpty);
  });
}
