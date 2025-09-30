import '../core/config/environment.dart';

/// Application-wide constants
///
/// Contains all the constant values used throughout the application
/// for better maintainability and configuration management.
/// Uses environment configuration for dynamic values.
class AppConstants {
  // Private constructor to prevent instantiation
  AppConstants._();

  // API Endpoints
  static String get baseUrl => Environment.baseUrl;
  static String get loginEndpoint => '/login';
  static String get usersEndpoint => '/users';
  static String get userDetailsEndpoint => '/users/2';

  // SharedPreferences Keys
  static const String userDataKey = 'user_data';
  static const String cachedUsersKey = 'cached_users';

  // Agora Configuration
  static String get agoraAppId => Environment.agoraAppId;
  static const String defaultChannelName = 'hipster_video_call';
  static String? get agoraToken => Environment.agoraToken;

  // App Configuration
  static String get appTitle => Environment.appName;
  static int get apiTimeoutSeconds => Environment.apiTimeout ~/ 1000;
  static int get cacheExpiryHours => Environment.cacheExpiryHours;

  // UI Constants
  static const double defaultPadding = 16.0;
  static const double defaultBorderRadius = 8.0;
  static const double buttonHeight = 48.0;

  // Test Credentials (for demo purposes)
  static const String testEmail = 'eve.holt@reqres.in';
  static const String testPassword = 'cityslicka';

  // Error Messages
  static const String networkErrorMessage =
      'Network error. Please check your connection.';
  static const String genericErrorMessage =
      'Something went wrong. Please try again.';
  static const String loginFailedMessage =
      'Login failed. Please check your credentials.';
  static const String usersLoadFailedMessage =
      'Failed to load users. Please try again.';
}
