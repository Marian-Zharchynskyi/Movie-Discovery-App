import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:movie_discovery_app/core/error/exceptions.dart';
import 'package:movie_discovery_app/features/auth/data/datasources/auth_local_data_source.dart';

class MockFlutterSecureStorage extends Mock implements FlutterSecureStorage {}

void main() {
  late AuthLocalDataSourceImpl dataSource;
  late MockFlutterSecureStorage mockSecureStorage;

  setUp(() {
    mockSecureStorage = MockFlutterSecureStorage();
    dataSource = AuthLocalDataSourceImpl(secureStorage: mockSecureStorage);
  });

  const tToken = 'test_token_123';
  const tTokenKey = 'auth_token';

  group('getStoredToken', () {
    test('should return token from secure storage when present', () async {
      // arrange
      when(() => mockSecureStorage.read(key: any(named: 'key')))
          .thenAnswer((_) async => tToken);

      // act
      final result = await dataSource.getStoredToken();

      // assert
      expect(result, tToken);
      verify(() => mockSecureStorage.read(key: tTokenKey)).called(1);
    });

    test('should return null when no token is stored', () async {
      // arrange
      when(() => mockSecureStorage.read(key: any(named: 'key')))
          .thenAnswer((_) async => null);

      // act
      final result = await dataSource.getStoredToken();

      // assert
      expect(result, null);
    });

    test('should throw CacheException when reading fails', () async {
      // arrange
      when(() => mockSecureStorage.read(key: any(named: 'key')))
          .thenThrow(Exception('Storage error'));

      // act
      final call = dataSource.getStoredToken;

      // assert
      expect(() => call(), throwsA(isA<CacheException>()));
    });
  });

  group('storeToken', () {
    test('should store token in secure storage', () async {
      // arrange
      when(() => mockSecureStorage.write(
            key: any(named: 'key'),
            value: any(named: 'value'),
          )).thenAnswer((_) async => Future.value());

      // act
      await dataSource.storeToken(tToken);

      // assert
      verify(() => mockSecureStorage.write(key: tTokenKey, value: tToken))
          .called(1);
    });

    test('should throw CacheException when storing fails', () async {
      // arrange
      when(() => mockSecureStorage.write(
            key: any(named: 'key'),
            value: any(named: 'value'),
          )).thenThrow(Exception('Storage error'));

      // act
      final call = dataSource.storeToken;

      // assert
      expect(() => call(tToken), throwsA(isA<CacheException>()));
    });
  });

  group('clearToken', () {
    test('should delete token from secure storage', () async {
      // arrange
      when(() => mockSecureStorage.delete(key: any(named: 'key')))
          .thenAnswer((_) async => Future.value());

      // act
      await dataSource.clearToken();

      // assert
      verify(() => mockSecureStorage.delete(key: tTokenKey)).called(1);
    });

    test('should throw CacheException when clearing fails', () async {
      // arrange
      when(() => mockSecureStorage.delete(key: any(named: 'key')))
          .thenThrow(Exception('Storage error'));

      // act
      final call = dataSource.clearToken;

      // assert
      expect(() => call(), throwsA(isA<CacheException>()));
    });
  });
}
