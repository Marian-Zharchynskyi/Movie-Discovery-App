import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:movie_discovery_app/core/injection_container.dart';
import 'package:movie_discovery_app/features/movies/domain/entities/movie_entity.dart';
import 'package:movie_discovery_app/features/movies/domain/usecases/search_movies.dart';

final searchMoviesUseCaseProvider = Provider<SearchMovies>((ref) {
  return sl<SearchMovies>();
});

class SearchMoviesState {
  final bool isLoading;
  final String? errorMessage;
  final List<MovieEntity> movies;
  final String query;

  const SearchMoviesState({
    this.isLoading = false,
    this.errorMessage,
    this.movies = const [],
    this.query = '',
  });

  const SearchMoviesState.initial() : this();

  SearchMoviesState copyWith({
    bool? isLoading,
    String? errorMessage,
    List<MovieEntity>? movies,
    String? query,
  }) {
    return SearchMoviesState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      movies: movies ?? this.movies,
      query: query ?? this.query,
    );
  }
}

final searchMoviesProvider = StateNotifierProvider<SearchMoviesNotifier, SearchMoviesState>((ref) {
  final searchMovies = ref.watch(searchMoviesUseCaseProvider);
  return SearchMoviesNotifier(searchMovies);
});

class SearchMoviesNotifier extends StateNotifier<SearchMoviesState> {
  final SearchMovies searchMovies;

  SearchMoviesNotifier(this.searchMovies) : super(const SearchMoviesState.initial());

  Future<void> search(String query) async {
    if (query.trim().isEmpty) {
      state = const SearchMoviesState.initial();
      return;
    }

    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
      query: query,
    );

    final result = await searchMovies(query);

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

  void clear() {
    state = const SearchMoviesState.initial();
  }
}
