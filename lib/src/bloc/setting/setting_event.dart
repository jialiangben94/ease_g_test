part of 'setting_bloc.dart';

abstract class SettingEvent extends Equatable {
  const SettingEvent();
}

class GetSetting extends SettingEvent {
  @override
  List<Object> get props => [];
}

class ChangeSetting extends SettingEvent {
  final Locale type;
  const ChangeSetting(this.type);
  @override
  List<Object> get props => [];
}
