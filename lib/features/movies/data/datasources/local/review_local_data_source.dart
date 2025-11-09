import 'package:hive_flutter/hive_flutter.dart';
import 'package:movie_discovery_app/core/error/exceptions.dart';
import 'package:movie_discovery_app/features/movies/data/models/review_model.dart';

abstract class ReviewLocalDataSource {
  Future<void> cacheReviews(int movieId, int page, List<ReviewModel> reviews);
  Future<List<ReviewModel>> getCachedReviews(int movieId, int page);
}

class ReviewLocalDataSourceImpl implements ReviewLocalDataSource {
  static const String _boxName = 'movie_reviews_cache';
  static const Duration _ttl = Duration(hours: 12);

  Future<Box> _box() async => await Hive.openBox(_boxName);

  String _key(int movieId, int page) => '$movieId:$page';

  @override
  Future<void> cacheReviews(int movieId, int page, List<ReviewModel> reviews) async {
    try {
      final box = await _box();
      await box.put(_key(movieId, page), {
        'data': reviews.map((r) => r.toJson()).toList(),
        'cachedAt': DateTime.now().millisecondsSinceEpoch,
      });
    } catch (e) {
      throw CacheException('Failed to cache reviews: $e');
    }
  }

  @override
  Future<List<ReviewModel>> getCachedReviews(int movieId, int page) async {
    try {
      final box = await _box();
      final raw = box.get(_key(movieId, page));
      if (raw == null) return [];
      final cachedAt = DateTime.fromMillisecondsSinceEpoch(raw['cachedAt'] as int);
      if (DateTime.now().difference(cachedAt) > _ttl) return [];
      final list = (raw['data'] as List).cast<Map>().map((e) => ReviewModel.fromJson(Map<String, dynamic>.from(e))).toList();
      return list;
    } catch (e) {
      throw CacheException('Failed to get cached reviews: $e');
    }
  }
}
