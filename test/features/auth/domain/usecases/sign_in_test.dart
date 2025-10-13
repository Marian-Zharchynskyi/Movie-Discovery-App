import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:movie_discovery_app/core/error/failures.dart';
import 'package:movie_discovery_app/features/auth/domain/entities/user_entity.dart';
import 'package:movie_discovery_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:movie_discovery_app/features/auth/domain/usecases/sign_in.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late SignIn usecase;
  late MockAuthRepository mockAuthRepository;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    usecase = SignIn(mockAuthRepository);
  });

  const tEmail = 'test@example.com';
  const tPassword = 'password123';
  const tUser = UserEntity(
    id: '1',
    email: tEmail,
    displayName: 'Test User',
    role: 'User',
  );

  test('should sign in user with email and password', () async {
    // arrange
    when(() => mockAuthRepository.signInWithEmailAndPassword(
          email: any(named: 'email'),
          password: any(named: 'password'),
        )).thenAnswer((_) async => const Right(tUser));

    // act
    final result = await usecase(email: tEmail, password: tPassword);

    // assert
    expect(result, const Right(tUser));
    verify(() => mockAuthRepository.signInWithEmailAndPassword(
          email: tEmail,
          password: tPassword,
        )).called(1);
    verifyNoMoreInteractions(mockAuthRepository);
  });

  test('should return ServerFailure when sign in fails', () async {
    // arrange
    const tFailure = ServerFailure('Invalid credentials');
    when(() => mockAuthRepository.signInWithEmailAndPassword(
          email: any(named: 'email'),
          password: any(named: 'password'),
        )).thenAnswer((_) async => const Left(tFailure));

    // act
    final result = await usecase(email: tEmail, password: tPassword);

    // assert
    expect(result, const Left(tFailure));
    verify(() => mockAuthRepository.signInWithEmailAndPassword(
          email: tEmail,
          password: tPassword,
        )).called(1);
  });
}
