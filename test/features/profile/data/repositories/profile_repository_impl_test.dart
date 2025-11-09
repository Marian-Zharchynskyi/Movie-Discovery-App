import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:movie_discovery_app/core/error/failures.dart';
import 'package:movie_discovery_app/features/auth/domain/entities/user_entity.dart';
import 'package:movie_discovery_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:movie_discovery_app/features/profile/data/datasources/profile_local_data_source.dart';
import 'package:movie_discovery_app/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:movie_discovery_app/features/profile/domain/entities/profile_entity.dart';

import 'profile_repository_impl_test.mocks.dart';

@GenerateMocks([AuthRepository, ProfileLocalDataSource])
void main() {
  late ProfileRepositoryImpl repository;
  late MockAuthRepository mockAuthRepository;
  late MockProfileLocalDataSource mockLocalDataSource;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    mockLocalDataSource = MockProfileLocalDataSource();
    repository = ProfileRepositoryImpl(
      authRepository: mockAuthRepository,
      localDataSource: mockLocalDataSource,
    );
  });

  group('ProfileRepositoryImpl', () {
    const tUserId = 'user123';
    const tEmail = 'test@example.com';
    const tDisplayName = 'Test User';
    const tPhotoUrl = 'https://example.com/photo.jpg';
    const tRole = 'user';

    final tUserEntity = UserEntity(
      id: tUserId,
      email: tEmail,
      displayName: tDisplayName,
      photoUrl: tPhotoUrl,
      role: tRole,
    );

    final tProfileEntity = ProfileEntity(
      id: tUserId,
      email: tEmail,
      displayName: tDisplayName,
      photoUrl: tPhotoUrl,
      role: tRole,
    );

    group('getProfile', () {
      test('should return ProfileEntity when user is authenticated', () async {
        // arrange
        when(mockAuthRepository.getCurrentUser())
            .thenAnswer((_) async => Right(tUserEntity));

        // act
        final result = await repository.getProfile();

        // assert
        expect(result, Right(tProfileEntity));
        verify(mockAuthRepository.getCurrentUser());
        verifyNoMoreInteractions(mockAuthRepository);
      });

      test('should return CacheFailure when no user is authenticated', () async {
        // arrange
        when(mockAuthRepository.getCurrentUser())
            .thenAnswer((_) async => const Right(null));

        // act
        final result = await repository.getProfile();

        // assert
        expect(result, const Left(CacheFailure('No authenticated user')));
        verify(mockAuthRepository.getCurrentUser());
      });

      test('should return Failure when auth repository fails', () async {
        // arrange
        const tFailure = CacheFailure('Auth error');
        when(mockAuthRepository.getCurrentUser())
            .thenAnswer((_) async => const Left(tFailure));

        // act
        final result = await repository.getProfile();

        // assert
        expect(result, const Left(tFailure));
        verify(mockAuthRepository.getCurrentUser());
      });
    });

    group('getThemeMode', () {
      const tThemeMode = 'dark';

      test('should return theme mode from local data source', () async {
        // arrange
        when(mockLocalDataSource.getThemeMode()).thenReturn(tThemeMode);

        // act
        final result = await repository.getThemeMode();

        // assert
        expect(result, const Right(tThemeMode));
        verify(mockLocalDataSource.getThemeMode());
        verifyNoMoreInteractions(mockLocalDataSource);
      });

      test('should return null when no theme mode is set', () async {
        // arrange
        when(mockLocalDataSource.getThemeMode()).thenReturn(null);

        // act
        final result = await repository.getThemeMode();

        // assert
        expect(result, const Right(null));
        verify(mockLocalDataSource.getThemeMode());
      });

      test('should return CacheFailure when exception occurs', () async {
        // arrange
        when(mockLocalDataSource.getThemeMode()).thenThrow(Exception('Error'));

        // act
        final result = await repository.getThemeMode();

        // assert
        expect(result.isLeft(), true);
        result.fold(
          (failure) => expect(failure, isA<CacheFailure>()),
          (_) => fail('Should return failure'),
        );
        verify(mockLocalDataSource.getThemeMode());
      });
    });

    group('setThemeMode', () {
      const tThemeMode = 'light';

      test('should set theme mode successfully', () async {
        // arrange
        when(mockLocalDataSource.setThemeMode(any))
            .thenAnswer((_) async => Future.value());

        // act
        final result = await repository.setThemeMode(tThemeMode);

        // assert
        expect(result, const Right(null));
        verify(mockLocalDataSource.setThemeMode(tThemeMode));
        verifyNoMoreInteractions(mockLocalDataSource);
      });

      test('should return CacheFailure when exception occurs', () async {
        // arrange
        when(mockLocalDataSource.setThemeMode(any))
            .thenThrow(Exception('Error'));

        // act
        final result = await repository.setThemeMode(tThemeMode);

        // assert
        expect(result.isLeft(), true);
        result.fold(
          (failure) => expect(failure, isA<CacheFailure>()),
          (_) => fail('Should return failure'),
        );
        verify(mockLocalDataSource.setThemeMode(tThemeMode));
      });
    });

    group('getLocaleCode', () {
      const tLocaleCode = 'uk';

      test('should return locale code from local data source', () async {
        // arrange
        when(mockLocalDataSource.getLocaleCode()).thenReturn(tLocaleCode);

        // act
        final result = await repository.getLocaleCode();

        // assert
        expect(result, const Right(tLocaleCode));
        verify(mockLocalDataSource.getLocaleCode());
        verifyNoMoreInteractions(mockLocalDataSource);
      });

      test('should return null when no locale code is set', () async {
        // arrange
        when(mockLocalDataSource.getLocaleCode()).thenReturn(null);

        // act
        final result = await repository.getLocaleCode();

        // assert
        expect(result, const Right(null));
        verify(mockLocalDataSource.getLocaleCode());
      });

      test('should return CacheFailure when exception occurs', () async {
        // arrange
        when(mockLocalDataSource.getLocaleCode()).thenThrow(Exception('Error'));

        // act
        final result = await repository.getLocaleCode();

        // assert
        expect(result.isLeft(), true);
        result.fold(
          (failure) => expect(failure, isA<CacheFailure>()),
          (_) => fail('Should return failure'),
        );
        verify(mockLocalDataSource.getLocaleCode());
      });
    });

    group('setLocaleCode', () {
      const tLocaleCode = 'en';

      test('should set locale code successfully', () async {
        // arrange
        when(mockLocalDataSource.setLocaleCode(any))
            .thenAnswer((_) async => Future.value());

        // act
        final result = await repository.setLocaleCode(tLocaleCode);

        // assert
        expect(result, const Right(null));
        verify(mockLocalDataSource.setLocaleCode(tLocaleCode));
        verifyNoMoreInteractions(mockLocalDataSource);
      });

      test('should handle null locale code', () async {
        // arrange
        when(mockLocalDataSource.setLocaleCode(null))
            .thenAnswer((_) async => Future.value());

        // act
        final result = await repository.setLocaleCode(null);

        // assert
        expect(result, const Right(null));
        verify(mockLocalDataSource.setLocaleCode(null));
      });

      test('should return CacheFailure when exception occurs', () async {
        // arrange
        when(mockLocalDataSource.setLocaleCode(any))
            .thenThrow(Exception('Error'));

        // act
        final result = await repository.setLocaleCode(tLocaleCode);

        // assert
        expect(result.isLeft(), true);
        result.fold(
          (failure) => expect(failure, isA<CacheFailure>()),
          (_) => fail('Should return failure'),
        );
        verify(mockLocalDataSource.setLocaleCode(tLocaleCode));
      });
    });
  });
}
