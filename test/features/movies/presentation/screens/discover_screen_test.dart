import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movie_discovery_app/features/movies/domain/entities/movie_entity.dart';
import 'package:movie_discovery_app/features/movies/domain/usecases/discover_movies.dart';
import 'package:movie_discovery_app/features/movies/presentation/providers/discover_movies_provider.dart';
import 'package:movie_discovery_app/features/movies/presentation/screens/discover_screen.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:movie_discovery_app/l10n/app_localizations.dart';
import 'package:movie_discovery_app/core/error/failures.dart';
import 'package:movie_discovery_app/features/movies/domain/repositories/movie_repository.dart';
import 'package:movie_discovery_app/features/movies/domain/entities/video_entity.dart';
import 'package:movie_discovery_app/features/movies/domain/entities/review_entity.dart';

class FakeMovieRepository implements MovieRepository {
  @override
  Future<Either<Failure, List<MovieEntity>>> discoverMovies({int page = 1, List<int>? genreIds, int? year, double? minRating}) async {
    if (genreIds?.contains(999) ?? false) return Left(ServerFailure('filter error'));
    return Right(List.generate(10, (i) => MovieEntity(
          id: i + (page - 1) * 10,
          title: 'Movie $page-$i',
          overview: '',
          posterPath: null,
          voteAverage: 7.0,
          releaseDate: '2024-01-01',
          genreIds: const [28],
        )));
  }

  // Unused methods for this test
  @override
  Future<Either<Failure, List<MovieEntity>>> getPopularMovies({int page = 1}) async => Right(const []);
  @override
  Future<Either<Failure, List<MovieEntity>>> getTopRatedMovies({int page = 1}) async => Right(const []);
  @override
  Future<Either<Failure, MovieEntity>> getMovieDetails(int movieId) async => Left(ServerFailure('not used'));
  @override
  Future<Either<Failure, List<MovieEntity>>> searchMovies(String query, {int page = 1}) async => Right(const []);
  @override
  Future<Either<Failure, List<VideoEntity>>> getMovieVideos(int movieId) async => Left(ServerFailure('not used'));
  @override
  Future<Either<Failure, List<ReviewEntity>>> getMovieReviews(int movieId, {int page = 1}) async => Left(ServerFailure('not used'));
}

void main() {
  testWidgets('DiscoverScreen renders and shows grid', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          discoverMoviesUseCaseProvider.overrideWith((ref) => DiscoverMovies(FakeMovieRepository())),
        ],
        child: const MaterialApp(
          localizationsDelegates: [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: DiscoverScreen(),
        ),
      ),
    );

    await tester.pump();
    // After initial fetch, body should not be empty
    expect(find.byType(GridView), findsOneWidget);
  });
}
