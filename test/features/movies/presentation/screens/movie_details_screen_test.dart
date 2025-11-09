import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movie_discovery_app/features/movies/domain/entities/movie_entity.dart';
import 'package:movie_discovery_app/features/movies/domain/entities/review_entity.dart';
import 'package:movie_discovery_app/features/movies/domain/entities/video_entity.dart';
import 'package:movie_discovery_app/features/movies/presentation/providers/movie_provider.dart';
import 'package:movie_discovery_app/features/movies/presentation/providers/movie_reviews_provider.dart';
import 'package:movie_discovery_app/features/movies/presentation/providers/movie_videos_provider.dart';
import 'package:movie_discovery_app/features/movies/presentation/screens/movie_details_screen.dart';

void main() {
  const tMovie = MovieEntity(
    id: 1,
    title: 'Test Movie',
    overview: 'Overview',
    posterPath: '/p.jpg',
    backdropPath: '/b.jpg',
    voteAverage: 8.0,
    releaseDate: '2024-01-01',
    genreIds: [28],
  );

  final videos = <VideoEntity>[
    const VideoEntity(
      id: 'v1',
      key: 'key',
      name: 'Official Trailer',
      site: 'YouTube',
      type: 'Trailer',
      official: true,
    )
  ];

  final reviews = <ReviewEntity>[
    const ReviewEntity(
      id: 'r1',
      author: 'John',
      content: 'Great movie',
      createdAt: '2024-01-01',
      rating: 8.0,
    )
  ];

  testWidgets('MovieDetailsScreen shows title and sections', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          movieDetailsProvider.overrideWith((ref, id) async => tMovie),
          movieVideosProvider.overrideWith((ref, id) async => videos),
          movieReviewsProvider.overrideWith((ref, id) async => reviews),
        ],
        child: const MaterialApp(
          home: MovieDetailsScreen(movie: tMovie),
        ),
      ),
    );

    await tester.pump();

    expect(find.text('Test Movie'), findsWidgets);
    expect(find.textContaining('Overview'), findsWidgets);
  });

  testWidgets('MovieDetailsScreen shows error state and retry', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          movieDetailsProvider.overrideWith((ref, id) async => throw Exception('fail')),
          movieVideosProvider.overrideWith((ref, id) async => <VideoEntity>[]),
          movieReviewsProvider.overrideWith((ref, id) async => <ReviewEntity>[]),
        ],
        child: const MaterialApp(
          home: MovieDetailsScreen(movie: tMovie),
        ),
      ),
    );

    await tester.pump();

    expect(find.byIcon(Icons.error_outline), findsOneWidget);
    expect(find.textContaining('Retry'), findsOneWidget);
  });
}
