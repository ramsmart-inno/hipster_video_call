import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';

import '../../services/auth_service.dart';
import '../../services/user_service.dart';
import '../../services/agora_service.dart';
import '../../services/secure_storage_service.dart';
import '../network/api_client.dart';
import '../network/dio_client.dart';

import 'injection.config.dart';

/// Dependency Injection container
final GetIt getIt = GetIt.instance;

/// Configure dependency injection
@InjectableInit()
Future<void> configureDependencies() async => getIt.init();

/// Register external dependencies that require async initialization
Future<void> registerExternalDependencies() async {
  // Register SharedPreferences
  final sharedPreferences = await SharedPreferences.getInstance();
  getIt.registerSingleton<SharedPreferences>(sharedPreferences);

  // Register FlutterSecureStorage with web-specific options
  const secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
    webOptions: WebOptions(
      dbName: 'hipster_video_call_secure_storage',
      publicKey: 'hipster_video_call_public_key',
    ),
  );
  getIt.registerSingleton<FlutterSecureStorage>(secureStorage);

  // Register Dio
  final dio = Dio();
  getIt.registerSingleton<Dio>(dio);
}

/// Module for registering services
@module
abstract class ServiceModule {
  @singleton
  SecureStorageService get secureStorageService =>
      SecureStorageService(getIt<FlutterSecureStorage>());

  @singleton
  ApiClient get apiClient => DioClient(getIt<Dio>());

  @singleton
  AuthService get authService => AuthService(
        getIt<ApiClient>(),
        getIt<SecureStorageService>(),
      );

  @singleton
  UserService get userService => UserService(
        getIt<ApiClient>(),
        getIt<SharedPreferences>(),
      );

  @singleton
  AgoraService get agoraService => AgoraService();
}
