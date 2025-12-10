import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:movie_discovery_app/core/router/app_router.dart';
import 'package:movie_discovery_app/l10n/app_localizations.dart';

class _HomeStubScreen extends StatelessWidget {
  const _HomeStubScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text('Home Stub')));
  }
}

class _FavoritesStubScreen extends StatelessWidget {
  const _FavoritesStubScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text('Favorites Stub')));
  }
}

class _AccountStubScreen extends StatelessWidget {
  const _AccountStubScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text('Account Stub')));
  }
}

Widget _buildApp({String initialLocation = '/home'}) {
  final router = GoRouter(
    initialLocation: initialLocation,
    routes: [
      ShellRoute(
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(
            path: '/home',
            builder: (context, state) => const _HomeStubScreen(),
          ),
          GoRoute(
            path: '/favorites',
            builder: (context, state) => const _FavoritesStubScreen(),
          ),
          GoRoute(
            path: '/account',
            builder: (context, state) => const _AccountStubScreen(),
          ),
        ],
      ),
    ],
  );

  return MaterialApp.router(
    routerConfig: router,
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: AppLocalizations.supportedLocales,
  );
}

void main() {
  testWidgets('MainShell switches tabs via bottom navigation', (tester) async {
    await tester.pumpWidget(_buildApp());
    await tester.pumpAndSettle();

    // Initially on home
    expect(find.byType(_HomeStubScreen), findsOneWidget);
    var bottomBar = tester.widget<BottomNavigationBar>(
      find.byType(BottomNavigationBar),
    );
    expect(bottomBar.currentIndex, 0);

    // Tap favorites tab
    await tester.tap(find.byIcon(Icons.favorite));
    await tester.pumpAndSettle();
    expect(find.byType(_FavoritesStubScreen), findsOneWidget);
    bottomBar = tester.widget<BottomNavigationBar>(
      find.byType(BottomNavigationBar),
    );
    expect(bottomBar.currentIndex, 1);

    // Tap account tab
    await tester.tap(find.byIcon(Icons.person));
    await tester.pumpAndSettle();
    expect(find.byType(_AccountStubScreen), findsOneWidget);
    bottomBar = tester.widget<BottomNavigationBar>(
      find.byType(BottomNavigationBar),
    );
    expect(bottomBar.currentIndex, 2);
  });

  testWidgets('MainShell selects favorites tab when initial route is /favorites', (tester) async {
    await tester.pumpWidget(_buildApp(initialLocation: '/favorites'));
    await tester.pumpAndSettle();

    expect(find.byType(_FavoritesStubScreen), findsOneWidget);
    final bottomBar = tester.widget<BottomNavigationBar>(
      find.byType(BottomNavigationBar),
    );
    expect(bottomBar.currentIndex, 1);
  });

  testWidgets('MainShell selects account tab when initial route is /account', (tester) async {
    await tester.pumpWidget(_buildApp(initialLocation: '/account'));
    await tester.pumpAndSettle();

    expect(find.byType(_AccountStubScreen), findsOneWidget);
    final bottomBar = tester.widget<BottomNavigationBar>(
      find.byType(BottomNavigationBar),
    );
    expect(bottomBar.currentIndex, 2);
  });
}
