import 'package:firebase_auth/firebase_auth.dart';

abstract class AuthRepository {
  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  });

  Future<UserCredential> registerWithEmailAndPassword({
    required String email,
    required String password,
  });

  Future<void> signOut();
  Future<bool> isSignedIn();
  Future<String?> getToken();
}
