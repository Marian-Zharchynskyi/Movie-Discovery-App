import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movie_discovery_app/shared/widgets/shimmers/movie_card_shimmer.dart';
import 'package:shimmer/shimmer.dart';

void main() {
  group('MovieCardShimmer', () {
    testWidgets('should display shimmer effect', (WidgetTester tester) async {
      // act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: MovieCardShimmer(),
          ),
        ),
      );

      // assert
      expect(find.byType(Shimmer), findsWidgets);
    });

    testWidgets('should display card structure', (WidgetTester tester) async {
      // act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: MovieCardShimmer(),
          ),
        ),
      );

      // assert
      expect(find.byType(Card), findsOneWidget);
    });

    testWidgets('should have multiple shimmer containers',
        (WidgetTester tester) async {
      // act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: MovieCardShimmer(),
          ),
        ),
      );

      // assert
      expect(find.byType(Container), findsWidgets);
    });
  });
}
