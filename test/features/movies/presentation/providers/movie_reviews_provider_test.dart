import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:movie_discovery_app/core/error/failures.dart';
import 'package:movie_discovery_app/features/movies/domain/entities/review_entity.dart';
import 'package:movie_discovery_app/features/movies/domain/usecases/get_movie_reviews.dart';
import 'package:movie_discovery_app/features/movies/presentation/providers/movie_reviews_provider.dart';

import 'movie_reviews_provider_test.mocks.dart';

@GenerateMocks([GetMovieReviews])
void main() {
  late MockGetMovieReviews mockGetMovieReviews;

  setUp(() {
    mockGetMovieReviews = MockGetMovieReviews();
  });

  group('movieReviewsProvider', () {
    const tMovieId = 123;
    final tReviews = [
      const ReviewEntity(
        id: '1',
        author: 'John Doe',
        content: 'Great movie!',
        rating: 8.5,
        createdAt: '2024-01-01',
      ),
      const ReviewEntity(
        id: '2',
        author: 'Jane Smith',
        content: 'Amazing!',
        rating: 9.0,
        createdAt: '2024-01-02',
      ),
    ];

    test('should return list of reviews when use case succeeds', () async {
      // arrange
      when(mockGetMovieReviews(any))
          .thenAnswer((_) async => Right(tReviews));

      final container = ProviderContainer(
        overrides: [
          getMovieReviewsProvider.overrideWithValue(mockGetMovieReviews),
        ],
      );
      addTearDown(container.dispose);

      // act
      final result = await container.read(movieReviewsProvider(tMovieId).future);

      // assert
      expect(result, tReviews);
      verify(mockGetMovieReviews(tMovieId));
      verifyNoMoreInteractions(mockGetMovieReviews);
    });

    test('should throw exception when use case fails', () async {
      // arrange
      const tFailure = ServerFailure('Server error');
      when(mockGetMovieReviews(any))
          .thenAnswer((_) async => const Left(tFailure));

      final container = ProviderContainer(
        overrides: [
          getMovieReviewsProvider.overrideWithValue(mockGetMovieReviews),
        ],
      );
      addTearDown(container.dispose);

      // act & assert
      expect(
        () => container.read(movieReviewsProvider(tMovieId).future),
        throwsA(isA<Exception>()),
      );
      verify(mockGetMovieReviews(tMovieId));
    });

    test('should return empty list when no reviews available', () async {
      // arrange
      when(mockGetMovieReviews(any))
          .thenAnswer((_) async => const Right([]));

      final container = ProviderContainer(
        overrides: [
          getMovieReviewsProvider.overrideWithValue(mockGetMovieReviews),
        ],
      );
      addTearDown(container.dispose);

      // act
      final result = await container.read(movieReviewsProvider(tMovieId).future);

      // assert
      expect(result, isEmpty);
      verify(mockGetMovieReviews(tMovieId));
    });
  });
}
