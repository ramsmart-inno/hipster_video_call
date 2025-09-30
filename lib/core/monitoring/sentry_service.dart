// import 'package:sentry_flutter/sentry_flutter.dart';
// import '../config/environment.dart';
// import '../../utils/app_logger.dart';

// /// Sentry error monitoring service
// ///
// /// Provides centralized error monitoring and crash reporting using Sentry.
// /// Automatically captures errors, exceptions, and performance data.
// class SentryService {
//   // Private constructor to prevent instantiation
//   SentryService._();

//   /// Initialize Sentry error monitoring
//   static Future<void> initialize() async {
//     final sentryDsn = Environment.sentryDsn;

//     if (sentryDsn == null || sentryDsn.isEmpty) {
//       AppLogger.warning('Sentry DSN not configured, error monitoring disabled');
//       return;
//     }

//     try {
//       await SentryFlutter.init(
//         (options) {
//           options.dsn = sentryDsn;
//           options.environment =
//               Environment.isProduction ? 'production' : 'development';
//           options.release = Environment.appVersion;
//           options.debug = Environment.isDebugMode;

//           // Performance monitoring
//           options.tracesSampleRate = Environment.isProduction ? 0.1 : 1.0;

//           // Session tracking
//           options.autoSessionTrackingInterval = const Duration(seconds: 30);

//           // Breadcrumbs
//           options.maxBreadcrumbs = 100;

//           // Attach screenshots on errors (mobile only)
//           options.attachScreenshot = true;

//           // Filter out sensitive data
//           options.beforeSend = _beforeSend;
//         },
//       );

//       AppLogger.info('Sentry error monitoring initialized successfully');
//     } catch (e) {
//       AppLogger.error('Failed to initialize Sentry', e);
//     }
//   }

//   /// Filter sensitive data before sending to Sentry
//   static SentryEvent? _beforeSend(SentryEvent event, {Hint? hint}) {
//     // Remove sensitive data from the event
//     final headers = event.request?.headers;
//     if (headers != null) {
//       headers.remove('Authorization');
//       headers.remove('Cookie');
//     }

//     // Filter out sensitive breadcrumbs
//     event.breadcrumbs?.removeWhere((breadcrumb) {
//       return breadcrumb.message?.contains('password') == true ||
//           breadcrumb.message?.contains('token') == true;
//     });

//     return event;
//   }

//   /// Capture an exception manually
//   static Future<void> captureException(
//     dynamic exception, {
//     StackTrace? stackTrace,
//     String? tag,
//     Map<String, dynamic>? extra,
//   }) async {
//     try {
//       await Sentry.captureException(
//         exception,
//         stackTrace: stackTrace,
//         withScope: (scope) {
//           if (tag != null) {
//             scope.setTag('custom_tag', tag);
//           }
//           if (extra != null) {
//             for (final entry in extra.entries) {
//               scope.setExtra(entry.key, entry.value);
//             }
//           }
//         },
//       );

//       AppLogger.debug('Exception captured by Sentry');
//     } catch (e) {
//       AppLogger.error('Failed to capture exception in Sentry', e);
//     }
//   }

//   /// Capture a message manually
//   static Future<void> captureMessage(
//     String message, {
//     SentryLevel level = SentryLevel.info,
//     String? tag,
//     Map<String, dynamic>? extra,
//   }) async {
//     try {
//       await Sentry.captureMessage(
//         message,
//         level: level,
//         withScope: (scope) {
//           if (tag != null) {
//             scope.setTag('custom_tag', tag);
//           }
//           if (extra != null) {
//             for (final entry in extra.entries) {
//               scope.setExtra(entry.key, entry.value);
//             }
//           }
//         },
//       );

//       AppLogger.debug('Message captured by Sentry');
//     } catch (e) {
//       AppLogger.error('Failed to capture message in Sentry', e);
//     }
//   }

//   /// Add breadcrumb for debugging
//   static void addBreadcrumb(
//     String message, {
//     String? category,
//     SentryLevel level = SentryLevel.info,
//     Map<String, dynamic>? data,
//   }) {
//     try {
//       Sentry.addBreadcrumb(
//         Breadcrumb(
//           message: message,
//           category: category,
//           level: level,
//           data: data,
//         ),
//       );

//       AppLogger.debug('Breadcrumb added to Sentry');
//     } catch (e) {
//       AppLogger.error('Failed to add breadcrumb to Sentry', e);
//     }
//   }

//   /// Set user context
//   static void setUser({
//     String? id,
//     String? email,
//     String? username,
//     Map<String, dynamic>? extras,
//   }) {
//     try {
//       Sentry.configureScope((scope) {
//         scope.setUser(SentryUser(
//           id: id,
//           email: email,
//           username: username,
//           data: extras,
//         ));
//       });

//       AppLogger.debug('User context set in Sentry');
//     } catch (e) {
//       AppLogger.error('Failed to set user context in Sentry', e);
//     }
//   }

//   /// Clear user context (on logout)
//   static void clearUser() {
//     try {
//       Sentry.configureScope((scope) {
//         scope.setUser(null);
//       });

//       AppLogger.debug('User context cleared in Sentry');
//     } catch (e) {
//       AppLogger.error('Failed to clear user context in Sentry', e);
//     }
//   }

//   /// Start a performance transaction
//   static ISentrySpan startTransaction(
//     String name,
//     String operation, {
//     String? description,
//   }) {
//     return Sentry.startTransaction(
//       name,
//       operation,
//       description: description,
//     );
//   }
// }
