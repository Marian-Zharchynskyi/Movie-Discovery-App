import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:movie_discovery_app/core/error/failures.dart';
import 'package:movie_discovery_app/features/profile/domain/repositories/profile_repository.dart';
import 'package:movie_discovery_app/features/profile/domain/usecases/get_locale_code.dart';

import 'get_locale_code_test.mocks.dart';

@GenerateMocks([ProfileRepository])
void main() {
  late GetLocaleCode usecase;
  late MockProfileRepository mockProfileRepository;

  setUp(() {
    mockProfileRepository = MockProfileRepository();
    usecase = GetLocaleCode(mockProfileRepository);
  });

  const tLocaleCode = 'en';

  test('should get locale code from the repository', () async {
    // arrange
    when(mockProfileRepository.getLocaleCode())
        .thenAnswer((_) async => const Right(tLocaleCode));

    // act
    final result = await usecase();

    // assert
    expect(result, const Right(tLocaleCode));
    verify(mockProfileRepository.getLocaleCode());
    verifyNoMoreInteractions(mockProfileRepository);
  });

  test('should return failure when repository fails', () async {
    // arrange
    const tFailure = CacheFailure('Failed to get locale code');
    when(mockProfileRepository.getLocaleCode())
        .thenAnswer((_) async => const Left(tFailure));

    // act
    final result = await usecase();

    // assert
    expect(result, const Left(tFailure));
    verify(mockProfileRepository.getLocaleCode());
    verifyNoMoreInteractions(mockProfileRepository);
  });
}
