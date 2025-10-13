import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:movie_discovery_app/core/injection_container.dart';
import 'package:movie_discovery_app/features/movies/domain/entities/review_entity.dart';
import 'package:movie_discovery_app/features/movies/domain/usecases/get_movie_reviews.dart';

final getMovieReviewsProvider = Provider<GetMovieReviews>((ref) {
  return sl<GetMovieReviews>();
});

final movieReviewsProvider = FutureProvider.family<List<ReviewEntity>, int>((ref, movieId) async {
  final getMovieReviews = ref.watch(getMovieReviewsProvider);
  final result = await getMovieReviews(movieId);
  return result.fold(
    (failure) => throw Exception(failure.message),
    (reviews) => reviews,
  );
});
