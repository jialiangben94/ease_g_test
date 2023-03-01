part of 'user_profile_form_bloc.dart';

abstract class UserProfileFormState extends Equatable {
  const UserProfileFormState();
}

class UserProfileFormInitial extends UserProfileFormState {
  @override
  List<Object> get props => [];
}

class UserProfileFormUpdating extends UserProfileFormState {
  @override
  List<Object> get props => [];
}

class UserProfileFormDefault extends UserProfileFormState {
  final Agent agent;
  const UserProfileFormDefault (this.agent);
  @override
  List<Object> get props => [];
}

class UserProfileUpdatePhone extends UserProfileFormState {
  final Agent agent;
  const UserProfileUpdatePhone(this.agent);
  @override
  List<Object> get props => [];
}

// class UserProfileUpdateOfficeAdress extends UserProfileFormState {
//   final Agent agent;
//   const UserProfileUpdateOfficeAdress(this.agent);
//   @override
//   List<Object> get props => [];
// }

class UserProfileUpdateHomeAdress extends UserProfileFormState {
  final Agent agent;
  const UserProfileUpdateHomeAdress(this.agent);
  @override
  List<Object> get props => [];
}

class UserProfileSucceed extends UserProfileFormState {
  final String message;
  const UserProfileSucceed(this.message);

  @override
  List<Object> get props => [message];
}


class UserProfileError extends UserProfileFormState {
  final String message;
  const UserProfileError(this.message);

  @override
  List<Object> get props => [message];
}
