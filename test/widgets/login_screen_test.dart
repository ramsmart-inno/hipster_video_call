import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:hipster_video_call/screens/login_screen.dart';
import 'package:hipster_video_call/blocs/auth/auth_bloc.dart';
import 'package:hipster_video_call/services/auth_service.dart';
import 'package:hipster_video_call/widgets/loading_indicator.dart';

import 'login_screen_test.mocks.dart';

@GenerateMocks([AuthService, AuthBloc])
void main() {
  group('LoginScreen Widget Tests', () {
    late MockAuthBloc mockAuthBloc;

    setUp(() {
      mockAuthBloc = MockAuthBloc();
    });

    Widget createWidgetUnderTest() {
      return MaterialApp(
        home: BlocProvider<AuthBloc>.value(
          value: mockAuthBloc,
          child: const LoginScreen(),
        ),
      );
    }

    testWidgets('should display all required UI elements', (tester) async {
      // Arrange
      when(mockAuthBloc.state).thenReturn(AuthInitial());
      when(mockAuthBloc.stream).thenAnswer((_) => Stream.value(AuthInitial()));

      // Act
      await tester.pumpWidget(createWidgetUnderTest());

      // Assert
      expect(find.text('Hipster Video Call'), findsOneWidget);
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('Login'), findsOneWidget);
      expect(find.byType(TextFormField), findsNWidgets(2));
      expect(find.byType(ElevatedButton), findsOneWidget);
    });

    testWidgets('should show loading indicator when auth state is loading',
        (tester) async {
      // Arrange
      when(mockAuthBloc.state).thenReturn(AuthLoading());
      when(mockAuthBloc.stream).thenAnswer((_) => Stream.value(AuthLoading()));

      // Act
      await tester.pumpWidget(createWidgetUnderTest());

      // Assert - Check for LoadingIndicator widget
      expect(find.byType(LoadingIndicator), findsOneWidget);
      expect(find.text('Email'), findsNothing);
      expect(find.text('Password'), findsNothing);
    });

    testWidgets('should validate email field correctly', (tester) async {
      // Arrange
      when(mockAuthBloc.state).thenReturn(AuthInitial());
      when(mockAuthBloc.stream).thenAnswer((_) => Stream.value(AuthInitial()));

      // Act
      await tester.pumpWidget(createWidgetUnderTest());

      // Find the login button and tap it without entering email
      final loginButton = find.text('Login');
      await tester.tap(loginButton);
      await tester.pump();

      // Assert
      expect(find.text('Please enter your email'), findsOneWidget);
    });

    testWidgets('should validate password field correctly', (tester) async {
      // Arrange
      when(mockAuthBloc.state).thenReturn(AuthInitial());
      when(mockAuthBloc.stream).thenAnswer((_) => Stream.value(AuthInitial()));

      // Act
      await tester.pumpWidget(createWidgetUnderTest());

      // Enter email but not password
      final emailField = find.byType(TextFormField).first;
      await tester.enterText(emailField, 'test@example.com');

      final loginButton = find.text('Login');
      await tester.tap(loginButton);
      await tester.pump();

      // Assert
      expect(find.text('Please enter your password'), findsOneWidget);
    });

    testWidgets('should validate email format correctly', (tester) async {
      // Arrange
      when(mockAuthBloc.state).thenReturn(AuthInitial());
      when(mockAuthBloc.stream).thenAnswer((_) => Stream.value(AuthInitial()));

      // Act
      await tester.pumpWidget(createWidgetUnderTest());

      // Enter invalid email format
      final emailField = find.byType(TextFormField).first;
      await tester.enterText(emailField, 'invalid-email');

      final loginButton = find.text('Login');
      await tester.tap(loginButton);
      await tester.pump();

      // Assert
      expect(find.text('Please enter a valid email'), findsOneWidget);
    });

    testWidgets('should trigger login event when form is valid',
        (tester) async {
      // Arrange
      when(mockAuthBloc.state).thenReturn(AuthInitial());
      when(mockAuthBloc.stream).thenAnswer((_) => Stream.value(AuthInitial()));

      // Act
      await tester.pumpWidget(createWidgetUnderTest());

      // Enter valid credentials
      final emailField = find.byType(TextFormField).first;
      final passwordField = find.byType(TextFormField).last;

      await tester.enterText(emailField, 'test@example.com');
      await tester.enterText(passwordField, 'password123');

      final loginButton = find.text('Login');
      await tester.tap(loginButton);
      await tester.pump();

      // Assert
      verify(mockAuthBloc.add(any)).called(1);
    });

    testWidgets('should show error message when auth state is error',
        (tester) async {
      // Arrange
      const errorMessage = 'Login failed';
      when(mockAuthBloc.state).thenReturn(AuthError(errorMessage));
      when(mockAuthBloc.stream)
          .thenAnswer((_) => Stream.value(AuthError(errorMessage)));

      // Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      // Assert
      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text(errorMessage), findsOneWidget);
    });

    testWidgets('should have password field with obscure text', (tester) async {
      // Arrange
      when(mockAuthBloc.state).thenReturn(AuthInitial());
      when(mockAuthBloc.stream).thenAnswer((_) => Stream.value(AuthInitial()));

      // Act
      await tester.pumpWidget(createWidgetUnderTest());

      // Assert - Check that password field exists
      final passwordFields = find.byType(TextFormField);
      expect(passwordFields, findsNWidgets(2));

      // Check that visibility toggle icon exists
      expect(find.byIcon(Icons.visibility), findsOneWidget);
    });
  });
}
