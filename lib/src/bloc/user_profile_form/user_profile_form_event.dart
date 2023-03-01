part of 'user_profile_form_bloc.dart';

abstract class UserProfileFormEvent extends Equatable {
  const UserProfileFormEvent();
}

class UpdateUserPhoneNum extends UserProfileFormEvent {
  final String phoneNum;
  const UpdateUserPhoneNum(this.phoneNum);
  @override
  List<Object> get props => [];
}

// class UpdateUserOfficeAddress extends UserProfileFormEvent {
//   final String officeAddressOne;
//   final String officeAddressTwo;
//   final String officeAddressThree;

//   const UpdateUserOfficeAddress(
//       this.officeAddressOne, this.officeAddressTwo, this.officeAddressThree);
//   List<Object> get props => [];
// }

class UpdateUserHomeAddress extends UserProfileFormEvent {
  final String homeAddressOne;
  final String homeAddressTwo;
  final String homeAddressThree;

  const UpdateUserHomeAddress(
      this.homeAddressOne, this.homeAddressTwo, this.homeAddressThree);
  @override
  List<Object> get props => [];
}
