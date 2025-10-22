import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:movie_discovery_app/core/error/failures.dart';
import 'package:movie_discovery_app/features/movies/domain/entities/video_entity.dart';
import 'package:movie_discovery_app/features/movies/domain/repositories/movie_repository.dart';
import 'package:movie_discovery_app/features/movies/domain/usecases/get_movie_videos.dart';

class MockMovieRepository extends Mock implements MovieRepository {}

void main() {
  late GetMovieVideos usecase;
  late MockMovieRepository mockMovieRepository;

  setUp(() {
    mockMovieRepository = MockMovieRepository();
    usecase = GetMovieVideos(mockMovieRepository);
  });

  const tMovieId = 1;
  const tVideoList = [
    VideoEntity(
      id: '1',
      key: 'abc123',
      name: 'Official Trailer',
      site: 'YouTube',
      type: 'Trailer',
      official: true,
    ),
    VideoEntity(
      id: '2',
      key: 'def456',
      name: 'Behind the Scenes',
      site: 'YouTube',
      type: 'Featurette',
      official: false,
    ),
  ];

  test('should get movie videos from repository', () async {
    // arrange
    when(() => mockMovieRepository.getMovieVideos(any()))
        .thenAnswer((_) async => const Right(tVideoList));

    // act
    final result = await usecase(tMovieId);

    // assert
    expect(result, const Right(tVideoList));
    verify(() => mockMovieRepository.getMovieVideos(tMovieId)).called(1);
    verifyNoMoreInteractions(mockMovieRepository);
  });

  test('should return empty list when no videos', () async {
    // arrange
    when(() => mockMovieRepository.getMovieVideos(any()))
        .thenAnswer((_) async => const Right([]));

    // act
    final result = await usecase(tMovieId);

    // assert
    result.fold(
      (l) => fail('Expected Right, got Left: ${l.runtimeType}'),
      (r) => expect(r, isEmpty),
    );
  });

  test('should return ServerFailure when getting videos fails', () async {
    // arrange
    const tFailure = ServerFailure('Failed to get videos');
    when(() => mockMovieRepository.getMovieVideos(any()))
        .thenAnswer((_) async => const Left(tFailure));

    // act
    final result = await usecase(tMovieId);

    // assert
    expect(result, const Left(tFailure));
  });
}
