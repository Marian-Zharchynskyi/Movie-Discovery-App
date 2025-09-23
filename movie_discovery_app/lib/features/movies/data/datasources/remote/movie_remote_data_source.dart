import 'package:dio/dio.dart';
import 'package:movie_discovery_app/core/error/exceptions.dart';
import 'package:movie_discovery_app/features/movies/data/models/movie_model.dart';

abstract class MovieRemoteDataSource {
  Future<List<MovieModel>> getPopularMovies();
  Future<List<MovieModel>> getTopRatedMovies();
  Future<MovieModel> getMovieDetails(int movieId);
}

class MovieRemoteDataSourceImpl implements MovieRemoteDataSource {
  final Dio client;

  MovieRemoteDataSourceImpl({required this.client});

  @override
  Future<List<MovieModel>> getPopularMovies() async {
    try {
      final response = await client.get('/movie/popular');
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
  Future<List<MovieModel>> getTopRatedMovies() async {
    try {
      final response = await client.get('/movie/top_rated');
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
}
