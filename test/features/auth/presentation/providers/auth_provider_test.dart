import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:movie_discovery_app/core/error/failures.dart';
import 'package:movie_discovery_app/features/auth/domain/entities/user_entity.dart';
import 'package:movie_discovery_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:movie_discovery_app/features/auth/domain/usecases/get_current_user.dart';
import 'package:movie_discovery_app/features/auth/domain/usecases/sign_in.dart';
import 'package:movie_discovery_app/features/auth/domain/usecases/sign_out.dart';
import 'package:movie_discovery_app/features/auth/domain/usecases/sign_up.dart';
import 'package:movie_discovery_app/features/auth/presentation/providers/auth_provider.dart';

class MockAuthRepository extends Mock implements AuthRepository {}
class MockSignIn extends Mock implements SignIn {}
class MockSignUp extends Mock implements SignUp {}
class MockSignOut extends Mock implements SignOut {}
class MockGetCurrentUser extends Mock implements GetCurrentUser {}

void main() {
  late AuthNotifier authNotifier;
  late MockAuthRepository mockAuthRepository;
  late MockSignIn mockSignIn;
  late MockSignUp mockSignUp;
  late MockSignOut mockSignOut;
  late MockGetCurrentUser mockGetCurrentUser;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    mockSignIn = MockSignIn();
    mockSignUp = MockSignUp();
    mockSignOut = MockSignOut();
    mockGetCurrentUser = MockGetCurrentUser();

    when(() => mockAuthRepository.authStateChanges)
        .thenAnswer((_) => const Stream.empty());
    when(() => mockGetCurrentUser())
        .thenAnswer((_) async => const Right(null));

    authNotifier = AuthNotifier(
      signIn: mockSignIn,
      signUp: mockSignUp,
      signOut: mockSignOut,
      getCurrentUser: mockGetCurrentUser,
      authRepository: mockAuthRepository,
    );
  });

  tearDown(() {
    authNotifier.dispose();
  });

  const tUser = UserEntity(
    id: '1',
    email: 'test@example.com',
    displayName: 'Test User',
    role: 'User',
  );

  group('AuthNotifier', () {
    test('initial state should be unauthenticated', () {
      expect(authNotifier.state.isAuthenticated, false);
      expect(authNotifier.state.user, null);
      expect(authNotifier.state.isLoading, false);
    });

    group('signInWithEmailAndPassword', () {
      test('should update state with user when sign in is successful', () async {
        // arrange
        when(() => mockSignIn(email: any(named: 'email'), password: any(named: 'password')))
            .thenAnswer((_) async => const Right(tUser));

        // act
        final result = await authNotifier.signInWithEmailAndPassword(
          email: 'test@example.com',
          password: 'password123',
        );

        // assert
        expect(result, true);
        expect(authNotifier.state.isAuthenticated, true);
        expect(authNotifier.state.user, tUser);
        expect(authNotifier.state.error, null);
        expect(authNotifier.state.isLoading, false);
      });

      test('should update state with error when sign in fails', () async {
        // arrange
        const tFailure = ServerFailure('Invalid credentials');
        when(() => mockSignIn(email: any(named: 'email'), password: any(named: 'password')))
            .thenAnswer((_) async => const Left(tFailure));

        // act
        final result = await authNotifier.signInWithEmailAndPassword(
          email: 'test@example.com',
          password: 'wrong',
        );

        // assert
        expect(result, false);
        expect(authNotifier.state.isAuthenticated, false);
        expect(authNotifier.state.error, 'Invalid credentials');
        expect(authNotifier.state.isLoading, false);
      });
    });

    group('signUpWithEmailAndPassword', () {
      test('should update state with user when sign up is successful', () async {
        // arrange
        when(() => mockSignUp(
              email: any(named: 'email'),
              password: any(named: 'password'),
              displayName: any(named: 'displayName'),
            )).thenAnswer((_) async => const Right(tUser));

        // act
        final result = await authNotifier.signUpWithEmailAndPassword(
          email: 'test@example.com',
          password: 'password123',
          displayName: 'Test User',
        );

        // assert
        expect(result, true);
        expect(authNotifier.state.isAuthenticated, true);
        expect(authNotifier.state.user, tUser);
        expect(authNotifier.state.error, null);
      });

      test('should update state with error when sign up fails', () async {
        // arrange
        const tFailure = ServerFailure('Email already in use');
        when(() => mockSignUp(
              email: any(named: 'email'),
              password: any(named: 'password'),
              displayName: any(named: 'displayName'),
            )).thenAnswer((_) async => const Left(tFailure));

        // act
        final result = await authNotifier.signUpWithEmailAndPassword(
          email: 'test@example.com',
          password: 'password123',
        );

        // assert
        expect(result, false);
        expect(authNotifier.state.error, 'Email already in use');
      });
    });

    group('signOutUser', () {
      test('should reset state when sign out is successful', () async {
        // arrange
        when(() => mockSignOut()).thenAnswer((_) async => const Right(null));

        // act
        await authNotifier.signOutUser();

        // assert
        expect(authNotifier.state.isAuthenticated, false);
        expect(authNotifier.state.user, null);
      });

      test('should update error when sign out fails', () async {
        // arrange
        const tFailure = ServerFailure('Sign out failed');
        when(() => mockSignOut()).thenAnswer((_) async => const Left(tFailure));

        // act
        await authNotifier.signOutUser();

        // assert
        expect(authNotifier.state.error, 'Sign out failed');
      });
    });

    group('checkAuthStatus', () {
      test('should update state with user when user is authenticated', () async {
        // arrange
        when(() => mockGetCurrentUser())
            .thenAnswer((_) async => const Right(tUser));

        // act
        await authNotifier.checkAuthStatus();

        // assert
        expect(authNotifier.state.isAuthenticated, true);
        expect(authNotifier.state.user, tUser);
        expect(authNotifier.state.isLoading, false);
      });

      test('should set unauthenticated when no user found', () async {
        // arrange
        when(() => mockGetCurrentUser())
            .thenAnswer((_) async => const Right(null));

        // act
        await authNotifier.checkAuthStatus();

        // assert
        expect(authNotifier.state.isAuthenticated, false);
        expect(authNotifier.state.user, null);
      });
    });
  });
}
