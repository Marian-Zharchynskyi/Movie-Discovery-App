import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:movie_discovery_app/features/favorites/presentation/widgets/favorite_button.dart';
import 'package:movie_discovery_app/features/movies/domain/entities/movie_entity.dart';
import 'package:movie_discovery_app/features/movies/presentation/screens/movie_details_screen.dart';
import 'package:movie_discovery_app/shared/widgets/rating_stars.dart';
import 'package:movie_discovery_app/shared/widgets/shimmers/image_shimmer.dart';

class MovieCard extends StatelessWidget {
  final MovieEntity movie;

  const MovieCard({super.key, required this.movie});

  static String heroTagFor(MovieEntity movie) => 'moviePoster_${movie.id}';

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MovieDetailsScreen(movie: movie),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Poster + Favorite button
            SizedBox(
              height: 220,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (movie.posterPath != null)
                    Hero(
                      tag: MovieCard.heroTagFor(movie),
                      child: CachedNetworkImage(
                        imageUrl: movie.fullPosterPath,
                        fit: BoxFit.cover,
                        placeholder: (ctx, url) => const ImageShimmer(width: double.infinity, height: double.infinity),
                        errorWidget: (ctx, url, error) => const Center(child: Icon(Icons.broken_image, size: 48)),
                      ),
                    )
                  else
                    const Center(child: Icon(Icons.movie, size: 48)),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: FavoriteButton(
                          movie: movie,
                          size: 32,
                          activeColor: Colors.red,
                          inactiveColor: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Title + rating + year
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    movie.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      RatingStars(rating10: movie.voteAverage, size: 14),
                      const SizedBox(width: 6),
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
      ),
    );
  }
}
