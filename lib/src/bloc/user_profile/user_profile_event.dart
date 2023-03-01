part of 'user_profile_bloc.dart';

abstract class UserProfileEvent extends Equatable {
  const UserProfileEvent();
}

final userProfileEventController = StreamController<UserProfileEvent>();
Sink<UserProfileEvent> get userProfileEventSink {
  return userProfileEventController.sink;
}

class LoadUserProfile extends UserProfileEvent {
  @override
  List<Object> get props => [];
}

class LoadUserProfileAPI extends UserProfileEvent {
  @override
  List<Object> get props => [];
}

class UpdateUserProfile extends UserProfileEvent {
  final String? token;
  final String? refreshToken;
  final Agent agent;
  const UpdateUserProfile(this.token, this.refreshToken, this.agent);
  @override
  List<Object> get props => [];
}
