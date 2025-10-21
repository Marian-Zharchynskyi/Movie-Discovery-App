import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:movie_discovery_app/core/error/failures.dart';
import 'package:movie_discovery_app/features/profile/domain/repositories/profile_repository.dart';
import 'package:movie_discovery_app/features/profile/domain/usecases/set_theme_mode.dart';

import 'set_theme_mode_test.mocks.dart';

@GenerateMocks([ProfileRepository])
void main() {
  late SetThemeMode usecase;
  late MockProfileRepository mockProfileRepository;

  setUp(() {
    mockProfileRepository = MockProfileRepository();
    usecase = SetThemeMode(mockProfileRepository);
  });

  const tThemeMode = 'dark';

  test('should set theme mode in the repository', () async {
    // arrange
    when(mockProfileRepository.setThemeMode(any))
        .thenAnswer((_) async => const Right(null));

    // act
    final result = await usecase(tThemeMode);

    // assert
    expect(result, const Right(null));
    verify(mockProfileRepository.setThemeMode(tThemeMode));
    verifyNoMoreInteractions(mockProfileRepository);
  });

  test('should return failure when repository fails', () async {
    // arrange
    const tFailure = CacheFailure('Failed to set theme mode');
    when(mockProfileRepository.setThemeMode(any))
        .thenAnswer((_) async => const Left(tFailure));

    // act
    final result = await usecase(tThemeMode);

    // assert
    expect(result, const Left(tFailure));
    verify(mockProfileRepository.setThemeMode(tThemeMode));
    verifyNoMoreInteractions(mockProfileRepository);
  });
}
