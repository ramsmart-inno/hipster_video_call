import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/foundation.dart';
import '../utils/app_constants.dart';
import '../utils/app_logger.dart';
import 'platform_service.dart';

class AgoraService {
  // Get Agora App ID from constants
  String get appId => AppConstants.agoraAppId;

  // Agora client instance
  RtcEngine? _engine;

  // Expose engine for video views
  RtcEngine? get engine => _engine;

  // Channel name - hardcoded for demo purposes
  static const String defaultChannelName = AppConstants.defaultChannelName;

  // Current channel name
  String? _currentChannelName;
  String? get currentChannelName => _currentChannelName;

  // Get token from constants
  String? get token => AppConstants.agoraToken;

  // Callbacks for UI updates
  Function(int uid)? onUserJoined;
  Function(int uid)? onUserLeft;
  Function(int uid)? onLocalUserJoined;

  // Initialize Agora SDK
  Future<void> initialize() async {
    try {
      // Validate App ID first
      if (appId == 'YOUR_AGORA_APP_ID_HERE' ||
          appId.isEmpty ||
          appId.length < 10) {
        AppLogger.error('❌ INVALID AGORA APP ID: $appId');
        AppLogger.error(
            '❌ Please get a valid App ID from https://dashboard.agora.io/');
        AppLogger.error('❌ Create a new project and copy the App ID');
        throw Exception(
            'Invalid Agora App ID! Please get a valid App ID from https://dashboard.agora.io/');
      }

      AppLogger.info(
          'Initializing Agora SDK with App ID: ${appId.substring(0, 8)}...');

      // Request permissions based on platform
      if (kIsWeb) {
        // For web, request permissions through browser API
        AppLogger.info('Requesting web permissions...');
        final webPermissions =
            await PlatformService.instance.requestWebPermissions();
        AppLogger.info('Web permissions granted: $webPermissions');

        // Add a small delay for web to ensure permissions are properly set
        await Future.delayed(const Duration(milliseconds: 500));
      } else {
        // For mobile, use permission_handler
        final permissions =
            await [Permission.camera, Permission.microphone].request();
        AppLogger.info(
            'Permissions: Camera: ${permissions[Permission.camera]}, Microphone: ${permissions[Permission.microphone]}');
      }

      // Create RTC engine instance
      AppLogger.info('Creating Agora RTC engine...');
      _engine = createAgoraRtcEngine();

      AppLogger.info('Initializing Agora RTC engine...');
      await _engine!.initialize(RtcEngineContext(
        appId: appId,
        channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
      ));

      AppLogger.info('Agora SDK initialized successfully');
    } catch (e) {
      AppLogger.error('Failed to initialize Agora SDK: $e');
      rethrow;
    }

    // Set up event handlers
    _engine!.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
          AppLogger.info(
              '✅ Local user joined channel: ${connection.channelId}, UID: ${connection.localUid}, elapsed: ${elapsed}ms');
          AppLogger.info('🔄 Triggering local user joined callback...');
          onLocalUserJoined?.call(connection.localUid ?? 0);
        },
        onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
          AppLogger.info(
              '🎉 Remote user joined: $remoteUid in channel: ${connection.channelId}, elapsed: ${elapsed}ms');
          AppLogger.info('🔄 Triggering remote user joined callback...');
          onUserJoined?.call(remoteUid);
        },
        onUserOffline: (RtcConnection connection, int remoteUid,
            UserOfflineReasonType reason) {
          AppLogger.info('👋 Remote user left: $remoteUid, reason: $reason');
          onUserLeft?.call(remoteUid);
        },
        onError: (ErrorCodeType err, String msg) {
          AppLogger.error('❌ Agora Error: $err - $msg');
        },
        onConnectionStateChanged: (RtcConnection connection,
            ConnectionStateType state, ConnectionChangedReasonType reason) {
          AppLogger.info(
              '🔗 Connection state changed: $state, reason: $reason, channel: ${connection.channelId}');
        },
        onNetworkQuality: (RtcConnection connection, int remoteUid,
            QualityType txQuality, QualityType rxQuality) {
          if (remoteUid == 0) {
            AppLogger.debug(
                '📶 Local network quality - TX: $txQuality, RX: $rxQuality');
          }
        },
      ),
    );

    // Enable video (following official example pattern)
    await _engine!.enableVideo();
    await _engine!.startPreview();
    // Set video encoder configuration
    await _engine!.setVideoEncoderConfiguration(
      const VideoEncoderConfiguration(
        dimensions: VideoDimensions(width: 640, height: 360),
        frameRate: 15,
        bitrate: 800,
      ),
    );
  }

  // Join a channel
  Future<void> joinChannel({String? channelName}) async {
    try {
      if (_engine == null) {
        throw Exception('Engine is not initialized');
      }

      final channel = channelName ?? defaultChannelName;
      _currentChannelName = channel;
      AppLogger.info('Joining channel: $channel');

      // Join the channel using Live Broadcasting profile (following official example)
      await _engine!.joinChannel(
        token: token ?? '',
        channelId: channel,
        uid: 0, // 0 means let the SDK assign a uid
        options: const ChannelMediaOptions(
          channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
          clientRoleType: ClientRoleType.clientRoleBroadcaster,
        ),
      );

      AppLogger.info('Successfully joined channel: $channel');
    } catch (e) {
      AppLogger.error('Failed to join channel: $e');
      rethrow;
    }
  }

  // Leave the channel
  Future<void> leaveChannel() async {
    if (_engine == null) {
      return;
    }
    await _engine!.leaveChannel();
  }

  // Toggle local audio (mute/unmute)
  Future<void> toggleLocalAudio(bool enabled) async {
    if (_engine == null) {
      return;
    }
    if (enabled) {
      await _engine!.enableLocalAudio(true);
    } else {
      await _engine!.enableLocalAudio(false);
    }
  }

  // Toggle local video (enable/disable)
  Future<void> toggleLocalVideo(bool enabled) async {
    if (_engine == null) {
      return;
    }
    if (enabled) {
      await _engine!.enableLocalVideo(true);
    } else {
      await _engine!.enableLocalVideo(false);
    }
  }

  // Start screen sharing
  Future<void> startScreenSharing() async {
    if (_engine == null) {
      return;
    }

    // For simplicity, we're using a basic implementation
    // In a real app, you'd need to handle platform-specific implementations
    await _engine!.startScreenCapture(
      const ScreenCaptureParameters2(
        captureAudio: true,
        captureVideo: true,
      ),
    );
  }

  // Stop screen sharing
  Future<void> stopScreenSharing() async {
    if (_engine == null) {
      return;
    }
    await _engine!.stopScreenCapture();
  }

  // Dispose resources
  Future<void> dispose() async {
    if (_engine == null) {
      return;
    }
    await _engine!.leaveChannel();
    await _engine!.release();
    _engine = null;
  }
}
