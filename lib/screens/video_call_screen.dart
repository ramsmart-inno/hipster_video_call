import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import '../blocs/video_call/video_call_bloc.dart';
import '../services/agora_service.dart';
import '../widgets/loading_indicator.dart';
import '../core/di/injection.dart';
import '../core/theme/app_theme.dart';

class VideoCallScreen extends StatefulWidget {
  const VideoCallScreen({super.key});

  @override
  State<VideoCallScreen> createState() => _VideoCallScreenState();
}

class _VideoCallScreenState extends State<VideoCallScreen> {
  final _channelController = TextEditingController(text: 'hipster_video_call');
  late AgoraService _agoraService;

  @override
  void initState() {
    super.initState();
    _agoraService = getIt<AgoraService>();
    context.read<VideoCallBloc>().add(InitializeVideoCallEvent());
  }

  @override
  void dispose() {
    _channelController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Video Call'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.people),
            onPressed: () {
              context.go('/users');
            },
          ),
        ],
      ),
      body: BlocConsumer<VideoCallBloc, VideoCallState>(
        listener: (context, state) {
          if (state is VideoCallError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          if (state is VideoCallLoading) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Initializing video call...'),
                ],
              ),
            );
          }

          if (state is VideoCallReady) {
            return _buildJoinUI();
          }

          if (state is VideoCallConnected) {
            return _buildCallUI(state);
          }

          if (state is VideoCallError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error, size: 64, color: AppTheme.errorColor),
                  SizedBox(height: 16),
                  Text(
                    'Error: ${state.message}',
                    style:
                        AppTheme.bodyLarge.copyWith(color: AppTheme.errorColor),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context
                          .read<VideoCallBloc>()
                          .add(InitializeVideoCallEvent());
                    },
                    child: Text('Retry'),
                  ),
                ],
              ),
            );
          }

          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryColor.withValues(alpha: 0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      'assets/appicon_512.png',
                      width: 64,
                      height: 64,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                SizedBox(height: 16),
                Text('Ready to start video call'),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    context
                        .read<VideoCallBloc>()
                        .add(InitializeVideoCallEvent());
                  },
                  child: Text('Initialize'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildJoinUI() {
    return Container(
      decoration: AppTheme.primaryGradientDecoration,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.video_call,
              size: 80,
              color: Colors.white,
            ),
            const SizedBox(height: 24),
            Text(
              'Ready to Join Video Call',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                controller: _channelController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(
                    borderSide: BorderSide.none,
                  ),
                  hintText: 'Enter meeting ID',
                  labelText: 'Meeting ID',
                  prefixIcon: Icon(Icons.meeting_room),
                  contentPadding: EdgeInsets.all(16),
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  if (_channelController.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please enter a meeting ID'),
                      ),
                    );
                    return;
                  }
                  context.read<VideoCallBloc>().add(
                        JoinChannelEvent(
                          channelName: _channelController.text.trim(),
                        ),
                      );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.successColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      child: Image.asset(
                        'assets/appicon_512.png',
                        width: 24,
                        height: 24,
                        fit: BoxFit.contain,
                      ),
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Join Call',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                _channelController.text = 'hipster_video_call';
                context.read<VideoCallBloc>().add(
                      JoinChannelEvent(
                        channelName: 'hipster_video_call',
                      ),
                    );
              },
              child: Text(
                'Quick Join: hipster_video_call',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.8),
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCallUI(VideoCallConnected state) {
    return Stack(
      children: [
        // Remote video view
        Center(
          child: _remoteVideo(state),
        ),

        // Local video view
        Align(
          alignment: Alignment.topRight,
          child: Container(
            width: 120,
            height: 160,
            margin: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: state.isLocalUserJoined && _agoraService.engine != null
                  ? AgoraVideoView(
                      controller: VideoViewController(
                        rtcEngine: _agoraService.engine!,
                        canvas: const VideoCanvas(uid: 0),
                      ),
                      onAgoraVideoViewCreated: (viewId) {
                        _agoraService.engine!.startPreview();
                      },
                    )
                  : const CircularProgressIndicator(),
            ),
          ),
        ),

        // Call controls
        Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Mute/Unmute
                RawMaterialButton(
                  onPressed: () {
                    context.read<VideoCallBloc>().add(
                          ToggleAudioEvent(enabled: !state.isAudioEnabled),
                        );
                  },
                  shape: const CircleBorder(),
                  elevation: 2.0,
                  fillColor:
                      state.isAudioEnabled ? Colors.white : AppTheme.errorColor,
                  padding: const EdgeInsets.all(12.0),
                  child: Icon(
                    state.isAudioEnabled ? Icons.mic : Icons.mic_off,
                    color: state.isAudioEnabled
                        ? AppTheme.primaryColor
                        : Colors.white,
                    size: 20.0,
                  ),
                ),

                // End Call
                RawMaterialButton(
                  onPressed: () {
                    context.read<VideoCallBloc>().add(LeaveChannelEvent());
                    context.go('/');
                  },
                  shape: const CircleBorder(),
                  elevation: 2.0,
                  fillColor: AppTheme.errorColor,
                  padding: const EdgeInsets.all(15.0),
                  child: const Icon(
                    Icons.call_end,
                    color: Colors.white,
                    size: 35.0,
                  ),
                ),

                // Toggle Camera
                RawMaterialButton(
                  onPressed: () {
                    context.read<VideoCallBloc>().add(
                          ToggleVideoEvent(enabled: !state.isVideoEnabled),
                        );
                  },
                  shape: const CircleBorder(),
                  elevation: 2.0,
                  fillColor:
                      state.isVideoEnabled ? Colors.white : AppTheme.errorColor,
                  padding: const EdgeInsets.all(12.0),
                  child: Icon(
                    state.isVideoEnabled ? Icons.videocam : Icons.videocam_off,
                    color: state.isVideoEnabled
                        ? AppTheme.primaryColor
                        : Colors.white,
                    size: 20.0,
                  ),
                ),

                // Screen Share
                RawMaterialButton(
                  onPressed: () {
                    context.read<VideoCallBloc>().add(
                          ToggleScreenSharingEvent(
                              enabled: !state.isScreenSharing),
                        );
                  },
                  shape: const CircleBorder(),
                  elevation: 2.0,
                  fillColor: state.isScreenSharing
                      ? AppTheme.successColor
                      : Colors.white,
                  padding: const EdgeInsets.all(12.0),
                  child: Icon(
                    Icons.screen_share,
                    color: state.isScreenSharing
                        ? Colors.white
                        : AppTheme.primaryColor,
                    size: 20.0,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Remote video view with Google Meet-like UI
  Widget _remoteVideo(VideoCallConnected state) {
    if (state.remoteUsers.isNotEmpty && _agoraService.engine != null) {
      return Stack(
        children: [
          // Main remote video
          AgoraVideoView(
            controller: VideoViewController.remote(
              rtcEngine: _agoraService.engine!,
              canvas: VideoCanvas(uid: state.remoteUsers.first),
              connection: RtcConnection(channelId: state.channelName),
            ),
          ),

          // Participant count indicator
          Positioned(
            top: 16,
            left: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.people, color: Colors.white, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    '${state.remoteUsers.length + (state.isLocalUserJoined ? 1 : 0)}',
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ],
              ),
            ),
          ),

          // Meeting info
          Positioned(
            top: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                state.channelName,
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
          ),
        ],
      );
    } else {
      return Container(
        decoration: AppTheme.primaryGradientDecoration,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: const Icon(
                  Icons.people_outline,
                  size: 50,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Waiting for others to join...',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Share the meeting link to invite participants',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border:
                      Border.all(color: Colors.white.withValues(alpha: 0.3)),
                ),
                child: Text(
                  'Meeting ID: ${state.channelName}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontFamily: 'monospace',
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }
  }
}
