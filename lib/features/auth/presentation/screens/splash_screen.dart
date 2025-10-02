import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../controllers/auth_controller.dart';

class SplashScreen extends ConsumerWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<AsyncValue<void>>(authControllerProvider, (_, state) {
      state.whenOrNull(
        data: (_) {
          // Navigate to home if authenticated, otherwise to login
          final isAuthenticated = ref.read(authControllerProvider.notifier).isSignedIn();
          isAuthenticated.then((isAuth) {
            if (isAuth) {
              context.go('/home');
            } else {
              context.go('/login');
            }
          });
        },
        error: (error, _) => context.go('/login'),
      );
    });

    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
