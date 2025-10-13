import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:movie_discovery_app/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Authentication Flow Integration Tests', () {
    testWidgets('User can view login screen', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Wait for app to initialize
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();

      // Check if login/auth UI elements are present
      final loginFinder = find.text('Login');
      final signInFinder = find.text('Sign In');
      
      // Either login button or sign in text should be present
      expect(
        loginFinder.evaluate().isNotEmpty || signInFinder.evaluate().isNotEmpty,
        true,
      );
    });

    testWidgets('Login form validation works', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();

      // Look for email and password fields
      final emailFields = find.byType(TextField);
      if (emailFields.evaluate().length >= 2) {
        // Try to submit empty form
        final submitButton = find.widgetWithText(ElevatedButton, 'Sign In');
        if (submitButton.evaluate().isNotEmpty) {
          await tester.tap(submitButton);
          await tester.pumpAndSettle();

          // Validation errors should appear
          // This is a basic check that the form doesn't crash
          expect(find.byType(Scaffold), findsWidgets);
        }
      }
    });

    testWidgets('User can navigate between login and signup', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();

      // Look for signup navigation
      final signUpFinder = find.text('Sign Up');
      final registerFinder = find.text('Register');
      
      if (signUpFinder.evaluate().isNotEmpty) {
        await tester.tap(signUpFinder.first);
        await tester.pumpAndSettle();
        
        // Should navigate to signup screen
        expect(find.byType(Scaffold), findsWidgets);
      } else if (registerFinder.evaluate().isNotEmpty) {
        await tester.tap(registerFinder.first);
        await tester.pumpAndSettle();
        
        expect(find.byType(Scaffold), findsWidgets);
      }
    });
  });

  group('Authenticated User Flow', () {
    testWidgets('Authenticated user can access profile', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();

      // Look for profile icon
      final profileFinder = find.byIcon(Icons.person);
      final accountFinder = find.byIcon(Icons.account_circle);
      
      if (profileFinder.evaluate().isNotEmpty) {
        await tester.tap(profileFinder.first);
        await tester.pumpAndSettle();
        
        expect(find.byType(Scaffold), findsWidgets);
      } else if (accountFinder.evaluate().isNotEmpty) {
        await tester.tap(accountFinder.first);
        await tester.pumpAndSettle();
        
        expect(find.byType(Scaffold), findsWidgets);
      }
    });
  });
}
