import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:hipster_video_call/services/auth_service.dart';
import 'package:hipster_video_call/services/secure_storage_service.dart';
import 'package:hipster_video_call/core/network/api_client.dart';

import 'auth_service_test.mocks.dart';

@GenerateMocks([ApiClient, SecureStorageService])
void main() {
  group('AuthService Tests', () {
    late AuthService authService;
    late MockApiClient mockApiClient;
    late MockSecureStorageService mockSecureStorage;

    setUp(() {
      mockApiClient = MockApiClient();
      mockSecureStorage = MockSecureStorageService();
      authService = AuthService(mockApiClient, mockSecureStorage);
    });

    group('login', () {
      test('should login successfully and store user data', () async {
        // Arrange
        const email = 'test@example.com';
        const password = 'password123';
        const token = 'test_token';

        final loginResponse = ApiResponse<Map<String, dynamic>>.success(
          data: {'token': token},
        );

        final userResponse = ApiResponse<Map<String, dynamic>>.success(
          data: {
            'data': {
              'id': 1,
              'email': email,
              'first_name': 'John',
              'last_name': 'Doe',
              'avatar': 'https://example.com/avatar.jpg',
            }
          },
        );

        when(mockApiClient.post<Map<String, dynamic>>(
          '/login',
          data: {'email': email, 'password': password},
        )).thenAnswer((_) async => loginResponse);

        when(mockApiClient.get<Map<String, dynamic>>('/users/2'))
            .thenAnswer((_) async => userResponse);

        when(mockSecureStorage.storeUserToken(token)).thenAnswer((_) async {});
        when(mockSecureStorage.storeUserId('1')).thenAnswer((_) async {});
        when(mockSecureStorage.storeUserEmail(email)).thenAnswer((_) async {});

        // Act
        final result = await authService.login(email, password);

        // Assert
        expect(result.email, equals(email));
        expect(result.token, equals(token));
        expect(result.firstName, equals('John'));
        expect(result.lastName, equals('Doe'));

        verify(mockApiClient.setAuthToken(token)).called(1);
        verify(mockSecureStorage.storeUserToken(token)).called(1);
        verify(mockSecureStorage.storeUserId('1')).called(1);
        verify(mockSecureStorage.storeUserEmail(email)).called(1);
      });

      test('should throw exception when login fails', () async {
        // Arrange
        const email = 'test@example.com';
        const password = 'wrong_password';

        final errorResponse = ApiResponse<Map<String, dynamic>>.error(
          statusCode: 400,
          error: 'Invalid credentials',
        );

        when(mockApiClient.post<Map<String, dynamic>>(
          '/login',
          data: {'email': email, 'password': password},
        )).thenAnswer((_) async => errorResponse);

        // Act & Assert
        expect(
          () => authService.login(email, password),
          throwsException,
        );
      });
    });

    group('getCurrentUser', () {
      test('should return user when valid token exists', () async {
        // Arrange
        const token = 'valid_token';
        const userId = '1';
        const email = 'test@example.com';

        when(mockSecureStorage.getUserToken()).thenAnswer((_) async => token);
        when(mockSecureStorage.getUserId()).thenAnswer((_) async => userId);
        when(mockSecureStorage.getUserEmail()).thenAnswer((_) async => email);

        final userResponse = ApiResponse<Map<String, dynamic>>.success(
          data: {
            'data': {
              'id': 1,
              'email': email,
              'first_name': 'John',
              'last_name': 'Doe',
              'avatar': 'https://example.com/avatar.jpg',
            }
          },
        );

        when(mockApiClient.get<Map<String, dynamic>>('/users/$userId'))
            .thenAnswer((_) async => userResponse);

        // Act
        final result = await authService.getCurrentUser();

        // Assert
        expect(result, isNotNull);
        expect(result!.email, equals(email));
        expect(result.token, equals(token));
        verify(mockApiClient.setAuthToken(token)).called(1);
      });

      test('should return null when no token exists', () async {
        // Arrange
        when(mockSecureStorage.getUserToken()).thenAnswer((_) async => null);

        // Act
        final result = await authService.getCurrentUser();

        // Assert
        expect(result, isNull);
      });
    });

    group('logout', () {
      test('should clear all user data and auth token', () async {
        // Arrange
        when(mockSecureStorage.clearUserData()).thenAnswer((_) async {});

        // Act
        await authService.logout();

        // Assert
        verify(mockApiClient.clearAuthToken()).called(1);
        verify(mockSecureStorage.clearUserData()).called(1);
      });
    });

    group('isAuthenticated', () {
      test('should return true when user is logged in', () async {
        // Arrange
        when(mockSecureStorage.isUserLoggedIn()).thenAnswer((_) async => true);

        // Act
        final result = await authService.isAuthenticated();

        // Assert
        expect(result, isTrue);
      });

      test('should return false when user is not logged in', () async {
        // Arrange
        when(mockSecureStorage.isUserLoggedIn()).thenAnswer((_) async => false);

        // Act
        final result = await authService.isAuthenticated();

        // Assert
        expect(result, isFalse);
      });
    });
  });
}
