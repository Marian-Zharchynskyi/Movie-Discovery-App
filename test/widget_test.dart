import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:movie_discovery_app/features/movies/domain/usecases/get_popular_movies.dart';
import 'package:movie_discovery_app/features/movies/presentation/providers/movie_provider.dart';
import 'package:movie_discovery_app/features/movies/presentation/screens/home_screen.dart';
import 'package:movie_discovery_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:movie_discovery_app/features/auth/domain/entities/user_entity.dart';
import 'package:movie_discovery_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:movie_discovery_app/features/auth/domain/usecases/get_current_user.dart';
import 'package:movie_discovery_app/features/auth/domain/usecases/sign_in.dart';
import 'package:movie_discovery_app/features/auth/domain/usecases/sign_out.dart';
import 'package:movie_discovery_app/features/auth/domain/usecases/sign_up.dart';

// Mocks
class MockGetPopularMovies extends Mock implements GetPopularMovies {}
class MockSignIn extends Mock implements SignIn {}
class MockSignUp extends Mock implements SignUp {}
class MockSignOut extends Mock implements SignOut {}
class MockGetCurrentUser extends Mock implements GetCurrentUser {}
class MockAuthRepository extends Mock implements AuthRepository {
  @override
  Stream<UserEntity?> get authStateChanges => const Stream.empty();
}

void main() {
  late MockGetPopularMovies mockGetPopularMovies;
  late MockAuthRepository mockAuthRepository;
  late MockSignIn mockSignIn;
  late MockSignUp mockSignUp;
  late MockSignOut mockSignOut;
  late MockGetCurrentUser mockGetCurrentUser;

  setUp(() {
    mockGetPopularMovies = MockGetPopularMovies();
    mockAuthRepository = MockAuthRepository();
    mockSignIn = MockSignIn();
    mockSignUp = MockSignUp();
    mockSignOut = MockSignOut();
    mockGetCurrentUser = MockGetCurrentUser();
  });

  testWidgets('HomeScreen should display correctly', (WidgetTester tester) async {
    // Setup mocks
    when(() => mockGetPopularMovies(page: any(named: 'page')))
        .thenAnswer((_) async => const Right([]));

    // Build HomeScreen directly with provider overrides
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          getPopularMoviesProvider.overrideWithValue(mockGetPopularMovies),
          // Mock auth provider to prevent Firebase initialization
          authProvider.overrideWith((ref) {
            return AuthNotifier(
              signIn: mockSignIn,
              signUp: mockSignUp,
              signOut: mockSignOut,
              getCurrentUser: mockGetCurrentUser,
              authRepository: mockAuthRepository,
            );
          }),
        ],
        child: const MaterialApp(
          home: HomeScreen(),
        ),
      ),
    );
    
    // Wait for the first frame
    await tester.pump();
    
    // Wait for any remaining animations
    await tester.pumpAndSettle();
    
    // Verify HomeScreen is displayed
    expect(find.byType(HomeScreen), findsOneWidget);
    
    // Verify the AppBar title is displayed
    expect(find.text('Popular Movies'), findsOneWidget);
  });
}