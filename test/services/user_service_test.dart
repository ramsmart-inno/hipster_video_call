import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hipster_video_call/services/user_service.dart';
import 'package:hipster_video_call/core/network/api_client.dart';
import 'package:hipster_video_call/models/user_list_model.dart';

import 'user_service_test.mocks.dart';

@GenerateMocks([ApiClient, SharedPreferences])
void main() {
  group('UserService Tests', () {
    late UserService userService;
    late MockApiClient mockApiClient;
    late MockSharedPreferences mockPrefs;

    setUp(() {
      mockApiClient = MockApiClient();
      mockPrefs = MockSharedPreferences();
      userService = UserService(mockApiClient, mockPrefs);
    });

    final testUsers = [
      UserListModel(
        id: 1,
        email: 'user1@example.com',
        firstName: 'John',
        lastName: 'Doe',
        avatar: 'https://example.com/avatar1.jpg',
      ),
      UserListModel(
        id: 2,
        email: 'user2@example.com',
        firstName: 'Jane',
        lastName: 'Smith',
        avatar: 'https://example.com/avatar2.jpg',
      ),
    ];

    final testApiResponse = {
      'data': testUsers.map((user) => user.toJson()).toList(),
      'page': 1,
      'per_page': 6,
      'total': 2,
      'total_pages': 1,
    };

    group('getUsers', () {
      test(
          'should return cached users when cache exists and forceRefresh is false',
          () async {
        // Arrange
        final cachedData = testUsers.map((user) => user.toJson()).toList();
        when(mockPrefs.getString('cached_users')).thenReturn(
            '[${cachedData.map((user) => user.toString().replaceAll("'", '"')).join(',')}]');

        // Act
        final result = await userService.getUsers(forceRefresh: false);

        // Assert
        expect(result, hasLength(2));
        expect(result.first.email, equals('user1@example.com'));
        verifyNever(mockApiClient.get<Map<String, dynamic>>(any));
      });

      test('should fetch from API when cache is empty', () async {
        // Arrange
        when(mockPrefs.getString('cached_users')).thenReturn(null);

        final apiResponse =
            ApiResponse<Map<String, dynamic>>.success(data: testApiResponse);
        when(mockApiClient.get<Map<String, dynamic>>(
          '/users',
          queryParameters: {'page': '1'},
        )).thenAnswer((_) async => apiResponse);

        when(mockPrefs.setString(any, any)).thenAnswer((_) async => true);
        when(mockPrefs.setInt(any, any)).thenAnswer((_) async => true);

        // Act
        final result = await userService.getUsers();

        // Assert
        expect(result, hasLength(2));
        expect(result.first.email, equals('user1@example.com'));
        verify(mockApiClient.get<Map<String, dynamic>>(
          '/users',
          queryParameters: {'page': '1'},
        )).called(1);
        verify(mockPrefs.setString('cached_users', any)).called(1);
      });

      test('should fetch from API when forceRefresh is true', () async {
        // Arrange
        final apiResponse =
            ApiResponse<Map<String, dynamic>>.success(data: testApiResponse);
        when(mockApiClient.get<Map<String, dynamic>>(
          '/users',
          queryParameters: {'page': '1'},
        )).thenAnswer((_) async => apiResponse);

        when(mockPrefs.setString(any, any)).thenAnswer((_) async => true);
        when(mockPrefs.setInt(any, any)).thenAnswer((_) async => true);

        // Act
        final result = await userService.getUsers(forceRefresh: true);

        // Assert
        expect(result, hasLength(2));
        verify(mockApiClient.get<Map<String, dynamic>>(
          '/users',
          queryParameters: {'page': '1'},
        )).called(1);
        verifyNever(mockPrefs.getString('cached_users'));
      });

      test('should return cached data as fallback when API fails', () async {
        // Arrange
        when(mockPrefs.getString('cached_users')).thenReturn(null);

        when(mockApiClient.get<Map<String, dynamic>>(
          '/users',
          queryParameters: {'page': '1'},
        )).thenThrow(Exception('Network error'));

        final cachedData = testUsers.map((user) => user.toJson()).toList();
        when(mockPrefs.getString('cached_users')).thenReturn(
            '[${cachedData.map((user) => user.toString().replaceAll("'", '"')).join(',')}]');

        // Act & Assert
        expect(() => userService.getUsers(), throwsException);
      });

      test('should throw exception when API fails and no cache exists',
          () async {
        // Arrange
        when(mockPrefs.getString('cached_users')).thenReturn(null);

        final errorResponse = ApiResponse<Map<String, dynamic>>.error(
          statusCode: 500,
          error: 'Server error',
        );
        when(mockApiClient.get<Map<String, dynamic>>(
          '/users',
          queryParameters: {'page': '1'},
        )).thenAnswer((_) async => errorResponse);

        // Act & Assert
        expect(() => userService.getUsers(), throwsException);
      });
    });

    group('clearCache', () {
      test('should clear cached users data', () async {
        // Arrange
        when(mockPrefs.remove('cached_users')).thenAnswer((_) async => true);
        when(mockPrefs.remove('cached_users_timestamp'))
            .thenAnswer((_) async => true);

        // Act
        await userService.clearCache();

        // Assert
        verify(mockPrefs.remove('cached_users')).called(1);
        verify(mockPrefs.remove('cached_users_timestamp')).called(1);
      });
    });

    group('hasCachedData', () {
      test('should return true when cache exists', () {
        // Arrange
        when(mockPrefs.getString('cached_users')).thenReturn('cached_data');

        // Act
        final result = userService.hasCachedData;

        // Assert
        expect(result, isTrue);
      });

      test('should return false when cache is empty', () {
        // Arrange
        when(mockPrefs.getString('cached_users')).thenReturn(null);

        // Act
        final result = userService.hasCachedData;

        // Assert
        expect(result, isFalse);
      });
    });

    group('isCacheExpired', () {
      test('should return true when cache is older than 1 hour', () {
        // Arrange
        final oldTimestamp = DateTime.now().subtract(const Duration(hours: 2));
        when(mockPrefs.getInt('cached_users_timestamp'))
            .thenReturn(oldTimestamp.millisecondsSinceEpoch);

        // Act
        final result = userService.isCacheExpired;

        // Assert
        expect(result, isTrue);
      });

      test('should return false when cache is fresh', () {
        // Arrange
        final recentTimestamp =
            DateTime.now().subtract(const Duration(minutes: 30));
        when(mockPrefs.getInt('cached_users_timestamp'))
            .thenReturn(recentTimestamp.millisecondsSinceEpoch);

        // Act
        final result = userService.isCacheExpired;

        // Assert
        expect(result, isFalse);
      });

      test('should return true when no timestamp exists', () {
        // Arrange
        when(mockPrefs.getInt('cached_users_timestamp')).thenReturn(null);

        // Act
        final result = userService.isCacheExpired;

        // Assert
        expect(result, isTrue);
      });
    });
  });
}
