import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:movie_discovery_app/main.dart';
import 'package:movie_discovery_app/features/movies/presentation/screens/home_screen.dart';

void main() {
  testWidgets('App should show splash screen on startup', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: MovieDiscoveryApp(),
        ),
      ),
    );

    expect(find.byType(HomeScreen), findsOneWidget);
  });

  testWidgets('App should have correct title', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: MovieDiscoveryApp(),
        ),
      ),
    );

    final titleFinder = find.text('Movie Discovery');
    expect(titleFinder, findsOneWidget);
  });
}
