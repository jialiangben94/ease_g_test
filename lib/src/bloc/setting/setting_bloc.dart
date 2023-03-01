import 'package:bloc/bloc.dart';
import 'package:ease/src/setting/app_language.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

part 'setting_event.dart';
part 'setting_state.dart';

class SettingBloc extends Bloc<SettingEvent, SettingState> {
  final AppSettingRepo appLanguage;

  SettingBloc(this.appLanguage) : super(SettingInitial()) {
    on<GetSetting>(mapGetSettingEventToState);
    on<ChangeSetting>(mapChangeSettingEventToState);
  }

  void mapGetSettingEventToState(
      GetSetting event, Emitter<SettingState> emit) async {
    emit(SettingInitial());
    final Locale language = await appLanguage.fetchLocale();
    emit(SettingLoaded(language));
  }

  void mapChangeSettingEventToState(
      ChangeSetting event, Emitter<SettingState> emit) async {
    emit(SettingInitial());
    final Locale language = await appLanguage.changeLanguage(event.type);
    emit(SettingLoaded(language));
  }
}
