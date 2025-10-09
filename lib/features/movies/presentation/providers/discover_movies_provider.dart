import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:movie_discovery_app/core/injection_container.dart';
import 'package:movie_discovery_app/features/movies/domain/entities/movie_entity.dart';
import 'package:movie_discovery_app/features/movies/domain/usecases/discover_movies.dart';

final discoverMoviesUseCaseProvider = Provider<DiscoverMovies>((ref) {
  return sl<DiscoverMovies>();
});

class DiscoverMoviesParams {
  final int page;
  final List<int>? genreIds;
  final int? year;
  final double? minRating;

  const DiscoverMoviesParams({
    this.page = 1,
    this.genreIds,
    this.year,
    this.minRating,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DiscoverMoviesParams &&
          runtimeType == other.runtimeType &&
          page == other.page &&
          _listEquals(genreIds, other.genreIds) &&
          year == other.year &&
          minRating == other.minRating;

  @override
  int get hashCode =>
      page.hashCode ^
      (genreIds?.hashCode ?? 0) ^
      (year?.hashCode ?? 0) ^
      (minRating?.hashCode ?? 0);

  bool _listEquals(List<int>? a, List<int>? b) {
    if (a == null) return b == null;
    if (b == null || a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}

class DiscoverMoviesState {
  final bool isLoading;
  final bool isLoadingMore;
  final String? errorMessage;
  final List<MovieEntity> movies;
  final int currentPage;
  final bool hasMorePages;
  final List<int>? selectedGenres;
  final int? selectedYear;
  final double? selectedMinRating;

  const DiscoverMoviesState({
    this.isLoading = false,
    this.isLoadingMore = false,
    this.errorMessage,
    this.movies = const [],
    this.currentPage = 1,
    this.hasMorePages = true,
    this.selectedGenres,
    this.selectedYear,
    this.selectedMinRating,
  });

  const DiscoverMoviesState.initial() : this();

  DiscoverMoviesState copyWith({
    bool? isLoading,
    bool? isLoadingMore,
    String? errorMessage,
    List<MovieEntity>? movies,
    int? currentPage,
    bool? hasMorePages,
    List<int>? selectedGenres,
    int? selectedYear,
    double? selectedMinRating,
  }) {
    return DiscoverMoviesState(
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      errorMessage: errorMessage,
      movies: movies ?? this.movies,
      currentPage: currentPage ?? this.currentPage,
      hasMorePages: hasMorePages ?? this.hasMorePages,
      selectedGenres: selectedGenres ?? this.selectedGenres,
      selectedYear: selectedYear ?? this.selectedYear,
      selectedMinRating: selectedMinRating ?? this.selectedMinRating,
    );
  }
}

final discoverMoviesProvider = StateNotifierProvider<DiscoverMoviesNotifier, DiscoverMoviesState>((ref) {
  final discoverMovies = ref.watch(discoverMoviesUseCaseProvider);
  return DiscoverMoviesNotifier(discoverMovies);
});

class DiscoverMoviesNotifier extends StateNotifier<DiscoverMoviesState> {
  final DiscoverMovies discoverMovies;

  DiscoverMoviesNotifier(this.discoverMovies) : super(const DiscoverMoviesState.initial());

  Future<void> fetchMovies({
    List<int>? genreIds,
    int? year,
    double? minRating,
  }) async {
    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
      currentPage: 1,
      hasMorePages: true,
      selectedGenres: genreIds,
      selectedYear: year,
      selectedMinRating: minRating,
    );

    final result = await discoverMovies(
      page: 1,
      genreIds: genreIds,
      year: year,
      minRating: minRating,
    );

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
    if (state.isLoadingMore || !state.hasMorePages) return;

    state = state.copyWith(isLoadingMore: true);
    final nextPage = state.currentPage + 1;

    final result = await discoverMovies(
      page: nextPage,
      genreIds: state.selectedGenres,
      year: state.selectedYear,
      minRating: state.selectedMinRating,
    );

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

  void clearFilters() {
    state = const DiscoverMoviesState.initial();
  }
}
