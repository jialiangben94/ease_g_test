part of 'setting_bloc.dart';

abstract class SettingState extends Equatable {
  const SettingState();
}

class SettingInitial extends SettingState {
  @override
  List<Object> get props => [];
}

class SettingLoaded extends SettingState {
  final Locale language;
  const SettingLoaded(this.language);

  @override
  List<Object> get props => [language];
}
