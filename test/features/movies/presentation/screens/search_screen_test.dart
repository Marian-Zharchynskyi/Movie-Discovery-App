import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movie_discovery_app/features/movies/domain/entities/movie_entity.dart';
import 'package:movie_discovery_app/features/movies/domain/usecases/search_movies.dart';
import 'package:movie_discovery_app/features/movies/presentation/providers/search_movies_provider.dart';
import 'package:movie_discovery_app/features/movies/presentation/screens/search_screen.dart';
import 'package:dartz/dartz.dart';
import 'package:movie_discovery_app/core/error/failures.dart';
import 'package:movie_discovery_app/features/movies/domain/repositories/movie_repository.dart';
import 'package:movie_discovery_app/features/movies/domain/entities/video_entity.dart';
import 'package:movie_discovery_app/features/movies/domain/entities/review_entity.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:movie_discovery_app/l10n/app_localizations.dart';

class FakeMovieRepository implements MovieRepository {
  @override
  Future<Either<Failure, List<MovieEntity>>> searchMovies(String query, {int page = 1}) async {
    if (query == 'error') {
      return Left(ServerFailure('Error'));
    }
    return Right(const [
      MovieEntity(
        id: 1,
        title: 'Result 1',
        overview: '',
        posterPath: null,
        voteAverage: 7.0,
        releaseDate: '2024-01-01',
        genreIds: [28],
      )
    ]);
  }

  // Unused in these tests
  @override
  Future<Either<Failure, List<MovieEntity>>> getPopularMovies({int page = 1}) async => Right(const []);
  @override
  Future<Either<Failure, List<MovieEntity>>> getTopRatedMovies({int page = 1}) async => Right(const []);
  @override
  Future<Either<Failure, MovieEntity>> getMovieDetails(int movieId) async => Left(ServerFailure('not used'));
  @override
  Future<Either<Failure, List<VideoEntity>>> getMovieVideos(int movieId) async => Left(ServerFailure('not used'));
  @override
  Future<Either<Failure, List<ReviewEntity>>> getMovieReviews(int movieId, {int page = 1}) async => Left(ServerFailure('not used'));
  @override
  Future<Either<Failure, List<MovieEntity>>> discoverMovies({int page = 1, List<int>? genreIds, int? year, double? minRating}) async => Right(const []);
}

void main() {
  testWidgets('SearchScreen shows hint before query', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          localizationsDelegates: [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: SearchScreen(),
        ),
      ),
    );
    expect(find.byType(TextField), findsOneWidget);
  });

  testWidgets('SearchScreen displays results after successful search', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          searchMoviesUseCaseProvider.overrideWith((ref) => SearchMovies(FakeMovieRepository())),
        ],
        child: const MaterialApp(
          localizationsDelegates: [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: SearchScreen(),
        ),
      ),
    );

    // enter text and submit
    await tester.enterText(find.byType(TextField), 'matrix');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();

    expect(find.text('Result 1'), findsOneWidget);
  });

  testWidgets('SearchScreen shows error on failure and can retry', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          searchMoviesUseCaseProvider.overrideWith((ref) => SearchMovies(FakeMovieRepository())),
        ],
        child: const MaterialApp(
          localizationsDelegates: [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: SearchScreen(),
        ),
      ),
    );

    await tester.enterText(find.byType(TextField), 'error');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();

    expect(find.byIcon(Icons.error_outline), findsOneWidget);
    expect(find.textContaining('Retry'), findsOneWidget);
  });
}
