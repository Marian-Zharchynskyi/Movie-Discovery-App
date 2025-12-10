import 'package:flutter_test/flutter_test.dart';
import 'package:movie_discovery_app/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:movie_discovery_app/core/services/mock_auth_api.dart';
import 'package:movie_discovery_app/core/error/exceptions.dart';

void main() {
  group('AuthRemoteDataSourceImpl – placeholder until Firebase mocks are added', () {
    late AuthRemoteDataSourceMock ds;
    setUp(() {
      ds = AuthRemoteDataSourceMock(mockAuthApi: MockAuthApi());
      (ds.mockAuthApi).clearAllUsers();
    });

    test('signIn wrong password → ServerException', () async {
      await ds.signUpWithEmailAndPassword(email: 'e@test.com', password: 'secret');
      expect(
        () => ds.signInWithEmailAndPassword(email: 'e@test.com', password: 'bad'),
        throwsA(isA<ServerException>()),
      );
    });

    test('getJwtToken returns null after signOut', () async {
      await ds.signUpWithEmailAndPassword(email: 'e@test.com', password: 'secret');
      expect(await ds.getJwtToken(), isNotNull);
      await ds.signOut();
      expect(await ds.getJwtToken(), isNull);
    });
  });
}
