import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:movie_discovery_app/main.dart';
import 'package:movie_discovery_app/features/movies/domain/usecases/get_popular_movies.dart';
import 'package:movie_discovery_app/features/movies/presentation/providers/movie_provider.dart';
import 'package:movie_discovery_app/features/movies/presentation/screens/home_screen.dart';

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

    // Build our app with the real provider but with mocked dependencies
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          getPopularMoviesProvider.overrideWithValue(mockGetPopularMovies),
        ],
        child: const MaterialApp(
          home: MovieDiscoveryApp(),
        ),
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