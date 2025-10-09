import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:movie_discovery_app/core/injection_container.dart';
import 'package:movie_discovery_app/features/movies/domain/entities/video_entity.dart';
import 'package:movie_discovery_app/features/movies/domain/usecases/get_movie_videos.dart';

final getMovieVideosProvider = Provider<GetMovieVideos>((ref) {
  return sl<GetMovieVideos>();
});

final movieVideosProvider = FutureProvider.family<List<VideoEntity>, int>((ref, movieId) async {
  final getMovieVideos = ref.watch(getMovieVideosProvider);
  final result = await getMovieVideos(movieId);
  return result.fold(
    (failure) => throw Exception(failure.message),
    (videos) => videos,
  );
});
