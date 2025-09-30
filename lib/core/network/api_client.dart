/// Abstract API client interface
/// 
/// Defines the contract for making HTTP requests throughout the application.
/// This abstraction allows for easy testing and switching between different
/// HTTP client implementations.
abstract class ApiClient {
  /// Make a GET request
  /// 
  /// [endpoint] - The API endpoint to call
  /// [queryParameters] - Optional query parameters
  /// [headers] - Optional custom headers
  Future<ApiResponse<T>> get<T>(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
  });

  /// Make a POST request
  /// 
  /// [endpoint] - The API endpoint to call
  /// [data] - Request body data
  /// [queryParameters] - Optional query parameters
  /// [headers] - Optional custom headers
  Future<ApiResponse<T>> post<T>(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
  });

  /// Make a PUT request
  /// 
  /// [endpoint] - The API endpoint to call
  /// [data] - Request body data
  /// [queryParameters] - Optional query parameters
  /// [headers] - Optional custom headers
  Future<ApiResponse<T>> put<T>(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
  });

  /// Make a DELETE request
  /// 
  /// [endpoint] - The API endpoint to call
  /// [queryParameters] - Optional query parameters
  /// [headers] - Optional custom headers
  Future<ApiResponse<T>> delete<T>(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
  });

  /// Set authentication token for requests
  void setAuthToken(String token);

  /// Clear authentication token
  void clearAuthToken();
}

/// API Response wrapper
/// 
/// Standardizes API responses across the application with consistent
/// error handling and data structure.
class ApiResponse<T> {
  /// Response data
  final T? data;
  
  /// HTTP status code
  final int statusCode;
  
  /// Response message
  final String? message;
  
  /// Whether the request was successful
  final bool isSuccess;
  
  /// Error details if request failed
  final String? error;

  /// Creates a new ApiResponse instance
  ApiResponse({
    this.data,
    required this.statusCode,
    this.message,
    required this.isSuccess,
    this.error,
  });

  /// Creates a successful response
  factory ApiResponse.success({
    T? data,
    int statusCode = 200,
    String? message,
  }) {
    return ApiResponse<T>(
      data: data,
      statusCode: statusCode,
      message: message,
      isSuccess: true,
    );
  }

  /// Creates an error response
  factory ApiResponse.error({
    required int statusCode,
    String? message,
    String? error,
  }) {
    return ApiResponse<T>(
      statusCode: statusCode,
      message: message,
      isSuccess: false,
      error: error,
    );
  }

  @override
  String toString() {
    return 'ApiResponse{data: $data, statusCode: $statusCode, message: $message, isSuccess: $isSuccess, error: $error}';
  }
}
