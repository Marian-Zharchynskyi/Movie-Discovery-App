import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:movie_discovery_app/core/error/failures.dart';
import 'package:movie_discovery_app/features/movies/domain/entities/video_entity.dart';
import 'package:movie_discovery_app/features/movies/domain/usecases/get_movie_videos.dart';
import 'package:movie_discovery_app/features/movies/presentation/providers/movie_videos_provider.dart';

import 'movie_videos_provider_test.mocks.dart';

@GenerateMocks([GetMovieVideos])
void main() {
  late MockGetMovieVideos mockGetMovieVideos;

  setUp(() {
    mockGetMovieVideos = MockGetMovieVideos();
  });

  group('movieVideosProvider', () {
    const tMovieId = 123;
    final tVideos = [
      const VideoEntity(
        id: '1',
        key: 'abc123',
        name: 'Official Trailer',
        site: 'YouTube',
        type: 'Trailer',
        official: true,
      ),
      const VideoEntity(
        id: '2',
        key: 'def456',
        name: 'Behind the Scenes',
        site: 'YouTube',
        type: 'Featurette',
        official: false,
      ),
    ];

    test('should return list of videos when use case succeeds', () async {
      // arrange
      when(mockGetMovieVideos(any))
          .thenAnswer((_) async => Right(tVideos));

      final container = ProviderContainer(
        overrides: [
          getMovieVideosProvider.overrideWithValue(mockGetMovieVideos),
        ],
      );
      addTearDown(container.dispose);

      // act
      final result = await container.read(movieVideosProvider(tMovieId).future);

      // assert
      expect(result, tVideos);
      verify(mockGetMovieVideos(tMovieId));
      verifyNoMoreInteractions(mockGetMovieVideos);
    });

    test('should throw exception when use case fails', () async {
      // arrange
      const tFailure = ServerFailure('Server error');
      when(mockGetMovieVideos(any))
          .thenAnswer((_) async => const Left(tFailure));

      final container = ProviderContainer(
        overrides: [
          getMovieVideosProvider.overrideWithValue(mockGetMovieVideos),
        ],
      );
      addTearDown(container.dispose);

      // act & assert
      expect(
        () => container.read(movieVideosProvider(tMovieId).future),
        throwsA(isA<Exception>()),
      );
      verify(mockGetMovieVideos(tMovieId));
    });

    test('should return empty list when no videos available', () async {
      // arrange
      when(mockGetMovieVideos(any))
          .thenAnswer((_) async => const Right([]));

      final container = ProviderContainer(
        overrides: [
          getMovieVideosProvider.overrideWithValue(mockGetMovieVideos),
        ],
      );
      addTearDown(container.dispose);

      // act
      final result = await container.read(movieVideosProvider(tMovieId).future);

      // assert
      expect(result, isEmpty);
      verify(mockGetMovieVideos(tMovieId));
    });

    test('should handle different video types', () async {
      // arrange
      final tTrailers = [
        const VideoEntity(
          id: '1',
          key: 'trailer1',
          name: 'Main Trailer',
          site: 'YouTube',
          type: 'Trailer',
          official: true,
        ),
      ];
      when(mockGetMovieVideos(any))
          .thenAnswer((_) async => Right(tTrailers));

      final container = ProviderContainer(
        overrides: [
          getMovieVideosProvider.overrideWithValue(mockGetMovieVideos),
        ],
      );
      addTearDown(container.dispose);

      // act
      final result = await container.read(movieVideosProvider(tMovieId).future);

      // assert
      expect(result.length, 1);
      expect(result.first.type, 'Trailer');
      verify(mockGetMovieVideos(tMovieId));
    });
  });
}
