import '../models/user_model.dart';
import '../utils/app_logger.dart';
import '../core/network/api_client.dart';
import 'secure_storage_service.dart';

/// Authentication service with secure storage and API abstraction
///
/// Handles user authentication, token management, and secure storage
/// of sensitive user data using modern Flutter best practices.
class AuthService {
  final ApiClient _apiClient;
  final SecureStorageService _secureStorage;

  /// Creates a new AuthService instance
  AuthService(this._apiClient, this._secureStorage);

  /// Login with email and password
  ///
  /// Returns a [User] object if successful, throws exception if failed.
  /// Stores authentication token securely for future requests.
  Future<User> login(String email, String password) async {
    try {
      AppLogger.info('Attempting login for user: $email');

      // Make API call to login endpoint
      final response = await _apiClient.post<Map<String, dynamic>>(
        '/login',
        data: {
          'email': email,
          'password': password,
        },
      );

      if (response.isSuccess && response.data != null) {
        final String token = response.data!['token'];

        // Set auth token for subsequent requests
        _apiClient.setAuthToken(token);

        // Get user details
        final userResponse =
            await _apiClient.get<Map<String, dynamic>>('/users/2');

        if (userResponse.isSuccess && userResponse.data != null) {
          final Map<String, dynamic> userData = userResponse.data!['data'];
          userData['token'] = token;

          // Create user object
          final user = User.fromJson(userData);

          // Store user data securely
          await _storeUserSecurely(user);

          AppLogger.info('Login successful for user: $email');
          return user;
        } else {
          throw Exception('Failed to load user data');
        }
      } else {
        throw Exception('Login failed: ${response.error ?? 'Unknown error'}');
      }
    } catch (e) {
      AppLogger.error('Login error for user: $email', e);
      rethrow;
    }
  }

  /// Check if user is already logged in
  ///
  /// Returns the current [User] if authenticated, null otherwise.
  Future<User?> getCurrentUser() async {
    try {
      AppLogger.info('🔍 Checking for current user...');

      // Test storage functionality first
      await _secureStorage.testStorage();

      final token = await _secureStorage.getUserToken();
      final userId = await _secureStorage.getUserId();
      final email = await _secureStorage.getUserEmail();

      AppLogger.debug(
          '📱 Stored data - Token: ${token != null ? "✅" : "❌"}, UserId: ${userId != null ? "✅" : "❌"}, Email: ${email != null ? "✅" : "❌"}');

      if (token != null && userId != null && email != null) {
        AppLogger.info('🔑 Found stored credentials, validating with API...');

        // Set auth token for API requests
        _apiClient.setAuthToken(token);

        // Try to get fresh user data from API
        final userResponse =
            await _apiClient.get<Map<String, dynamic>>('/users/$userId');

        if (userResponse.isSuccess && userResponse.data != null) {
          final userData = userResponse.data!['data'];
          userData['token'] = token;

          final user = User.fromJson(userData);
          AppLogger.info(
              '✅ Current user retrieved successfully: ${user.email}');
          return user;
        } else {
          AppLogger.warning('⚠️ API validation failed, clearing stored data');
          await _secureStorage.clearUserData();
        }
      }

      AppLogger.info('❌ No valid current user found');
      return null;
    } catch (e) {
      AppLogger.error('💥 Error getting current user', e);
      // Clear potentially corrupted data
      await _secureStorage.clearUserData();
      return null;
    }
  }

  /// Logout user
  ///
  /// Clears all stored user data and authentication tokens.
  Future<void> logout() async {
    try {
      // Clear auth token from API client
      _apiClient.clearAuthToken();

      // Clear all stored user data
      await _secureStorage.clearUserData();

      AppLogger.info('User logged out successfully');
    } catch (e) {
      AppLogger.error('Error during logout', e);
      rethrow;
    }
  }

  /// Store user data securely
  Future<void> _storeUserSecurely(User user) async {
    await Future.wait([
      _secureStorage.storeUserToken(user.token),
      _secureStorage.storeUserId(user.id.toString()),
      _secureStorage.storeUserEmail(user.email),
    ]);

    AppLogger.debug('User data stored securely');
  }

  /// Check if user is authenticated
  Future<bool> isAuthenticated() async {
    return await _secureStorage.isUserLoggedIn();
  }
}
