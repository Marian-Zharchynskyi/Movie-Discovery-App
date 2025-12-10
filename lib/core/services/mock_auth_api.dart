import 'dart:convert';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:movie_discovery_app/core/error/exceptions.dart';

class MockAuthApi {
  static const String _jwtSecret = 'your-secret-key-change-in-production';
  static const Duration _tokenExpiration = Duration(hours: 24);
  static final Map<String, Map<String, dynamic>> _users = {};

  Future<Map<String, dynamic>> signUp({
    required String email,
    required String password,
    String? displayName,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));

    if (!_isValidEmail(email)) {
      throw ServerException('Invalid email format');
    }

    if (password.length < 6) {
      throw ServerException('Password must be at least 6 characters');
    }

    if (_users.containsKey(email)) {
      throw ServerException('User with this email already exists');
    }

    final userId = _generateUserId();
    final hashedPassword = _hashPassword(password);

    _users[email] = {
      'id': userId,
      'email': email,
      'password': hashedPassword,
      'displayName': displayName ?? email.split('@')[0],
      'photoUrl': null,
      'createdAt': DateTime.now().toIso8601String(),
    };

    final token = _generateJwtToken(userId, email);

    return {
      'user': {
        'id': userId,
        'email': email,
        'displayName': displayName ?? email.split('@')[0],
        'photoUrl': null,
      },
      'token': token,
    };
  }

  Future<Map<String, dynamic>> signIn({
    required String email,
    required String password,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));

    if (!_users.containsKey(email)) {
      throw ServerException('No user found with this email');
    }

    final user = _users[email]!;
    final hashedPassword = _hashPassword(password);

    if (user['password'] != hashedPassword) {
      throw ServerException('Incorrect password');
    }

    final token = _generateJwtToken(user['id'], email);

    return {
      'user': {
        'id': user['id'],
        'email': user['email'],
        'displayName': user['displayName'],
        'photoUrl': user['photoUrl'],
      },
      'token': token,
    };
  }

  Future<Map<String, dynamic>?> verifyToken(String token) async {
    try {
      final jwt = JWT.verify(token, SecretKey(_jwtSecret));
      final payload = jwt.payload as Map<String, dynamic>;
      final email = payload['email'] as String;

      if (!_users.containsKey(email)) {
        return null;
      }

      final user = _users[email]!;

      return {
        'id': user['id'],
        'email': user['email'],
        'displayName': user['displayName'],
        'photoUrl': user['photoUrl'],
      };
    } on JWTExpiredException {
      throw ServerException('Token has expired');
    } on JWTException catch (e) {
      throw ServerException('Invalid token: ${e.message}');
    }
  }

  Future<String> refreshToken(String oldToken) async {
    final userData = await verifyToken(oldToken);
    if (userData == null) {
      throw ServerException('Invalid token');
    }

    return _generateJwtToken(userData['id'], userData['email']);
  }

  String createJwtForFirebaseUser({
    required String userId,
    required String email,
    String role = 'User',
  }) {
    return _generateJwtToken(userId, email, role: role);
  }

  Future<Map<String, dynamic>> updateProfile({
    required String token,
    String? displayName,
    String? photoUrl,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final userData = await verifyToken(token);
    if (userData == null) {
      throw ServerException('Unauthorized');
    }

    final email = userData['email'] as String;
    final user = _users[email]!;

    if (displayName != null) {
      user['displayName'] = displayName;
    }

    if (photoUrl != null) {
      user['photoUrl'] = photoUrl;
    }

    return {
      'id': user['id'],
      'email': user['email'],
      'displayName': user['displayName'],
      'photoUrl': user['photoUrl'],
    };
  }

  String _generateJwtToken(String userId, String email, {String role = 'User'}) {
    final jwt = JWT(
      {
        'userId': userId,
        'email': email,
        'role': role,
        'iat': DateTime.now().millisecondsSinceEpoch,
        'exp': DateTime.now()
            .add(_tokenExpiration)
            .millisecondsSinceEpoch,
      },
    );

    return jwt.sign(SecretKey(_jwtSecret));
  }

  String _generateUserId() {
    return 'user_${DateTime.now().millisecondsSinceEpoch}_${_users.length}';
  }

  String _hashPassword(String password) {
    return base64Encode(utf8.encode(password + _jwtSecret));
  }

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }

  Map<String, Map<String, dynamic>> getAllUsers() {
    return Map.from(_users);
  }

  void clearAllUsers() {
    _users.clear();
  }
}
