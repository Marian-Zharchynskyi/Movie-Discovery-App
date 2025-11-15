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

      expect(find.text('Test User'), findsOneWidget);
      expect(find.text('user@example.com'), findsOneWidget);
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
  });
}
