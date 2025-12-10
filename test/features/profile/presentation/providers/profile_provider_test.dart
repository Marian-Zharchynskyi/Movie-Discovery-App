import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:movie_discovery_app/core/error/failures.dart';
import 'package:movie_discovery_app/features/profile/domain/entities/profile_entity.dart';
import 'package:movie_discovery_app/features/profile/domain/usecases/get_profile.dart';
import 'package:movie_discovery_app/features/profile/presentation/providers/profile_provider.dart';

import 'profile_provider_test.mocks.dart';

@GenerateMocks([GetProfile])
void main() {
  late ProfileNotifier notifier;
  late MockGetProfile mockGetProfile;

  setUp(() {
    mockGetProfile = MockGetProfile();
    notifier = ProfileNotifier(getProfile: mockGetProfile);
  });

  const tProfile = ProfileEntity(
    id: 'test-user-id',
    email: 'test@example.com',
    displayName: 'Test User',
    photoUrl: 'https://example.com/photo.jpg',
    role: 'User',
  );

  group('ProfileNotifier', () {
    test('initial state should be ProfileState.initial', () {
      expect(notifier.state, const ProfileState.initial());
    });

    test('should emit loading and profile when loadProfile succeeds', () async {
      // arrange
      when(mockGetProfile()).thenAnswer((_) async => const Right(tProfile));

      // act
      await notifier.loadProfile();

      // assert
      expect(notifier.state.profile, tProfile);
      expect(notifier.state.isLoading, false);
      expect(notifier.state.error, null);
      verify(mockGetProfile());
    });

    test('should emit loading and error when loadProfile fails', () async {
      // arrange
      const tFailure = CacheFailure('Failed to load profile');
      when(mockGetProfile()).thenAnswer((_) async => const Left(tFailure));

      // act
      await notifier.loadProfile();

      // assert
      expect(notifier.state.profile, null);
      expect(notifier.state.isLoading, false);
      expect(notifier.state.error, tFailure.message);
      verify(mockGetProfile());
    });

    test('should clear error when clearError is called', () async {
      // arrange
      const tFailure = CacheFailure('Failed to load profile');
      when(mockGetProfile()).thenAnswer((_) async => const Left(tFailure));
      await notifier.loadProfile();

      // act
      notifier.clearError();

      // assert
      expect(notifier.state.error, null);
    });
  });
}
