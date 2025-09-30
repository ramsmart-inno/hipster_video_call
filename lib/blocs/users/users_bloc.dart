import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/user_list_model.dart';
import '../../services/user_service.dart';

// Events
abstract class UsersEvent {}

class FetchUsersEvent extends UsersEvent {
  final bool forceRefresh;
  
  FetchUsersEvent({this.forceRefresh = false});
}

// States
abstract class UsersState {}

class UsersInitial extends UsersState {}

class UsersLoading extends UsersState {}

class UsersLoaded extends UsersState {
  final List<UserListModel> users;
  final bool fromCache;
  
  UsersLoaded(this.users, {this.fromCache = false});
}

class UsersError extends UsersState {
  final String message;
  
  UsersError(this.message);
}

// BLoC
class UsersBloc extends Bloc<UsersEvent, UsersState> {
  final UserService _userService;
  
  UsersBloc(this._userService) : super(UsersInitial()) {
    on<FetchUsersEvent>(_onFetchUsers);
  }
  
  Future<void> _onFetchUsers(FetchUsersEvent event, Emitter<UsersState> emit) async {
    emit(UsersLoading());
    try {
      final users = await _userService.getUsers(forceRefresh: event.forceRefresh);
      emit(UsersLoaded(users, fromCache: !event.forceRefresh));
    } catch (e) {
      emit(UsersError(e.toString()));
    }
  }
}