import 'package:dio/dio.dart';
import 'package:movie_discovery_app/core/error/exceptions.dart';
import 'package:movie_discovery_app/features/movies/data/models/movie_model.dart';
import 'package:movie_discovery_app/features/movies/data/models/video_model.dart';
import 'package:movie_discovery_app/features/movies/data/models/review_model.dart';

abstract class MovieRemoteDataSource {
  Future<List<MovieModel>> getPopularMovies({int page = 1});
  Future<List<MovieModel>> getTopRatedMovies({int page = 1});
  Future<MovieModel> getMovieDetails(int movieId);
  Future<List<MovieModel>> searchMovies(String query, {int page = 1});
  Future<List<VideoModel>> getMovieVideos(int movieId);
  Future<List<ReviewModel>> getMovieReviews(int movieId, {int page = 1});
  Future<List<MovieModel>> discoverMovies({
    int page = 1,
    List<int>? genreIds,
    int? year,
    double? minRating,
  });
}

class MovieRemoteDataSourceImpl implements MovieRemoteDataSource {
  final Dio client;

  MovieRemoteDataSourceImpl({required this.client});

  @override
  Future<List<MovieModel>> getPopularMovies({int page = 1}) async {
    try {
      final response = await client.get(
        '/movie/popular',
        queryParameters: {'page': page},
      );
      if (response.statusCode == 200) {
        return (response.data['results'] as List)
            .map((movie) => MovieModel.fromJson(movie))
            .toList();
      } else {
        throw ServerException('Failed to load popular movies');
      }
    } catch (e) {
      throw ServerException('Failed to load popular movies: $e');
    }
  }

  @override
  Future<MovieModel> getMovieDetails(int movieId) async {
    try {
      final response = await client.get('/movie/$movieId');
      if (response.statusCode == 200) {
        return MovieModel.fromJson(response.data);
      } else {
        throw ServerException('Failed to load movie details');
      }
    } catch (e) {
      throw ServerException('Failed to load movie details: $e');
    }
  }

  @override
  Future<List<MovieModel>> getTopRatedMovies({int page = 1}) async {
    try {
      final response = await client.get(
        '/movie/top_rated',
        queryParameters: {'page': page},
      );
      if (response.statusCode == 200) {
        return (response.data['results'] as List)
            .map((movie) => MovieModel.fromJson(movie))
            .toList();
      } else {
        throw ServerException('Failed to load top rated movies');
      }
    } catch (e) {
      throw ServerException('Failed to load top rated movies: $e');
    }
  }

  @override
  Future<List<MovieModel>> searchMovies(String query, {int page = 1}) async {
    try {
      final response = await client.get(
        '/search/movie',
        queryParameters: {
          'query': query,
          'page': page,
        },
      );
      if (response.statusCode == 200) {
        return (response.data['results'] as List)
            .map((movie) => MovieModel.fromJson(movie))
            .toList();
      } else {
        throw ServerException('Failed to search movies');
      }
    } catch (e) {
      throw ServerException('Failed to search movies: $e');
    }
  }

  @override
  Future<List<VideoModel>> getMovieVideos(int movieId) async {
    try {
      final response = await client.get('/movie/$movieId/videos');
      if (response.statusCode == 200) {
        return (response.data['results'] as List)
            .map((video) => VideoModel.fromJson(video))
            .toList();
      } else {
        throw ServerException('Failed to load movie videos');
      }
    } catch (e) {
      throw ServerException('Failed to load movie videos: $e');
    }
  }

  @override
  Future<List<ReviewModel>> getMovieReviews(int movieId, {int page = 1}) async {
    try {
      final response = await client.get(
        '/movie/$movieId/reviews',
        queryParameters: {'page': page},
      );
      if (response.statusCode == 200) {
        return (response.data['results'] as List)
            .map((review) => ReviewModel.fromJson(review))
            .toList();
      } else {
        throw ServerException('Failed to load movie reviews');
      }
    } catch (e) {
      throw ServerException('Failed to load movie reviews: $e');
    }
  }

  @override
  Future<List<MovieModel>> discoverMovies({
    int page = 1,
    List<int>? genreIds,
    int? year,
    double? minRating,
  }) async {
    try {
      final queryParams = <String, dynamic>{'page': page};
      
      if (genreIds != null && genreIds.isNotEmpty) {
        queryParams['with_genres'] = genreIds.join(',');
      }
      if (year != null) {
        queryParams['primary_release_year'] = year;
      }
      if (minRating != null) {
        queryParams['vote_average.gte'] = minRating;
      }

      final response = await client.get(
        '/discover/movie',
        queryParameters: queryParams,
      );
      
      if (response.statusCode == 200) {
        return (response.data['results'] as List)
            .map((movie) => MovieModel.fromJson(movie))
            .toList();
      } else {
        throw ServerException('Failed to discover movies');
      }
    } catch (e) {
      throw ServerException('Failed to discover movies: $e');
    }
  }
}
