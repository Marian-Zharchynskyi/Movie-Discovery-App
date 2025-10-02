import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:movie_discovery_app/features/auth/presentation/screens/login_screen.dart';
import 'package:movie_discovery_app/features/auth/presentation/screens/register_screen.dart';
import 'package:movie_discovery_app/features/auth/presentation/screens/splash_screen.dart';
import 'package:movie_discovery_app/features/auth/presentation/router/auth_guard.dart';
import 'package:movie_discovery_app/features/home/presentation/screens/home_screen.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

final goRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/splash',
    routes: [
      // Splash screen
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      
      // Auth routes
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      
      // Protected routes
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) => AuthGuard(
          child: child,
          redirectTo: '/login',
        ),
        routes: [
          GoRoute(
            path: '/home',
            builder: (context, state) => const HomeScreen(),
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Page not found: ${state.uri}'),
      ),
    ),
  );
});

// For direct access to the router in widgets
final routerProvider = Provider<GoRouter>((ref) {
  return ref.watch(goRouterProvider);
});
