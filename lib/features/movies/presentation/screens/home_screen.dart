import 'package:flutter/material.dart';
  import 'package:flutter_riverpod/flutter_riverpod.dart';
  import 'package:movie_discovery_app/features/movies/presentation/providers/movie_provider.dart';
  import 'package:movie_discovery_app/features/movies/presentation/widgets/movie_card.dart';
  import 'package:movie_discovery_app/shared/widgets/shimmers/movie_grid_shimmer.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

  class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(movieProvider.notifier).fetchPopularMovies());
  }

    @override
    Widget build(BuildContext context) {
      final state = ref.watch(movieProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Popular Movies'),
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
              'Error: ${state.errorMessage}',
              style: const TextStyle(color: Colors.red, fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => ref.read(movieProvider.notifier).fetchPopularMovies(),
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
      padding: const EdgeInsets.all(8),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: 0.62,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: state.movies.length,
      itemBuilder: (context, index) {
        final movie = state.movies[index];
        return MovieCard(movie: movie);
      },
    );
  }
}
