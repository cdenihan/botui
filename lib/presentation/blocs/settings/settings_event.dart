part of 'settings_bloc.dart';

abstract class SettingsEvent extends Equatable {
  const SettingsEvent();

  @override
  List<Object> get props => [];
}

class LoadSettingsEvent extends SettingsEvent {}

class SettingTappedEvent extends SettingsEvent {
  final Setting setting;

  const SettingTappedEvent({required this.setting});

  @override
  List<Object> get props => [setting];
}
