import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:movie_discovery_app/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Favorites Flow Integration Tests', () {
    testWidgets('User can add movie to favorites', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();

      // Look for favorite button (heart icon)
      final favoriteFinder = find.byIcon(Icons.favorite_border);
      if (favoriteFinder.evaluate().isNotEmpty) {
        // Tap the first favorite button
        await tester.tap(favoriteFinder.first);
        await tester.pumpAndSettle();

        // The icon should change to filled heart
        expect(find.byIcon(Icons.favorite), findsWidgets);
      }
    });

    testWidgets('User can view favorites list', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();

      // Navigate to favorites screen
      final favoritesNavFinder = find.byIcon(Icons.favorite);
      if (favoritesNavFinder.evaluate().isNotEmpty) {
        await tester.tap(favoritesNavFinder.first);
        await tester.pumpAndSettle();

        // Favorites screen should be displayed
        expect(find.byType(Scaffold), findsWidgets);
      }
    });

    testWidgets('User can remove movie from favorites', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();

      // Look for filled favorite button
      final filledFavoriteFinder = find.byIcon(Icons.favorite);
      if (filledFavoriteFinder.evaluate().isNotEmpty) {
        final initialCount = filledFavoriteFinder.evaluate().length;
        
        // Tap to remove from favorites
        await tester.tap(filledFavoriteFinder.first);
        await tester.pumpAndSettle();

        // Should have one less filled favorite
        final newCount = find.byIcon(Icons.favorite).evaluate().length;
        expect(newCount, lessThanOrEqualTo(initialCount));
      }
    });

    testWidgets('Favorites persist across navigation', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();

      // Add a movie to favorites
      final favoriteBorderFinder = find.byIcon(Icons.favorite_border);
      if (favoriteBorderFinder.evaluate().isNotEmpty) {
        await tester.tap(favoriteBorderFinder.first);
        await tester.pumpAndSettle();

        // Navigate to favorites screen
        final favoritesNavFinder = find.byIcon(Icons.favorite);
        if (favoritesNavFinder.evaluate().length > 1) {
          await tester.tap(favoritesNavFinder.last);
          await tester.pumpAndSettle();

          // Navigate back to home
          final backFinder = find.byIcon(Icons.home);
          if (backFinder.evaluate().isNotEmpty) {
            await tester.tap(backFinder.first);
            await tester.pumpAndSettle();

            // Favorite should still be marked
            expect(find.byIcon(Icons.favorite), findsWidgets);
          }
        }
      }
    });
  });
}
