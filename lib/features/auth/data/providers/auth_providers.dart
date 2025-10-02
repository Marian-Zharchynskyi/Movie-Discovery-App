import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:movie_discovery_app/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:movie_discovery_app/features/auth/domain/repositories/auth_repository.dart';

final firebaseAuthProvider = Provider<FirebaseAuth>((ref) => FirebaseAuth.instance);

final flutterSecureStorageProvider = Provider<FlutterSecureStorage>(
  (ref) => const FlutterSecureStorage(),
);

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    firebaseAuth: ref.watch(firebaseAuthProvider),
    secureStorage: ref.watch(flutterSecureStorageProvider),
  );
});
