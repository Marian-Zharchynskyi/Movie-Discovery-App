import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movie_discovery_app/core/error/failures.dart';
import 'package:movie_discovery_app/features/favorites/domain/entities/favorite_movie_entity.dart';
import 'package:movie_discovery_app/features/favorites/domain/repositories/favorites_repository.dart';
import 'package:movie_discovery_app/features/favorites/domain/usecases/add_to_favorites.dart';
import 'package:movie_discovery_app/features/favorites/domain/usecases/get_favorite_movies.dart';
import 'package:movie_discovery_app/features/favorites/domain/usecases/is_favorite.dart';
import 'package:movie_discovery_app/features/favorites/domain/usecases/remove_from_favorites.dart';
import 'package:movie_discovery_app/features/favorites/presentation/providers/favorites_cubit.dart';
import 'package:movie_discovery_app/features/favorites/presentation/screens/favorites_screen.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:movie_discovery_app/l10n/app_localizations.dart';

class FakeFavoritesRepository implements FavoritesRepository {
  List<FavoriteMovieEntity> store = const [];

  @override
  Future<Either<Failure, List<FavoriteMovieEntity>>> getFavoriteMovies() async => Right(store);
  @override
  Future<Either<Failure, bool>> addToFavorites(FavoriteMovieEntity movie) async {
    store = [...store, movie];
    return const Right(true);
  }
  @override
  Future<Either<Failure, bool>> removeFromFavorites(int movieId) async {
    store = store.where((m) => m.id != movieId).toList();
    return const Right(true);
  }
  @override
  Future<Either<Failure, bool>> isFavorite(int movieId) async => Right(store.any((m) => m.id == movieId));
}

void main() {
  testWidgets('FavoritesScreen renders and shows empty state', (tester) async {
    final repo = FakeFavoritesRepository();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          getFavoriteMoviesProvider.overrideWith((ref) => GetFavoriteMovies(repo)),
          addToFavoritesProvider.overrideWith((ref) => AddToFavorites(repo)),
          removeFromFavoritesProvider.overrideWith((ref) => RemoveFromFavorites(repo)),
          isFavoriteProvider.overrideWith((ref) => IsFavorite(repo)),
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
      ),
    );

    await tester.pump();

    expect(find.byIcon(Icons.favorite_border), findsOneWidget);
    expect(find.textContaining('No'), findsWidgets);
  });
}
