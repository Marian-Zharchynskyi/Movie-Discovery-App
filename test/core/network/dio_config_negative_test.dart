import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movie_discovery_app/core/error/exceptions.dart';
import 'package:movie_discovery_app/core/network/dio_config.dart';

class _ThrowingAdapter implements HttpClientAdapter {
  final DioException Function(RequestOptions) builder;
  _ThrowingAdapter(this.builder);
  @override
  void close({bool force = false}) {}
  @override
  Future<ResponseBody> fetch(RequestOptions options, Stream<List<int>>? requestStream, Future<void>? cancelFuture) async {
    throw builder(options);
  }
}

void main() {
  group('DioConfig negative paths', () {
    test('ErrorInterceptor maps 404 to ServerException(Not found)', () async {
      final dio = DioConfig.createDio(baseUrl: 'https://example.com');
      dio.httpClientAdapter = _ThrowingAdapter((opts) => DioException(
            requestOptions: opts,
            response: Response(requestOptions: opts, statusCode: 404, data: {'message': 'nope'}),
            type: DioExceptionType.badResponse,
          ));

      await expectLater(
        dio.get('/any'),
        throwsA(isA<DioException>().having((e) => e.error, 'error', isA<ServerException>())),
      );
    });

    test('Timeout error maps to ServerException', () async {
      final dio = DioConfig.createDio(baseUrl: 'https://example.com');
      dio.httpClientAdapter = _ThrowingAdapter((opts) => DioException(
            requestOptions: opts,
            type: DioExceptionType.connectionTimeout,
            message: 'Timeout',
          ));

      await expectLater(
        dio.get('/timeout'),
        throwsA(isA<DioException>().having((e) => e.error, 'error', isA<ServerException>())),
      );
    });
  });
}
