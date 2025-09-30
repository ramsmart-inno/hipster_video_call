import 'package:flutter/foundation.dart';
import 'package:universal_html/html.dart' as html;
import '../utils/app_logger.dart';

/// Service to handle platform-specific functionality
class PlatformService {
  static PlatformService? _instance;
  static PlatformService get instance => _instance ??= PlatformService._();

  PlatformService._();

  /// Check if running on web platform
  bool get isWeb => kIsWeb;

  /// Check if running on mobile platform
  bool get isMobile => !kIsWeb;

  /// Check if running on desktop platform
  bool get isDesktop =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.windows ||
          defaultTargetPlatform == TargetPlatform.macOS ||
          defaultTargetPlatform == TargetPlatform.linux);

  /// Get platform name
  String get platformName {
    if (kIsWeb) return 'Web';
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 'Android';
      case TargetPlatform.iOS:
        return 'iOS';
      case TargetPlatform.windows:
        return 'Windows';
      case TargetPlatform.macOS:
        return 'macOS';
      case TargetPlatform.linux:
        return 'Linux';
      default:
        return 'Unknown';
    }
  }

  /// Request camera and microphone permissions for web
  Future<bool> requestWebPermissions() async {
    if (!kIsWeb) return true;

    try {
      // Request camera and microphone permissions
      final stream = await html.window.navigator.mediaDevices?.getUserMedia({
        'video': true,
        'audio': true,
      });

      if (stream != null) {
        // Stop the stream immediately as we just needed to check permissions
        // Use the correct method for stopping tracks in universal_html
        final tracks = stream.getTracks();
        for (final track in tracks) {
          // Call the correct method to stop the track
          track.enabled = false;
          // Note: universal_html doesn't have stop() method, so we disable instead
        }
        return true;
      }
      return false;
    } catch (e) {
      AppLogger.error('Error requesting web permissions: $e');
      return false;
    }
  }

  /// Check if camera permission is granted (web-specific)
  Future<bool> isCameraPermissionGranted() async {
    if (!kIsWeb) return true;

    try {
      final permissions =
          await html.window.navigator.permissions?.query({'name': 'camera'});
      return permissions?.state == 'granted';
    } catch (e) {
      AppLogger.error('Error checking camera permission: $e');
      return false;
    }
  }

  /// Check if microphone permission is granted (web-specific)
  Future<bool> isMicrophonePermissionGranted() async {
    if (!kIsWeb) return true;

    try {
      final permissions = await html.window.navigator.permissions
          ?.query({'name': 'microphone'});
      return permissions?.state == 'granted';
    } catch (e) {
      AppLogger.error('Error checking microphone permission: $e');
      return false;
    }
  }

  /// Get user agent string (web-specific)
  String get userAgent {
    if (kIsWeb) {
      return html.window.navigator.userAgent;
    }
    return 'Mobile App';
  }

  /// Check if browser supports WebRTC
  bool get supportsWebRTC {
    if (!kIsWeb) return false;

    try {
      return html.window.navigator.mediaDevices != null;
    } catch (e) {
      return false;
    }
  }

  /// Get screen dimensions
  Map<String, double> get screenDimensions {
    if (kIsWeb) {
      return {
        'width': html.window.screen?.width?.toDouble() ?? 1920,
        'height': html.window.screen?.height?.toDouble() ?? 1080,
      };
    }
    return {
      'width': 0,
      'height': 0,
    };
  }

  /// Open URL in new tab (web-specific)
  void openUrlInNewTab(String url) {
    if (kIsWeb) {
      html.window.open(url, '_blank');
    }
  }

  /// Copy text to clipboard
  Future<bool> copyToClipboard(String text) async {
    if (kIsWeb) {
      try {
        await html.window.navigator.clipboard?.writeText(text);
        return true;
      } catch (e) {
        AppLogger.error('Error copying to clipboard: $e');
        return false;
      }
    }
    return false;
  }

  /// Show browser notification (web-specific)
  Future<bool> showNotification(String title, String body) async {
    if (!kIsWeb) return false;

    try {
      // Request notification permission
      final permission = await html.Notification.requestPermission();
      if (permission == 'granted') {
        html.Notification(title, body: body);
        return true;
      }
      return false;
    } catch (e) {
      AppLogger.error('Error showing notification: $e');
      return false;
    }
  }

  /// Get browser information
  Map<String, String> get browserInfo {
    if (!kIsWeb) return {};

    final userAgent = html.window.navigator.userAgent.toLowerCase();
    String browser = 'Unknown';

    if (userAgent.contains('chrome')) {
      browser = 'Chrome';
    } else if (userAgent.contains('firefox')) {
      browser = 'Firefox';
    } else if (userAgent.contains('safari')) {
      browser = 'Safari';
    } else if (userAgent.contains('edge')) {
      browser = 'Edge';
    }

    return {
      'browser': browser,
      'userAgent': html.window.navigator.userAgent,
      'language': html.window.navigator.language ?? 'en',
      'platform': html.window.navigator.platform ?? 'Unknown',
    };
  }

  /// Check if running in PWA mode
  bool get isPWA {
    if (!kIsWeb) return false;

    try {
      return html.window.matchMedia('(display-mode: standalone)').matches;
    } catch (e) {
      return false;
    }
  }

  /// Get connection type (web-specific)
  String get connectionType {
    if (!kIsWeb) return 'Unknown';

    try {
      final connection = html.window.navigator.connection;
      return connection?.effectiveType ?? 'Unknown';
    } catch (e) {
      return 'Unknown';
    }
  }
}
