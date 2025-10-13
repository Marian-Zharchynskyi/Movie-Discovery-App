import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:movie_discovery_app/core/error/failures.dart';
import 'package:movie_discovery_app/features/auth/domain/entities/user_entity.dart';
import 'package:movie_discovery_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:movie_discovery_app/features/auth/domain/usecases/get_current_user.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late GetCurrentUser usecase;
  late MockAuthRepository mockAuthRepository;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    usecase = GetCurrentUser(mockAuthRepository);
  });

  const tUser = UserEntity(
    id: '1',
    email: 'test@example.com',
    displayName: 'Test User',
    role: 'User',
  );

  test('should get current user when user is authenticated', () async {
    // arrange
    when(() => mockAuthRepository.getCurrentUser())
        .thenAnswer((_) async => const Right(tUser));

    // act
    final result = await usecase();

    // assert
    expect(result, const Right(tUser));
    verify(() => mockAuthRepository.getCurrentUser()).called(1);
    verifyNoMoreInteractions(mockAuthRepository);
  });

  test('should return null when no user is authenticated', () async {
    // arrange
    when(() => mockAuthRepository.getCurrentUser())
        .thenAnswer((_) async => const Right(null));

    // act
    final result = await usecase();

    // assert
    expect(result, const Right(null));
    verify(() => mockAuthRepository.getCurrentUser()).called(1);
  });

  test('should return ServerFailure when getting current user fails', () async {
    // arrange
    const tFailure = ServerFailure('Failed to get current user');
    when(() => mockAuthRepository.getCurrentUser())
        .thenAnswer((_) async => const Left(tFailure));

    // act
    final result = await usecase();

    // assert
    expect(result, const Left(tFailure));
    verify(() => mockAuthRepository.getCurrentUser()).called(1);
  });
}
