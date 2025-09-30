import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:hipster_video_call/blocs/auth/auth_bloc.dart';
import 'package:hipster_video_call/services/auth_service.dart';
import 'package:hipster_video_call/models/user_model.dart';

import 'auth_bloc_test.mocks.dart';

@GenerateMocks([AuthService])
void main() {
  group('AuthBloc Tests', () {
    late AuthBloc authBloc;
    late MockAuthService mockAuthService;

    setUp(() {
      mockAuthService = MockAuthService();
      authBloc = AuthBloc(mockAuthService);
    });

    tearDown(() {
      authBloc.close();
    });

    test('initial state should be AuthInitial', () {
      expect(authBloc.state, isA<AuthInitial>());
    });

    group('LoginEvent', () {
      final testUser = User(
        id: 1,
        email: 'test@example.com',
        firstName: 'John',
        lastName: 'Doe',
        avatar: 'https://example.com/avatar.jpg',
        token: 'test_token',
      );

      blocTest<AuthBloc, AuthState>(
        'should emit [AuthLoading, AuthAuthenticated] when login succeeds',
        build: () {
          when(mockAuthService.login('test@example.com', 'password123'))
              .thenAnswer((_) async => testUser);
          return authBloc;
        },
        act: (bloc) => bloc.add(LoginEvent(
          email: 'test@example.com',
          password: 'password123',
        )),
        expect: () => [
          isA<AuthLoading>(),
          isA<AuthAuthenticated>().having(
            (state) => state.user.email,
            'user email',
            'test@example.com',
          ),
        ],
        verify: (_) {
          verify(mockAuthService.login('test@example.com', 'password123'))
              .called(1);
        },
      );

      blocTest<AuthBloc, AuthState>(
        'should emit [AuthLoading, AuthError] when login fails',
        build: () {
          when(mockAuthService.login('test@example.com', 'wrong_password'))
              .thenThrow(Exception('Invalid credentials'));
          return authBloc;
        },
        act: (bloc) => bloc.add(LoginEvent(
          email: 'test@example.com',
          password: 'wrong_password',
        )),
        expect: () => [
          isA<AuthLoading>(),
          isA<AuthError>().having(
            (state) => state.message,
            'error message',
            contains('Invalid credentials'),
          ),
        ],
      );
    });

    group('CheckAuthStatusEvent', () {
      final testUser = User(
        id: 1,
        email: 'test@example.com',
        firstName: 'John',
        lastName: 'Doe',
        avatar: 'https://example.com/avatar.jpg',
        token: 'test_token',
      );

      blocTest<AuthBloc, AuthState>(
        'should emit [AuthLoading, AuthAuthenticated] when user is logged in',
        build: () {
          when(mockAuthService.getCurrentUser())
              .thenAnswer((_) async => testUser);
          return authBloc;
        },
        act: (bloc) => bloc.add(CheckAuthStatusEvent()),
        expect: () => [
          isA<AuthLoading>(),
          isA<AuthAuthenticated>().having(
            (state) => state.user.email,
            'user email',
            'test@example.com',
          ),
        ],
      );

      blocTest<AuthBloc, AuthState>(
        'should emit [AuthLoading, AuthUnauthenticated] when no user is logged in',
        build: () {
          when(mockAuthService.getCurrentUser())
              .thenAnswer((_) async => null);
          return authBloc;
        },
        act: (bloc) => bloc.add(CheckAuthStatusEvent()),
        expect: () => [
          isA<AuthLoading>(),
          isA<AuthUnauthenticated>(),
        ],
      );

      blocTest<AuthBloc, AuthState>(
        'should emit [AuthLoading, AuthUnauthenticated] when getCurrentUser throws',
        build: () {
          when(mockAuthService.getCurrentUser())
              .thenThrow(Exception('Network error'));
          return authBloc;
        },
        act: (bloc) => bloc.add(CheckAuthStatusEvent()),
        expect: () => [
          isA<AuthLoading>(),
          isA<AuthUnauthenticated>(),
        ],
      );
    });

    group('LogoutEvent', () {
      blocTest<AuthBloc, AuthState>(
        'should emit [AuthLoading, AuthUnauthenticated] when logout succeeds',
        build: () {
          when(mockAuthService.logout()).thenAnswer((_) async {});
          return authBloc;
        },
        act: (bloc) => bloc.add(LogoutEvent()),
        expect: () => [
          isA<AuthLoading>(),
          isA<AuthUnauthenticated>(),
        ],
        verify: (_) {
          verify(mockAuthService.logout()).called(1);
        },
      );
    });
  });
}
