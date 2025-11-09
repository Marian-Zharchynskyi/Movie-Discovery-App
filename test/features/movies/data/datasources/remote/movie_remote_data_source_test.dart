import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:movie_discovery_app/core/error/exceptions.dart';
import 'package:movie_discovery_app/features/movies/data/datasources/remote/movie_remote_data_source.dart';
import 'package:movie_discovery_app/features/movies/data/models/movie_model.dart';
import 'package:movie_discovery_app/features/movies/data/models/review_model.dart';
import 'package:movie_discovery_app/features/movies/data/models/video_model.dart';

class MockDio extends Mock implements Dio {}

void main() {
  late MovieRemoteDataSourceImpl dataSource;
  late MockDio mockDio;

  setUp(() {
    mockDio = MockDio();
    dataSource = MovieRemoteDataSourceImpl(client: mockDio);
  });

  group('getPopularMovies', () {
    final tMovieJson = {
      'id': 1,
      'title': 'Test Movie',
      'overview': 'Test overview',
      'poster_path': '/test.jpg',
      'backdrop_path': '/backdrop.jpg',
      'vote_average': 8.0,
      'release_date': '2024-01-01',
      'genre_ids': [28, 12],
    };

    final tResponse = Response(
      requestOptions: RequestOptions(path: '/movie/popular'),
      statusCode: 200,
      data: {
        'results': [tMovieJson],
      },
    );

    test('should return list of movies when response is successful', () async {
      // arrange
      when(() => mockDio.get(
            any(),
            queryParameters: any(named: 'queryParameters'),
          )).thenAnswer((_) async => tResponse);

      // act
      final result = await dataSource.getPopularMovies(page: 1);

      // assert
      expect(result, isA<List<MovieModel>>());
      expect(result.length, 1);
      expect(result[0].title, 'Test Movie');
      verify(() => mockDio.get(
            '/movie/popular',
            queryParameters: {'page': 1},
          )).called(1);
    });

    test('should throw ServerException when status code is not 200', () async {
      // arrange
      when(() => mockDio.get(
            any(),
            queryParameters: any(named: 'queryParameters'),
          )).thenAnswer((_) async => Response(
            requestOptions: RequestOptions(path: '/movie/popular'),
            statusCode: 404,
            data: {},
          ));

      // act & assert
      expect(
        () => dataSource.getPopularMovies(page: 1),
        throwsA(isA<ServerException>()),
      );
    });

    test('should throw ServerException when request fails', () async {
      // arrange
      when(() => mockDio.get(
            any(),
            queryParameters: any(named: 'queryParameters'),
          )).thenThrow(DioException(
        requestOptions: RequestOptions(path: '/movie/popular'),
        type: DioExceptionType.connectionTimeout,
      ));

      // act & assert
      expect(
        () => dataSource.getPopularMovies(page: 1),
        throwsA(isA<ServerException>()),
      );
    });
  });

  group('getTopRatedMovies', () {
    final tMovieJson = {
      'id': 2,
      'title': 'Top Rated Movie',
      'overview': 'Great movie',
      'poster_path': '/top.jpg',
      'backdrop_path': null,
      'vote_average': 9.5,
      'release_date': '2024-02-01',
      'genre_ids': [18],
    };

    test('should return list of top rated movies', () async {
      // arrange
      when(() => mockDio.get(
            any(),
            queryParameters: any(named: 'queryParameters'),
          )).thenAnswer((_) async => Response(
            requestOptions: RequestOptions(path: '/movie/top_rated'),
            statusCode: 200,
            data: {
              'results': [tMovieJson],
            },
          ));

      // act
      final result = await dataSource.getTopRatedMovies(page: 1);

      // assert
      expect(result, isA<List<MovieModel>>());
      expect(result.length, 1);
      expect(result[0].title, 'Top Rated Movie');
    });
  });

  group('getMovieDetails', () {
    const tMovieId = 1;
    final tMovieJson = {
      'id': tMovieId,
      'title': 'Detailed Movie',
      'overview': 'Detailed overview',
      'poster_path': '/detail.jpg',
      'backdrop_path': '/backdrop.jpg',
      'vote_average': 8.5,
      'release_date': '2024-03-01',
      'genre_ids': [28, 12, 878],
    };

    test('should return movie details when successful', () async {
      // arrange
      when(() => mockDio.get(any())).thenAnswer((_) async => Response(
            requestOptions: RequestOptions(path: '/movie/$tMovieId'),
            statusCode: 200,
            data: tMovieJson,
          ));

      // act
      final result = await dataSource.getMovieDetails(tMovieId);

      // assert
      expect(result, isA<MovieModel>());
      expect(result.title, 'Detailed Movie');
      verify(() => mockDio.get('/movie/$tMovieId')).called(1);
    });

    test('should throw ServerException when fails', () async {
      // arrange
      when(() => mockDio.get(any())).thenThrow(DioException(
        requestOptions: RequestOptions(path: '/movie/$tMovieId'),
      ));

      // act & assert
      expect(
        () => dataSource.getMovieDetails(tMovieId),
        throwsA(isA<ServerException>()),
      );
    });
  });

  group('searchMovies', () {
    const tQuery = 'Inception';
    final tMovieJson = {
      'id': 3,
      'title': 'Inception',
      'overview': 'Dream movie',
      'poster_path': '/inception.jpg',
      'backdrop_path': null,
      'vote_average': 8.8,
      'release_date': '2010-07-16',
      'genre_ids': [28, 878, 53],
    };

    test('should return search results when successful', () async {
      // arrange
      when(() => mockDio.get(
            any(),
            queryParameters: any(named: 'queryParameters'),
          )).thenAnswer((_) async => Response(
            requestOptions: RequestOptions(path: '/search/movie'),
            statusCode: 200,
            data: {
              'results': [tMovieJson],
            },
          ));

      // act
      final result = await dataSource.searchMovies(tQuery, page: 1);

      // assert
      expect(result, isA<List<MovieModel>>());
      expect(result.length, 1);
      expect(result[0].title, 'Inception');
      verify(() => mockDio.get(
            '/search/movie',
            queryParameters: {'query': tQuery, 'page': 1},
          )).called(1);
    });

    test('should return empty list when no results', () async {
      // arrange
      when(() => mockDio.get(
            any(),
            queryParameters: any(named: 'queryParameters'),
          )).thenAnswer((_) async => Response(
            requestOptions: RequestOptions(path: '/search/movie'),
            statusCode: 200,
            data: {
              'results': [],
            },
          ));

      // act
      final result = await dataSource.searchMovies(tQuery);

      // assert
      expect(result, isEmpty);
    });
  });

  group('getMovieVideos', () {
    const tMovieId = 1;
    final tVideoJson = {
      'id': 'video1',
      'key': 'abc123',
      'name': 'Official Trailer',
      'site': 'YouTube',
      'type': 'Trailer',
      'official': true,
      'published_at': '2024-01-01',
    };

    test('should return list of videos when successful', () async {
      // arrange
      when(() => mockDio.get(any())).thenAnswer((_) async => Response(
            requestOptions: RequestOptions(path: '/movie/$tMovieId/videos'),
            statusCode: 200,
            data: {
              'results': [tVideoJson],
            },
          ));

      // act
      final result = await dataSource.getMovieVideos(tMovieId);

      // assert
      expect(result, isA<List<VideoModel>>());
      expect(result.length, 1);
      expect(result[0].key, 'abc123');
    });

    test('should throw ServerException when fails', () async {
      // arrange
      when(() => mockDio.get(any())).thenThrow(DioException(
        requestOptions: RequestOptions(path: '/movie/$tMovieId/videos'),
      ));

      // act & assert
      expect(
        () => dataSource.getMovieVideos(tMovieId),
        throwsA(isA<ServerException>()),
      );
    });
  });

  group('getMovieReviews', () {
    const tMovieId = 1;
    final tReviewJson = {
      'id': 'review1',
      'author': 'John Doe',
      'content': 'Great movie!',
      'created_at': '2024-01-15',
      'author_details': {
        'rating': 9.0,
      },
    };

    test('should return list of reviews when successful', () async {
      // arrange
      when(() => mockDio.get(
            any(),
            queryParameters: any(named: 'queryParameters'),
          )).thenAnswer((_) async => Response(
            requestOptions: RequestOptions(path: '/movie/$tMovieId/reviews'),
            statusCode: 200,
            data: {
              'results': [tReviewJson],
            },
          ));

      // act
      final result = await dataSource.getMovieReviews(tMovieId, page: 1);

      // assert
      expect(result, isA<List<ReviewModel>>());
      expect(result.length, 1);
      expect(result[0].author, 'John Doe');
    });

    test('should return empty list when no reviews', () async {
      // arrange
      when(() => mockDio.get(
            any(),
            queryParameters: any(named: 'queryParameters'),
          )).thenAnswer((_) async => Response(
            requestOptions: RequestOptions(path: '/movie/$tMovieId/reviews'),
            statusCode: 200,
            data: {
              'results': [],
            },
          ));

      // act
      final result = await dataSource.getMovieReviews(tMovieId);

      // assert
      expect(result, isEmpty);
    });
  });

  group('discoverMovies', () {
    final tMovieJson = {
      'id': 4,
      'title': 'Discovered Movie',
      'overview': 'Found it!',
      'poster_path': '/discover.jpg',
      'backdrop_path': null,
      'vote_average': 7.5,
      'release_date': '2024-04-01',
      'genre_ids': [28],
    };

    test('should discover movies with filters', () async {
      // arrange
      when(() => mockDio.get(
            any(),
            queryParameters: any(named: 'queryParameters'),
          )).thenAnswer((_) async => Response(
            requestOptions: RequestOptions(path: '/discover/movie'),
            statusCode: 200,
            data: {
              'results': [tMovieJson],
            },
          ));

      // act
      final result = await dataSource.discoverMovies(
        page: 1,
        genreIds: [28],
        year: 2024,
        minRating: 7.0,
      );

      // assert
      expect(result, isA<List<MovieModel>>());
      expect(result.length, 1);
      verify(() => mockDio.get(
            '/discover/movie',
            queryParameters: {
              'page': 1,
              'with_genres': '28',
              'primary_release_year': 2024,
              'vote_average.gte': 7.0,
            },
          )).called(1);
    });

    test('should discover movies without filters', () async {
      // arrange
      when(() => mockDio.get(
            any(),
            queryParameters: any(named: 'queryParameters'),
          )).thenAnswer((_) async => Response(
            requestOptions: RequestOptions(path: '/discover/movie'),
            statusCode: 200,
            data: {
              'results': [tMovieJson],
            },
          ));

      // act
      final result = await dataSource.discoverMovies(page: 1);

      // assert
      expect(result, isA<List<MovieModel>>());
      verify(() => mockDio.get(
            '/discover/movie',
            queryParameters: {'page': 1},
          )).called(1);
    });
  });
}
