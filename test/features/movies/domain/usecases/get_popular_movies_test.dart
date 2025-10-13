import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:movie_discovery_app/core/error/failures.dart';
import 'package:movie_discovery_app/features/movies/domain/entities/movie_entity.dart';
import 'package:movie_discovery_app/features/movies/domain/repositories/movie_repository.dart';
import 'package:movie_discovery_app/features/movies/domain/usecases/get_popular_movies.dart';

class MockMovieRepository extends Mock implements MovieRepository {}

void main() {
  late GetPopularMovies usecase;
  late MockMovieRepository mockMovieRepository;

  setUp(() {
    mockMovieRepository = MockMovieRepository();
    usecase = GetPopularMovies(mockMovieRepository);
  });

  const tMovieList = [
    MovieEntity(
      id: 1,
      title: 'Test Movie 1',
      overview: 'Test overview 1',
      posterPath: '/test1.jpg',
      voteAverage: 7.5,
      releaseDate: '2024-01-01',
      genreIds: [28, 12],
    ),
    MovieEntity(
      id: 2,
      title: 'Test Movie 2',
      overview: 'Test overview 2',
      posterPath: '/test2.jpg',
      voteAverage: 8.0,
      releaseDate: '2024-01-02',
      genreIds: [18, 35],
    ),
  ];

  test('should get popular movies from repository', () async {
    // arrange
    when(() => mockMovieRepository.getPopularMovies(page: any(named: 'page')))
        .thenAnswer((_) async => const Right(tMovieList));

    // act
    final result = await usecase(page: 1);

    // assert
    expect(result, const Right(tMovieList));
    verify(() => mockMovieRepository.getPopularMovies(page: 1)).called(1);
    verifyNoMoreInteractions(mockMovieRepository);
  });

  test('should return ServerFailure when repository call fails', () async {
    // arrange
    const tFailure = ServerFailure('Failed to fetch popular movies');
    when(() => mockMovieRepository.getPopularMovies(page: any(named: 'page')))
        .thenAnswer((_) async => const Left(tFailure));

    // act
    final result = await usecase(page: 1);

    // assert
    expect(result, const Left(tFailure));
    verify(() => mockMovieRepository.getPopularMovies(page: 1)).called(1);
  });

  test('should use default page value of 1 when not provided', () async {
    // arrange
    when(() => mockMovieRepository.getPopularMovies(page: any(named: 'page')))
        .thenAnswer((_) async => const Right(tMovieList));

    // act
    final result = await usecase();

    // assert
    expect(result, const Right(tMovieList));
    verify(() => mockMovieRepository.getPopularMovies(page: 1)).called(1);
  });
}
