import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:movie_discovery_app/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuth _firebaseAuth;
  final FlutterSecureStorage _secureStorage;
  static const _tokenKey = 'auth_token';

  AuthRepositoryImpl({
    FirebaseAuth? firebaseAuth,
    FlutterSecureStorage? secureStorage,
  })  : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _secureStorage = secureStorage ?? const FlutterSecureStorage();

  @override
  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (userCredential.user != null) {
        final token = await userCredential.user!.getIdToken();
        await _secureStorage.write(key: _tokenKey, value: token);
      }
      
      return userCredential;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<UserCredential> registerWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (userCredential.user != null) {
        final token = await userCredential.user!.getIdToken();
        await _secureStorage.write(key: _tokenKey, value: token);
      }
      
      return userCredential;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
    await _secureStorage.delete(key: _tokenKey);
  }

  @override
  Future<bool> isSignedIn() async {
    final token = await _secureStorage.read(key: _tokenKey);
    return token != null && _firebaseAuth.currentUser != null;
  }

  @override
  Future<String?> getToken() async {
    return _secureStorage.read(key: _tokenKey);
  }
}
