import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:movie_discovery_app/features/auth/presentation/controllers/auth_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AuthGuard extends ConsumerWidget {
  final Widget child;
  final String redirectTo;

  const AuthGuard({
    super.key,
    required this.child,
    this.redirectTo = '/login',
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAuthenticated = ref.read(authControllerProvider.notifier).isSignedIn();

    return FutureBuilder<bool>(
      future: isAuthenticated,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        final isLoggedIn = snapshot.data ?? false;

        if (!isLoggedIn) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.go(redirectTo);
          });
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        return child;
      },
    );
  }
}
