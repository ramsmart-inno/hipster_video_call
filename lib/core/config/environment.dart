import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../utils/app_logger.dart';

/// Environment configuration manager
///
/// Manages environment-specific configuration values loaded from .env files.
/// Provides type-safe access to environment variables with fallback defaults.
class Environment {
  // Private constructor to prevent instantiation
  Environment._();

  /// Initialize environment configuration
  static Future<void> initialize() async {
    try {
      await dotenv.load(fileName: '.env');
      AppLogger.info('Environment configuration loaded successfully');
    } catch (e) {
      AppLogger.warning('Failed to load .env file, using defaults', e);
    }
  }

  // API Configuration
  static String get baseUrl {
    try {
      return dotenv.env['BASE_URL'] ?? 'https://reqres.in/api';
    } catch (e) {
      return 'https://reqres.in/api';
    }
  }

  static int get apiTimeout {
    try {
      return int.tryParse(dotenv.env['API_TIMEOUT'] ?? '30000') ?? 30000;
    } catch (e) {
      return 30000;
    }
  }

  // API Configuration
  static String get apiKey {
    try {
      return dotenv.env['API_KEY'] ?? 'reqres-free-v1';
    } catch (e) {
      return 'reqres-free-v1';
    }
  }

  // Agora Configuration
  static String get agoraAppId {
    try {
      final appId = dotenv.env['AGORA_APP_ID'];
      if (appId != null || appId == 'YOUR_AGORA_APP_ID_HERE') {
        AppLogger.error(
            '⚠️ INVALID AGORA APP ID! Please get a valid App ID from https://dashboard.agora.io/');
        AppLogger.error('⚠️ Current App ID: $appId');
      }
      return appId!;
    } catch (e) {
      AppLogger.error('⚠️ Failed to load Agora App ID, using placeholder');
      return 'YOUR_AGORA_APP_ID_HERE';
    }
  }

  static String? get agoraToken {
    try {
      // For secured mode, add your token here or in .env file
      // Example: return 'your_generated_token_here';
      return dotenv.env['AGORA_TOKEN']?.isEmpty == true
          ? null
          : dotenv.env['AGORA_TOKEN'];
    } catch (e) {
      return null;
    }
  }

  // Sentry Configuration
  static String? get sentryDsn {
    try {
      return dotenv.env['SENTRY_DSN']?.isEmpty == true
          ? null
          : dotenv.env['SENTRY_DSN'];
    } catch (e) {
      return null;
    }
  }

  // App Configuration
  static String get appName {
    try {
      return dotenv.env['APP_NAME'] ?? 'Hipster Video Call';
    } catch (e) {
      return 'Hipster Video Call';
    }
  }

  static String get appVersion {
    try {
      return dotenv.env['APP_VERSION'] ?? '1.0.0';
    } catch (e) {
      return '1.0.0';
    }
  }

  static bool get isDebugMode {
    try {
      return dotenv.env['DEBUG_MODE']?.toLowerCase() == 'true';
    } catch (e) {
      return false;
    }
  }

  // Cache Configuration
  static int get cacheExpiryHours {
    try {
      return int.tryParse(dotenv.env['CACHE_EXPIRY_HOURS'] ?? '24') ?? 24;
    } catch (e) {
      return 24;
    }
  }

  static int get maxCacheSizeMB {
    try {
      return int.tryParse(dotenv.env['MAX_CACHE_SIZE_MB'] ?? '50') ?? 50;
    } catch (e) {
      return 50;
    }
  }

  /// Get environment variable with fallback
  static String getString(String key, {String fallback = ''}) {
    try {
      return dotenv.env[key] ?? fallback;
    } catch (e) {
      return fallback;
    }
  }

  /// Get integer environment variable with fallback
  static int getInt(String key, {int fallback = 0}) {
    try {
      return int.tryParse(dotenv.env[key] ?? '') ?? fallback;
    } catch (e) {
      return fallback;
    }
  }

  /// Get boolean environment variable with fallback
  static bool getBool(String key, {bool fallback = false}) {
    try {
      final value = dotenv.env[key]?.toLowerCase();
      return value == 'true' || value == '1';
    } catch (e) {
      return fallback;
    }
  }

  /// Check if running in production environment
  static bool get isProduction => !isDebugMode;

  /// Get all environment variables (for debugging)
  static Map<String, String> get allVariables {
    try {
      return dotenv.env;
    } catch (e) {
      return <String, String>{};
    }
  }

  /// Validate required environment variables
  static bool validateRequiredVariables() {
    final requiredVars = ['BASE_URL'];
    final missingVars = <String>[];

    for (final variable in requiredVars) {
      try {
        if (dotenv.env[variable]?.isEmpty ?? true) {
          missingVars.add(variable);
        }
      } catch (e) {
        missingVars.add(variable);
      }
    }

    if (missingVars.isNotEmpty) {
      AppLogger.error(
          'Missing required environment variables: ${missingVars.join(', ')}');
      return false;
    }

    AppLogger.info('All required environment variables are present');
    return true;
  }
}
