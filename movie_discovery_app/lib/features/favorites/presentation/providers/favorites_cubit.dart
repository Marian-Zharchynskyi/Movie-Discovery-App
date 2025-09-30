import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:movie_discovery_app/core/injection_container.dart';
import 'package:movie_discovery_app/features/favorites/domain/entities/favorite_movie_entity.dart';
import 'package:movie_discovery_app/features/favorites/domain/usecases/add_to_favorites.dart';
import 'package:movie_discovery_app/features/favorites/domain/usecases/get_favorite_movies.dart';
import 'package:movie_discovery_app/features/favorites/domain/usecases/is_favorite.dart';
import 'package:movie_discovery_app/features/favorites/domain/usecases/remove_from_favorites.dart';

final getFavoriteMoviesProvider = Provider<GetFavoriteMovies>((ref) {
  return sl<GetFavoriteMovies>();
});

final addToFavoritesProvider = Provider<AddToFavorites>((ref) {
  return sl<AddToFavorites>();
});

final removeFromFavoritesProvider = Provider<RemoveFromFavorites>((ref) {
  return sl<RemoveFromFavorites>();
});

final isFavoriteProvider = Provider<IsFavorite>((ref) {
  return sl<IsFavorite>();
});

class FavoritesState {
  final List<FavoriteMovieEntity> favoriteMovies;
  final bool isLoading;
  final String? error;

  const FavoritesState({
    this.favoriteMovies = const [],
    this.isLoading = false,
    this.error,
  });

  const FavoritesState.initial() : this();

  FavoritesState copyWith({
    List<FavoriteMovieEntity>? favoriteMovies,
    bool? isLoading,
    String? error,
  }) {
    return FavoritesState(
      favoriteMovies: favoriteMovies ?? this.favoriteMovies,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

final favoritesProvider =
    StateNotifierProvider<FavoritesNotifier, FavoritesState>((ref) {
  return FavoritesNotifier(
    getFavoriteMovies: ref.watch(getFavoriteMoviesProvider),
    addToFavorites: ref.watch(addToFavoritesProvider),
    removeFromFavorites: ref.watch(removeFromFavoritesProvider),
    isFavorite: ref.watch(isFavoriteProvider),
  );
});

class FavoritesNotifier extends StateNotifier<FavoritesState> {
  final GetFavoriteMovies getFavoriteMovies;
  final AddToFavorites addToFavorites;
  final RemoveFromFavorites removeFromFavorites;
  final IsFavorite isFavorite;

  FavoritesNotifier({
    required this.getFavoriteMovies,
    required this.addToFavorites,
    required this.removeFromFavorites,
    required this.isFavorite,
  }) : super(const FavoritesState.initial());

  Future<void> loadFavoriteMovies() async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await getFavoriteMovies();

    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        error: failure.message,
      ),
      (movies) => state = state.copyWith(
        favoriteMovies: movies,
        isLoading: false,
        error: null,
      ),
    );
  }

  Future<bool> addMovieToFavorites(FavoriteMovieEntity movie) async {
    final result = await addToFavorites(movie);

    return result.fold(
      (failure) {
        state = state.copyWith(error: failure.message);
        return false;
      },
      (success) {
        if (success) {
          loadFavoriteMovies();
        }
        return success;
      },
    );
  }

  Future<bool> removeMovieFromFavorites(int movieId) async {
    final result = await removeFromFavorites(movieId);

    return result.fold(
      (failure) {
        state = state.copyWith(error: failure.message);
        return false;
      },
      (success) {
        if (success) {
          loadFavoriteMovies();
        }
        return success;
      },
    );
  }

  Future<bool> checkIsFavorite(int movieId) async {
    final result = await isFavorite(movieId);

    return result.fold(
      (failure) {
        state = state.copyWith(error: failure.message);
        return false;
      },
      (isFav) => isFav,
    );
  }
}
