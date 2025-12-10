import 'package:flutter_test/flutter_test.dart';
import 'package:movie_discovery_app/core/services/mock_auth_api.dart';
import 'package:movie_discovery_app/features/auth/data/datasources/auth_remote_data_source.dart';

void main() {
  late MockAuthApi api;
  late AuthRemoteDataSourceMock ds;

  setUp(() {
    api = MockAuthApi();
    api.clearAllUsers();
    ds = AuthRemoteDataSourceMock(mockAuthApi: api);
  });

  group('AuthRemoteDataSourceMock', () {
    test('signUp -> success returns user and token available', () async {
      final user = await ds.signUpWithEmailAndPassword(
        email: 'test@example.com',
        password: 'secret123',
        displayName: 'Tester',
      );

      expect(user.email, 'test@example.com');
      expect(await ds.getJwtToken(), isNotNull);
    });

    test('signIn -> wrong password throws', () async {
      await ds.signUpWithEmailAndPassword(
        email: 'test@example.com',
        password: 'secret123',
      );

      expect(
        () => ds.signInWithEmailAndPassword(email: 'test@example.com', password: 'bad'),
        throwsA(isA<Exception>()),
      );
    });

    test('getCurrentUser -> returns user when token valid, null after signOut', () async {
      await ds.signUpWithEmailAndPassword(
        email: 'test@example.com',
        password: 'secret123',
      );

      final u1 = await ds.getCurrentUser();
      expect(u1, isNotNull);

      await ds.signOut();
      final u2 = await ds.getCurrentUser();
      expect(u2, isNull);
    });

    test('authStateChanges -> emits current user (single value)', () async {
      await ds.signUpWithEmailAndPassword(
        email: 'test@example.com',
        password: 'secret123',
      );

      final emitted = await ds.authStateChanges.first;
      expect(emitted, isNotNull);
    });
  });
}
