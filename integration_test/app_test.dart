import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:hipster_video_call/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('App Integration Tests', () {
    testWidgets('App should start and show login screen', (tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Verify that the app starts and shows the login screen
      expect(find.text('Hipster Video Call'), findsOneWidget);
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('Login'), findsOneWidget);
    });

    testWidgets('Login flow should work correctly', (tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Find email and password fields
      final emailField = find.byType(TextFormField).first;
      final passwordField = find.byType(TextFormField).last;
      final loginButton = find.text('Login');

      // Enter test credentials
      await tester.enterText(emailField, 'eve.holt@reqres.in');
      await tester.enterText(passwordField, 'cityslicka');
      
      // Tap login button
      await tester.tap(loginButton);
      await tester.pumpAndSettle();

      // Wait for navigation and verify we're on the video call screen
      // Note: This might take some time due to API call
      await tester.pumpAndSettle(const Duration(seconds: 5));
      
      // Verify we're on the video call screen
      expect(find.text('Video Call'), findsOneWidget);
    });

    testWidgets('Navigation should work correctly', (tester) async {
      // Start the app and login first
      app.main();
      await tester.pumpAndSettle();

      // Login process
      final emailField = find.byType(TextFormField).first;
      final passwordField = find.byType(TextFormField).last;
      final loginButton = find.text('Login');

      await tester.enterText(emailField, 'eve.holt@reqres.in');
      await tester.enterText(passwordField, 'cityslicka');
      await tester.tap(loginButton);
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Navigate to users screen
      final usersButton = find.text('Users');
      if (usersButton.evaluate().isNotEmpty) {
        await tester.tap(usersButton);
        await tester.pumpAndSettle();

        // Verify we're on the users screen
        expect(find.text('Users'), findsOneWidget);
      }
    });

    testWidgets('Error handling should work correctly', (tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Try to login with invalid credentials
      final emailField = find.byType(TextFormField).first;
      final passwordField = find.byType(TextFormField).last;
      final loginButton = find.text('Login');

      await tester.enterText(emailField, 'invalid@email.com');
      await tester.enterText(passwordField, 'wrongpassword');
      await tester.tap(loginButton);
      await tester.pumpAndSettle();

      // Wait for error message
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Verify error handling (snackbar or error message)
      expect(find.byType(SnackBar), findsOneWidget);
    });

    testWidgets('Form validation should work correctly', (tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Try to login without entering credentials
      final loginButton = find.text('Login');
      await tester.tap(loginButton);
      await tester.pumpAndSettle();

      // Verify validation messages appear
      expect(find.text('Please enter your email'), findsOneWidget);
      expect(find.text('Please enter your password'), findsOneWidget);
    });

    testWidgets('Loading states should be handled correctly', (tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Enter valid credentials
      final emailField = find.byType(TextFormField).first;
      final passwordField = find.byType(TextFormField).last;
      final loginButton = find.text('Login');

      await tester.enterText(emailField, 'eve.holt@reqres.in');
      await tester.enterText(passwordField, 'cityslicka');
      
      // Tap login and immediately check for loading indicator
      await tester.tap(loginButton);
      await tester.pump(); // Don't settle, we want to catch the loading state

      // Verify loading indicator appears
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });
}
