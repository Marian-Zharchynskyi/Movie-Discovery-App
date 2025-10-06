import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:movie_discovery_app/features/movies/data/models/genre_model.dart';
import 'package:movie_discovery_app/features/movies/domain/entities/movie_entity.dart';
import 'package:movie_discovery_app/features/movies/presentation/providers/movie_provider.dart';
import 'package:movie_discovery_app/features/movies/presentation/widgets/movie_card.dart';
import 'package:movie_discovery_app/shared/widgets/rating_stars.dart';
import 'package:movie_discovery_app/shared/widgets/shimmers/image_shimmer.dart';
import 'package:movie_discovery_app/shared/widgets/shimmers/movie_details_shimmer.dart';

class MovieDetailsScreen extends ConsumerWidget {
  final MovieEntity movie;

  const MovieDetailsScreen({
    super.key,
    required this.movie,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final asyncMovie = ref.watch(movieDetailsProvider(movie.id));

    return asyncMovie.when(
      loading: () => Scaffold(
        appBar: AppBar(title: Text(movie.title)),
        body: const MovieDetailsShimmer(),
      ),
      error: (err, st) => Scaffold(
        appBar: AppBar(title: Text(movie.title)),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 48),
                const SizedBox(height: 12),
                Text('Failed to load details', style: theme.textTheme.titleMedium),
                const SizedBox(height: 8),
                Text('$err', textAlign: TextAlign.center, style: theme.textTheme.bodySmall),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => ref.refresh(movieDetailsProvider(movie.id)),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      ),
      data: (movieData) {
        final m = movieData;
        final releaseYear = m.releaseDate.isNotEmpty ? m.releaseDate.split('-').first : 'N/A';
        return Scaffold(
          appBar: AppBar(
            title: Text(m.title),
          ),
          body: LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 700;
              return SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header: poster + basic info
                    isWide
                        ? Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _Poster(movie: m),
                              const SizedBox(width: 24.0),
                              Expanded(child: _BasicInfo(movie: m, releaseYear: releaseYear)),
                            ],
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Center(child: _Poster(movie: m)),
                              const SizedBox(height: 16.0),
                              _BasicInfo(movie: m, releaseYear: releaseYear),
                            ],
                          ),

                    const SizedBox(height: 24.0),

                    // Overview
                    if (m.overview.isNotEmpty) ...[
                      Text(
                        'Overview',
                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8.0),
                      Text(m.overview, style: theme.textTheme.bodyMedium),
                    ],

                    // Backdrop
                    if (m.backdropPath != null) ...[
                      const SizedBox(height: 24.0),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12.0),
                        child: CachedNetworkImage(
                          imageUrl: m.fullBackdropPath,
                          height: 220,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          placeholder: (ctx, url) => const ImageShimmer(width: double.infinity, height: 220),
                          errorWidget: (ctx, url, error) => const SizedBox.shrink(),
                        ),
                      ),
                    ],
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class _Poster extends StatelessWidget {
  final MovieEntity movie;

  const _Poster({required this.movie});

  @override
  Widget build(BuildContext context) {
    final poster = movie.posterPath != null
        ? CachedNetworkImage(
            imageUrl: movie.fullPosterPath,
            width: 180,
            height: 270,
            fit: BoxFit.cover,
            placeholder: (ctx, url) => const ImageShimmer(width: 180, height: 270, borderRadius: BorderRadius.all(Radius.circular(10))),
            errorWidget: (ctx, url, error) => Container(
              width: 180,
              height: 270,
              color: Colors.grey[300],
              child: const Icon(Icons.broken_image, size: 48),
            ),
          )
        : Container(
            width: 180,
            height: 270,
            color: Colors.grey[300],
            child: const Icon(Icons.movie, size: 48),
          );

    return ClipRRect(
      borderRadius: BorderRadius.circular(10.0),
      child: Hero(
        tag: MovieCard.heroTagFor(movie),
        child: poster,
      ),
    );
  }
}

class _BasicInfo extends StatelessWidget {
  final MovieEntity movie;
  final String releaseYear;

  const _BasicInfo({required this.movie, required this.releaseYear});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          movie.title,
          style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8.0),
        Row(
          children: [
            RatingStars(rating10: movie.voteAverage, size: 18),
            const SizedBox(width: 8.0),
            Text('${movie.voteAverage.toStringAsFixed(1)}/10', style: theme.textTheme.bodyMedium),
          ],
        ),
        const SizedBox(height: 8.0),
        Text('Release: $releaseYear', style: theme.textTheme.bodyMedium),
        if (movie.genreIds.isNotEmpty) ...[
          const SizedBox(height: 8.0),
          Wrap(
            spacing: 8.0,
            runSpacing: 4.0,
            children: movie.genreIds.take(3).map((genreId) {
              return Chip(
                label: Text(GenreModel.getGenreName(genreId)),
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                labelStyle: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                  fontSize: 12,
                ),
              );
            }).toList(),
          ),
        ],
      ],
    );
  }
}
