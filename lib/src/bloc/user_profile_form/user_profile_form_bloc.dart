import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:ease/src/data/user_repository/agent.dart';
import 'package:ease/src/data/user_repository/authentication_repo.dart';
import 'package:ease/src/service/auth_service.dart';
import 'package:equatable/equatable.dart';

part 'user_profile_form_event.dart';
part 'user_profile_form_state.dart';

class UserProfileFormBloc
    extends Bloc<UserProfileFormEvent, UserProfileFormState> {
  final AuthenticationRepository repository;
  final AuthService authRepo;

  UserProfileFormBloc(this.repository, this.authRepo)
      : super(UserProfileFormInitial()) {
    on<UpdateUserPhoneNum>(mapUpdateUserPhoneNumEventToState);
    on<UpdateUserHomeAddress>(mapUpdateUserHomeAddressEventToState);
  }

  void mapUpdateUserPhoneNumEventToState(
      UpdateUserPhoneNum event, Emitter<UserProfileFormState> emit) async {
    try {
      final Agent agent = await repository.fetchUserProfile();
      RegExp regExp = RegExp(r"^^(\??01)[0|1|2|3|4|6|7|8|9]\-*[0-9]{7,8}$");
      if (regExp.hasMatch(event.phoneNum)) {
        try {
          await authRepo.updateMobilePhone(agent.accountCode, event.phoneNum);
          final Agent updatedAgents = await repository.fetchUserProfile();

          // 1. UPDATE PHONE
          emit(UserProfileUpdatePhone(updatedAgents));
          await Future.delayed(const Duration(milliseconds: 100), () {});

          // 2. CHANGE TO PROFILE SUCCEED TO SHOW SUCCESSFUL RIBBON
          emit(const UserProfileSucceed("Successfully update phone number"));
          await Future.delayed(const Duration(milliseconds: 200), () {});

          // 3. RETURN NORMAL FROM
          emit(UserProfileFormDefault(updatedAgents));
        } catch (e) {
          emit(const UserProfileError("Couldn't update phone number"));
        }
      } else {
        // 1. UPDATE UNSUCCESSFUL MESSAGE
        emit(const UserProfileError("Phone Number is in wrong format"));
        await Future.delayed(const Duration(milliseconds: 100), () {});
        final Agent updatedAgents = await repository.fetchUserProfile();
        // 2. RETURN NORMAL FORM
        emit(UserProfileFormDefault(updatedAgents));
      }
    } catch (e) {
      emit(UserProfileError(e.toString()));
    }
  }

  void mapUpdateUserHomeAddressEventToState(
      UpdateUserHomeAddress event, Emitter<UserProfileFormState> emit) async {
    final Agent agent = await repository.fetchUserProfile();

    // await authRepo.updateAddres(agent.userId, event.phoneNum);
    try {
      await authRepo.updateHomeAddress(agent.accountCode, event.homeAddressOne,
          event.homeAddressTwo, event.homeAddressThree);

      final Agent updatedAgents = await repository.fetchUserProfile();

      // 1. UPDATE PHONE
      emit(UserProfileUpdateHomeAdress(updatedAgents));
      await Future.delayed(const Duration(milliseconds: 100), () {});

      // 2. CHANGE TO PROFILE SUCCEED TO SHOW SUCCESSFUL RIBBON
      emit(const UserProfileSucceed("Successfully update address"));
      await Future.delayed(const Duration(milliseconds: 500), () {});
      // 3. RETURN NORMAL FROM
      emit(UserProfileFormDefault(updatedAgents));
    } catch (e) {
      emit(UserProfileError(e.toString()));
    }
  }
}
