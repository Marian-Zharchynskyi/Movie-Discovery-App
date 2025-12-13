import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
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
import 'package:movie_discovery_app/features/auth/domain/entities/user_entity.dart';
import 'package:movie_discovery_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:movie_discovery_app/features/auth/domain/usecases/get_current_user.dart';
import 'package:movie_discovery_app/features/auth/domain/usecases/sign_in.dart';
import 'package:movie_discovery_app/features/auth/domain/usecases/sign_out.dart';
import 'package:movie_discovery_app/features/auth/domain/usecases/sign_up.dart';
import 'package:movie_discovery_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:movie_discovery_app/features/favorites/domain/usecases/add_to_favorites.dart';
import 'package:movie_discovery_app/features/favorites/domain/usecases/get_favorite_movies.dart';
import 'package:movie_discovery_app/features/favorites/domain/usecases/is_favorite.dart';
import 'package:movie_discovery_app/features/favorites/domain/usecases/remove_from_favorites.dart';
import 'package:movie_discovery_app/features/favorites/presentation/providers/favorites_cubit.dart';

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

class MockAuthRepository extends Mock implements AuthRepository {
  @override
  Stream<UserEntity?> get authStateChanges => const Stream.empty();
}

class MockSignIn extends Mock implements SignIn {}
class MockSignUp extends Mock implements SignUp {}
class MockSignOut extends Mock implements SignOut {}
class MockGetCurrentUser extends Mock implements GetCurrentUser {}
class MockGetFavoriteMovies extends Mock implements GetFavoriteMovies {}
class MockAddToFavorites extends Mock implements AddToFavorites {}
class MockRemoveFromFavorites extends Mock implements RemoveFromFavorites {}
class MockIsFavorite extends Mock implements IsFavorite {}

void main() {
  late MockAuthRepository mockAuthRepository;
  late MockSignIn mockSignIn;
  late MockSignUp mockSignUp;
  late MockSignOut mockSignOut;
  late MockGetCurrentUser mockGetCurrentUser;
  late MockGetFavoriteMovies mockGetFavoriteMovies;
  late MockAddToFavorites mockAddToFavorites;
  late MockRemoveFromFavorites mockRemoveFromFavorites;
  late MockIsFavorite mockIsFavorite;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    mockSignIn = MockSignIn();
    mockSignUp = MockSignUp();
    mockSignOut = MockSignOut();
    mockGetCurrentUser = MockGetCurrentUser();
    mockGetFavoriteMovies = MockGetFavoriteMovies();
    mockAddToFavorites = MockAddToFavorites();
    mockRemoveFromFavorites = MockRemoveFromFavorites();
    mockIsFavorite = MockIsFavorite();

    when(() => mockGetCurrentUser()).thenAnswer(
      (_) async => const Right(null),
    );
    when(() => mockIsFavorite(any(), any())).thenAnswer(
      (_) async => const Right(false),
    );
  });
  testWidgets('SearchScreen shows hint before query', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          searchMoviesUseCaseProvider.overrideWith((ref) => SearchMovies(FakeMovieRepository())),
          authProvider.overrideWith((ref) {
            return AuthNotifier(
              signIn: mockSignIn,
              signUp: mockSignUp,
              signOut: mockSignOut,
              getCurrentUser: mockGetCurrentUser,
              authRepository: mockAuthRepository,
            );
          }),
          getFavoriteMoviesProvider.overrideWithValue(mockGetFavoriteMovies),
          addToFavoritesProvider.overrideWithValue(mockAddToFavorites),
          removeFromFavoritesProvider.overrideWithValue(mockRemoveFromFavorites),
          isFavoriteProvider.overrideWithValue(mockIsFavorite),
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
    await tester.pumpAndSettle();
    expect(find.byType(TextField), findsOneWidget);
  });

  testWidgets('SearchScreen displays results after successful search', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          searchMoviesUseCaseProvider.overrideWith((ref) => SearchMovies(FakeMovieRepository())),
          authProvider.overrideWith((ref) {
            return AuthNotifier(
              signIn: mockSignIn,
              signUp: mockSignUp,
              signOut: mockSignOut,
              getCurrentUser: mockGetCurrentUser,
              authRepository: mockAuthRepository,
            );
          }),
          getFavoriteMoviesProvider.overrideWithValue(mockGetFavoriteMovies),
          addToFavoritesProvider.overrideWithValue(mockAddToFavorites),
          removeFromFavoritesProvider.overrideWithValue(mockRemoveFromFavorites),
          isFavoriteProvider.overrideWithValue(mockIsFavorite),
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
    await tester.pumpAndSettle();

    // enter text and submit
    await tester.tap(find.byType(TextField));
    await tester.pump();
    await tester.enterText(find.byType(TextField), 'matrix');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();

    expect(find.text('Result 1'), findsOneWidget);
  });

  testWidgets('SearchScreen shows error on failure and can retry', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          searchMoviesUseCaseProvider.overrideWith((ref) => SearchMovies(FakeMovieRepository())),
          authProvider.overrideWith((ref) {
            return AuthNotifier(
              signIn: mockSignIn,
              signUp: mockSignUp,
              signOut: mockSignOut,
              getCurrentUser: mockGetCurrentUser,
              authRepository: mockAuthRepository,
            );
          }),
          getFavoriteMoviesProvider.overrideWithValue(mockGetFavoriteMovies),
          addToFavoritesProvider.overrideWithValue(mockAddToFavorites),
          removeFromFavoritesProvider.overrideWithValue(mockRemoveFromFavorites),
          isFavoriteProvider.overrideWithValue(mockIsFavorite),
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
    await tester.pumpAndSettle();

    await tester.tap(find.byType(TextField));
    await tester.pump();
    await tester.enterText(find.byType(TextField), 'error');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.error_outline), findsOneWidget);
    expect(find.textContaining('Retry'), findsOneWidget);
  });
}
