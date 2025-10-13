import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:movie_discovery_app/features/movies/data/models/genre_model.dart';
import 'package:movie_discovery_app/features/movies/domain/entities/movie_entity.dart';
import 'package:movie_discovery_app/features/movies/domain/entities/video_entity.dart';
import 'package:movie_discovery_app/features/movies/domain/entities/review_entity.dart';
import 'package:movie_discovery_app/features/movies/presentation/providers/movie_provider.dart';
import 'package:movie_discovery_app/features/movies/presentation/providers/movie_videos_provider.dart';
import 'package:movie_discovery_app/features/movies/presentation/providers/movie_reviews_provider.dart';
import 'package:movie_discovery_app/features/movies/presentation/widgets/movie_card.dart';
import 'package:movie_discovery_app/shared/widgets/rating_stars.dart';
import 'package:movie_discovery_app/shared/widgets/shimmers/image_shimmer.dart';
import 'package:movie_discovery_app/shared/widgets/shimmers/movie_details_shimmer.dart';
import 'package:movie_discovery_app/shared/widgets/shimmers/trailers_list_shimmer.dart';
import 'package:movie_discovery_app/shared/widgets/shimmers/reviews_list_shimmer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:movie_discovery_app/l10n/app_localizations.dart';

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
                Text(AppLocalizations.of(context).failedToLoadDetails, style: theme.textTheme.titleMedium),
                const SizedBox(height: 8),
                Text('$err', textAlign: TextAlign.center, style: theme.textTheme.bodySmall),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => ref.refresh(movieDetailsProvider(movie.id)),
                  child: Text(AppLocalizations.of(context).retry),
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
                        AppLocalizations.of(context).overview,
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

                    // Trailers Section
                    const SizedBox(height: 24.0),
                    _TrailersSection(movieId: m.id),

                    // Reviews Section
                    const SizedBox(height: 24.0),
                    _ReviewsSection(movieId: m.id),
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
        Text('${AppLocalizations.of(context).releaseLabel}: $releaseYear', style: theme.textTheme.bodyMedium),
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

class _TrailersSection extends ConsumerWidget {
  final int movieId;

  const _TrailersSection({required this.movieId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final asyncVideos = ref.watch(movieVideosProvider(movieId));

    return asyncVideos.when(
      loading: () => const TrailersListShimmer(),
      error: (_, _) => const SizedBox.shrink(),
      data: (videos) {
        final trailers = videos.where((v) => v.site == 'YouTube' && v.type == 'Trailer').toList();
        if (trailers.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context).trailers,
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12.0),
            SizedBox(
              height: 120,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: trailers.length,
                itemBuilder: (context, index) {
                  final trailer = trailers[index];
                  return Padding(
                    padding: EdgeInsets.only(right: index < trailers.length - 1 ? 12.0 : 0),
                    child: _TrailerCard(trailer: trailer),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

class _TrailerCard extends StatelessWidget {
  final VideoEntity trailer;

  const _TrailerCard({required this.trailer});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _launchUrl(trailer.youtubeUrl),
      borderRadius: BorderRadius.circular(8.0),
      child: Container(
        width: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.0),
          color: Colors.black,
        ),
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: CachedNetworkImage(
                imageUrl: trailer.youtubeThumbnail,
                width: 200,
                height: 120,
                fit: BoxFit.cover,
                errorWidget: (_, _, _) => Container(
                  color: Colors.grey[800],
                  child: const Icon(Icons.play_circle_outline, size: 48, color: Colors.white),
                ),
              ),
            ),
            Center(
              child: Container(
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.6),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.play_arrow, color: Colors.white, size: 32),
              ),
            ),
            Positioned(
              bottom: 8,
              left: 8,
              right: 8,
              child: Text(
                trailer.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  shadows: [Shadow(color: Colors.black, blurRadius: 4)],
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);

    // On web, open in a new tab/window
    if (kIsWeb) {
      await launchUrl(
        uri,
        webOnlyWindowName: '_blank',
      );
      return;
    }

    // Try external application first; if not supported, fall back to default
    final openedExternally = await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );
    if (!openedExternally) {
      await launchUrl(uri, mode: LaunchMode.platformDefault);
    }
  }
}

class _ReviewsSection extends ConsumerWidget {
  final int movieId;

  const _ReviewsSection({required this.movieId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final asyncReviews = ref.watch(movieReviewsProvider(movieId));

    return asyncReviews.when(
      loading: () => const ReviewsListShimmer(),
      error: (_, _) => const SizedBox.shrink(),
      data: (reviews) {
        if (reviews.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context).reviews,
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12.0),
            ...reviews.take(3).map((review) => Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: _ReviewCard(review: review),
            )),
          ],
        );
      },
    );
  }
}

class _ReviewCard extends StatelessWidget {
  final ReviewEntity review;

  const _ReviewCard({required this.review});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    review.author,
                    style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
                if (review.rating != null) ...[
                  const Icon(Icons.star, size: 16, color: Colors.amber),
                  const SizedBox(width: 4),
                  Text(
                    review.rating!.toStringAsFixed(1),
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ],
            ),
            const SizedBox(height: 8.0),
            Text(
              review.content,
              style: theme.textTheme.bodySmall,
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
