import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'app_logger.dart';
import 'app_constants.dart';

/// Centralized error handling utility
///
/// Provides consistent error handling and user-friendly error messages
/// across the application.
class ErrorHandler {
  // Private constructor to prevent instantiation
  ErrorHandler._();

  /// Handle and log errors, return user-friendly message
  static String handleError(dynamic error, [StackTrace? stackTrace]) {
    String userMessage;

    // Log the error for debugging
    AppLogger.error('Error occurred', error, stackTrace);

    // Determine user-friendly message based on error type
    if (error is SocketException) {
      userMessage = AppConstants.networkErrorMessage;
    } else if (error is FormatException) {
      userMessage = 'Invalid data format received.';
    } else if (error is TimeoutException) {
      userMessage = 'Request timed out. Please try again.';
    } else if (error.toString().contains('login')) {
      userMessage = AppConstants.loginFailedMessage;
    } else if (error.toString().contains('users')) {
      userMessage = AppConstants.usersLoadFailedMessage;
    } else {
      userMessage = AppConstants.genericErrorMessage;
    }

    return userMessage;
  }

  /// Show error snackbar to user
  static void showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'Dismiss',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  /// Show success snackbar to user
  static void showSuccessSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Show info snackbar to user
  static void showInfoSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.blue,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

/// Custom exception classes for better error handling
class NetworkException implements Exception {
  final String message;
  NetworkException(this.message);

  @override
  String toString() => 'NetworkException: $message';
}

class AuthenticationException implements Exception {
  final String message;
  AuthenticationException(this.message);

  @override
  String toString() => 'AuthenticationException: $message';
}

class ValidationException implements Exception {
  final String message;
  ValidationException(this.message);

  @override
  String toString() => 'ValidationException: $message';
}

class CacheException implements Exception {
  final String message;
  CacheException(this.message);

  @override
  String toString() => 'CacheException: $message';
}
