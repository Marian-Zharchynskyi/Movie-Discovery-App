import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:movie_discovery_app/features/movies/data/datasources/local/video_local_data_source.dart';
import 'package:movie_discovery_app/features/movies/data/models/video_model.dart';

void main() {
  late VideoLocalDataSourceImpl dataSource;

  setUpAll(() async {
    await Hive.initFlutter();
  });

  setUp(() {
    dataSource = VideoLocalDataSourceImpl();
  });

  tearDown(() async {
    await Hive.deleteBoxFromDisk('movie_videos_cache');
  });

  group('cacheVideos', () {
    const tMovieId = 1;
    final tVideos = [
      const VideoModel(
        id: '1',
        key: 'abc123',
        name: 'Test Trailer',
        site: 'YouTube',
        type: 'Trailer',
        official: true,
      ),
    ];

    test('should cache videos successfully', () async {
      // act
      await dataSource.cacheVideos(tMovieId, tVideos);

      // assert
      final result = await dataSource.getCachedVideos(tMovieId);
      expect(result.length, tVideos.length);
      expect(result.first.id, tVideos.first.id);
      expect(result.first.key, tVideos.first.key);
    });
  });

  group('getCachedVideos', () {
    const tMovieId = 1;
    final tVideos = [
      const VideoModel(
        id: '1',
        key: 'abc123',
        name: 'Test Trailer',
        site: 'YouTube',
        type: 'Trailer',
        official: true,
      ),
    ];

    test('should return cached videos when they exist and are fresh', () async {
      // arrange
      await dataSource.cacheVideos(tMovieId, tVideos);

      // act
      final result = await dataSource.getCachedVideos(tMovieId);

      // assert
      expect(result.length, tVideos.length);
      expect(result.first.id, tVideos.first.id);
    });

    test('should return empty list when no cached videos exist', () async {
      // act
      final result = await dataSource.getCachedVideos(999);

      // assert
      expect(result, isEmpty);
    });

    test('should return empty list for non-existent movie', () async {
      // act
      final result = await dataSource.getCachedVideos(tMovieId);

      // assert - no videos cached yet
      expect(result, isEmpty);
    });
  });
}
