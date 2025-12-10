import 'package:hive_flutter/hive_flutter.dart';
import 'package:movie_discovery_app/core/error/exceptions.dart';
import 'package:movie_discovery_app/features/movies/data/models/video_model.dart';

abstract class VideoLocalDataSource {
  Future<void> cacheVideos(int movieId, List<VideoModel> videos);
  Future<List<VideoModel>> getCachedVideos(int movieId);
}

class VideoLocalDataSourceImpl implements VideoLocalDataSource {
  static const String _boxName = 'movie_videos_cache';
  static const Duration _ttl = Duration(hours: 12);

  Future<Box> _box() async => await Hive.openBox(_boxName);

  String _key(int movieId) => '$movieId';

  @override
  Future<void> cacheVideos(int movieId, List<VideoModel> videos) async {
    try {
      final box = await _box();
      await box.put(_key(movieId), {
        'data': videos.map((v) => v.toJson()).toList(),
        'cachedAt': DateTime.now().millisecondsSinceEpoch,
      });
    } catch (e) {
      throw CacheException('Failed to cache videos: $e');
    }
  }

  @override
  Future<List<VideoModel>> getCachedVideos(int movieId) async {
    try {
      final box = await _box();
      final raw = box.get(_key(movieId));
      if (raw == null) return [];
      final cachedAt = DateTime.fromMillisecondsSinceEpoch(raw['cachedAt'] as int);
      if (DateTime.now().difference(cachedAt) > _ttl) return [];
      final list = (raw['data'] as List).cast<Map>().map((e) => VideoModel.fromJson(Map<String, dynamic>.from(e))).toList();
      return list;
    } catch (e) {
      throw CacheException('Failed to get cached videos: $e');
    }
  }
}
