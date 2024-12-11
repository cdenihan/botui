part of 'settings_bloc.dart';

abstract class SettingsEvent extends Equatable {
  const SettingsEvent();

  @override
  List<Object> get props => [];
}

class LoadSettingsEvent extends SettingsEvent {}

class SettingTappedEvent extends SettingsEvent {
  final String label;

  const SettingTappedEvent({required this.label});

  @override
  List<Object> get props => [label];
}
