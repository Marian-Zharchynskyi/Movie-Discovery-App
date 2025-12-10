import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:movie_discovery_app/core/error/exceptions.dart';
import 'package:movie_discovery_app/core/error/failures.dart';
import 'package:movie_discovery_app/core/services/mock_auth_api.dart';
import 'package:movie_discovery_app/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:movie_discovery_app/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:movie_discovery_app/features/auth/data/models/user_model.dart';
import 'package:movie_discovery_app/features/auth/data/repositories/auth_repository_impl.dart';

class MockAuthRemoteDataSource extends Mock implements AuthRemoteDataSource {}
class MockAuthLocalDataSource extends Mock implements AuthLocalDataSource {}
class MockMockAuthApi extends Mock implements MockAuthApi {}

void main() {
  late AuthRepositoryImpl repository;
  late MockAuthRemoteDataSource mockRemoteDataSource;
  late MockAuthLocalDataSource mockLocalDataSource;
  late MockMockAuthApi mockAuthApi;

  setUp(() {
    mockRemoteDataSource = MockAuthRemoteDataSource();
    mockLocalDataSource = MockAuthLocalDataSource();
    mockAuthApi = MockMockAuthApi();
    repository = AuthRepositoryImpl(
      remoteDataSource: mockRemoteDataSource,
      localDataSource: mockLocalDataSource,
      mockAuthApi: mockAuthApi,
    );
  });

  const tEmail = 'test@example.com';
  const tPassword = 'password123';
  const tDisplayName = 'Test User';
  const tToken = 'jwt_token_123';

  const tUserModel = UserModel(
    id: '123',
    email: tEmail,
    displayName: tDisplayName,
    role: 'User',
  );

  group('signInWithEmailAndPassword', () {
    test('should return UserEntity when sign in is successful', () async {
      // arrange
      when(() => mockRemoteDataSource.signInWithEmailAndPassword(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenAnswer((_) async => tUserModel);
      when(() => mockAuthApi.createJwtForFirebaseUser(
            userId: any(named: 'userId'),
            email: any(named: 'email'),
            role: any(named: 'role'),
          )).thenReturn(tToken);
      when(() => mockLocalDataSource.storeToken(any()))
          .thenAnswer((_) async => Future.value());

      // act
      final result = await repository.signInWithEmailAndPassword(
        email: tEmail,
        password: tPassword,
      );

      // assert
      expect(result, const Right(tUserModel));
      verify(() => mockRemoteDataSource.signInWithEmailAndPassword(
            email: tEmail,
            password: tPassword,
          )).called(1);
      verify(() => mockAuthApi.createJwtForFirebaseUser(
            userId: tUserModel.id,
            email: tUserModel.email,
            role: tUserModel.role,
          )).called(1);
      verify(() => mockLocalDataSource.storeToken(tToken)).called(1);
    });

    test('should return ServerFailure when sign in fails', () async {
      // arrange
      when(() => mockRemoteDataSource.signInWithEmailAndPassword(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenThrow(ServerException('Invalid credentials'));

      // act
      final result = await repository.signInWithEmailAndPassword(
        email: tEmail,
        password: tPassword,
      );

      // assert
      expect(result, const Left(ServerFailure('Invalid credentials')));
      verifyNever(() => mockLocalDataSource.storeToken(any()));
    });

    test('should return ServerFailure on unexpected error', () async {
      // arrange
      when(() => mockRemoteDataSource.signInWithEmailAndPassword(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenThrow(Exception('Unexpected error'));

      // act
      final result = await repository.signInWithEmailAndPassword(
        email: tEmail,
        password: tPassword,
      );

      // assert
      expect(result, const Left(ServerFailure('An unexpected error occurred')));
    });
  });

  group('signUpWithEmailAndPassword', () {
    test('should return UserEntity when sign up is successful', () async {
      // arrange
      when(() => mockRemoteDataSource.signUpWithEmailAndPassword(
            email: any(named: 'email'),
            password: any(named: 'password'),
            displayName: any(named: 'displayName'),
          )).thenAnswer((_) async => tUserModel);
      when(() => mockAuthApi.createJwtForFirebaseUser(
            userId: any(named: 'userId'),
            email: any(named: 'email'),
            role: any(named: 'role'),
          )).thenReturn(tToken);
      when(() => mockLocalDataSource.storeToken(any()))
          .thenAnswer((_) async => Future.value());

      // act
      final result = await repository.signUpWithEmailAndPassword(
        email: tEmail,
        password: tPassword,
        displayName: tDisplayName,
      );

      // assert
      expect(result, const Right(tUserModel));
      verify(() => mockRemoteDataSource.signUpWithEmailAndPassword(
            email: tEmail,
            password: tPassword,
            displayName: tDisplayName,
          )).called(1);
      verify(() => mockLocalDataSource.storeToken(tToken)).called(1);
    });

    test('should return ServerFailure when sign up fails', () async {
      // arrange
      when(() => mockRemoteDataSource.signUpWithEmailAndPassword(
            email: any(named: 'email'),
            password: any(named: 'password'),
            displayName: any(named: 'displayName'),
          )).thenThrow(ServerException('Email already in use'));

      // act
      final result = await repository.signUpWithEmailAndPassword(
        email: tEmail,
        password: tPassword,
        displayName: tDisplayName,
      );

      // assert
      expect(result, const Left(ServerFailure('Email already in use')));
    });
  });

  group('signOut', () {
    test('should sign out successfully', () async {
      // arrange
      when(() => mockRemoteDataSource.signOut())
          .thenAnswer((_) async => Future.value());
      when(() => mockLocalDataSource.clearToken())
          .thenAnswer((_) async => Future.value());

      // act
      final result = await repository.signOut();

      // assert
      expect(result, const Right(null));
      verify(() => mockRemoteDataSource.signOut()).called(1);
      verify(() => mockLocalDataSource.clearToken()).called(1);
    });

    test('should return ServerFailure when remote sign out fails', () async {
      // arrange
      when(() => mockRemoteDataSource.signOut())
          .thenThrow(ServerException('Sign out failed'));

      // act
      final result = await repository.signOut();

      // assert
      expect(result, const Left(ServerFailure('Sign out failed')));
    });

    test('should return CacheFailure when clearing token fails', () async {
      // arrange
      when(() => mockRemoteDataSource.signOut())
          .thenAnswer((_) async => Future.value());
      when(() => mockLocalDataSource.clearToken())
          .thenThrow(CacheException('Failed to clear token'));

      // act
      final result = await repository.signOut();

      // assert
      expect(result, const Left(CacheFailure('Failed to clear token')));
    });
  });

  group('getCurrentUser', () {
    test('should return current user when available', () async {
      // arrange
      when(() => mockRemoteDataSource.getCurrentUser())
          .thenAnswer((_) async => tUserModel);

      // act
      final result = await repository.getCurrentUser();

      // assert
      expect(result, const Right(tUserModel));
      verify(() => mockRemoteDataSource.getCurrentUser()).called(1);
    });

    test('should return null when no user is signed in', () async {
      // arrange
      when(() => mockRemoteDataSource.getCurrentUser())
          .thenAnswer((_) async => null);

      // act
      final result = await repository.getCurrentUser();

      // assert
      expect(result, const Right(null));
    });

    test('should return ServerFailure when getting user fails', () async {
      // arrange
      when(() => mockRemoteDataSource.getCurrentUser())
          .thenThrow(ServerException('Failed to get user'));

      // act
      final result = await repository.getCurrentUser();

      // assert
      expect(result, const Left(ServerFailure('Failed to get user')));
    });
  });

  group('authStateChanges', () {
    test('should return stream from remote data source', () {
      // arrange
      final tStream = Stream<UserModel?>.value(tUserModel);
      when(() => mockRemoteDataSource.authStateChanges).thenAnswer((_) => tStream);

      // act
      final result = repository.authStateChanges;

      // assert
      expect(result, tStream);
    });
  });

  group('getStoredToken', () {
    test('should return token when available', () async {
      // arrange
      when(() => mockLocalDataSource.getStoredToken())
          .thenAnswer((_) async => tToken);

      // act
      final result = await repository.getStoredToken();

      // assert
      expect(result, const Right(tToken));
      verify(() => mockLocalDataSource.getStoredToken()).called(1);
    });

    test('should return null when no token is stored', () async {
      // arrange
      when(() => mockLocalDataSource.getStoredToken())
          .thenAnswer((_) async => null);

      // act
      final result = await repository.getStoredToken();

      // assert
      expect(result, const Right(null));
    });

    test('should return CacheFailure when getting token fails', () async {
      // arrange
      when(() => mockLocalDataSource.getStoredToken())
          .thenThrow(CacheException('Failed to read token'));

      // act
      final result = await repository.getStoredToken();

      // assert
      expect(result, const Left(CacheFailure('Failed to read token')));
    });
  });

  group('storeToken', () {
    test('should store token successfully', () async {
      // arrange
      when(() => mockLocalDataSource.storeToken(any()))
          .thenAnswer((_) async => Future.value());

      // act
      final result = await repository.storeToken(tToken);

      // assert
      expect(result, const Right(null));
      verify(() => mockLocalDataSource.storeToken(tToken)).called(1);
    });

    test('should return CacheFailure when storing fails', () async {
      // arrange
      when(() => mockLocalDataSource.storeToken(any()))
          .thenThrow(CacheException('Failed to store token'));

      // act
      final result = await repository.storeToken(tToken);

      // assert
      expect(result, const Left(CacheFailure('Failed to store token')));
    });
  });

  group('clearToken', () {
    test('should clear token successfully', () async {
      // arrange
      when(() => mockLocalDataSource.clearToken())
          .thenAnswer((_) async => Future.value());

      // act
      final result = await repository.clearToken();

      // assert
      expect(result, const Right(null));
      verify(() => mockLocalDataSource.clearToken()).called(1);
    });

    test('should return CacheFailure when clearing fails', () async {
      // arrange
      when(() => mockLocalDataSource.clearToken())
          .thenThrow(CacheException('Failed to clear token'));

      // act
      final result = await repository.clearToken();

      // assert
      expect(result, const Left(CacheFailure('Failed to clear token')));
    });
  });
}
