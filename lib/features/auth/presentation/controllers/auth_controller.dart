import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:movie_discovery_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:movie_discovery_app/features/auth/data/providers/auth_providers.dart';

final authControllerProvider = StateNotifierProvider<AuthController, AsyncValue<void>>(
  (ref) => AuthController(
    ref.watch(authRepositoryProvider),
  ),
);

class AuthController extends StateNotifier<AsyncValue<void>> {
  final AuthRepository _authRepository;

  AuthController(this._authRepository) : super(const AsyncValue.data(null));

  Future<void> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => _authRepository.signInWithEmailAndPassword(
        email: email,
        password: password,
      ),
    );
  }

  Future<void> registerWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => _authRepository.registerWithEmailAndPassword(
        email: email,
        password: password,
      ),
    );
  }

  Future<void> signOut() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _authRepository.signOut());
  }

  Future<bool> isSignedIn() async {
    return await _authRepository.isSignedIn();
  }

  Future<String?> getToken() async {
    return await _authRepository.getToken();
  }
}
