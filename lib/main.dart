import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'core/firebase/firebase_initializer.dart';
import 'core/injection_container.dart' as di;
import 'core/router/app_router.dart';
import 'features/auth/presentation/controllers/auth_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    // Initialize Firebase
    await FirebaseInitializer.initialize();
    
    // Initialize dependencies
    await di.init();
    
    runApp(
      const ProviderScope(
        child: MovieDiscoveryApp(),
      ),
    );
  } catch (e, stackTrace) {
    // Handle any errors that occur during initialization
    debugPrint('Failed to initialize app: $e');
    debugPrint('Stack trace: $stackTrace');
    
    // Optionally, show an error UI or fallback
    runApp(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: Text('Failed to initialize the app. Please try again later.'),
          ),
        ),
      ),
    );
  }
}

class MovieDiscoveryApp extends ConsumerWidget {
  const MovieDiscoveryApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    
    return MaterialApp.router(
      title: 'Movie Discovery',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      routerConfig: router,
    );
  }
}

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