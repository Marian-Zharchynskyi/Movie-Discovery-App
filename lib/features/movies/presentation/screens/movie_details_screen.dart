import 'package:flutter/material.dart';
import 'package:movie_discovery_app/features/movies/domain/entities/movie_entity.dart';

class MovieDetailsScreen extends StatelessWidget {
  final MovieEntity movie;

  const MovieDetailsScreen({
    Key? key,
    required this.movie,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // Parse release year from releaseDate string (format: "yyyy-mm-dd")
    final releaseYear = movie.releaseDate.isNotEmpty 
        ? movie.releaseDate.split('-').first 
        : 'N/A';
    
    return Scaffold(
      appBar: AppBar(
        title: Text(movie.title),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Movie poster and basic info
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Movie poster
                ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: movie.posterPath != null
                      ? Image.network(
                          movie.fullPosterPath,
                          width: 150,
                          height: 225,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => _buildPlaceholderIcon(),
                        )
                      : _buildPlaceholderIcon(),
                ),
                const SizedBox(width: 16.0),
                // Basic info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        movie.title,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8.0),
                      Text(
                        'Release: $releaseYear',
                        style: theme.textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 8.0),
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 20),
                          const SizedBox(width: 4.0),
                          Text(
                            '${movie.voteAverage.toStringAsFixed(1)}/10',
                            style: theme.textTheme.bodyMedium,
                          ),
                        ],
                      ),
                      if (movie.genreIds.isNotEmpty) ...[
                        const SizedBox(height: 8.0),
                        Wrap(
                          spacing: 8.0,
                          runSpacing: 4.0,
                          children: movie.genreIds.take(3).map((genreId) {
                            return Chip(
                              label: Text('Genre $genreId'),
                              padding: EdgeInsets.zero,
                              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            );
                          }).toList(),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 24.0),
            
            // Overview
            if (movie.overview.isNotEmpty) ...[
              Text(
                'Overview',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8.0),
              Text(
                movie.overview,
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 24.0),
            ],
            
            // Additional details if backdrop is available
            if (movie.backdropPath != null) ...[
              const SizedBox(height: 16.0),
              ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: Image.network(
                  movie.fullBackdropPath,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
  
  Widget _buildPlaceholderIcon() {
    return Container(
      width: 150,
      height: 225,
      color: Colors.grey[300],
      child: const Icon(Icons.movie, size: 50, color: Colors.grey),
    );
  }
}
