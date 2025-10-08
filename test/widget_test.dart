import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:movie_discovery_app/core/router/app_router.dart';
import 'package:movie_discovery_app/features/movies/domain/usecases/get_popular_movies.dart';
import 'package:movie_discovery_app/features/movies/presentation/providers/movie_provider.dart';
import 'package:movie_discovery_app/features/movies/presentation/screens/home_screen.dart';
import 'package:movie_discovery_app/features/settings/presentation/providers/settings_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:movie_discovery_app/main.dart';

// Mock GetPopularMovies
class MockGetPopularMovies extends Mock implements GetPopularMovies {}

void main() {
  late MockGetPopularMovies mockGetPopularMovies;

  setUp(() {
    mockGetPopularMovies = MockGetPopularMovies();
  });

  testWidgets('App should show HomeScreen on startup', (WidgetTester tester) async {
    // Setup mock response
    when(() => mockGetPopularMovies())
        .thenAnswer((_) async => const Right([]));

    // Build our app with provider overrides
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          getPopularMoviesProvider.overrideWithValue(mockGetPopularMovies),
          // Provide in-memory SharedPreferences to settings provider stack
          sharedPrefsProvider.overrideWithValue(prefs),
          // Force router to start at /home without auth redirects
          goRouterProvider.overrideWith((ref) => GoRouter(
                initialLocation: '/home',
                routes: [
                  GoRoute(
                    path: '/home',
                    name: 'home',
                    builder: (context, state) => const HomeScreen(),
                  ),
                ],
              )),
        ],
        child: const MovieDiscoveryApp(),
      ),
    );
    
    // Wait for the first frame
    await tester.pump();
    
    // Wait for any remaining animations
    await tester.pumpAndSettle();
    
    // Verify HomeScreen is displayed
    expect(find.byType(HomeScreen), findsOneWidget);
    
    // Verify the AppBar title is displayed
    expect(find.text('Popular Movies'), findsOneWidget);
  });
}