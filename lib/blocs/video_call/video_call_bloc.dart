import 'package:flutter_bloc/flutter_bloc.dart';
import '../../services/agora_service.dart';
import '../../utils/app_logger.dart';

// Events
abstract class VideoCallEvent {}

class InitializeVideoCallEvent extends VideoCallEvent {}

class JoinChannelEvent extends VideoCallEvent {
  final String? channelName;

  JoinChannelEvent({this.channelName});
}

class LeaveChannelEvent extends VideoCallEvent {}

class ToggleAudioEvent extends VideoCallEvent {
  final bool enabled;

  ToggleAudioEvent({required this.enabled});
}

class ToggleVideoEvent extends VideoCallEvent {
  final bool enabled;

  ToggleVideoEvent({required this.enabled});
}

class ToggleScreenSharingEvent extends VideoCallEvent {
  final bool enabled;

  ToggleScreenSharingEvent({required this.enabled});
}

class UserJoinedEvent extends VideoCallEvent {
  final int uid;

  UserJoinedEvent({required this.uid});
}

class UserLeftEvent extends VideoCallEvent {
  final int uid;

  UserLeftEvent({required this.uid});
}

class LocalUserJoinedEvent extends VideoCallEvent {
  final int uid;

  LocalUserJoinedEvent({required this.uid});
}

// States
abstract class VideoCallState {}

class VideoCallInitial extends VideoCallState {}

class VideoCallLoading extends VideoCallState {}

class VideoCallReady extends VideoCallState {}

class VideoCallConnected extends VideoCallState {
  final bool isAudioEnabled;
  final bool isVideoEnabled;
  final bool isScreenSharing;
  final bool isLocalUserJoined;
  final List<int> remoteUsers;
  final String channelName;

  VideoCallConnected({
    this.isAudioEnabled = true,
    this.isVideoEnabled = true,
    this.isScreenSharing = false,
    this.isLocalUserJoined = false,
    this.remoteUsers = const [],
    this.channelName = 'hipster_video_call',
  });

  VideoCallConnected copyWith({
    bool? isAudioEnabled,
    bool? isVideoEnabled,
    bool? isScreenSharing,
    bool? isLocalUserJoined,
    List<int>? remoteUsers,
    String? channelName,
  }) {
    return VideoCallConnected(
      isAudioEnabled: isAudioEnabled ?? this.isAudioEnabled,
      isVideoEnabled: isVideoEnabled ?? this.isVideoEnabled,
      isScreenSharing: isScreenSharing ?? this.isScreenSharing,
      isLocalUserJoined: isLocalUserJoined ?? this.isLocalUserJoined,
      remoteUsers: remoteUsers ?? this.remoteUsers,
      channelName: channelName ?? this.channelName,
    );
  }
}

class VideoCallDisconnected extends VideoCallState {}

class VideoCallError extends VideoCallState {
  final String message;

  VideoCallError(this.message);
}

// BLoC
class VideoCallBloc extends Bloc<VideoCallEvent, VideoCallState> {
  final AgoraService _agoraService;

  VideoCallBloc(this._agoraService) : super(VideoCallInitial()) {
    on<InitializeVideoCallEvent>(_onInitialize);
    on<JoinChannelEvent>(_onJoinChannel);
    on<LeaveChannelEvent>(_onLeaveChannel);
    on<ToggleAudioEvent>(_onToggleAudio);
    on<ToggleVideoEvent>(_onToggleVideo);
    on<ToggleScreenSharingEvent>(_onToggleScreenSharing);
    on<UserJoinedEvent>(_onUserJoined);
    on<UserLeftEvent>(_onUserLeft);
    on<LocalUserJoinedEvent>(_onLocalUserJoined);

    // Set up callbacks for AgoraService
    _agoraService.onUserJoined = (uid) => add(UserJoinedEvent(uid: uid));
    _agoraService.onUserLeft = (uid) => add(UserLeftEvent(uid: uid));
    _agoraService.onLocalUserJoined =
        (uid) => add(LocalUserJoinedEvent(uid: uid));
  }

  Future<void> _onInitialize(
      InitializeVideoCallEvent event, Emitter<VideoCallState> emit) async {
    emit(VideoCallLoading());
    try {
      await _agoraService.initialize();
      emit(VideoCallReady());
    } catch (e) {
      emit(VideoCallError(e.toString()));
    }
  }

