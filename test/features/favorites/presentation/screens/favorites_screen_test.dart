import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:movie_discovery_app/core/error/failures.dart';
import 'package:movie_discovery_app/features/favorites/domain/entities/favorite_movie_entity.dart';
import 'package:movie_discovery_app/features/favorites/domain/repositories/favorites_repository.dart';
import 'package:movie_discovery_app/features/favorites/domain/usecases/add_to_favorites.dart';
import 'package:movie_discovery_app/features/favorites/domain/usecases/get_favorite_movies.dart';
import 'package:movie_discovery_app/features/favorites/domain/usecases/is_favorite.dart';
import 'package:movie_discovery_app/features/favorites/domain/usecases/remove_from_favorites.dart';
import 'package:movie_discovery_app/features/favorites/presentation/providers/favorites_cubit.dart';
import 'package:movie_discovery_app/features/favorites/presentation/screens/favorites_screen.dart';
import 'package:movie_discovery_app/l10n/app_localizations.dart';

class FakeFavoritesRepository implements FavoritesRepository {
  FakeFavoritesRepository({
    required this.getter,
    this.onAdd,
    this.onRemove,
    this.onIsFavorite,
  });

  final Future<Either<Failure, List<FavoriteMovieEntity>>> Function() getter;
  final Future<Either<Failure, bool>> Function(FavoriteMovieEntity movie)? onAdd;
  final Future<Either<Failure, bool>> Function(int movieId)? onRemove;
  final Future<Either<Failure, bool>> Function(int movieId)? onIsFavorite;

  @override
  Future<Either<Failure, List<FavoriteMovieEntity>>> getFavoriteMovies() => getter();

  @override
  Future<Either<Failure, bool>> addToFavorites(FavoriteMovieEntity movie) async =>
      onAdd != null ? await onAdd!(movie) : const Right(true);

  @override
  Future<Either<Failure, bool>> removeFromFavorites(int movieId) async =>
      onRemove != null ? await onRemove!(movieId) : const Right(true);

  @override
  Future<Either<Failure, bool>> isFavorite(int movieId) async =>
      onIsFavorite != null ? await onIsFavorite!(movieId) : const Right(false);
}

Widget _buildApp({required FavoritesRepository repo}) {
  return ProviderScope(
    overrides: [
      getFavoriteMoviesProvider.overrideWithValue(GetFavoriteMovies(repo)),
      addToFavoritesProvider.overrideWithValue(AddToFavorites(repo)),
      removeFromFavoritesProvider.overrideWithValue(RemoveFromFavorites(repo)),
      isFavoriteProvider.overrideWithValue(IsFavorite(repo)),
    ],
    child: const MaterialApp(
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: FavoritesScreen(),
    ),
  );
}

void main() {
  final tMovie = FavoriteMovieEntity(
    id: 1,
    title: 'Fav 1',
    overview: 'o',
    posterPath: '/p.jpg',
    voteAverage: 8.0,
    releaseDate: '2024-01-01',
    genreIds: const [28],
    dateAdded: DateTime(2024, 1, 1),
  );

  testWidgets('FavoritesScreen renders and shows empty state', (tester) async {
    final repo = FakeFavoritesRepository(
      getter: () async => const Right(<FavoriteMovieEntity>[]),
    );

    await tester.pumpWidget(_buildApp(repo: repo));
    await tester.pump();

    expect(find.byIcon(Icons.favorite_border), findsOneWidget);
    expect(find.textContaining('No'), findsWidgets);
  });

  testWidgets('shows loading indicator while loading', (tester) async {
    final repo = FakeFavoritesRepository(getter: () async {
      await Future.delayed(const Duration(milliseconds: 300));
      return const Right(<FavoriteMovieEntity>[]);
    });

    await tester.pumpWidget(_buildApp(repo: repo));
    // First frame (after post frame callback triggers), show progress
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    // Finish the delayed future
    await tester.pumpAndSettle();
  });

  testWidgets('shows empty state when no favorites', (tester) async {
    final repo = FakeFavoritesRepository(
      getter: () async => const Right(<FavoriteMovieEntity>[]),
    );

    await tester.pumpWidget(_buildApp(repo: repo));
    await tester.pumpAndSettle();

    expect(find.text('No favorites yet'), findsOneWidget);
  });

  testWidgets('shows error state when load fails', (tester) async {
    final repo = FakeFavoritesRepository(
      getter: () async => const Left(ServerFailure('Oops')),
    );

    await tester.pumpWidget(_buildApp(repo: repo));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.error_outline), findsOneWidget);
    expect(find.text('Error loading favorites'), findsOneWidget);
    expect(find.text('Oops'), findsOneWidget);
  });

  testWidgets('renders list when favorites available and supports pull-to-refresh', (tester) async {
    final repo = FakeFavoritesRepository(
      getter: () async => Right(<FavoriteMovieEntity>[tMovie]),
      onRemove: (id) async => const Right(true),
    );

    await tester.pumpWidget(_buildApp(repo: repo));
    await tester.pumpAndSettle();

    expect(find.text('Fav 1'), findsOneWidget);
    expect(find.byType(ListView), findsOneWidget);

    // Trigger pull-to-refresh gesture to ensure onRefresh path runs without crash
    final listFinder = find.byType(ListView);
    await tester.drag(listFinder, const Offset(0, 300));
    await tester.pump();
  });
}
