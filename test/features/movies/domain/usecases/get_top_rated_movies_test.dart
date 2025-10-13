import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:movie_discovery_app/core/error/failures.dart';
import 'package:movie_discovery_app/features/movies/domain/entities/movie_entity.dart';
import 'package:movie_discovery_app/features/movies/domain/repositories/movie_repository.dart';
import 'package:movie_discovery_app/features/movies/domain/usecases/get_top_rated_movies.dart';

class MockMovieRepository extends Mock implements MovieRepository {}

void main() {
  late GetTopRatedMovies usecase;
  late MockMovieRepository mockMovieRepository;

  setUp(() {
    mockMovieRepository = MockMovieRepository();
    usecase = GetTopRatedMovies(mockMovieRepository);
  });

  const tMovieList = [
    MovieEntity(
      id: 1,
      title: 'Top Rated Movie',
      overview: 'Highly rated movie',
      posterPath: '/test.jpg',
      voteAverage: 9.5,
      releaseDate: '2024-01-01',
      genreIds: [18],
    ),
  ];

  test('should get top rated movies from repository', () async {
    // arrange
    when(() => mockMovieRepository.getTopRatedMovies(page: any(named: 'page')))
        .thenAnswer((_) async => const Right(tMovieList));

    // act
    final result = await usecase();

    // assert
    expect(result, const Right(tMovieList));
    verify(() => mockMovieRepository.getTopRatedMovies()).called(1);
    verifyNoMoreInteractions(mockMovieRepository);
  });

  test('should return ServerFailure when repository call fails', () async {
    // arrange
    const tFailure = ServerFailure('Failed to fetch top rated movies');
    when(() => mockMovieRepository.getTopRatedMovies(page: any(named: 'page')))
        .thenAnswer((_) async => const Left(tFailure));

    // act
    final result = await usecase();

    // assert
    expect(result, const Left(tFailure));
    verify(() => mockMovieRepository.getTopRatedMovies()).called(1);
  });
}
