import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:movie_discovery_app/core/error/failures.dart';
import 'package:movie_discovery_app/features/movies/domain/entities/movie_entity.dart';
import 'package:movie_discovery_app/features/movies/domain/repositories/movie_repository.dart';
import 'package:movie_discovery_app/features/movies/domain/usecases/get_movie_details.dart';

class MockMovieRepository extends Mock implements MovieRepository {}

void main() {
  late GetMovieDetails usecase;
  late MockMovieRepository mockMovieRepository;

  setUp(() {
    mockMovieRepository = MockMovieRepository();
    usecase = GetMovieDetails(mockMovieRepository);
  });

  const tMovieId = 1;
  const tMovie = MovieEntity(
    id: tMovieId,
    title: 'Test Movie',
    overview: 'Test overview',
    posterPath: '/test.jpg',
    backdropPath: '/backdrop.jpg',
    voteAverage: 8.5,
    releaseDate: '2024-01-01',
    genreIds: [28, 12],
  );

  test('should get movie details by id', () async {
    // arrange
    when(() => mockMovieRepository.getMovieDetails(any()))
        .thenAnswer((_) async => const Right(tMovie));

    // act
    final result = await usecase(tMovieId);

    // assert
    expect(result, const Right(tMovie));
    verify(() => mockMovieRepository.getMovieDetails(tMovieId)).called(1);
    verifyNoMoreInteractions(mockMovieRepository);
  });

  test('should return ServerFailure when getting movie details fails', () async {
    // arrange
    const tFailure = ServerFailure('Movie not found');
    when(() => mockMovieRepository.getMovieDetails(any()))
        .thenAnswer((_) async => const Left(tFailure));

    // act
    final result = await usecase(tMovieId);

    // assert
    expect(result, const Left(tFailure));
    verify(() => mockMovieRepository.getMovieDetails(tMovieId)).called(1);
  });
}
