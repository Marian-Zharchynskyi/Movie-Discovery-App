import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:movie_discovery_app/features/movies/data/models/genre_model.dart';
import 'package:movie_discovery_app/features/movies/presentation/providers/discover_movies_provider.dart';
import 'package:movie_discovery_app/features/movies/presentation/widgets/movie_card.dart';
import 'package:movie_discovery_app/shared/widgets/shimmers/movie_grid_shimmer.dart';
import 'package:movie_discovery_app/shared/widgets/shimmers/movie_card_shimmer.dart';

class DiscoverScreen extends ConsumerStatefulWidget {
  const DiscoverScreen({super.key});

  @override
  ConsumerState<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends ConsumerState<DiscoverScreen> {
  final ScrollController _scrollController = ScrollController();
  List<int> _selectedGenres = [];
  int? _selectedYear;
  double? _selectedMinRating;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    Future.microtask(() => ref.read(discoverMoviesProvider.notifier).fetchMovies());
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isBottom) {
      ref.read(discoverMoviesProvider.notifier).loadMoreMovies();
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  void _applyFilters() {
    ref.read(discoverMoviesProvider.notifier).fetchMovies(
          genreIds: _selectedGenres.isEmpty ? null : _selectedGenres,
          year: _selectedYear,
          minRating: _selectedMinRating,
        );
  }

  void _showFilterDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => _FilterSheet(
        selectedGenres: _selectedGenres,
        selectedYear: _selectedYear,
        selectedMinRating: _selectedMinRating,
        onApply: (genres, year, rating) {
          setState(() {
            _selectedGenres = genres;
            _selectedYear = year;
            _selectedMinRating = rating;
          });
          _applyFilters();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(discoverMoviesProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Discover Movies'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final crossAxisCount = _crossAxisForWidth(constraints.maxWidth);
          if (state.isLoading && state.movies.isEmpty) {
            return MovieGridShimmer(crossAxisCount: crossAxisCount);
          }
          return _buildBody(state, crossAxisCount, theme);
        },
      ),
    );
  }

  int _crossAxisForWidth(double width) {
    if (width >= 1200) return 6;
    if (width >= 900) return 5;
    if (width >= 700) return 4;
    if (width >= 500) return 3;
    return 2;
  }

  Widget _buildBody(DiscoverMoviesState state, int crossAxisCount, ThemeData theme) {
    if (state.errorMessage != null && state.movies.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            Text(
              'Error: ${state.errorMessage}',
              style: const TextStyle(color: Colors.red, fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _applyFilters,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (state.movies.isEmpty) {
      return const Center(child: Text('No movies found'));
    }

    return GridView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(8),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: 0.62,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: state.movies.length + (state.isLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= state.movies.length) {
          return const MovieCardShimmer();
        }
        final movie = state.movies[index];
        return MovieCard(key: ValueKey(movie.id), movie: movie);
      },
    );
  }
}

class _FilterSheet extends StatefulWidget {
  final List<int> selectedGenres;
  final int? selectedYear;
  final double? selectedMinRating;
  final Function(List<int>, int?, double?) onApply;

  const _FilterSheet({
    required this.selectedGenres,
    required this.selectedYear,
    required this.selectedMinRating,
    required this.onApply,
  });

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  late List<int> _genres;
  late int? _year;
  late double? _minRating;

  @override
  void initState() {
    super.initState();
    _genres = List.from(widget.selectedGenres);
    _year = widget.selectedYear;
    _minRating = widget.selectedMinRating;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentYear = DateTime.now().year;

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Filters',
                    style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _genres.clear();
                        _year = null;
                        _minRating = null;
                      });
                    },
                    child: const Text('Clear All'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  children: [
                    // Genres
                    Text('Genres', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8.0,
                      runSpacing: 8.0,
                      children: GenreModel.genres.entries.map((entry) {
                        final isSelected = _genres.contains(entry.key);
                        return FilterChip(
                          label: Text(entry.value),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              if (selected) {
                                _genres.add(entry.key);
                              } else {
                                _genres.remove(entry.key);
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),

                    // Year
                    Text('Release Year', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<int?>(
                      initialValue: _year,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      items: [
                        const DropdownMenuItem(value: null, child: Text('Any Year')),
                        ...List.generate(50, (i) => currentYear - i).map((year) {
                          return DropdownMenuItem(value: year, child: Text(year.toString()));
                        }),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _year = value;
                        });
                      },
                    ),
                    const SizedBox(height: 24),

                    // Rating
                    Text('Minimum Rating', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: Slider(
                            value: _minRating ?? 0,
                            min: 0,
                            max: 10,
                            divisions: 20,
                            label: _minRating?.toStringAsFixed(1) ?? '0.0',
                            onChanged: (value) {
                              setState(() {
                                _minRating = value > 0 ? value : null;
                              });
                            },
                          ),
                        ),
                        SizedBox(
                          width: 50,
                          child: Text(
                            _minRating?.toStringAsFixed(1) ?? '0.0',
                            style: theme.textTheme.titleMedium,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    widget.onApply(_genres, _year, _minRating);
                    Navigator.pop(context);
                  },
                  child: const Text('Apply Filters'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
