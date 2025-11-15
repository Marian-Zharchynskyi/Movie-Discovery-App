import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:mocktail/mocktail.dart';
import 'package:movie_discovery_app/core/error/failures.dart';
import 'package:movie_discovery_app/core/injection_container.dart' as di;
import 'package:movie_discovery_app/core/preferences/user_preferences.dart';
import 'package:movie_discovery_app/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:movie_discovery_app/features/auth/domain/entities/user_entity.dart';
import 'package:movie_discovery_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:movie_discovery_app/features/auth/domain/usecases/get_current_user.dart';
import 'package:movie_discovery_app/features/auth/domain/usecases/sign_in.dart';
import 'package:movie_discovery_app/features/auth/domain/usecases/sign_out.dart';
import 'package:movie_discovery_app/features/auth/domain/usecases/sign_up.dart';
import 'package:movie_discovery_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:movie_discovery_app/features/profile/presentation/screens/account_screen.dart';
import 'package:movie_discovery_app/features/settings/presentation/providers/settings_provider.dart';
import 'package:movie_discovery_app/l10n/app_localizations.dart';

class _FakeAuthLocalDataSource implements AuthLocalDataSource {
  @override
  Future<void> clearToken() async {}

  @override
  Future<String?> getStoredToken() async => null;

  @override
  Future<void> storeToken(String token) async {}
}

class _FakeAuthRepository implements AuthRepository {
  _FakeAuthRepository(this._user);
  UserEntity? _user;

  @override
  Stream<UserEntity?> get authStateChanges => Stream<UserEntity?>.value(_user);

  @override
  Future<Either<Failure, void>> clearToken() async => const Right(null);

  @override
  Future<Either<Failure, UserEntity?>> getCurrentUser() async => Right(_user);

  @override
  Future<Either<Failure, String?>> getStoredToken() async => const Right(null);

  @override
  Future<Either<Failure, void>> storeToken(String token) async => const Right(null);

  @override
  Future<Either<Failure, UserEntity>> signInWithEmailAndPassword({required String email, required String password}) async {
    _user = UserEntity(id: '1', email: email);
    return Right(_user!);
  }

  @override
  Future<Either<Failure, UserEntity>> signUpWithEmailAndPassword({required String email, required String password, String? displayName}) async {
    _user = UserEntity(id: '1', email: email, displayName: displayName);
    return Right(_user!);
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    _user = null;
    return const Right(null);
  }
}

class MockUserPreferences extends Mock implements UserPreferences {}

Widget _buildApp({required UserEntity user, required UserPreferences prefs}) {
  // Ensure AuthLocalDataSource is registered so AccountScreen's token logging does not crash.
  if (!di.sl.isRegistered<AuthLocalDataSource>()) {
    di.sl.registerLazySingleton<AuthLocalDataSource>(() => _FakeAuthLocalDataSource());
  }

  return ProviderScope(
    overrides: [
      authProvider.overrideWith((ref) {
        final fakeRepo = _FakeAuthRepository(user);
        return AuthNotifier(
          signIn: SignIn(fakeRepo),
          signUp: SignUp(fakeRepo),
          signOut: SignOut(fakeRepo),
          getCurrentUser: GetCurrentUser(fakeRepo),
          authRepository: fakeRepo,
        );
      }),
      settingsProvider.overrideWith((ref) {
        final notifier = SettingsNotifier(prefs);
        notifier.loadSettings();
        return notifier;
      }),
    ],
    child: const MaterialApp(
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: AccountScreen(),
    ),
  );
}

