import 'package:flutter_test/flutter_test.dart';
import 'package:movie_discovery_app/features/movies/data/models/video_model.dart';

void main() {
  group('VideoModel', () {
    const tVideoModel = VideoModel(
      id: '123',
      key: 'abc123xyz',
      name: 'Official Trailer',
      site: 'YouTube',
      type: 'Trailer',
      official: true,
    );

    group('fromJson', () {
      test('should return a valid VideoModel from JSON', () {
        // arrange
        final json = {
          'id': '123',
          'key': 'abc123xyz',
          'name': 'Official Trailer',
          'site': 'YouTube',
          'type': 'Trailer',
          'official': true,
        };

        // act
        final result = VideoModel.fromJson(json);

        // assert
        expect(result.id, '123');
        expect(result.key, 'abc123xyz');
        expect(result.name, 'Official Trailer');
        expect(result.site, 'YouTube');
        expect(result.type, 'Trailer');
        expect(result.official, true);
      });

      test('should default official to false when not provided', () {
        // arrange
        final json = {
          'id': '123',
          'key': 'abc123xyz',
          'name': 'Behind the Scenes',
          'site': 'YouTube',
          'type': 'Featurette',
        };

        // act
        final result = VideoModel.fromJson(json);

        // assert
        expect(result.official, false);
      });

      test('should handle official as null', () {
        // arrange
        final json = {
          'id': '123',
          'key': 'abc123xyz',
          'name': 'Clip',
          'site': 'YouTube',
          'type': 'Clip',
          'official': null,
        };

        // act
        final result = VideoModel.fromJson(json);

        // assert
        expect(result.official, false);
      });

      test('should handle different video types', () {
        // arrange
        final json = {
          'id': '456',
          'key': 'def456',
          'name': 'Teaser',
          'site': 'Vimeo',
          'type': 'Teaser',
          'official': false,
        };

        // act
        final result = VideoModel.fromJson(json);

        // assert
        expect(result.type, 'Teaser');
        expect(result.site, 'Vimeo');
        expect(result.official, false);
      });
    });

    group('toJson', () {
      test('should return a JSON map containing proper data', () {
        // act
        final result = tVideoModel.toJson();

        // assert
        final expectedMap = {
          'id': '123',
          'key': 'abc123xyz',
          'name': 'Official Trailer',
          'site': 'YouTube',
          'type': 'Trailer',
          'official': true,
        };
        expect(result, expectedMap);
      });

      test('should handle official false in toJson', () {
        // arrange
        const videoModel = VideoModel(
          id: '123',
          key: 'abc123',
          name: 'Clip',
          site: 'YouTube',
          type: 'Clip',
          official: false,
        );

        // act
        final result = videoModel.toJson();

        // assert
        expect(result['official'], false);
      });
    });

    group('fromJson and toJson', () {
      test('should maintain data integrity through serialization cycle', () {
        // arrange
        final json = tVideoModel.toJson();

        // act
        final result = VideoModel.fromJson(json);

        // assert
        expect(result.id, tVideoModel.id);
        expect(result.key, tVideoModel.key);
        expect(result.name, tVideoModel.name);
        expect(result.site, tVideoModel.site);
        expect(result.type, tVideoModel.type);
        expect(result.official, tVideoModel.official);
      });

      test('should handle round trip with official false', () {
        // arrange
        const videoModel = VideoModel(
          id: '789',
          key: 'ghi789',
          name: 'Behind the Scenes',
          site: 'YouTube',
          type: 'Featurette',
          official: false,
        );
        final json = videoModel.toJson();

        // act
        final result = VideoModel.fromJson(json);

        // assert
        expect(result.official, false);
      });
    });
  });
}
