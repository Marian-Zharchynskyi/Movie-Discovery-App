import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:movie_discovery_app/core/error/exceptions.dart';

abstract class AuthLocalDataSource {
  Future<String?> getStoredToken();
  Future<void> storeToken(String token);
  Future<void> clearToken();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final FlutterSecureStorage secureStorage;
  static const String _tokenKey = 'auth_token';

  AuthLocalDataSourceImpl({required this.secureStorage});

  @override
  Future<String?> getStoredToken() async {
    try {
      return await secureStorage.read(key: _tokenKey);
    } catch (e) {
      throw CacheException('Failed to read token from storage');
    }
  }

  @override
  Future<void> storeToken(String token) async {
    try {
      await secureStorage.write(key: _tokenKey, value: token);
    } catch (e) {
      throw CacheException('Failed to store token');
    }
  }

  @override
  Future<void> clearToken() async {
    try {
      await secureStorage.delete(key: _tokenKey);
    } catch (e) {
      throw CacheException('Failed to clear token');
    }
  }
}
