import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:movie_discovery_app/core/injection_container.dart';
import 'package:movie_discovery_app/features/favorites/domain/entities/favorite_movie_entity.dart';
import 'package:movie_discovery_app/features/favorites/domain/usecases/add_to_favorites.dart';
import 'package:movie_discovery_app/features/favorites/domain/usecases/get_favorite_movies.dart';
import 'package:movie_discovery_app/features/favorites/domain/usecases/is_favorite.dart';
import 'package:movie_discovery_app/features/favorites/domain/usecases/remove_from_favorites.dart';

// Providers
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

// State
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

// State Notifier
class FavoritesNotifier extends StateNotifier<FavoritesState> {
  final GetFavoriteMovies _getFavoriteMovies;
  final AddToFavorites _addToFavorites;
  final RemoveFromFavorites _removeFromFavorites;
  final IsFavorite _isFavorite;

  FavoritesNotifier({
    required GetFavoriteMovies getFavoriteMovies,
    required AddToFavorites addToFavorites,
    required RemoveFromFavorites removeFromFavorites,
    required IsFavorite isFavorite,
  })  : _getFavoriteMovies = getFavoriteMovies,
        _addToFavorites = addToFavorites,
        _removeFromFavorites = removeFromFavorites,
        _isFavorite = isFavorite,
        super(const FavoritesState.initial());

  // Load all favorite movies
  Future<void> loadFavoriteMovies() async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _getFavoriteMovies();

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

  // Add a movie to favorites
  Future<bool> addMovieToFavorites(FavoriteMovieEntity movie) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      final result = await _addToFavorites(movie);

      return result.fold(
        (failure) {
          state = state.copyWith(
            isLoading: false,
            error: failure.message,
          );
          return false;
        },
        (success) {
                  // Add to local state if not already present
          if (!state.favoriteMovies.any((m) => m.id == movie.id)) {
            state = state.copyWith(
              favoriteMovies: [...state.favoriteMovies, movie],
              isLoading: false,
            );
          } else {
            state = state.copyWith(isLoading: false);
          }
          return true;
        },
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to add to favorites: $e',
      );
      return false;
    }
  }

  // Remove a movie from favorites
  Future<bool> removeFromFavorites(int movieId) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      final result = await _removeFromFavorites(movieId);

      return result.fold(
        (failure) {
          state = state.copyWith(
            isLoading: false,
            error: failure.message,
          );
          return false;
        },
        (success) {
          state = state.copyWith(
            favoriteMovies: state.favoriteMovies
                .where((movie) => movie.id != movieId)
                .toList(),
            isLoading: false,
          );
          return true;
        },
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to remove from favorites: $e',
      );
      return false;
    }
  }

  // Check if a movie is in favorites
  Future<bool> isFavorite(int movieId) async {
    try {
      final result = await _isFavorite(movieId);
      return result.fold(
        (failure) {
          state = state.copyWith(error: failure.message);
          return false;
        },
        (isFavorite) => isFavorite,
      );
    } catch (e) {
      state = state.copyWith(error: 'Failed to check favorite status: $e');
      return false;
    }
  }

  // Get a favorite movie by ID
  FavoriteMovieEntity? getFavoriteMovie(int movieId) {
    try {
      return state.favoriteMovies.firstWhere(
        (movie) => movie.id == movieId,
      );
    } catch (e) {
      return null;
    }
  }

  // Toggle favorite status
  Future<bool> toggleFavorite(FavoriteMovieEntity movie) async {
    final isCurrentlyFavorite = state.favoriteMovies.any((m) => m.id == movie.id);
    
    if (isCurrentlyFavorite) {
      return await removeFromFavorites(movie.id);
    } else {
      return await addMovieToFavorites(movie);
    }
  }
}

// Provider
final favoritesProvider = StateNotifierProvider<FavoritesNotifier, FavoritesState>((ref) {
  return FavoritesNotifier(
    getFavoriteMovies: ref.watch(getFavoriteMoviesProvider),
    addToFavorites: ref.watch(addToFavoritesProvider),
    removeFromFavorites: ref.watch(removeFromFavoritesProvider),
    isFavorite: ref.watch(isFavoriteProvider),
  );
});
