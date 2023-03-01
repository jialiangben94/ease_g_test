import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:ease/src/data/user_repository/agent.dart';
import 'package:ease/src/data/user_repository/authentication_repo.dart';
import 'package:equatable/equatable.dart';

part 'user_profile_event.dart';
part 'user_profile_state.dart';

class UserProfileBloc extends Bloc<UserProfileEvent, UserProfileBlocState> {
  final AuthenticationRepository repository;
  UserProfileBloc(this.repository) : super(UserProfileInitial()) {
    on<UpdateUserProfile>(mapUpdateUserProfileEventToState);
    on<LoadUserProfile>(mapLoadUserProfileEventToState);
    on<LoadUserProfileAPI>(mapLoadUserProfileAPIEventToState);
  }

  void mapUpdateUserProfileEventToState(
      UpdateUserProfile event, Emitter<UserProfileBlocState> emit) async {
    emit(const UserProfileLoading());
    try {
      repository.saveToken(event.token!, event.refreshToken!);
      repository.saveUserProfile(event.agent);
      emit(UserProfileLoaded(event.agent));
    } catch (e) {
      emit(UserProfileError(e.toString()));
    }
  }

  void mapLoadUserProfileEventToState(
      LoadUserProfile event, Emitter<UserProfileBlocState> emit) async {
    emit(const UserProfileLoading());
    try {
      final Agent agent = await repository.fetchUserProfile();
      emit(UserProfileLoaded(agent));
    } catch (e) {
      emit(UserProfileError(e.toString()));
    }
  }

  void mapLoadUserProfileAPIEventToState(
      LoadUserProfileAPI event, Emitter<UserProfileBlocState> emit) async {
    emit(const UserProfileLoading());
    try {
      final Agent? agent = await repository.fetchUserProfileAPI();
      emit(UserProfileLoaded(agent));
    } catch (e) {
      emit(UserProfileError(e.toString()));
    }
  }
}
