import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dartz/dartz.dart';
import 'package:movie_discovery_app/core/error/failures.dart';
import 'package:movie_discovery_app/core/router/app_router.dart';
import 'package:movie_discovery_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:movie_discovery_app/features/auth/domain/entities/user_entity.dart';
import 'package:movie_discovery_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:movie_discovery_app/features/auth/domain/usecases/get_current_user.dart';
import 'package:movie_discovery_app/features/auth/domain/usecases/sign_in.dart';
import 'package:movie_discovery_app/features/auth/domain/usecases/sign_out.dart';
import 'package:movie_discovery_app/features/auth/domain/usecases/sign_up.dart';
import 'package:movie_discovery_app/features/auth/presentation/screens/login_screen.dart';
import 'package:movie_discovery_app/features/movies/presentation/screens/home_screen.dart';
import 'package:movie_discovery_app/features/movies/presentation/providers/movie_provider.dart';
import 'package:movie_discovery_app/features/movies/domain/usecases/get_popular_movies.dart';
import 'package:movie_discovery_app/features/movies/domain/repositories/movie_repository.dart';
import 'package:movie_discovery_app/features/movies/domain/entities/movie_entity.dart';
import 'package:movie_discovery_app/features/movies/domain/entities/video_entity.dart';
import 'package:movie_discovery_app/features/movies/domain/entities/review_entity.dart';
// Do not import the real AdminUsersScreen to avoid Firebase dependency in tests
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:movie_discovery_app/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';

class _FakeAuthRepository implements AuthRepository {
  _FakeAuthRepository(this._user);
  UserEntity? _user;

  @override
  Stream<UserEntity?> get authStateChanges => Stream<UserEntity?>.value(_user);

  @override
  Future<Either<Failure, void>> clearToken() async => const Right(null);

  @override
  Future<Either<Failure, UserEntity?>> getCurrentUser() async => Right(_user);

  @override
  Future<Either<Failure, String?>> getStoredToken() async => const Right(null);

  @override
  Future<Either<Failure, void>> storeToken(String token) async => const Right(null);

  @override
  Future<Either<Failure, UserEntity>> signInWithEmailAndPassword({required String email, required String password}) async {
    _user = UserEntity(id: '1', email: email);
    return Right(_user!);
  }

  @override
  Future<Either<Failure, UserEntity>> signUpWithEmailAndPassword({required String email, required String password, String? displayName}) async {
    _user = UserEntity(id: '1', email: email, displayName: displayName);
    return Right(_user!);
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    _user = null;
    return const Right(null);
  }
}

class _ShellApp extends ConsumerStatefulWidget {
  const _ShellApp({required this.initialAuthState, this.goToAfterBuild});
  final AuthState initialAuthState;
  final String? goToAfterBuild;

  @override
  ConsumerState<_ShellApp> createState() => _ShellAppState();
}

