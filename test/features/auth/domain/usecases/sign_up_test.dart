import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:movie_discovery_app/core/error/failures.dart';
import 'package:movie_discovery_app/features/auth/domain/entities/user_entity.dart';
import 'package:movie_discovery_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:movie_discovery_app/features/auth/domain/usecases/sign_up.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late SignUp usecase;
  late MockAuthRepository mockAuthRepository;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    usecase = SignUp(mockAuthRepository);
  });

  const tEmail = 'test@example.com';
  const tPassword = 'password123';
  const tDisplayName = 'Test User';
  const tUser = UserEntity(
    id: '1',
    email: tEmail,
    displayName: tDisplayName,
    role: 'User',
  );

  test('should sign up user with email, password and display name', () async {
    // arrange
    when(() => mockAuthRepository.signUpWithEmailAndPassword(
          email: any(named: 'email'),
          password: any(named: 'password'),
          displayName: any(named: 'displayName'),
        )).thenAnswer((_) async => const Right(tUser));

    // act
    final result = await usecase(
      email: tEmail,
      password: tPassword,
      displayName: tDisplayName,
    );

    // assert
    expect(result, const Right(tUser));
    verify(() => mockAuthRepository.signUpWithEmailAndPassword(
          email: tEmail,
          password: tPassword,
          displayName: tDisplayName,
        )).called(1);
    verifyNoMoreInteractions(mockAuthRepository);
  });

  test('should return ServerFailure when sign up fails', () async {
    // arrange
    const tFailure = ServerFailure('Email already in use');
    when(() => mockAuthRepository.signUpWithEmailAndPassword(
          email: any(named: 'email'),
          password: any(named: 'password'),
          displayName: any(named: 'displayName'),
        )).thenAnswer((_) async => const Left(tFailure));

    // act
    final result = await usecase(
      email: tEmail,
      password: tPassword,
      displayName: tDisplayName,
    );

    // assert
    expect(result, const Left(tFailure));
    verify(() => mockAuthRepository.signUpWithEmailAndPassword(
          email: tEmail,
          password: tPassword,
          displayName: tDisplayName,
        )).called(1);
  });
}
