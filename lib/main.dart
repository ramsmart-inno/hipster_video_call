import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:sentry_flutter/sentry_flutter.dart';  // Temporarily disabled

import 'blocs/auth/auth_bloc.dart';
import 'blocs/users/users_bloc.dart';
import 'blocs/video_call/video_call_bloc.dart';
import 'services/auth_service.dart';
import 'services/user_service.dart';
import 'services/agora_service.dart';
import 'services/platform_service.dart';
import 'utils/app_router.dart';
import 'utils/app_constants.dart';
import 'utils/app_logger.dart';
import 'core/di/injection.dart';
import 'core/config/environment.dart';
import 'core/theme/app_theme.dart';
// import 'core/monitoring/sentry_service.dart';  // Temporarily disabled

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize environment configuration
  await Environment.initialize();

  // Platform-specific initialization
  if (kIsWeb) {
    // Web-specific initialization
    AppLogger.info('Running on Web platform');

    // Check WebRTC support
    if (PlatformService.instance.supportsWebRTC) {
      AppLogger.info('WebRTC is supported');
    } else {
      AppLogger.warning('WebRTC is not supported in this browser');
    }
  } else {
    AppLogger.info('Running on ${PlatformService.instance.platformName}');
  }

  // Initialize error monitoring
  // await SentryService.initialize();  // Temporarily disabled

  // Initialize dependency injection
  await registerExternalDependencies();
  await configureDependencies();

  // Run app with Sentry error monitoring
  // await SentryFlutter.init(
  //   (options) {
  //     // Sentry configuration is handled in SentryService
  //   },
  //   appRunner: () => runApp(MyApp()),
  // );
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final AuthBloc _authBloc;
  late final AppRouter _appRouter;

  @override
  void initState() {
    super.initState();
    _authBloc = AuthBloc(getIt<AuthService>());
    _authBloc.add(CheckAuthStatusEvent());
    _appRouter = AppRouter(_authBloc);
  }

  @override
  void dispose() {
    _authBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>.value(value: _authBloc),
        BlocProvider<UsersBloc>(
          create: (context) => UsersBloc(getIt<UserService>()),
        ),
        BlocProvider<VideoCallBloc>(
          create: (context) => VideoCallBloc(getIt<AgoraService>()),
        ),
      ],
      child: MaterialApp.router(
        title: AppConstants.appTitle,
        theme: AppTheme.lightTheme,
        debugShowCheckedModeBanner: false,
        routerConfig: _appRouter.router,
      ),
    );
  }
}