class _ShellAppState extends ConsumerState<_ShellApp> {
  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      overrides: [
        authProvider.overrideWith((ref) {
          final fakeRepo = _FakeAuthRepository(widget.initialAuthState.user);
          return AuthNotifier(
            signIn: SignIn(fakeRepo),
            signUp: SignUp(fakeRepo),
            signOut: SignOut(fakeRepo),
            getCurrentUser: GetCurrentUser(fakeRepo),
            authRepository: fakeRepo,
          );
        }),
        // Keep HomeScreen lightweight by overriding movieProvider
        movieProvider.overrideWith((ref) => MovieNotifier(GetPopularMovies(_FakeMovieRepository()))),
        // Override router to set desired initialLocation without imperative go()
        goRouterProvider.overrideWith((ref) {
          final authState = ref.watch(authProvider);
          return GoRouter(
            initialLocation: widget.goToAfterBuild ?? '/login',
            redirect: (context, state) {
              final isAuthenticated = authState.isAuthenticated;
              final isAdmin = authState.user?.role == 'Admin';
              final isLoggingIn = state.matchedLocation == '/login' || state.matchedLocation == '/register';

              if (!isAuthenticated && !isLoggingIn) return '/login';
              if (isAuthenticated && isLoggingIn) return '/home';

              final isAdminRoute = state.matchedLocation.startsWith('/admin');
              if (isAdminRoute && !isAdmin) return '/home';

              return null;
            },
            routes: [
              GoRoute(
                path: '/login',
                name: 'login',
                builder: (context, state) => const LoginScreen(),
              ),
              ShellRoute(
                builder: (context, state, child) => MainShell(child: child),
                routes: [
                  GoRoute(
                    path: '/home',
                    name: 'home',
                    builder: (context, state) => const HomeScreen(),
                  ),
                  GoRoute(
                    path: '/admin/users',
                    name: 'admin_users',
                    builder: (context, state) => const _AdminUsersTestPlaceholder(),
                  ),
                ],
              ),
            ],
          );
        }),
      ],
      child: Consumer(
        builder: (context, ref, _) {
          final router = ref.watch(goRouterProvider);
          return MaterialApp.router(
            routerConfig: router,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: AppLocalizations.supportedLocales,
          );
        },
      ),
    );
  }
}

class _AdminUsersTestPlaceholder extends StatelessWidget {
  const _AdminUsersTestPlaceholder();
  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text('Admin Test Screen')));
  }
}

class _FakeMovieRepository implements MovieRepository {
  @override
  Future<Either<Failure, List<MovieEntity>>> getPopularMovies({int page = 1}) async => const Right([]);

  @override
  Future<Either<Failure, List<MovieEntity>>> getTopRatedMovies({int page = 1}) async => const Right([]);

  @override
  Future<Either<Failure, MovieEntity>> getMovieDetails(int movieId) async => Left(ServerFailure('x'));

  @override
  Future<Either<Failure, List<VideoEntity>>> getMovieVideos(int movieId) async => const Right([]);

  @override
  Future<Either<Failure, List<ReviewEntity>>> getMovieReviews(int movieId, {int page = 1}) async => const Right([]);

  @override
  Future<Either<Failure, List<MovieEntity>>> discoverMovies({int page = 1, List<int>? genreIds, int? year, double? minRating}) async => const Right([]);

  @override
  Future<Either<Failure, List<MovieEntity>>> searchMovies(String query, {int page = 1}) async => const Right([]);
}

void main() {
  testWidgets('unauthenticated user sees LoginScreen', (tester) async {
    final unauth = AuthState(isAuthenticated: false, user: null);

    await tester.pumpWidget(_ShellApp(initialAuthState: unauth));
    await tester.pump();

    expect(find.byType(LoginScreen), findsOneWidget);
  });

  testWidgets('authenticated user is redirected to HomeScreen from /login', (tester) async {
    final auth = AuthState(
      isAuthenticated: true,
      user: const UserEntity(id: '1', email: 'u@example.com'),
    );

    await tester.pumpWidget(_ShellApp(initialAuthState: auth));
    await tester.pumpAndSettle();

    expect(find.byType(HomeScreen), findsOneWidget);
  });

  testWidgets('non-admin blocked from /admin/users and redirected to /home', (tester) async {
    final user = AuthState(
      isAuthenticated: true,
      user: const UserEntity(id: '1', email: 'u@example.com', role: 'User'),
    );

    await tester.pumpWidget(_ShellApp(initialAuthState: user, goToAfterBuild: '/admin/users'));
    await tester.pumpAndSettle();

    // Should land on home
    expect(find.byType(HomeScreen), findsOneWidget);
  });

  testWidgets('admin can access /admin/users', (tester) async {
    final admin = AuthState(
      isAuthenticated: true,
      user: const UserEntity(id: '2', email: 'a@example.com', role: 'Admin'),
    );

    await tester.pumpWidget(_ShellApp(initialAuthState: admin, goToAfterBuild: '/admin/users'));
    await tester.pumpAndSettle();

    expect(find.text('Admin Test Screen'), findsOneWidget);
  });
}
