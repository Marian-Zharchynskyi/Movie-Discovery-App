import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movie_discovery_app/features/auth/domain/entities/user_entity.dart';
import 'package:movie_discovery_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:movie_discovery_app/features/auth/domain/usecases/get_current_user.dart';
import 'package:movie_discovery_app/features/auth/domain/usecases/sign_in.dart';
import 'package:movie_discovery_app/features/auth/domain/usecases/sign_out.dart';
import 'package:movie_discovery_app/features/auth/domain/usecases/sign_up.dart';
import 'package:movie_discovery_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:movie_discovery_app/features/auth/presentation/screens/register_screen.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:movie_discovery_app/l10n/app_localizations.dart';
import 'package:movie_discovery_app/core/error/failures.dart';

class FakeAuthRepository implements AuthRepository {
  UserEntity? current;
  @override
  Stream<UserEntity?> get authStateChanges async* {}

  @override
  Future<Either<Failure, UserEntity>> signInWithEmailAndPassword({required String email, required String password}) async {
    current = UserEntity(id: '1', email: email, role: 'User');
    return Right(current!);
  }

  @override
  Future<Either<Failure, UserEntity>> signUpWithEmailAndPassword({required String email, required String password, String? displayName}) async {
    current = UserEntity(id: '1', email: email, displayName: displayName, role: 'User');
    return Right(current!);
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    current = null;
    return const Right(null);
  }

  @override
  Future<Either<Failure, UserEntity?>> getCurrentUser() async => Right(current);
  @override
  Future<Either<Failure, String?>> getStoredToken() async => const Right(null);
  @override
  Future<Either<Failure, void>> storeToken(String token) async => const Right(null);
  @override
  Future<Either<Failure, void>> clearToken() async => const Right(null);
}

void main() {
  testWidgets('RegisterScreen renders and has fields', (tester) async {
    final repo = FakeAuthRepository();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authProvider.overrideWith((ref) => AuthNotifier(
                signIn: SignIn(repo),
                signUp: SignUp(repo),
                signOut: SignOut(repo),
                getCurrentUser: GetCurrentUser(repo),
                authRepository: repo,
              )),
        ],
        child: const MaterialApp(
          localizationsDelegates: [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: RegisterScreen(),
        ),
      ),
    );

    // Name, Email, Password, Confirm Password
    expect(find.byType(TextFormField), findsNWidgets(4));
    expect(find.byType(FilledButton), findsOneWidget);
  });
}
