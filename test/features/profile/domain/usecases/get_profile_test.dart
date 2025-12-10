import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:movie_discovery_app/core/error/failures.dart';
import 'package:movie_discovery_app/features/profile/domain/entities/profile_entity.dart';
import 'package:movie_discovery_app/features/profile/domain/repositories/profile_repository.dart';
import 'package:movie_discovery_app/features/profile/domain/usecases/get_profile.dart';

import 'get_profile_test.mocks.dart';

@GenerateMocks([ProfileRepository])
void main() {
  late GetProfile usecase;
  late MockProfileRepository mockProfileRepository;

  setUp(() {
    mockProfileRepository = MockProfileRepository();
    usecase = GetProfile(mockProfileRepository);
  });

  const tProfile = ProfileEntity(
    id: 'test-user-id',
    email: 'test@example.com',
    displayName: 'Test User',
    photoUrl: 'https://example.com/photo.jpg',
    role: 'User',
  );

  test('should get profile from the repository', () async {
    // arrange
    when(mockProfileRepository.getProfile())
        .thenAnswer((_) async => const Right(tProfile));

    // act
    final result = await usecase();

    // assert
    expect(result, const Right(tProfile));
    verify(mockProfileRepository.getProfile());
    verifyNoMoreInteractions(mockProfileRepository);
  });

  test('should return failure when repository fails', () async {
    // arrange
    const tFailure = CacheFailure('Failed to get profile');
    when(mockProfileRepository.getProfile())
        .thenAnswer((_) async => const Left(tFailure));

    // act
    final result = await usecase();

    // assert
    expect(result, const Left(tFailure));
    verify(mockProfileRepository.getProfile());
    verifyNoMoreInteractions(mockProfileRepository);
  });
}
