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

class _Wrapped<T> {
  final T value;
  const _Wrapped(this.value);
}

class FavoritesState {
  final List<FavoriteMovieEntity> favoriteMovies;
  final bool isLoading;
  final String? error;
  final String? userId;

  const FavoritesState({
    this.favoriteMovies = const [],
    this.isLoading = false,
    this.error,
    this.userId,
  });

  const FavoritesState.initial() : this();

  FavoritesState copyWith({
    List<FavoriteMovieEntity>? favoriteMovies,
    Object? isLoading = const _Wrapped(null),
    Object? error = const _Wrapped(null),
    Object? userId = const _Wrapped(null),
  }) {
    return FavoritesState(
      favoriteMovies: favoriteMovies ?? this.favoriteMovies,
      isLoading: isLoading is _Wrapped
          ? (isLoading.value as bool? ?? this.isLoading)
          : isLoading as bool,
      error: error is _Wrapped
          ? (error.value as String? ?? this.error)
          : error as String?,
      userId: userId is _Wrapped
          ? (userId.value as String? ?? this.userId)
          : userId as String?,
    );
  }
}

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

  void setUserId(String? userId) {
    if (state.userId != userId) {
      state = state.copyWith(userId: userId, favoriteMovies: []);
      if (userId != null) {
        loadFavoriteMovies();
      }
    }
  }

  Future<void> loadFavoriteMovies() async {
    final userId = state.userId;
    if (userId == null) {
      state = state.copyWith(favoriteMovies: [], isLoading: false);
      return;
    }

    state = state.copyWith(isLoading: true, error: null);

    try {
      final result = await _getFavoriteMovies(userId);

      result.fold(
        (failure) {
          state = state.copyWith(
            isLoading: false,
            error: failure.message,
          );
        },
        (movies) {
          state = state.copyWith(
            favoriteMovies: movies,
            isLoading: false,
            error: null,
          );
        },
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<bool> addMovieToFavorites(FavoriteMovieEntity movie) async {
    final userId = state.userId;
    if (userId == null) return false;

    try {
      state = state.copyWith(isLoading: true, error: null);
      final result = await _addToFavorites(movie, userId);

      return result.fold(
        (failure) {
          state = state.copyWith(
            isLoading: false,
            error: failure.message,
          );
          return false;
        },
        (success) {
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
        error: e.toString(),
      );
      return false;
    }
  }

  Future<bool> removeFromFavorites(int movieId) async {
    final userId = state.userId;
    if (userId == null) return false;

    try {
      state = state.copyWith(isLoading: true, error: null);
      final result = await _removeFromFavorites(movieId, userId);

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
        error: e.toString(),
      );
      return false;
    }
  }

  Future<bool> isFavorite(int movieId) async {
    final userId = state.userId;
    if (userId == null) return false;

    try {
      final result = await _isFavorite(movieId, userId);
      return result.fold(
        (failure) {
          state = state.copyWith(error: failure.message);
          return false;
        },
        (isFavorite) => isFavorite,
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  FavoriteMovieEntity? getFavoriteMovie(int movieId) {
    try {
      return state.favoriteMovies.firstWhere(
        (movie) => movie.id == movieId,
      );
    } catch (e) {
      return null;
    }
  }

  Future<bool> toggleFavorite(FavoriteMovieEntity movie) async {
    final isCurrentlyFavorite = state.favoriteMovies.any((m) => m.id == movie.id);
    
    if (isCurrentlyFavorite) {
      return await removeFromFavorites(movie.id);
    } else {
      return await addMovieToFavorites(movie);
    }
  }
}

final favoritesProvider = StateNotifierProvider<FavoritesNotifier, FavoritesState>((ref) {
  return FavoritesNotifier(
    getFavoriteMovies: ref.watch(getFavoriteMoviesProvider),
    addToFavorites: ref.watch(addToFavoritesProvider),
    removeFromFavorites: ref.watch(removeFromFavoritesProvider),
    isFavorite: ref.watch(isFavoriteProvider),
  );
});
