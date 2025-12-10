import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:movie_discovery_app/core/error/failures.dart';
import 'package:movie_discovery_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:movie_discovery_app/features/auth/domain/usecases/get_stored_token.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late GetStoredToken usecase;
  late MockAuthRepository mockAuthRepository;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    usecase = GetStoredToken(mockAuthRepository);
  });

  const tToken = 'test_token_123';

  test('should get stored token from repository', () async {
    // arrange
    when(() => mockAuthRepository.getStoredToken())
        .thenAnswer((_) async => const Right(tToken));

    // act
    final result = await usecase();

    // assert
    expect(result, const Right(tToken));
    verify(() => mockAuthRepository.getStoredToken()).called(1);
    verifyNoMoreInteractions(mockAuthRepository);
  });

  test('should return null when no token is stored', () async {
    // arrange
    when(() => mockAuthRepository.getStoredToken())
        .thenAnswer((_) async => const Right(null));

    // act
    final result = await usecase();

    // assert
    expect(result, const Right(null));
  });

  test('should return CacheFailure when getting token fails', () async {
    // arrange
    const tFailure = CacheFailure('Failed to get token');
    when(() => mockAuthRepository.getStoredToken())
        .thenAnswer((_) async => const Left(tFailure));

    // act
    final result = await usecase();

    // assert
    expect(result, const Left(tFailure));
  });
}
