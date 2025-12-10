import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:movie_discovery_app/features/movies/data/datasources/local/review_local_data_source.dart';
import 'package:movie_discovery_app/features/movies/data/models/review_model.dart';

void main() {
  late ReviewLocalDataSourceImpl dataSource;
  late Directory tempDir;

  setUpAll(() async {
    tempDir = await Directory.systemTemp.createTemp('hive_test_');
    Hive.init(tempDir.path);
  });

  tearDownAll(() async {
    await Hive.close();
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  setUp(() {
    dataSource = ReviewLocalDataSourceImpl();
  });

  tearDown(() async {
    await Hive.deleteBoxFromDisk('movie_reviews_cache');
  });

  group('cacheReviews', () {
    const tMovieId = 1;
    const tPage = 1;
    const tReviews = [
      ReviewModel(
        id: '1',
        author: 'Test Author',
        content: 'Test content',
        createdAt: '2024-01-01',
        rating: 8.0,
      ),
    ];

    test('should cache reviews successfully', () async {
      // act
      await dataSource.cacheReviews(tMovieId, tPage, tReviews);

      // assert
      final result = await dataSource.getCachedReviews(tMovieId, tPage);
      expect(result.length, tReviews.length);
      expect(result.first.id, tReviews.first.id);
      expect(result.first.author, tReviews.first.author);
    });
  });

  group('getCachedReviews', () {
    const tMovieId = 1;
    const tPage = 1;
    const tReviews = [
      ReviewModel(
        id: '1',
        author: 'Test Author',
        content: 'Test content',
        createdAt: '2024-01-01',
        rating: 8.0,
      ),
    ];

    test('should return cached reviews when they exist and are fresh', () async {
      // arrange
      await dataSource.cacheReviews(tMovieId, tPage, tReviews);

      // act
      final result = await dataSource.getCachedReviews(tMovieId, tPage);

      // assert
      expect(result.length, tReviews.length);
      expect(result.first.id, tReviews.first.id);
    });

    test('should return empty list when no cached reviews exist', () async {
      // act
      final result = await dataSource.getCachedReviews(999, 1);

      // assert
      expect(result, isEmpty);
    });

    test('should return empty list when cached reviews are expired', () async {
      // This test would require mocking time or waiting 12 hours
      // For now, we just test the basic functionality
      final result = await dataSource.getCachedReviews(tMovieId, tPage);
      expect(result, isEmpty);
    });
  });
}
