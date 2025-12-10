import 'package:flutter_test/flutter_test.dart';
import 'package:movie_discovery_app/core/network/dio_config.dart';

void main() {
  group('DioConfig.createDio', () {
    test('sets baseUrl, timeouts and headers including Authorization when apiKey provided', () {
      final dio = DioConfig.createDio(
        baseUrl: 'https://example.com/api',
        apiKey: 'TEST_KEY',
        connectTimeout: const Duration(seconds: 5),
        receiveTimeout: const Duration(seconds: 7),
        enableLogging: true,
        maxRetries: 2,
      );

      final opts = dio.options;
      expect(opts.baseUrl, 'https://example.com/api');
      expect(opts.connectTimeout, const Duration(seconds: 5));
      expect(opts.receiveTimeout, const Duration(seconds: 7));
      expect(opts.headers['Content-Type'], 'application/json');
      expect(opts.headers['Accept'], 'application/json');
      expect(opts.headers['Authorization'], 'Bearer TEST_KEY');

      // Interceptors should contain at least logging, retry, error and api-key interceptors when apiKey provided
      expect(dio.interceptors, isNotEmpty);
      // We cannot access private interceptor classes here, but the count should be >= 3
      expect(dio.interceptors.length >= 3, isTrue);
    });

    test('does not set Authorization header when apiKey is null', () {
      final dio = DioConfig.createDio(
        baseUrl: 'https://example.com/api',
      );

      expect(dio.options.headers.containsKey('Authorization'), isFalse);
    });
  });
}
