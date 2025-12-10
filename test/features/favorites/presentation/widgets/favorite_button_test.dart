import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:movie_discovery_app/features/favorites/presentation/providers/favorites_cubit.dart';
import 'package:movie_discovery_app/features/favorites/presentation/widgets/favorite_button.dart';
import 'package:movie_discovery_app/features/movies/domain/entities/movie_entity.dart';

import 'favorite_button_test.mocks.dart';

@GenerateMocks([FavoritesNotifier])
void main() {
  late MockFavoritesNotifier mockFavoritesNotifier;

  setUp(() {
    mockFavoritesNotifier = MockFavoritesNotifier();
  });

  final tMovie = MovieEntity(
    id: 1,
    title: 'Test Movie',
    overview: 'Test overview',
    posterPath: '/test.jpg',
    backdropPath: '/backdrop.jpg',
    voteAverage: 8.5,
    releaseDate: '2024-01-01',
    genreIds: const [1, 2],
  );

  Widget createWidgetUnderTest() {
    return ProviderScope(
      overrides: [
        favoritesProvider.overrideWith((ref) => mockFavoritesNotifier),
      ],
      child: MaterialApp(
        home: Scaffold(
          body: FavoriteButton(movie: tMovie),
        ),
      ),
    );
  }

  group('FavoriteButton', () {
    testWidgets('should display favorite_border icon when not favorite',
        (WidgetTester tester) async {
      // arrange
      when(mockFavoritesNotifier.isFavorite(any))
          .thenAnswer((_) async => false);

      // act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // assert
      expect(find.byIcon(Icons.favorite_border), findsOneWidget);
      expect(find.byIcon(Icons.favorite), findsNothing);
    });

    testWidgets('should display favorite icon when is favorite',
        (WidgetTester tester) async {
      // arrange
      when(mockFavoritesNotifier.isFavorite(any))
          .thenAnswer((_) async => true);

      // act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // assert
      expect(find.byIcon(Icons.favorite), findsOneWidget);
      expect(find.byIcon(Icons.favorite_border), findsNothing);
    });

    testWidgets('should show loading indicator when checking favorite status',
        (WidgetTester tester) async {
      // arrange
      when(mockFavoritesNotifier.isFavorite(any))
          .thenAnswer((_) async {
        await Future.delayed(const Duration(milliseconds: 100));
        return false;
      });

      // act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      // assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      // Allow the delayed future to complete to avoid pending timers at test end
      await tester.pump(const Duration(milliseconds: 200));
    });

    testWidgets('should toggle favorite when tapped',
        (WidgetTester tester) async {
      // arrange
      when(mockFavoritesNotifier.isFavorite(any))
          .thenAnswer((_) async => false);
      when(mockFavoritesNotifier.addMovieToFavorites(any))
          .thenAnswer((_) async => true);

      // act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      await tester.tap(find.byType(IconButton));
      await tester.pumpAndSettle();

      // assert
      verify(mockFavoritesNotifier.addMovieToFavorites(any)).called(1);
    });

    testWidgets('should show snackbar when adding to favorites succeeds',
        (WidgetTester tester) async {
      // arrange
      when(mockFavoritesNotifier.isFavorite(any))
          .thenAnswer((_) async => false);
      when(mockFavoritesNotifier.addMovieToFavorites(any))
          .thenAnswer((_) async => true);

      // act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      await tester.tap(find.byType(IconButton));
      await tester.pumpAndSettle();

      // assert
      expect(find.text('Added to favorites'), findsOneWidget);
    });

    testWidgets('should show error snackbar when adding to favorites fails',
        (WidgetTester tester) async {
      // arrange
      when(mockFavoritesNotifier.isFavorite(any))
          .thenAnswer((_) async => false);
      when(mockFavoritesNotifier.addMovieToFavorites(any))
          .thenAnswer((_) async => false);

      // act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      await tester.tap(find.byType(IconButton));
      await tester.pumpAndSettle();

      // assert
      expect(find.text('Failed to add to favorites'), findsOneWidget);
    });

    testWidgets('should remove from favorites when already favorite',
        (WidgetTester tester) async {
      // arrange
      when(mockFavoritesNotifier.isFavorite(any))
          .thenAnswer((_) async => true);
      when(mockFavoritesNotifier.removeFromFavorites(any))
          .thenAnswer((_) async => true);

      // act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      await tester.tap(find.byType(IconButton));
      await tester.pumpAndSettle();

      // assert
      verify(mockFavoritesNotifier.removeFromFavorites(tMovie.id)).called(1);
      expect(find.text('Removed from favorites'), findsOneWidget);
    });

    testWidgets('should use custom size',
        (WidgetTester tester) async {
      // arrange
      when(mockFavoritesNotifier.isFavorite(any))
          .thenAnswer((_) async => false);

      // act
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            favoritesProvider.overrideWith((ref) => mockFavoritesNotifier),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: FavoriteButton(movie: tMovie, size: 48.0),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // assert
      final icon = tester.widget<Icon>(find.byIcon(Icons.favorite_border));
      expect(icon.size, 48.0);
    });
  });
}
