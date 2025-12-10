import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:movie_discovery_app/core/error/failures.dart';
import 'package:movie_discovery_app/features/profile/domain/repositories/profile_repository.dart';
import 'package:movie_discovery_app/features/profile/domain/usecases/set_locale_code.dart';

import 'set_locale_code_test.mocks.dart';

@GenerateMocks([ProfileRepository])
void main() {
  late SetLocaleCode usecase;
  late MockProfileRepository mockProfileRepository;

  setUp(() {
    mockProfileRepository = MockProfileRepository();
    usecase = SetLocaleCode(mockProfileRepository);
  });

  const tLocaleCode = 'uk';

  test('should set locale code in the repository', () async {
    // arrange
    when(mockProfileRepository.setLocaleCode(any))
        .thenAnswer((_) async => const Right(null));

    // act
    final result = await usecase(tLocaleCode);

    // assert
    expect(result, const Right(null));
    verify(mockProfileRepository.setLocaleCode(tLocaleCode));
    verifyNoMoreInteractions(mockProfileRepository);
  });

  test('should return failure when repository fails', () async {
    // arrange
    const tFailure = CacheFailure('Failed to set locale code');
    when(mockProfileRepository.setLocaleCode(any))
        .thenAnswer((_) async => const Left(tFailure));

    // act
    final result = await usecase(tLocaleCode);

    // assert
    expect(result, const Left(tFailure));
    verify(mockProfileRepository.setLocaleCode(tLocaleCode));
    verifyNoMoreInteractions(mockProfileRepository);
  });
}
