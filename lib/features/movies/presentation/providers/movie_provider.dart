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
  final String? errorMessage;
  final List<MovieEntity> movies;

  const MovieState({
    this.isLoading = false,
    this.errorMessage,
    this.movies = const [],
  });

  const MovieState.initial() : this();

  MovieState copyWith({
    bool? isLoading,
    String? errorMessage,
    List<MovieEntity>? movies,
  }) {
    return MovieState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      movies: movies ?? this.movies,
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
    state = state.copyWith(isLoading: true, errorMessage: null);
    
    final result = await getPopularMovies();
    
    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        errorMessage: failure.message,
      ),
      (movies) => state = state.copyWith(
        isLoading: false,
        movies: movies,
      ),
    );
  }
}
