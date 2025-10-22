import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:movie_discovery_app/core/error/failures.dart';
import 'package:movie_discovery_app/features/movies/domain/entities/review_entity.dart';
import 'package:movie_discovery_app/features/movies/domain/repositories/movie_repository.dart';
import 'package:movie_discovery_app/features/movies/domain/usecases/get_movie_reviews.dart';

class MockMovieRepository extends Mock implements MovieRepository {}

void main() {
  late GetMovieReviews usecase;
  late MockMovieRepository mockMovieRepository;

  setUp(() {
    mockMovieRepository = MockMovieRepository();
    usecase = GetMovieReviews(mockMovieRepository);
  });

  const tMovieId = 1;
  const tReviewList = [
    ReviewEntity(
      id: '1',
      author: 'John Doe',
      content: 'Great movie!',
      rating: 9.0,
      createdAt: '2024-01-15',
    ),
    ReviewEntity(
      id: '2',
      author: 'Jane Smith',
      content: 'Amazing film!',
      rating: 8.5,
      createdAt: '2024-01-16',
    ),
  ];

  test('should get movie reviews from repository', () async {
    // arrange
    when(() => mockMovieRepository.getMovieReviews(any(), page: any(named: 'page')))
        .thenAnswer((_) async => const Right(tReviewList));

    // act
    final result = await usecase(tMovieId);

    // assert
    expect(result, const Right(tReviewList));
    verify(() => mockMovieRepository.getMovieReviews(tMovieId, page: 1)).called(1);
    verifyNoMoreInteractions(mockMovieRepository);
  });

  test('should get movie reviews for specific page', () async {
    // arrange
    when(() => mockMovieRepository.getMovieReviews(any(), page: any(named: 'page')))
        .thenAnswer((_) async => const Right(tReviewList));

    // act
    final result = await usecase(tMovieId, page: 2);

    // assert
    expect(result, const Right(tReviewList));
    verify(() => mockMovieRepository.getMovieReviews(tMovieId, page: 2)).called(1);
  });

  test('should return empty list when no reviews', () async {
    // arrange
    when(() => mockMovieRepository.getMovieReviews(any(), page: any(named: 'page')))
        .thenAnswer((_) async => const Right([]));

    // act
    final result = await usecase(tMovieId);

    // assert
    result.fold(
      (l) => fail('Expected Right, got Left: ${l.runtimeType}'),
      (r) => expect(r, isEmpty),
    );
  });

  test('should return ServerFailure when getting reviews fails', () async {
    // arrange
    const tFailure = ServerFailure('Failed to get reviews');
    when(() => mockMovieRepository.getMovieReviews(any(), page: any(named: 'page')))
        .thenAnswer((_) async => const Left(tFailure));

    // act
    final result = await usecase(tMovieId);

    // assert
    expect(result, const Left(tFailure));
  });
}
