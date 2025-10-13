import 'package:flutter_test/flutter_test.dart';
import 'package:movie_discovery_app/core/error/failures.dart';

void main() {
  group('Failure', () {
    test('ServerFailure should have correct message', () {
      const failure = ServerFailure('Server error');
      expect(failure.message, 'Server error');
    });

    test('CacheFailure should have correct message', () {
      const failure = CacheFailure('Cache error');
      expect(failure.message, 'Cache error');
    });

    test('NetworkFailure should have correct message', () {
      const failure = NetworkFailure('Network error');
      expect(failure.message, 'Network error');
    });

    test('Failures with same message should be equal', () {
      const failure1 = ServerFailure('Error');
      const failure2 = ServerFailure('Error');
      expect(failure1, failure2);
    });

    test('Failures with different messages should not be equal', () {
      const failure1 = ServerFailure('Error 1');
      const failure2 = ServerFailure('Error 2');
      expect(failure1, isNot(failure2));
    });

    test('Different failure types should not be equal', () {
      const serverFailure = ServerFailure('Error');
      const cacheFailure = CacheFailure('Error');
      expect(serverFailure, isNot(cacheFailure));
    });
  });
}
