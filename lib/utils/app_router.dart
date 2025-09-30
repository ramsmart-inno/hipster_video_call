import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../screens/splash_screen.dart';
import '../screens/login_screen.dart';
import '../screens/home_screen.dart';
import '../screens/video_call_screen.dart';
import '../screens/users_screen.dart';
import '../blocs/auth/auth_bloc.dart';

class AuthChangeNotifier extends ChangeNotifier {
  final AuthBloc authBloc;

  AuthChangeNotifier(this.authBloc) {
    authBloc.stream.listen((_) {
      notifyListeners();
    });
  }
}

class AppRouter {
  final AuthBloc authBloc;
  late final AuthChangeNotifier _authChangeNotifier;

  AppRouter(this.authBloc) {
    _authChangeNotifier = AuthChangeNotifier(authBloc);
  }

  late final GoRouter router = GoRouter(
    initialLocation: '/splash',
    refreshListenable: _authChangeNotifier,
    redirect: (context, state) {
      final isAuthenticated = authBloc.state is AuthAuthenticated;
      final isLoginRoute = state.matchedLocation == '/login';
      final isSplashRoute = state.matchedLocation == '/splash';

      // Allow splash screen to show initially
      if (isSplashRoute) {
        return null;
      }

      // If not authenticated and not on login route, redirect to login
      if (!isAuthenticated && !isLoginRoute) {
        return '/login';
      }

      // If authenticated and on login route, redirect to home
      if (isAuthenticated && isLoginRoute) {
        return '/';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/video-call',
        builder: (context, state) => const VideoCallScreen(),
      ),
      GoRoute(
        path: '/users',
        builder: (context, state) => const UsersScreen(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Error: ${state.error}'),
      ),
    ),
  );
}
