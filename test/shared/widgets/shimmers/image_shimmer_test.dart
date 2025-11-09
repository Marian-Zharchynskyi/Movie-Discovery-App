import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movie_discovery_app/shared/widgets/shimmers/image_shimmer.dart';
import 'package:shimmer/shimmer.dart';

void main() {
  group('ImageShimmer', () {
    testWidgets('should display shimmer effect', (WidgetTester tester) async {
      // act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ImageShimmer(width: 100, height: 150),
          ),
        ),
      );

      // assert
      expect(find.byType(Shimmer), findsOneWidget);
    });

    testWidgets('should use provided width and height',
        (WidgetTester tester) async {
      // act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ImageShimmer(width: 200, height: 300),
          ),
        ),
      );

      // assert
      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(Shimmer),
          matching: find.byType(Container),
        ),
      );
      expect(container.constraints?.maxWidth, 200);
      expect(container.constraints?.maxHeight, 300);
    });

    testWidgets('should have rounded corners', (WidgetTester tester) async {
      // act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ImageShimmer(width: 100, height: 150),
          ),
        ),
      );

      // assert
      expect(find.byType(ClipRRect), findsOneWidget);
    });
  });
}
