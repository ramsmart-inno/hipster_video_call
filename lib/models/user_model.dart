/// User model representing an authenticated user
///
/// Contains user information including authentication token
/// and personal details retrieved from the API.
class User {
  /// Unique identifier for the user
  final int id;

  /// User's email address (used for authentication)
  final String email;

  /// User's first name
  final String firstName;

  /// User's last name
  final String lastName;

  /// URL to user's avatar image
  final String avatar;

  /// Authentication token for API requests
  final String token;

  /// Creates a new User instance
  ///
  /// All parameters are required for a complete user profile.
  User({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.avatar,
    required this.token,
  });

  /// Creates a User instance from JSON data
  ///
  /// Handles null values gracefully by providing empty string defaults
  /// for optional fields like names and avatar.
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      avatar: json['avatar'] ?? '',
      token: json['token'] ?? '',
    );
  }

  /// Converts the User instance to JSON format
  ///
  /// Used for serialization when storing user data locally
  /// or sending data to APIs.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'first_name': firstName,
      'last_name': lastName,
      'avatar': avatar,
      'token': token,
    };
  }

  /// Returns the user's full name
  String get fullName => '$firstName $lastName'.trim();

  /// Returns true if the user has a valid token
  bool get isAuthenticated => token.isNotEmpty;
}