void main() {
  setUpAll(() {
    registerFallbackValue(const Locale('en'));
  });

  group('AccountScreen', () {
    testWidgets('shows user info for authenticated user', (tester) async {
      final prefs = MockUserPreferences();
      when(() => prefs.getThemeModeString()).thenReturn('system');
      when(() => prefs.getLocaleCode()).thenReturn('en');

      const user = UserEntity(
        id: 'u1',
        email: 'user@example.com',
        displayName: 'Test User',
        role: 'User',
      );

      await tester.pumpWidget(_buildApp(user: user, prefs: prefs));
      await tester.pumpAndSettle();

      // Name and email may appear in multiple sections (header and info tiles), so allow multiple matches
      expect(find.text('Test User'), findsWidgets);
      expect(find.text('user@example.com'), findsWidgets);
      expect(find.byType(CircleAvatar), findsOneWidget);
    });

    testWidgets('shows admin-specific actions only for admin user', (tester) async {
      final prefs = MockUserPreferences();
      when(() => prefs.getThemeModeString()).thenReturn('system');
      when(() => prefs.getLocaleCode()).thenReturn('en');

      const adminUser = UserEntity(
        id: 'a1',
        email: 'admin@example.com',
        displayName: 'Admin',
        role: 'Admin',
      );

      await tester.pumpWidget(_buildApp(user: adminUser, prefs: prefs));
      await tester.pumpAndSettle();

      // Admin tile uses supervisor_account icon
      expect(find.byIcon(Icons.supervisor_account), findsOneWidget);
    });

    testWidgets('opens theme dialog when theme tile is tapped', (tester) async {
      final prefs = MockUserPreferences();
      when(() => prefs.getThemeModeString()).thenReturn('system');
      when(() => prefs.getLocaleCode()).thenReturn('en');
      when(() => prefs.setThemeModeString(any())).thenAnswer((_) async {});

      const user = UserEntity(
        id: 'u2',
        email: 'user2@example.com',
        displayName: 'Theme User',
        role: 'User',
      );

      await tester.pumpWidget(_buildApp(user: user, prefs: prefs));
      await tester.pumpAndSettle();

      // Tap on the theme ListTile (leading icon depends on current themeMode; start with system -> brightness_auto)
      await tester.tap(find.byIcon(Icons.brightness_auto));
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsOneWidget);
    });

    testWidgets('opens language dialog when language tile is tapped', (tester) async {
      final prefs = MockUserPreferences();
      when(() => prefs.getThemeModeString()).thenReturn('system');
      when(() => prefs.getLocaleCode()).thenReturn('en');
      when(() => prefs.setLocaleCode(any())).thenAnswer((_) async {});

      const user = UserEntity(
        id: 'u3',
        email: 'user3@example.com',
        displayName: 'Lang User',
        role: 'User',
      );

      await tester.pumpWidget(_buildApp(user: user, prefs: prefs));
      await tester.pumpAndSettle();

      // Tap on the language ListTile
      await tester.tap(find.byIcon(Icons.language));
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsOneWidget);
    });

    testWidgets('shows snackBar when edit profile is tapped', (tester) async {
      final prefs = MockUserPreferences();
      when(() => prefs.getThemeModeString()).thenReturn('system');
      when(() => prefs.getLocaleCode()).thenReturn('en');

      const user = UserEntity(
        id: 'u4',
        email: 'user4@example.com',
        displayName: 'Edit User',
        role: 'User',
      );

      await tester.pumpWidget(_buildApp(user: user, prefs: prefs));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.edit));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.byType(SnackBar), findsWidgets);
    });

    testWidgets('shows snackBar when change password is tapped', (tester) async {
      final prefs = MockUserPreferences();
      when(() => prefs.getThemeModeString()).thenReturn('system');
      when(() => prefs.getLocaleCode()).thenReturn('en');

      const user = UserEntity(
        id: 'u5',
        email: 'user5@example.com',
        displayName: 'Password User',
        role: 'User',
      );

      await tester.pumpWidget(_buildApp(user: user, prefs: prefs));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.lock));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.byType(SnackBar), findsWidgets);
    });

    testWidgets('shows snackBar when notifications is tapped', (tester) async {
      final prefs = MockUserPreferences();
      when(() => prefs.getThemeModeString()).thenReturn('system');
      when(() => prefs.getLocaleCode()).thenReturn('en');

      const user = UserEntity(
        id: 'u6',
        email: 'user6@example.com',
        displayName: 'Notif User',
        role: 'User',
      );

      await tester.pumpWidget(_buildApp(user: user, prefs: prefs));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.notifications));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.byType(SnackBar), findsWidgets);
    });
  });
}
