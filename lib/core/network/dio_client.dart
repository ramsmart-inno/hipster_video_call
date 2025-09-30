import 'package:dio/dio.dart';
import '../../utils/app_logger.dart';
import '../config/environment.dart';
import 'api_client.dart';
import 'interceptors/auth_interceptor.dart';
import 'interceptors/logging_interceptor.dart';
import 'interceptors/error_interceptor.dart';

/// Dio implementation of ApiClient
///
/// Provides HTTP client functionality using Dio with interceptors
/// for authentication, logging, and error handling.
class DioClient implements ApiClient {
  late final Dio _dio;
  String? _authToken;

  /// Creates a new DioClient instance
  DioClient(Dio dio) {
    _dio = dio;
    _setupDio();
    _setupInterceptors();
  }

  /// Configure Dio with base settings
  void _setupDio() {
    final baseUrl = Environment.baseUrl;
    final timeout = Environment.apiTimeout;
    final apiKey = Environment.apiKey;

    _dio.options = BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: Duration(milliseconds: timeout),
      receiveTimeout: Duration(milliseconds: timeout),
      sendTimeout: Duration(milliseconds: timeout),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'x-api-key': apiKey,
      },
    );

    AppLogger.info(
        'Dio client configured with base URL: $baseUrl and API key: ${apiKey.substring(0, 8)}...');
  }

  /// Setup interceptors for authentication, logging, and error handling
  void _setupInterceptors() {
    _dio.interceptors.addAll([
      AuthInterceptor(() => _authToken),
      LoggingInterceptor(),
      ErrorInterceptor(),
    ]);

    AppLogger.debug('Dio interceptors configured');
  }

  @override
  Future<ApiResponse<T>> get<T>(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
  }) async {
    try {
      AppLogger.debug('Making GET request to: $endpoint');

      final response = await _dio.get(
        endpoint,
        queryParameters: queryParameters,
        options: Options(headers: headers),
      );

      return _handleResponse<T>(response);
    } catch (e) {
      return _handleError<T>(e);
    }
  }

  @override
  Future<ApiResponse<T>> post<T>(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
  }) async {
    try {
      AppLogger.debug('Making POST request to: $endpoint');

      final response = await _dio.post(
        endpoint,
        data: data,
        queryParameters: queryParameters,
        options: Options(headers: headers),
      );

      return _handleResponse<T>(response);
    } catch (e) {
      return _handleError<T>(e);
    }
  }

  @override
  Future<ApiResponse<T>> put<T>(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
  }) async {
    try {
      AppLogger.debug('Making PUT request to: $endpoint');

      final response = await _dio.put(
        endpoint,
        data: data,
        queryParameters: queryParameters,
        options: Options(headers: headers),
      );

      return _handleResponse<T>(response);
    } catch (e) {
      return _handleError<T>(e);
    }
  }

  @override
  Future<ApiResponse<T>> delete<T>(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
  }) async {
    try {
      AppLogger.debug('Making DELETE request to: $endpoint');

      final response = await _dio.delete(
        endpoint,
        queryParameters: queryParameters,
        options: Options(headers: headers),
      );

      return _handleResponse<T>(response);
    } catch (e) {
      return _handleError<T>(e);
    }
  }

  @override
  void setAuthToken(String token) {
    _authToken = token;
    AppLogger.debug('Auth token set for API requests');
  }

  @override
  void clearAuthToken() {
    _authToken = null;
    AppLogger.debug('Auth token cleared');
  }

  /// Handle successful response
  ApiResponse<T> _handleResponse<T>(Response response) {
    AppLogger.info('API request successful: ${response.statusCode}');

    return ApiResponse.success(
      data: response.data,
      statusCode: response.statusCode ?? 200,
      message: response.statusMessage,
    );
  }

  /// Handle error response
  ApiResponse<T> _handleError<T>(dynamic error) {
    if (error is DioException) {
      AppLogger.error('Dio error occurred', error);

      return ApiResponse.error(
        statusCode: error.response?.statusCode ?? 500,
        message: error.message,
        error: error.response?.data?.toString() ?? error.toString(),
      );
    }

    AppLogger.error('Unknown error occurred', error);

    return ApiResponse.error(
      statusCode: 500,
      message: 'Unknown error occurred',
      error: error.toString(),
    );
  }
}
