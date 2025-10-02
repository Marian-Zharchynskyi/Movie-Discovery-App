import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:movie_discovery_app/features/auth/presentation/controllers/auth_controller.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Movie Discovery'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await ref.read(authControllerProvider.notifier).signOut();
              if (context.mounted) {
                // ignore: use_build_context_synchronously
                GoRouter.of(context).go('/login');
              }
            },
          ),
        ],
      ),
      body: const Center(
        child: Text(
          'Welcome to Movie Discovery!',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
