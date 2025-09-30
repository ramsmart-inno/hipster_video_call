import 'package:dio/dio.dart';
import '../../../utils/app_logger.dart';

/// Authentication interceptor for Dio
/// 
/// Automatically adds authentication headers to requests when a token is available.
class AuthInterceptor extends Interceptor {
  final String? Function() _getToken;

  /// Creates a new AuthInterceptor
  /// 
  /// [_getToken] - Function that returns the current auth token
  AuthInterceptor(this._getToken);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final token = _getToken();
    
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
      AppLogger.debug('Auth token added to request headers');
    }

    super.onRequest(options, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // Handle 401 Unauthorized responses
    if (err.response?.statusCode == 401) {
      AppLogger.warning('Unauthorized request - token may be expired');
      // Here you could trigger a token refresh or logout
    }

    super.onError(err, handler);
  }
}
