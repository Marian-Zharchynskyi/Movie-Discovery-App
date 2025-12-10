import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:movie_discovery_app/core/error/exceptions.dart';

class DioConfig {
  static Dio createDio({
    required String baseUrl,
    String? apiKey,
    Duration connectTimeout = const Duration(seconds: 30),
    Duration receiveTimeout = const Duration(seconds: 30),
    bool enableLogging = true,
    int maxRetries = 3,
  }) {
    final dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: connectTimeout,
        receiveTimeout: receiveTimeout,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (apiKey != null) 'Authorization': 'Bearer $apiKey',
        },
      ),
    );

    dio.interceptors.addAll([
      if (enableLogging) _LoggingInterceptor(),
      _RetryInterceptor(maxRetries: maxRetries),
      _ErrorInterceptor(),
      if (apiKey != null) _ApiKeyInterceptor(apiKey),
    ]);

    return dio;
  }
}

class _LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (kDebugMode) {
      print('🚀 [DIO] Request: ${options.method} ${options.uri}');
      print('📝 [DIO] Headers: ${options.headers}');
      if (options.data != null) {
        print('📦 [DIO] Body: ${options.data}');
      }
    }
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (kDebugMode) {
      print('✅ [DIO] Response: ${response.statusCode} ${response.realUri}');
      print('📄 [DIO] Data length: ${response.data?.toString().length ?? 0}');
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (kDebugMode) {
      print('❌ [DIO] Error: ${err.type} - ${err.message}');
      if (err.response != null) {
        print('📄 [DIO] Error response: ${err.response!.statusCode} ${err.response!.data}');
      }
    }
    handler.next(err);
  }
}

class _RetryInterceptor extends Interceptor {
  final int maxRetries;

  _RetryInterceptor({required this.maxRetries});

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (_shouldRetry(err) && err.requestOptions.extra['retries'] != null) {
      final retries = (err.requestOptions.extra['retries'] as int) + 1;

      if (retries <= maxRetries) {
        if (kDebugMode) {
          print('🔄 [DIO] Retrying request ($retries/$maxRetries): ${err.requestOptions.uri}');
        }

        err.requestOptions.extra['retries'] = retries;

        await Future.delayed(Duration(milliseconds: (1 << retries) * 1000));

        try {
          final response = await Dio().fetch(err.requestOptions);
          handler.resolve(response);
          return;
        } catch (retryError) {
          if (kDebugMode) {
            print('❌ [DIO] Retry failed: $retryError');
          }
        }
      }
    }

    handler.next(err);
  }

  bool _shouldRetry(DioException err) {
    return err.type == DioExceptionType.connectionTimeout ||
           err.type == DioExceptionType.sendTimeout ||
           err.type == DioExceptionType.receiveTimeout ||
           (err.response?.statusCode == 429) ||
           (err.response?.statusCode == 503) ||
           (err.response?.statusCode == 502) ||
           (err.response?.statusCode == 500);
  }
}

class _ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    String message = _getErrorMessage(err);

    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        throw ServerException('Network timeout: $message');

      case DioExceptionType.badResponse:
        final statusCode = err.response?.statusCode;
        if (statusCode != null) {
          switch (statusCode) {
            case 400:
              throw ServerException('Bad request: $message');
            case 401:
              throw ServerException('Unauthorized: $message');
            case 403:
              throw ServerException('Forbidden: $message');
            case 404:
              throw ServerException('Not found: $message');
            case 500:
              throw ServerException('Internal server error: $message');
            case 502:
              throw ServerException('Bad gateway: $message');
            case 503:
              throw ServerException('Service unavailable: $message');
            default:
              throw ServerException('Server error ($statusCode): $message');
          }
        }
        break;

      case DioExceptionType.cancel:
        throw ServerException('Request cancelled: $message');

      default:
        throw ServerException('Network error: $message');
    }

    handler.next(err);
  }

  String _getErrorMessage(DioException err) {
    if (err.message != null && err.message!.isNotEmpty) {
      return err.message!;
    }

    if (err.response?.data != null) {
      if (err.response!.data is Map && err.response!.data.containsKey('message')) {
        return err.response!.data['message'].toString();
      }
      if (err.response!.data is Map && err.response!.data.containsKey('error')) {
        return err.response!.data['error'].toString();
      }
      return err.response!.data.toString();
    }

    return 'Unknown error occurred';
  }
}

class _ApiKeyInterceptor extends Interceptor {
  final String apiKey;

  _ApiKeyInterceptor(this.apiKey);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.queryParameters['api_key'] = apiKey;
    handler.next(options);
  }
}
