import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:movie_discovery_app/core/error/failures.dart';
import 'package:movie_discovery_app/features/movies/domain/entities/movie_entity.dart';
import 'package:movie_discovery_app/features/movies/domain/repositories/movie_repository.dart';
import 'package:movie_discovery_app/features/movies/domain/usecases/discover_movies.dart';

class MockMovieRepository extends Mock implements MovieRepository {}

void main() {
  late DiscoverMovies usecase;
  late MockMovieRepository mockMovieRepository;

  setUp(() {
    mockMovieRepository = MockMovieRepository();
    usecase = DiscoverMovies(mockMovieRepository);
  });

  const tMovieList = [
    MovieEntity(
      id: 1,
      title: 'Discovered Movie',
      overview: 'A discovered movie',
      posterPath: '/test.jpg',
      voteAverage: 8.0,
      releaseDate: '2024-01-01',
      genreIds: [28, 12],
    ),
  ];

  test('should discover movies with filters', () async {
    // arrange
    when(() => mockMovieRepository.discoverMovies(
          page: any(named: 'page'),
          genreIds: any(named: 'genreIds'),
          year: any(named: 'year'),
          minRating: any(named: 'minRating'),
        )).thenAnswer((_) async => const Right(tMovieList));

    // act
    final result = await usecase(
      page: 1,
      genreIds: [28],
      year: 2024,
      minRating: 7.0,
    );

    // assert
    expect(result, const Right(tMovieList));
    verify(() => mockMovieRepository.discoverMovies(
          page: 1,
          genreIds: [28],
          year: 2024,
          minRating: 7.0,
        )).called(1);
  });

  test('should discover movies without filters', () async {
    // arrange
    when(() => mockMovieRepository.discoverMovies(
          page: any(named: 'page'),
          genreIds: any(named: 'genreIds'),
          year: any(named: 'year'),
          minRating: any(named: 'minRating'),
        )).thenAnswer((_) async => const Right(tMovieList));

    // act
    final result = await usecase(page: 1);

    // assert
    expect(result, const Right(tMovieList));
    verify(() => mockMovieRepository.discoverMovies(
          page: 1,
          genreIds: null,
          year: null,
          minRating: null,
        )).called(1);
  });

  test('should return ServerFailure when discovery fails', () async {
    // arrange
    const tFailure = ServerFailure('Failed to discover movies');
    when(() => mockMovieRepository.discoverMovies(
          page: any(named: 'page'),
          genreIds: any(named: 'genreIds'),
          year: any(named: 'year'),
          minRating: any(named: 'minRating'),
        )).thenAnswer((_) async => const Left(tFailure));

    // act
    final result = await usecase(page: 1);

    // assert
    expect(result, const Left(tFailure));
  });
}
