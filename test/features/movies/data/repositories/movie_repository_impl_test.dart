import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:movie_discovery_app/core/error/exceptions.dart';
import 'package:movie_discovery_app/core/error/failures.dart';
import 'package:movie_discovery_app/features/movies/data/datasources/local/movie_local_data_source.dart';
import 'package:movie_discovery_app/features/movies/data/datasources/remote/movie_remote_data_source.dart';
import 'package:movie_discovery_app/features/movies/data/models/movie_model.dart';
import 'package:movie_discovery_app/features/movies/data/repositories/movie_repository_impl.dart';

class MockMovieRemoteDataSource extends Mock implements MovieRemoteDataSource {}
class MockMovieLocalDataSource extends Mock implements MovieLocalDataSource {}

void main() {
  late MovieRepositoryImpl repository;
  late MockMovieRemoteDataSource mockRemoteDataSource;
  late MockMovieLocalDataSource mockLocalDataSource;

  setUp(() {
    mockRemoteDataSource = MockMovieRemoteDataSource();
    mockLocalDataSource = MockMovieLocalDataSource();
    repository = MovieRepositoryImpl(
      remoteDataSource: mockRemoteDataSource,
      localDataSource: mockLocalDataSource,
    );
  });

  setUpAll(() {
    registerFallbackValue(const MovieModel(
      id: 0,
      title: '',
      overview: '',
      posterPath: null,
      backdropPath: null,
      voteAverage: 0,
      releaseDate: '',
      genreIds: [],
    ));
  });

  const tMovieList = [
    MovieModel(
      id: 1,
      title: 'Test Movie',
      overview: 'Test overview',
      posterPath: '/test.jpg',
      backdropPath: null,
      voteAverage: 8.0,
      releaseDate: '2024-01-01',
      genreIds: [28, 12],
    ),
  ];

  const tMovie = MovieModel(
    id: 1,
    title: 'Test Movie',
    overview: 'Test overview',
    posterPath: '/test.jpg',
    backdropPath: null,
    voteAverage: 8.0,
    releaseDate: '2024-01-01',
    genreIds: [28, 12],
  );

  group('getPopularMovies', () {
    test('should return movies when remote call is successful', () async {
      // arrange
      when(() => mockRemoteDataSource.getPopularMovies(page: any(named: 'page')))
          .thenAnswer((_) async => tMovieList);
      when(() => mockLocalDataSource.cachePopularMovies(any()))
          .thenAnswer((_) async => Future.value());

      // act
      final result = await repository.getPopularMovies(page: 1);

      // assert
      expect(result, const Right(tMovieList));
      verify(() => mockRemoteDataSource.getPopularMovies(page: 1)).called(1);
      verify(() => mockLocalDataSource.cachePopularMovies(tMovieList)).called(1);
    });

    test('should cache only first page', () async {
      // arrange
      when(() => mockRemoteDataSource.getPopularMovies(page: any(named: 'page')))
          .thenAnswer((_) async => tMovieList);

      // act
      await repository.getPopularMovies(page: 2);

      // assert
      verify(() => mockRemoteDataSource.getPopularMovies(page: 2)).called(1);
      verifyNever(() => mockLocalDataSource.cachePopularMovies(any()));
    });

    test('should return cached movies when remote call fails on first page', () async {
      // arrange
      when(() => mockRemoteDataSource.getPopularMovies(page: any(named: 'page')))
          .thenThrow(ServerException('Network error'));
      when(() => mockLocalDataSource.getCachedPopularMovies())
          .thenAnswer((_) async => tMovieList);

      // act
      final result = await repository.getPopularMovies(page: 1);

      // assert
      expect(result, const Right(tMovieList));
      verify(() => mockLocalDataSource.getCachedPopularMovies()).called(1);
    });

    test('should return ServerFailure when remote and cache both fail', () async {
      // arrange
      when(() => mockRemoteDataSource.getPopularMovies(page: any(named: 'page')))
          .thenThrow(ServerException('Network error'));
      when(() => mockLocalDataSource.getCachedPopularMovies())
          .thenThrow(CacheException('Cache error'));

      // act
      final result = await repository.getPopularMovies(page: 1);

      // assert
      expect(result, const Left(ServerFailure('Network error')));
    });
  });

  group('getMovieDetails', () {
    const tMovieId = 1;

    test('should return movie details when remote call is successful', () async {
      // arrange
      when(() => mockRemoteDataSource.getMovieDetails(any()))
          .thenAnswer((_) async => tMovie);
      when(() => mockLocalDataSource.cacheMovieDetails(any()))
          .thenAnswer((_) async => Future.value());

      // act
      final result = await repository.getMovieDetails(tMovieId);

      // assert
      expect(result, const Right(tMovie));
      verify(() => mockRemoteDataSource.getMovieDetails(tMovieId)).called(1);
      verify(() => mockLocalDataSource.cacheMovieDetails(tMovie)).called(1);
    });

    test('should return cached movie when remote call fails', () async {
      // arrange
      when(() => mockRemoteDataSource.getMovieDetails(any()))
          .thenThrow(ServerException('Network error'));
      when(() => mockLocalDataSource.getCachedMovieById(any()))
          .thenAnswer((_) async => tMovie);

      // act
      final result = await repository.getMovieDetails(tMovieId);

      // assert
      expect(result, const Right(tMovie));
      verify(() => mockLocalDataSource.getCachedMovieById(tMovieId)).called(1);
    });

    test('should return ServerFailure when both remote and cache fail', () async {
      // arrange
      when(() => mockRemoteDataSource.getMovieDetails(any()))
          .thenThrow(ServerException('Network error'));
      when(() => mockLocalDataSource.getCachedMovieById(any()))
          .thenThrow(CacheException('Cache error'));

      // act
      final result = await repository.getMovieDetails(tMovieId);

      // assert
      expect(result, const Left(ServerFailure('Network error')));
    });
  });

  group('searchMovies', () {
    const tQuery = 'test';

    test('should return search results when remote call is successful', () async {
      // arrange
      when(() => mockRemoteDataSource.searchMovies(any(), page: any(named: 'page')))
          .thenAnswer((_) async => tMovieList);

      // act
      final result = await repository.searchMovies(tQuery, page: 1);

      // assert
      expect(result, const Right(tMovieList));
      verify(() => mockRemoteDataSource.searchMovies(tQuery, page: 1)).called(1);
    });

    test('should return cached results when remote fails on first page', () async {
      // arrange
      when(() => mockRemoteDataSource.searchMovies(any(), page: any(named: 'page')))
          .thenThrow(ServerException('Network error'));
      when(() => mockLocalDataSource.searchCachedMovies(any()))
          .thenAnswer((_) async => tMovieList);

      // act
      final result = await repository.searchMovies(tQuery, page: 1);

      // assert
      expect(result, const Right(tMovieList));
      verify(() => mockLocalDataSource.searchCachedMovies(tQuery)).called(1);
    });
  });
}
