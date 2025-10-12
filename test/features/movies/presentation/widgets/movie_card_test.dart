import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:movie_discovery_app/features/auth/domain/entities/user_entity.dart';
import 'package:movie_discovery_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:movie_discovery_app/features/auth/domain/usecases/get_current_user.dart';
import 'package:movie_discovery_app/features/auth/domain/usecases/sign_in.dart';
import 'package:movie_discovery_app/features/auth/domain/usecases/sign_out.dart';
import 'package:movie_discovery_app/features/auth/domain/usecases/sign_up.dart';
import 'package:movie_discovery_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:movie_discovery_app/features/movies/domain/entities/movie_entity.dart';
import 'package:movie_discovery_app/features/movies/presentation/widgets/movie_card.dart';
import 'package:movie_discovery_app/shared/widgets/rating_stars.dart';

class MockAuthRepository extends Mock implements AuthRepository {
  @override
  Stream<UserEntity?> get authStateChanges => const Stream.empty();
}

class MockSignIn extends Mock implements SignIn {}
class MockSignUp extends Mock implements SignUp {}
class MockSignOut extends Mock implements SignOut {}
class MockGetCurrentUser extends Mock implements GetCurrentUser {}

void main() {
  late MockAuthRepository mockAuthRepository;
  late MockSignIn mockSignIn;
  late MockSignUp mockSignUp;
  late MockSignOut mockSignOut;
  late MockGetCurrentUser mockGetCurrentUser;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    mockSignIn = MockSignIn();
    mockSignUp = MockSignUp();
    mockSignOut = MockSignOut();
    mockGetCurrentUser = MockGetCurrentUser();
  });

  const tMovie = MovieEntity(
    id: 1,
    title: 'Test Movie',
    overview: 'Test overview',
    posterPath: '/test.jpg',
    voteAverage: 8.5,
    releaseDate: '2024-01-15',
    genreIds: [28, 12],
  );

  Widget createWidgetUnderTest() {
    return ProviderScope(
      overrides: [
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
        home: Scaffold(
          body: MovieCard(movie: tMovie),
        ),
      ),
    );
  }

  testWidgets('MovieCard displays movie title', (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pump();

    expect(find.text('Test Movie'), findsOneWidget);
  });

  testWidgets('MovieCard displays movie rating', (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pump();

    expect(find.text('8.5'), findsOneWidget);
    expect(find.byType(RatingStars), findsOneWidget);
  });

  testWidgets('MovieCard displays release year', (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pump();

    expect(find.text('2024'), findsOneWidget);
  });

  testWidgets('MovieCard is tappable', (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pump();

    // MovieCard contains an InkWell that makes it tappable
    expect(find.byType(InkWell), findsWidgets);
  });

  testWidgets('MovieCard displays placeholder when no poster', (WidgetTester tester) async {
    const movieNoPoster = MovieEntity(
      id: 2,
      title: 'No Poster Movie',
      overview: 'Test overview',
      posterPath: null,
      voteAverage: 7.0,
      releaseDate: '2024-01-01',
      genreIds: [18],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
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
          home: Scaffold(
            body: MovieCard(movie: movieNoPoster),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.byIcon(Icons.movie), findsOneWidget);
  });
}
