import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:movie_discovery_app/core/injection_container.dart';
import 'package:movie_discovery_app/features/movies/domain/entities/movie_entity.dart';
import 'package:movie_discovery_app/features/movies/domain/usecases/get_popular_movies.dart';
import 'package:movie_discovery_app/features/movies/domain/usecases/get_movie_details.dart';

final getPopularMoviesProvider = Provider<GetPopularMovies>((ref) {
  return sl<GetPopularMovies>();
});

final getMovieDetailsProvider = Provider<GetMovieDetails>((ref) {
  return sl<GetMovieDetails>();
});

class MovieState {
  final bool isLoading;
  final bool isLoadingMore;
  final String? errorMessage;
  final List<MovieEntity> movies;
  final int currentPage;
  final bool hasMorePages;

  const MovieState({
    this.isLoading = false,
    this.isLoadingMore = false,
    this.errorMessage,
    this.movies = const [],
    this.currentPage = 1,
    this.hasMorePages = true,
  });

  const MovieState.initial() : this();

  MovieState copyWith({
    bool? isLoading,
    bool? isLoadingMore,
    String? errorMessage,
    List<MovieEntity>? movies,
    int? currentPage,
    bool? hasMorePages,
  }) {
    return MovieState(
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      errorMessage: errorMessage ?? this.errorMessage,
      movies: movies ?? this.movies,
      currentPage: currentPage ?? this.currentPage,
      hasMorePages: hasMorePages ?? this.hasMorePages,
    );
  }
}

/// Fetch movie details by ID. Exposes AsyncValue state (loading/error/data).
final movieDetailsProvider = FutureProvider.family<MovieEntity, int>((ref, movieId) async {
  final getMovieDetails = ref.watch(getMovieDetailsProvider);
  final result = await getMovieDetails(movieId);
  return result.fold(
    (failure) => throw Exception(failure.message),
    (movie) => movie,
  );
});

final movieProvider = StateNotifierProvider<MovieNotifier, MovieState>((ref) {
  final getPopularMovies = ref.watch(getPopularMoviesProvider);
  return MovieNotifier(getPopularMovies);
});

class MovieNotifier extends StateNotifier<MovieState> {
  final GetPopularMovies getPopularMovies;

  MovieNotifier(this.getPopularMovies) : super(const MovieState.initial());

  Future<void> fetchPopularMovies() async {
    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
      currentPage: 1,
      hasMorePages: true,
    );
    
    final result = await getPopularMovies(page: 1);
    
    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        errorMessage: failure.message,
      ),
      (movies) => state = state.copyWith(
        isLoading: false,
        movies: movies,
        currentPage: 1,
        hasMorePages: movies.length >= 20,
      ),
    );
  }

  Future<void> loadMoreMovies() async {
    // Prevent multiple simultaneous loads
    if (state.isLoadingMore || !state.hasMorePages) return;

    state = state.copyWith(isLoadingMore: true);
    final nextPage = state.currentPage + 1;

    final result = await getPopularMovies(page: nextPage);

    result.fold(
      (failure) => state = state.copyWith(
        isLoadingMore: false,
        errorMessage: failure.message,
      ),
      (newMovies) {
        final updatedMovies = [...state.movies, ...newMovies];
        state = state.copyWith(
          isLoadingMore: false,
          movies: updatedMovies,
          currentPage: nextPage,
          hasMorePages: newMovies.length >= 20,
          );
      },
    );
  }
}
