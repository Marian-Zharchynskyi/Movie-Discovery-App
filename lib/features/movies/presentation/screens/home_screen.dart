import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:movie_discovery_app/features/favorites/presentation/widgets/favorite_button.dart';
import 'package:movie_discovery_app/features/movies/domain/entities/movie_entity.dart';
import 'package:movie_discovery_app/features/movies/presentation/providers/movie_provider.dart';

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
      body: _buildBody(state),
    );
  }

  Widget _buildBody(MovieState state) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

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
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.6,
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

class MovieCard extends StatelessWidget {
  final MovieEntity movie;

  const MovieCard({super.key, required this.movie});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Movie poster with favorite button
          SizedBox(
            height: 200, // Fixed height for the image container
            child: Stack(
              fit: StackFit.expand, // Make stack fill the SizedBox
              children: [
                // Movie poster
                movie.posterPath != null
                    ? Image.network(
                        movie.fullPosterPath,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => const Center(
                          child: Icon(Icons.error, size: 50),
                        ),
                      )
                    : const Center(child: Icon(Icons.movie, size: 50)),
                // Favorite button
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: FavoriteButton(
                      movieId: movie.id,
                      size: 36,
                      activeColor: Colors.red,
                      inactiveColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  movie.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      movie.voteAverage.toStringAsFixed(1),
                      style: const TextStyle(fontSize: 12),
                    ),
                    const Spacer(),
                    Text(
                      movie.releaseDate.split('-').first,
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
