import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:movie_discovery_app/core/error/failures.dart';
import 'package:movie_discovery_app/features/profile/domain/repositories/profile_repository.dart';
import 'package:movie_discovery_app/features/profile/domain/usecases/get_theme_mode.dart';

import 'get_theme_mode_test.mocks.dart';

@GenerateMocks([ProfileRepository])
void main() {
  late GetThemeMode usecase;
  late MockProfileRepository mockProfileRepository;

  setUp(() {
    mockProfileRepository = MockProfileRepository();
    usecase = GetThemeMode(mockProfileRepository);
  });

  const tThemeMode = 'dark';

  test('should get theme mode from the repository', () async {
    // arrange
    when(mockProfileRepository.getThemeMode())
        .thenAnswer((_) async => const Right(tThemeMode));

    // act
    final result = await usecase();

    // assert
    expect(result, const Right(tThemeMode));
    verify(mockProfileRepository.getThemeMode());
    verifyNoMoreInteractions(mockProfileRepository);
  });

  test('should return failure when repository fails', () async {
    // arrange
    const tFailure = CacheFailure('Failed to get theme mode');
    when(mockProfileRepository.getThemeMode())
        .thenAnswer((_) async => const Left(tFailure));

    // act
    final result = await usecase();

    // assert
    expect(result, const Left(tFailure));
    verify(mockProfileRepository.getThemeMode());
    verifyNoMoreInteractions(mockProfileRepository);
  });
}
