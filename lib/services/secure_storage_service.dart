import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../utils/app_logger.dart';

/// Secure storage service for sensitive data
///
/// Provides encrypted storage for sensitive information like tokens,
/// user credentials, and other private data using the device's keychain.
class SecureStorageService {
  final FlutterSecureStorage _secureStorage;

  /// Creates a new SecureStorageService instance
  SecureStorageService(this._secureStorage);

  // Storage keys
  static const String _userTokenKey = 'user_token';
  static const String _userIdKey = 'user_id';
  static const String _userEmailKey = 'user_email';
  static const String _refreshTokenKey = 'refresh_token';

  /// Store user authentication token securely
  Future<void> storeUserToken(String token) async {
    try {
      await _secureStorage.write(key: _userTokenKey, value: token);
      AppLogger.debug('💾 User token stored securely (${token.length} chars)');
    } catch (e) {
      AppLogger.error('💥 Failed to store user token', e);
      rethrow;
    }
  }

  /// Retrieve user authentication token
  Future<String?> getUserToken() async {
    try {
      final token = await _secureStorage.read(key: _userTokenKey);
      AppLogger.debug(
          '🔑 User token retrieved: ${token != null ? "Found (${token.length} chars)" : "Not found"}');
      return token;
    } catch (e) {
      AppLogger.error('💥 Failed to retrieve user token', e);
      return null;
    }
  }

  /// Store user ID securely
  Future<void> storeUserId(String userId) async {
    try {
      await _secureStorage.write(key: _userIdKey, value: userId);
      AppLogger.debug('User ID stored securely');
    } catch (e) {
      AppLogger.error('Failed to store user ID', e);
      rethrow;
    }
  }

  /// Retrieve user ID
  Future<String?> getUserId() async {
    try {
      final userId = await _secureStorage.read(key: _userIdKey);
      AppLogger.debug('User ID retrieved from secure storage');
      return userId;
    } catch (e) {
      AppLogger.error('Failed to retrieve user ID', e);
      return null;
    }
  }

  /// Store user email securely
  Future<void> storeUserEmail(String email) async {
    try {
      await _secureStorage.write(key: _userEmailKey, value: email);
      AppLogger.debug('User email stored securely');
    } catch (e) {
      AppLogger.error('Failed to store user email', e);
      rethrow;
    }
  }

  /// Retrieve user email
  Future<String?> getUserEmail() async {
    try {
      final email = await _secureStorage.read(key: _userEmailKey);
      AppLogger.debug('User email retrieved from secure storage');
      return email;
    } catch (e) {
      AppLogger.error('Failed to retrieve user email', e);
      return null;
    }
  }

  /// Store refresh token securely
  Future<void> storeRefreshToken(String refreshToken) async {
    try {
      await _secureStorage.write(key: _refreshTokenKey, value: refreshToken);
      AppLogger.debug('Refresh token stored securely');
    } catch (e) {
      AppLogger.error('Failed to store refresh token', e);
      rethrow;
    }
  }

  /// Retrieve refresh token
  Future<String?> getRefreshToken() async {
    try {
      final refreshToken = await _secureStorage.read(key: _refreshTokenKey);
      AppLogger.debug('Refresh token retrieved from secure storage');
      return refreshToken;
    } catch (e) {
      AppLogger.error('Failed to retrieve refresh token', e);
      return null;
    }
  }

  /// Clear all stored user data
  Future<void> clearUserData() async {
    try {
      await _secureStorage.delete(key: _userTokenKey);
      await _secureStorage.delete(key: _userIdKey);
      await _secureStorage.delete(key: _userEmailKey);
      await _secureStorage.delete(key: _refreshTokenKey);
      AppLogger.info('All user data cleared from secure storage');
    } catch (e) {
      AppLogger.error('Failed to clear user data', e);
      rethrow;
    }
  }

  /// Check if user is logged in (has valid token)
  Future<bool> isUserLoggedIn() async {
    final token = await getUserToken();
    final isLoggedIn = token != null && token.isNotEmpty;
    AppLogger.debug(
        '🔍 Login status check: ${isLoggedIn ? "✅ Logged in" : "❌ Not logged in"}');
    return isLoggedIn;
  }

  /// Test storage functionality (for debugging)
  Future<void> testStorage() async {
    try {
      AppLogger.info('🧪 Testing secure storage...');

      // Test write
      await _secureStorage.write(key: 'test_key', value: 'test_value');
      AppLogger.debug('✅ Test write successful');

      // Test read
      final value = await _secureStorage.read(key: 'test_key');
      AppLogger.debug('✅ Test read successful: $value');

      // Test delete
      await _secureStorage.delete(key: 'test_key');
      AppLogger.debug('✅ Test delete successful');

      AppLogger.info('🎉 Secure storage test completed successfully');
    } catch (e) {
      AppLogger.error('💥 Secure storage test failed', e);
    }
  }

  /// Clear all stored data
  Future<void> clearAll() async {
    try {
      await _secureStorage.deleteAll();
      AppLogger.info('All secure storage data cleared');
    } catch (e) {
      AppLogger.error('Failed to clear all secure storage data', e);
      rethrow;
    }
  }
}