  Future<void> _onJoinChannel(
      JoinChannelEvent event, Emitter<VideoCallState> emit) async {
    emit(VideoCallLoading());
    try {
      final channelName = event.channelName ?? 'hipster_video_call';
      await _agoraService.joinChannel(channelName: channelName);
      emit(VideoCallConnected(
        isAudioEnabled: true,
        isVideoEnabled: true,
        isScreenSharing: false,
        isLocalUserJoined: false,
        remoteUsers: const [],
        channelName: channelName,
      ));
    } catch (e) {
      emit(VideoCallError(e.toString()));
    }
  }

  Future<void> _onLeaveChannel(
      LeaveChannelEvent event, Emitter<VideoCallState> emit) async {
    if (state is VideoCallConnected) {
      try {
        await _agoraService.leaveChannel();
        emit(VideoCallDisconnected());
      } catch (e) {
        emit(VideoCallError(e.toString()));
      }
    }
  }

  Future<void> _onToggleAudio(
      ToggleAudioEvent event, Emitter<VideoCallState> emit) async {
    if (state is VideoCallConnected) {
      final currentState = state as VideoCallConnected;
      try {
        await _agoraService.toggleLocalAudio(event.enabled);
        emit(currentState.copyWith(isAudioEnabled: event.enabled));
      } catch (e) {
        emit(VideoCallError(e.toString()));
      }
    }
  }

  Future<void> _onToggleVideo(
      ToggleVideoEvent event, Emitter<VideoCallState> emit) async {
    if (state is VideoCallConnected) {
      final currentState = state as VideoCallConnected;
      try {
        await _agoraService.toggleLocalVideo(event.enabled);
        emit(currentState.copyWith(isVideoEnabled: event.enabled));
      } catch (e) {
        emit(VideoCallError(e.toString()));
      }
    }
  }

  Future<void> _onToggleScreenSharing(
      ToggleScreenSharingEvent event, Emitter<VideoCallState> emit) async {
    if (state is VideoCallConnected) {
      final currentState = state as VideoCallConnected;
      try {
        if (event.enabled) {
          await _agoraService.startScreenSharing();
        } else {
          await _agoraService.stopScreenSharing();
        }
        emit(currentState.copyWith(isScreenSharing: event.enabled));
      } catch (e) {
        emit(VideoCallError(e.toString()));
      }
    }
  }

  Future<void> _onUserJoined(
      UserJoinedEvent event, Emitter<VideoCallState> emit) async {
    AppLogger.info(
        '📱 VideoCallBloc: User joined event received for UID: ${event.uid}');
    if (state is VideoCallConnected) {
      final currentState = state as VideoCallConnected;
      final updatedUsers = List<int>.from(currentState.remoteUsers);
      if (!updatedUsers.contains(event.uid)) {
        updatedUsers.add(event.uid);
        AppLogger.info(
            '📱 VideoCallBloc: Added user ${event.uid} to remote users list. Total: ${updatedUsers.length}');
      } else {
        AppLogger.info(
            '📱 VideoCallBloc: User ${event.uid} already in remote users list');
      }
      emit(currentState.copyWith(remoteUsers: updatedUsers));
    } else {
      AppLogger.warning(
          '📱 VideoCallBloc: Received user joined event but not in connected state. Current state: ${state.runtimeType}');
    }
  }

  Future<void> _onUserLeft(
      UserLeftEvent event, Emitter<VideoCallState> emit) async {
    if (state is VideoCallConnected) {
      final currentState = state as VideoCallConnected;
      final updatedUsers = List<int>.from(currentState.remoteUsers);
      updatedUsers.remove(event.uid);
      emit(currentState.copyWith(remoteUsers: updatedUsers));
    }
  }

  Future<void> _onLocalUserJoined(
      LocalUserJoinedEvent event, Emitter<VideoCallState> emit) async {
    AppLogger.info(
        '📱 VideoCallBloc: Local user joined event received for UID: ${event.uid}');
    if (state is VideoCallConnected) {
      final currentState = state as VideoCallConnected;
      AppLogger.info('📱 VideoCallBloc: Setting local user as joined');
      emit(currentState.copyWith(isLocalUserJoined: true));
    } else {
      AppLogger.warning(
          '📱 VideoCallBloc: Received local user joined event but not in connected state. Current state: ${state.runtimeType}');
    }
  }

  @override
  Future<void> close() {
    _agoraService.dispose();
    return super.close();
  }
}
