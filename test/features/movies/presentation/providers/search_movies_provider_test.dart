import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:movie_discovery_app/core/error/failures.dart';
import 'package:movie_discovery_app/features/movies/domain/entities/movie_entity.dart';
import 'package:movie_discovery_app/features/movies/domain/usecases/search_movies.dart';
import 'package:movie_discovery_app/features/movies/presentation/providers/search_movies_provider.dart';
import 'package:movie_discovery_app/features/movies/domain/repositories/movie_repository.dart';
import 'package:movie_discovery_app/features/movies/domain/entities/video_entity.dart';
import 'package:movie_discovery_app/features/movies/domain/entities/review_entity.dart';

class FakeMovieRepository implements MovieRepository {
  final bool fail;
  FakeMovieRepository({this.fail = false});

  @override
  Future<Either<Failure, List<MovieEntity>>> searchMovies(String query, {int page = 1}) async {
    if (fail || query == 'error') return const Left(ServerFailure('oops'));
    return Right(const [
      MovieEntity(
        id: 1,
        title: 'Query Result',
        overview: '',
        posterPath: null,
        voteAverage: 7.0,
        releaseDate: '2024-01-01',
        genreIds: [28],
      )
    ]);
  }

  // Unused in this test
  @override
  Future<Either<Failure, List<MovieEntity>>> getPopularMovies({int page = 1}) async => Right(const []);
  @override
  Future<Either<Failure, List<MovieEntity>>> getTopRatedMovies({int page = 1}) async => Right(const []);
  @override
  Future<Either<Failure, MovieEntity>> getMovieDetails(int movieId) async => const Left(ServerFailure('x'));
  @override
  Future<Either<Failure, List<VideoEntity>>> getMovieVideos(int movieId) async => const Left(ServerFailure('x'));
  @override
  Future<Either<Failure, List<ReviewEntity>>> getMovieReviews(int movieId, {int page = 1}) async => const Left(ServerFailure('x'));
  @override
  Future<Either<Failure, List<MovieEntity>>> discoverMovies({int page = 1, List<int>? genreIds, int? year, double? minRating}) async => Right(const []);
}

void main() {
  test('search sets loading and then results', () async {
    final container = ProviderContainer(overrides: [
      searchMoviesUseCaseProvider.overrideWith((ref) => SearchMovies(FakeMovieRepository())),
    ]);
    addTearDown(container.dispose);

    final notifier = container.read(searchMoviesProvider.notifier);
    await notifier.search('matrix');

    final state = container.read(searchMoviesProvider);
    expect(state.isLoading, false);
    expect(state.movies.length, 1);
    expect(state.query, 'matrix');
  });

  test('search with empty query resets state', () async {
    final container = ProviderContainer(overrides: [
      searchMoviesUseCaseProvider.overrideWith((ref) => SearchMovies(FakeMovieRepository())),
    ]);
    addTearDown(container.dispose);

    final notifier = container.read(searchMoviesProvider.notifier);
    await notifier.search('   ');

    final state = container.read(searchMoviesProvider);
    expect(state.movies, isEmpty);
    expect(state.query, '');
  });

  test('search sets error on failure', () async {
    final container = ProviderContainer(overrides: [
      searchMoviesUseCaseProvider.overrideWith((ref) => SearchMovies(FakeMovieRepository(fail: true))),
    ]);
    addTearDown(container.dispose);

    final notifier = container.read(searchMoviesProvider.notifier);
    await notifier.search('anything');

    final state = container.read(searchMoviesProvider);
    expect(state.errorMessage, 'oops');
    expect(state.isLoading, false);
  });
}
