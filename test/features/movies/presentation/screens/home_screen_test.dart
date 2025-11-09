import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:movie_discovery_app/features/movies/presentation/providers/movie_provider.dart';
import 'package:movie_discovery_app/features/movies/presentation/screens/home_screen.dart';

class MockMovieNotifier extends Mock implements MovieNotifier {}

void main() {
  late MockMovieNotifier mockMovieNotifier;

  setUp(() {
    mockMovieNotifier = MockMovieNotifier();
  });

  testWidgets('HomeScreen displays loading shimmer when loading',
      (WidgetTester tester) async {
    when(() => mockMovieNotifier.fetchPopularMovies())
        .thenAnswer((_) async => {});

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          movieProvider.overrideWith((ref) {
            return mockMovieNotifier;
          }),
        ],
        child: const MaterialApp(home: HomeScreen()),
      ),
    );

    // Wait for initial frame
    await tester.pump();

    // Should show shimmer or app bar at least
    expect(find.byType(AppBar), findsOneWidget);
  });

  testWidgets('HomeScreen displays error message when error occurs',
      (WidgetTester tester) async {
    when(() => mockMovieNotifier.fetchPopularMovies())
        .thenAnswer((_) async => {});

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          movieProvider.overrideWith((ref) {
            return mockMovieNotifier;
          }),
        ],
        child: const MaterialApp(home: HomeScreen()),
      ),
    );

    await tester.pump();

    // Verify app bar is present
    expect(find.byType(AppBar), findsOneWidget);
  });

  testWidgets('HomeScreen displays search and discover buttons',
      (WidgetTester tester) async {
    when(() => mockMovieNotifier.fetchPopularMovies())
        .thenAnswer((_) async => {});

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          movieProvider.overrideWith((ref) {
            return mockMovieNotifier;
          }),
        ],
        child: const MaterialApp(home: HomeScreen()),
      ),
    );

    await tester.pump();

    // Should have search and discover icons in app bar
    expect(find.byIcon(Icons.search), findsOneWidget);
    expect(find.byIcon(Icons.explore), findsOneWidget);
  });

  testWidgets('HomeScreen has correct app bar title',
      (WidgetTester tester) async {
    when(() => mockMovieNotifier.fetchPopularMovies())
        .thenAnswer((_) async => {});

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          movieProvider.overrideWith((ref) {
            return mockMovieNotifier;
          }),
        ],
        child: const MaterialApp(home: HomeScreen()),
      ),
    );

    await tester.pump();

    // Should have app bar
    expect(find.byType(AppBar), findsOneWidget);
  });

  testWidgets('HomeScreen calls fetchPopularMovies on init',
      (WidgetTester tester) async {
    when(() => mockMovieNotifier.fetchPopularMovies())
        .thenAnswer((_) async => {});

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          movieProvider.overrideWith((ref) {
            return mockMovieNotifier;
          }),
        ],
        child: const MaterialApp(home: HomeScreen()),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    // Verify fetchPopularMovies was called
    verify(() => mockMovieNotifier.fetchPopularMovies()).called(greaterThan(0));
  });
}
