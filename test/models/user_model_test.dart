import 'package:flutter_test/flutter_test.dart';
import 'package:hipster_video_call/models/user_model.dart';

void main() {
  group('User Model Tests', () {
    test('should create User from JSON correctly', () {
      // Arrange
      final json = {
        'id': 1,
        'email': 'test@example.com',
        'first_name': 'John',
        'last_name': 'Doe',
        'avatar': 'https://example.com/avatar.jpg',
        'token': 'abc123',
      };

      // Act
      final user = User.fromJson(json);

      // Assert
      expect(user.id, 1);
      expect(user.email, 'test@example.com');
      expect(user.firstName, 'John');
      expect(user.lastName, 'Doe');
      expect(user.avatar, 'https://example.com/avatar.jpg');
      expect(user.token, 'abc123');
    });

    test('should handle null values in JSON gracefully', () {
      // Arrange
      final json = {
        'id': 1,
        'email': 'test@example.com',
        'first_name': null,
        'last_name': null,
        'avatar': null,
        'token': null,
      };

      // Act
      final user = User.fromJson(json);

      // Assert
      expect(user.firstName, '');
      expect(user.lastName, '');
      expect(user.avatar, '');
      expect(user.token, '');
    });

    test('should convert User to JSON correctly', () {
      // Arrange
      final user = User(
        id: 1,
        email: 'test@example.com',
        firstName: 'John',
        lastName: 'Doe',
        avatar: 'https://example.com/avatar.jpg',
        token: 'abc123',
      );

      // Act
      final json = user.toJson();

      // Assert
      expect(json['id'], 1);
      expect(json['email'], 'test@example.com');
      expect(json['first_name'], 'John');
      expect(json['last_name'], 'Doe');
      expect(json['avatar'], 'https://example.com/avatar.jpg');
      expect(json['token'], 'abc123');
    });

    test('should return correct full name', () {
      // Arrange
      final user = User(
        id: 1,
        email: 'test@example.com',
        firstName: 'John',
        lastName: 'Doe',
        avatar: '',
        token: '',
      );

      // Act & Assert
      expect(user.fullName, 'John Doe');
    });

    test('should return correct authentication status', () {
      // Arrange
      final authenticatedUser = User(
        id: 1,
        email: 'test@example.com',
        firstName: 'John',
        lastName: 'Doe',
        avatar: '',
        token: 'abc123',
      );

      final unauthenticatedUser = User(
        id: 1,
        email: 'test@example.com',
        firstName: 'John',
        lastName: 'Doe',
        avatar: '',
        token: '',
      );

      // Act & Assert
      expect(authenticatedUser.isAuthenticated, true);
      expect(unauthenticatedUser.isAuthenticated, false);
    });
  });
}
