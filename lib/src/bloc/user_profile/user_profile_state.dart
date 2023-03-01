part of 'user_profile_bloc.dart';

abstract class UserProfileBlocState extends Equatable {
  const UserProfileBlocState();
}

class UserProfileInitial extends UserProfileBlocState {
  @override
  List<Object> get props => [];
}

class UserProfileLoading extends UserProfileBlocState {
  const UserProfileLoading();
  @override
  List<Object> get props => [];
}

class UserProfileLoaded extends UserProfileBlocState {
  final Agent? agent;
  const UserProfileLoaded(this.agent);

  @override
  List<Object?> get props => [agent];
}

class UserPhoneUpdated extends UserProfileBlocState {
  final Agent agent;
  const UserPhoneUpdated(this.agent);

  @override
  List<Object> get props => [agent];
}

class UserProfileError extends UserProfileBlocState {
  final String message;
  const UserProfileError(this.message);

  @override
  List<Object> get props => [message];
}
