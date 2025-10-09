import 'package:dartz/dartz.dart';
import 'package:movie_discovery_app/core/error/failures.dart';
import 'package:movie_discovery_app/features/movies/domain/entities/video_entity.dart';
import 'package:movie_discovery_app/features/movies/domain/repositories/movie_repository.dart';

class GetMovieVideos {
  final MovieRepository repository;

  GetMovieVideos(this.repository);

  Future<Either<Failure, List<VideoEntity>>> call(int movieId) async {
    return await repository.getMovieVideos(movieId);
  }
}
