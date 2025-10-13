import 'dart:convert';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:movie_discovery_app/core/error/exceptions.dart';

/// Mock API service for authentication with JWT token generation
class MockAuthApi {
  // Secret key for JWT signing (in production, this should be stored securely)
  static const String _jwtSecret = 'your-secret-key-change-in-production';
  static const Duration _tokenExpiration = Duration(hours: 24);

  // Mock user database
  static final Map<String, Map<String, dynamic>> _users = {};

  /// Sign up a new user
  Future<Map<String, dynamic>> signUp({
    required String email,
    required String password,
    String? displayName,
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    // Validate email format
    if (!_isValidEmail(email)) {
      throw ServerException('Invalid email format');
    }

    // Validate password strength
    if (password.length < 6) {
      throw ServerException('Password must be at least 6 characters');
    }

    // Check if user already exists
    if (_users.containsKey(email)) {
      throw ServerException('User with this email already exists');
    }

    // Create user ID
    final userId = _generateUserId();

    // Hash password (in production, use proper hashing like bcrypt)
    final hashedPassword = _hashPassword(password);

    // Store user
    _users[email] = {
      'id': userId,
      'email': email,
      'password': hashedPassword,
      'displayName': displayName ?? email.split('@')[0],
      'photoUrl': null,
      'createdAt': DateTime.now().toIso8601String(),
    };

    // Generate JWT token
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

  /// Sign in an existing user
  Future<Map<String, dynamic>> signIn({
    required String email,
    required String password,
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    // Check if user exists
    if (!_users.containsKey(email)) {
      throw ServerException('No user found with this email');
    }

    final user = _users[email]!;
    final hashedPassword = _hashPassword(password);

    // Verify password
    if (user['password'] != hashedPassword) {
      throw ServerException('Incorrect password');
    }

    // Generate JWT token
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

  /// Verify JWT token and get user data
  Future<Map<String, dynamic>?> verifyToken(String token) async {
    try {
      // Verify and decode JWT
      final jwt = JWT.verify(token, SecretKey(_jwtSecret));
      final payload = jwt.payload as Map<String, dynamic>;

      final email = payload['email'] as String;

      // Check if user still exists
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

  /// Refresh JWT token
  Future<String> refreshToken(String oldToken) async {
    final userData = await verifyToken(oldToken);
    if (userData == null) {
      throw ServerException('Invalid token');
    }

    return _generateJwtToken(userData['id'], userData['email']);
  }

  /// Create a JWT for an already authenticated Firebase user
  /// This allows using our app-level JWT together with Firebase Auth
  String createJwtForFirebaseUser({
    required String userId,
    required String email,
    String role = 'User',
  }) {
    return _generateJwtToken(userId, email, role: role);
  }

  /// Update user profile
  Future<Map<String, dynamic>> updateProfile({
    required String token,
    String? displayName,
    String? photoUrl,
  }) async {
    // Simulate network delay
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

  /// Generate JWT token
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

  /// Generate unique user ID
  String _generateUserId() {
    return 'user_${DateTime.now().millisecondsSinceEpoch}_${_users.length}';
  }

  /// Simple password hashing (use bcrypt in production)
  String _hashPassword(String password) {
    // This is just a simple encoding for demo purposes
    // In production, use proper password hashing like bcrypt
    return base64Encode(utf8.encode(password + _jwtSecret));
  }

  /// Validate email format
  bool _isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }

  /// Get all users (for debugging)
  Map<String, Map<String, dynamic>> getAllUsers() {
    return Map.from(_users);
  }

  /// Clear all users (for testing)
  void clearAllUsers() {
    _users.clear();
  }
}
