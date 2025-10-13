import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:movie_discovery_app/core/error/failures.dart';
import 'package:movie_discovery_app/features/movies/domain/entities/movie_entity.dart';
import 'package:movie_discovery_app/features/movies/domain/repositories/movie_repository.dart';
import 'package:movie_discovery_app/features/movies/domain/usecases/search_movies.dart';

class MockMovieRepository extends Mock implements MovieRepository {}

void main() {
  late SearchMovies usecase;
  late MockMovieRepository mockMovieRepository;

  setUp(() {
    mockMovieRepository = MockMovieRepository();
    usecase = SearchMovies(mockMovieRepository);
  });

  const tQuery = 'Inception';
  const tMovieList = [
    MovieEntity(
      id: 1,
      title: 'Inception',
      overview: 'A mind-bending thriller',
      posterPath: '/inception.jpg',
      voteAverage: 8.8,
      releaseDate: '2010-07-16',
      genreIds: [28, 878, 53],
    ),
  ];

  test('should search movies with query', () async {
    // arrange
    when(() => mockMovieRepository.searchMovies(
          any(),
          page: any(named: 'page'),
        )).thenAnswer((_) async => const Right(tMovieList));

    // act
    final result = await usecase(tQuery);

    // assert
    expect(result, const Right(tMovieList));
    verify(() => mockMovieRepository.searchMovies(tQuery)).called(1);
    verifyNoMoreInteractions(mockMovieRepository);
  });

  test('should return ServerFailure when search fails', () async {
    // arrange
    const tFailure = ServerFailure('Failed to search movies');
    when(() => mockMovieRepository.searchMovies(
          any(),
          page: any(named: 'page'),
        )).thenAnswer((_) async => const Left(tFailure));

    // act
    final result = await usecase(tQuery);

    // assert
    expect(result, const Left(tFailure));
    verify(() => mockMovieRepository.searchMovies(tQuery)).called(1);
  });

  test('should return empty list when query is empty', () async {
    // arrange
    when(() => mockMovieRepository.searchMovies(
          any(),
          page: any(named: 'page'),
        )).thenAnswer((_) async => const Right(<MovieEntity>[]));

    // act
    final result = await usecase('');

    // assert
    expect(result, const Right(<MovieEntity>[]));
    verify(() => mockMovieRepository.searchMovies('')).called(1);
  });
}
