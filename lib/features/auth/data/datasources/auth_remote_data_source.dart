import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:movie_discovery_app/core/error/exceptions.dart';
import 'package:movie_discovery_app/core/services/mock_auth_api.dart';
import 'package:movie_discovery_app/features/auth/data/models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> signInWithEmailAndPassword({
    required String email,
    required String password,
  });

  Future<UserModel> signUpWithEmailAndPassword({
    required String email,
    required String password,
    String? displayName,
  });

  Future<void> signOut();

  Future<UserModel?> getCurrentUser();

  Stream<UserModel?> get authStateChanges;
  
  Future<String?> getJwtToken();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final FirebaseAuth firebaseAuth;
  final FirebaseFirestore firestore;

  AuthRemoteDataSourceImpl({required this.firebaseAuth, required this.firestore});

  @override
  Future<UserModel> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user == null) {
        throw ServerException('Failed to sign in');
      }

      // Fetch role from Firestore (default 'User' if missing)
      final uid = userCredential.user!.uid;
      final role = await _getUserRole(uid);
      return UserModel.fromFirebaseUser(userCredential.user!, role: role);
    } on FirebaseAuthException catch (e) {
      throw ServerException(_getErrorMessage(e.code));
    } catch (e) {
      throw ServerException('An unexpected error occurred');
    }
  }

  @override
  Future<UserModel> signUpWithEmailAndPassword({
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      final userCredential = await firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user == null) {
        throw ServerException('Failed to create account');
      }

      // Update display name if provided
      if (displayName != null && displayName.isNotEmpty) {
        await userCredential.user!.updateDisplayName(displayName);
        await userCredential.user!.reload();
      }

      final updatedUser = firebaseAuth.currentUser;
      if (updatedUser == null) {
        throw ServerException('Failed to get user data');
      }

      // Ensure user document exists with default role 'User'
      await _ensureUserDocument(
        updatedUser.uid,
        displayName: displayName,
        email: updatedUser.email,
      );

      final role = await _getUserRole(updatedUser.uid);
      return UserModel.fromFirebaseUser(updatedUser, role: role);
    } on FirebaseAuthException catch (e) {
      throw ServerException(_getErrorMessage(e.code));
    } catch (e) {
      throw ServerException('An unexpected error occurred');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await firebaseAuth.signOut();
    } catch (e) {
      throw ServerException('Failed to sign out');
    }
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    try {
      final user = firebaseAuth.currentUser;
      if (user == null) return null;
      final role = await _getUserRole(user.uid);
      return UserModel.fromFirebaseUser(user, role: role);
    } catch (e) {
      throw ServerException('Failed to get current user');
    }
  }

  @override
  Stream<UserModel?> get authStateChanges {
    return firebaseAuth.authStateChanges().asyncMap((user) async {
      if (user == null) return null;
      final role = await _getUserRole(user.uid);
      return UserModel.fromFirebaseUser(user, role: role);
    });
  }

  @override
  Future<String?> getJwtToken() async {
    try {
      final user = firebaseAuth.currentUser;
      if (user == null) return null;
      return await user.getIdToken();
    } catch (e) {
      throw ServerException('Failed to get JWT token');
    }
  }

  String _getErrorMessage(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No user found with this email';
      case 'wrong-password':
        return 'Wrong password provided';
      case 'email-already-in-use':
        return 'An account already exists with this email';
      case 'invalid-email':
        return 'Invalid email address';
      case 'weak-password':
        return 'Password is too weak';
      case 'operation-not-allowed':
        return 'Operation not allowed';
      case 'user-disabled':
        return 'This user has been disabled';
      default:
        return 'Authentication failed. Please try again';
    }
  }
}

extension on AuthRemoteDataSourceImpl {
  Future<String> _getUserRole(String uid) async {
    try {
      final doc = await firestore.collection('users').doc(uid).get();
      if (!doc.exists) return 'User';
      final data = doc.data();
      final role = (data?['role'] as String?) ?? 'User';
      return role;
    } catch (_) {
      return 'User';
    }
  }

  Future<void> _ensureUserDocument(String uid, {String? displayName, String? email}) async {
    final ref = firestore.collection('users').doc(uid);
    final snap = await ref.get();
    if (!snap.exists) {
      await ref.set({
        'role': 'User',
        'displayName': displayName,
        'email': email,
        'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }
  }
}

/// Mock API implementation with JWT tokens
class AuthRemoteDataSourceMock implements AuthRemoteDataSource {
  final MockAuthApi mockAuthApi;
  String? _currentToken;
  UserModel? _currentUser;

  AuthRemoteDataSourceMock({required this.mockAuthApi});

  @override
  Future<UserModel> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final result = await mockAuthApi.signIn(
        email: email,
        password: password,
      );

      _currentToken = result['token'] as String;
      final userData = result['user'] as Map<String, dynamic>;
      _currentUser = UserModel.fromJson(userData);

      return _currentUser!;
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException('An unexpected error occurred');
    }
  }

  @override
  Future<UserModel> signUpWithEmailAndPassword({
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      final result = await mockAuthApi.signUp(
        email: email,
        password: password,
        displayName: displayName,
      );

      _currentToken = result['token'] as String;
      final userData = result['user'] as Map<String, dynamic>;
      _currentUser = UserModel.fromJson(userData);

      return _currentUser!;
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException('An unexpected error occurred');
    }
  }

  @override
  Future<void> signOut() async {
    _currentToken = null;
    _currentUser = null;
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    if (_currentToken == null) return null;

    try {
      final userData = await mockAuthApi.verifyToken(_currentToken!);
      if (userData == null) {
        _currentToken = null;
        _currentUser = null;
        return null;
      }

      _currentUser = UserModel.fromJson(userData);
      return _currentUser;
    } on ServerException {
      _currentToken = null;
      _currentUser = null;
      return null;
    }
  }

  @override
  Stream<UserModel?> get authStateChanges {
    // For mock implementation, return a simple stream
    return Stream.value(_currentUser);
  }

  @override
  Future<String?> getJwtToken() async {
    return _currentToken;
  }
}
