import 'dart:io';
import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:path_provider/path_provider.dart';

final sl = GetIt.instance;

Future<void> init() async {
  //! External
  await _initExternalDependencies();
  
  //! Features - will be added in next steps
  // await _initAuthFeature();
  // await _initMoviesFeature();
  // await _initFavoritesFeature();
  // await _initProfileFeature();
}

Future<void> _initExternalDependencies() async {
  // Register environment variables
  await dotenv.load(fileName: ".env");
  
  // Register Dio with interceptors
  sl.registerLazySingleton<Dio>(() {
    final dio = Dio(
      BaseOptions(
        baseUrl: dotenv.env['TMDB_BASE_URL']!,
        queryParameters: {
          'api_key': dotenv.env['TMDB_API_KEY'],
        },
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
      ),
    );

    // Add logging interceptor in debug mode
    if (kDebugMode) {
      dio.interceptors.add(
        LogInterceptor(
          request: true,
          requestHeader: true,
          requestBody: true,
          responseHeader: true,
          responseBody: true,
          error: true,
        ),
      );
    }

    return dio;
  });

  // Register path_provider
  sl.registerLazySingletonAsync<Directory>(() => getApplicationDocumentsDirectory());
  
  // Initialize Hive
  // sl.registerLazySingletonAsync<Box>(
  //   () async {
  //     final appDocumentDir = await getApplicationDocumentsDirectory();
  //     Hive.init(appDocumentDir.path);
  //     return Hive.openBox('appBox');
  //   },
  // );
  
  // Initialize Drift database
  // sl.registerLazySingletonAsync<AppDatabase>(
  //   () async {
  //     final dbFolder = await getApplicationDocumentsDirectory();
  //     final file = File(path.join(dbFolder.path, 'db.sqlite'));
  //     return AppDatabase(file);
  //   },
  // );
  
  // Initialize Secure Storage
  // sl.registerLazySingleton<FlutterSecureStorage>(
  //   () => const FlutterSecureStorage(),
  // );
}

// Helper extension for async registration
extension GetItX on GetIt {
  void registerLazySingletonAsync<T extends Object>(
    FactoryFuncAsync<T> factoryFunc, {
    String? instanceName,
    DisposingFunc<T>? dispose,
  }) {
    registerFactoryAsync(
      () async {
        final instance = await factoryFunc();
        registerLazySingleton<T>(
          () => instance,
          instanceName: instanceName,
          dispose: dispose,
        );
        return instance;
      },
      instanceName: instanceName,
    );
  }
}
