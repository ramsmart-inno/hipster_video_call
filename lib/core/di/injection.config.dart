// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:get_it/get_it.dart' as _i174;
import 'package:hipster_video_call/core/di/injection.dart' as _i492;
import 'package:hipster_video_call/core/network/api_client.dart' as _i489;
import 'package:hipster_video_call/services/agora_service.dart' as _i1048;
import 'package:hipster_video_call/services/auth_service.dart' as _i1040;
import 'package:hipster_video_call/services/secure_storage_service.dart'
    as _i885;
import 'package:hipster_video_call/services/user_service.dart' as _i315;
import 'package:injectable/injectable.dart' as _i526;

extension GetItInjectableX on _i174.GetIt {
// initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(
      this,
      environment,
      environmentFilter,
    );
    final serviceModule = _$ServiceModule();
    gh.singleton<_i885.SecureStorageService>(
        () => serviceModule.secureStorageService);
    gh.singleton<_i489.ApiClient>(() => serviceModule.apiClient);
    gh.singleton<_i1040.AuthService>(() => serviceModule.authService);
    gh.singleton<_i315.UserService>(() => serviceModule.userService);
    gh.singleton<_i1048.AgoraService>(() => serviceModule.agoraService);
    return this;
  }
}

class _$ServiceModule extends _i492.ServiceModule {}
