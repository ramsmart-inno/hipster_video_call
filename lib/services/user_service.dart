import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_list_model.dart';
import '../utils/app_constants.dart';
import '../utils/app_logger.dart';
import '../core/network/api_client.dart';

/// User service with API abstraction and caching
/// 
/// Handles user data fetching with intelligent caching strategy
/// and fallback mechanisms for offline scenarios.
class UserService {
  final ApiClient _apiClient;
  final SharedPreferences _prefs;

  /// Creates a new UserService instance
  UserService(this._apiClient, this._prefs);

  // Key for storing users data in SharedPreferences
  static const String usersKey = AppConstants.cachedUsersKey;

  /// Fetch users from API or cache
  /// 
  /// [forceRefresh] - If true, bypasses cache and fetches fresh data
  /// Returns cached data as fallback if API call fails
  Future<List<UserListModel>> getUsers({bool forceRefresh = false}) async {
    if (!forceRefresh) {
      // Try to get from cache first
      final cachedUsers = await _getUsersFromCache();
      if (cachedUsers.isNotEmpty) {
        AppLogger.info('Users loaded from cache');
        return cachedUsers;
      }
    }

    // If cache is empty or force refresh, fetch from API
    try {
      AppLogger.info('Fetching users from API');
      
      final response = await _apiClient.get<Map<String, dynamic>>(
        '/users',
        queryParameters: {'page': '1'},
      );

      if (response.isSuccess && response.data != null) {
        final List<dynamic> usersList = response.data!['data'];

        // Convert to list of UserListModel objects
        final users = usersList
            .map((userData) => UserListModel.fromJson(userData))
            .toList();

        // Save to cache
        await _saveUsersToCache(users);

        AppLogger.info('Users fetched from API and cached');
        return users;
      } else {
        throw Exception('Failed to load users: ${response.error ?? 'Unknown error'}');
      }
    } catch (e) {
      AppLogger.error('Error fetching users', e);
      
      // If API call fails, try to get from cache as fallback
      final cachedUsers = await _getUsersFromCache();
      if (cachedUsers.isNotEmpty) {
        AppLogger.info('Returning cached users data as fallback');
        return cachedUsers;
      }
      
      rethrow;
    }
  }

  /// Get users from SharedPreferences cache
  Future<List<UserListModel>> _getUsersFromCache() async {
    try {
      final String? usersData = _prefs.getString(usersKey);

      if (usersData != null) {
        final List<dynamic> decodedData = json.decode(usersData);
        return decodedData
            .map((userData) => UserListModel.fromJson(userData))
            .toList();
      }
      return [];
    } catch (e) {
      AppLogger.warning('Failed to parse cached users data', e);
      return [];
    }
  }

  /// Save users to SharedPreferences cache
  Future<void> _saveUsersToCache(List<UserListModel> users) async {
    try {
      final List<Map<String, dynamic>> usersJson =
          users.map((user) => user.toJson()).toList();
      await _prefs.setString(usersKey, json.encode(usersJson));
      
      // Store cache timestamp
      await _prefs.setInt('${usersKey}_timestamp', DateTime.now().millisecondsSinceEpoch);
      
      AppLogger.debug('Users saved to cache');
    } catch (e) {
      AppLogger.error('Error saving users to cache', e);
    }
  }

  /// Clear cached users data
  Future<void> clearCache() async {
    await _prefs.remove(usersKey);
    await _prefs.remove('${usersKey}_timestamp');
    AppLogger.info('Users cache cleared');
  }

  /// Check if users data is cached
  bool get hasCachedData {
    final cachedData = _prefs.getString(usersKey);
    return cachedData != null && cachedData.isNotEmpty;
  }

  /// Get cache timestamp
  DateTime? get cacheTimestamp {
    final timestamp = _prefs.getInt('${usersKey}_timestamp');
    return timestamp != null ? DateTime.fromMillisecondsSinceEpoch(timestamp) : null;
  }

  /// Check if cache is expired (older than 1 hour)
  bool get isCacheExpired {
    final timestamp = cacheTimestamp;
    if (timestamp == null) return true;
    
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    return difference.inHours >= 1;
  }
}
