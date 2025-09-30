import 'package:dio/dio.dart';
import '../../../utils/app_logger.dart';

/// Logging interceptor for Dio
/// 
/// Logs all HTTP requests and responses for debugging purposes.
class LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    AppLogger.debug(
      'HTTP Request: ${options.method} ${options.uri}\n'
      'Headers: ${options.headers}\n'
      'Data: ${options.data}',
    );
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    AppLogger.debug(
      'HTTP Response: ${response.statusCode} ${response.requestOptions.uri}\n'
      'Headers: ${response.headers}\n'
      'Data: ${response.data}',
    );
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    AppLogger.error(
      'HTTP Error: ${err.response?.statusCode} ${err.requestOptions.uri}\n'
      'Message: ${err.message}\n'
      'Response: ${err.response?.data}',
      err,
    );
    super.onError(err, handler);
  }
}
