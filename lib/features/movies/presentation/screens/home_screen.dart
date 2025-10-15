import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:movie_discovery_app/features/movies/presentation/providers/movie_provider.dart';
import 'package:movie_discovery_app/features/movies/presentation/screens/search_screen.dart';
import 'package:movie_discovery_app/features/movies/presentation/screens/discover_screen.dart';
import 'package:movie_discovery_app/features/movies/presentation/widgets/movie_card.dart';
import 'package:movie_discovery_app/shared/widgets/shimmers/movie_grid_shimmer.dart';
import 'package:movie_discovery_app/l10n/app_localizations.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(movieProvider.notifier).fetchPopularMovies());
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isBottom) {
      ref.read(movieProvider.notifier).loadMoreMovies();
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

    @override
    Widget build(BuildContext context) {
      final state = ref.watch(movieProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).popularMovies),
        actions: [
          IconButton(
            tooltip: AppLocalizations.of(context).search,
            icon: const Icon(Icons.search),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SearchScreen()),
              );
            },
          ),
          IconButton(
            tooltip: AppLocalizations.of(context).discover,
            icon: const Icon(Icons.explore),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const DiscoverScreen()),
              );
            },
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final crossAxisCount = _crossAxisForWidth(constraints.maxWidth);
          if (state.isLoading) {
            return MovieGridShimmer(crossAxisCount: crossAxisCount);
          }
          return _buildBody(state, crossAxisCount);
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

  Widget _buildBody(MovieState state, int crossAxisCount) {
    
    if (state.errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${AppLocalizations.of(context).error}: ${state.errorMessage}',
              style: const TextStyle(color: Colors.red, fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => ref.read(movieProvider.notifier).fetchPopularMovies(),
              child: Text(AppLocalizations.of(context).retry),
            ),
          ],
        ),
      );
    }

    if (state.movies.isEmpty) {
      return Center(child: Text(AppLocalizations.of(context).noMoviesFound));
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
      addAutomaticKeepAlives: false,
      addRepaintBoundaries: true,
      addSemanticIndexes: false,
      itemCount: state.movies.length + (state.isLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= state.movies.length) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: CircularProgressIndicator(),
            ),
          );
        }
        final movie = state.movies[index];
        return MovieCard(key: ValueKey(movie.id), movie: movie);
      },
    );
  }
}
