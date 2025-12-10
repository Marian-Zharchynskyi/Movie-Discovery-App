import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movie_discovery_app/features/favorites/domain/entities/favorite_movie_entity.dart';
import 'package:movie_discovery_app/features/favorites/presentation/widgets/favorite_movie_item.dart';

void main() {
  final tMovie = FavoriteMovieEntity(
    id: 1,
    title: 'Test Movie',
    overview: 'This is a test movie overview',
    posterPath: '/test.jpg',
    backdropPath: '/backdrop.jpg',
    voteAverage: 8.5,
    releaseDate: '2024-01-15',
    genreIds: const [1, 2],
    dateAdded: DateTime(2024, 1, 1),
  );

  Widget createWidgetUnderTest({VoidCallback? onRemove}) {
    return ProviderScope(
      child: MaterialApp(
        home: Scaffold(
          body: FavoriteMovieItem(
            movie: tMovie,
            onRemove: onRemove,
          ),
        ),
      ),
    );
  }

  group('FavoriteMovieItem', () {
    testWidgets('should display movie title', (WidgetTester tester) async {
      // act
      await tester.pumpWidget(createWidgetUnderTest());

      // assert
      expect(find.text('Test Movie'), findsOneWidget);
    });

    testWidgets('should display movie overview', (WidgetTester tester) async {
      // act
      await tester.pumpWidget(createWidgetUnderTest());

      // assert
      expect(find.text('This is a test movie overview'), findsOneWidget);
    });

    testWidgets('should display vote average', (WidgetTester tester) async {
      // act
      await tester.pumpWidget(createWidgetUnderTest());

      // assert
      expect(find.text('8.5'), findsOneWidget);
      expect(find.byIcon(Icons.star), findsOneWidget);
    });

    testWidgets('should display formatted release date',
        (WidgetTester tester) async {
      // act
      await tester.pumpWidget(createWidgetUnderTest());

      // assert
      expect(find.textContaining('Jan'), findsOneWidget);
      expect(find.byIcon(Icons.calendar_today), findsOneWidget);
    });

    testWidgets('should be dismissible', (WidgetTester tester) async {
      // act
      await tester.pumpWidget(createWidgetUnderTest());

      // assert
      expect(find.byType(Dismissible), findsOneWidget);
    });

    testWidgets('should show delete icon in background when swiping',
        (WidgetTester tester) async {
      // act
      await tester.pumpWidget(createWidgetUnderTest());
      
      // Start swipe but don't complete it
      await tester.drag(find.byType(Dismissible), const Offset(-100, 0));
      await tester.pump();

      // assert
      expect(find.byIcon(Icons.delete), findsOneWidget);
    });

    testWidgets('should call onRemove when dismissed',
        (WidgetTester tester) async {
      // arrange
      bool removeCalled = false;
      void onRemove() {
        removeCalled = true;
      }

      // act
      await tester.pumpWidget(createWidgetUnderTest(onRemove: onRemove));
      await tester.drag(find.byType(Dismissible), const Offset(-500, 0));
      await tester.pumpAndSettle();

      // assert
      expect(removeCalled, true);
    });

    testWidgets('should display card with proper styling',
        (WidgetTester tester) async {
      // act
      await tester.pumpWidget(createWidgetUnderTest());

      // assert
      expect(find.byType(Card), findsOneWidget);
      final card = tester.widget<Card>(find.byType(Card));
      expect(card.elevation, 2);
    });

    testWidgets('should have hero animation for poster',
        (WidgetTester tester) async {
      // act
      await tester.pumpWidget(createWidgetUnderTest());

      // assert
      expect(find.byType(Hero), findsOneWidget);
      final hero = tester.widget<Hero>(find.byType(Hero));
      expect(hero.tag, 'moviePoster_1');
    });

    testWidgets('should be tappable', (WidgetTester tester) async {
      // act
      await tester.pumpWidget(createWidgetUnderTest());

      // assert
      expect(find.byType(InkWell), findsOneWidget);
    });

    testWidgets('should display N/A for empty release date',
        (WidgetTester tester) async {
      // arrange
      final movieWithoutDate = FavoriteMovieEntity(
        id: 1,
        title: 'Test Movie',
        overview: 'Overview',
        posterPath: '/test.jpg',
        backdropPath: '/backdrop.jpg',
        voteAverage: 8.5,
        releaseDate: '',
        genreIds: const [1, 2],
        dateAdded: DateTime(2024, 1, 1),
      );

      // act
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: FavoriteMovieItem(movie: movieWithoutDate),
            ),
          ),
        ),
      );

      // assert
      expect(find.text('N/A'), findsOneWidget);
    });
  });
}
