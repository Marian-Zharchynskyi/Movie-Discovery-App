import 'package:flutter_test/flutter_test.dart';
import 'package:movie_discovery_app/features/movies/domain/entities/video_entity.dart';

void main() {
  group('VideoEntity', () {
    const tVideoEntity = VideoEntity(
      id: '123',
      key: 'abc123xyz',
      name: 'Official Trailer',
      site: 'YouTube',
      type: 'Trailer',
      official: true,
    );

    test('should create VideoEntity with all fields', () {
      // assert
      expect(tVideoEntity.id, '123');
      expect(tVideoEntity.key, 'abc123xyz');
      expect(tVideoEntity.name, 'Official Trailer');
      expect(tVideoEntity.site, 'YouTube');
      expect(tVideoEntity.type, 'Trailer');
      expect(tVideoEntity.official, true);
    });

    test('should generate correct YouTube URL', () {
      // act
      final url = tVideoEntity.youtubeUrl;

      // assert
      expect(url, 'https://www.youtube.com/watch?v=abc123xyz');
    });

    test('should generate correct YouTube thumbnail URL', () {
      // act
      final thumbnail = tVideoEntity.youtubeThumbnail;

      // assert
      expect(thumbnail, 'https://img.youtube.com/vi/abc123xyz/hqdefault.jpg');
    });

    test('should handle different video keys in URLs', () {
      // arrange
      const video = VideoEntity(
        id: '456',
        key: 'different_key_123',
        name: 'Teaser',
        site: 'YouTube',
        type: 'Teaser',
        official: false,
      );

      // act & assert
      expect(video.youtubeUrl, 'https://www.youtube.com/watch?v=different_key_123');
      expect(video.youtubeThumbnail, 'https://img.youtube.com/vi/different_key_123/hqdefault.jpg');
    });

    test('should create non-official video', () {
      // arrange
      const video = VideoEntity(
        id: '789',
        key: 'xyz789',
        name: 'Fan Made',
        site: 'YouTube',
        type: 'Clip',
        official: false,
      );

      // assert
      expect(video.official, false);
    });
  });
}
