import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movie_discovery_app/shared/widgets/rating_stars.dart';

void main() {
  testWidgets('RatingStars displays 5 full stars for rating 10', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: RatingStars(rating10: 10.0),
        ),
      ),
    );

    expect(find.byIcon(Icons.star), findsNWidgets(5));
    expect(find.byIcon(Icons.star_half), findsNothing);
    expect(find.byIcon(Icons.star_border), findsNothing);
  });

  testWidgets('RatingStars displays 4 full stars and 1 half star for rating 9', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: RatingStars(rating10: 9.0),
        ),
      ),
    );

    expect(find.byIcon(Icons.star), findsNWidgets(4));
    expect(find.byIcon(Icons.star_half), findsOneWidget);
    expect(find.byIcon(Icons.star_border), findsNothing);
  });

  testWidgets('RatingStars displays 3 full stars and 2 empty stars for rating 6', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: RatingStars(rating10: 6.0),
        ),
      ),
    );

    expect(find.byIcon(Icons.star), findsNWidgets(3));
    expect(find.byIcon(Icons.star_half), findsNothing);
    expect(find.byIcon(Icons.star_border), findsNWidgets(2));
  });

  testWidgets('RatingStars displays no stars for rating 0', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: RatingStars(rating10: 0.0),
        ),
      ),
    );

    expect(find.byIcon(Icons.star), findsNothing);
    expect(find.byIcon(Icons.star_half), findsNothing);
    expect(find.byIcon(Icons.star_border), findsNWidgets(5));
  });

  testWidgets('RatingStars displays with custom size', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: RatingStars(rating10: 8.0, size: 24),
        ),
      ),
    );

    final starIcon = tester.widget<Icon>(find.byIcon(Icons.star).first);
    expect(starIcon.size, 24);
  });

  testWidgets('RatingStars displays with custom color', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: RatingStars(rating10: 8.0, color: Colors.red),
        ),
      ),
    );

    final starIcon = tester.widget<Icon>(find.byIcon(Icons.star).first);
    expect(starIcon.color, Colors.red);
  });
}
