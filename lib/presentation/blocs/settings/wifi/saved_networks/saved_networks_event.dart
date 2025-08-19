import 'package:equatable/equatable.dart';

abstract class SavedNetworksEvent extends Equatable {
  const SavedNetworksEvent();
  @override
  List<Object?> get props => [];
}

class LoadSavedNetworksEvent extends SavedNetworksEvent {}

class RemoveSavedNetworkEvent extends SavedNetworksEvent {
  final String ssid;
  const RemoveSavedNetworkEvent(this.ssid);

  @override
  List<Object?> get props => [ssid];
}

class ConnectToSavedNetworkEvent extends SavedNetworksEvent {
  final String ssid;
  const ConnectToSavedNetworkEvent(this.ssid);

  @override
  List<Object?> get props => [ssid];
}
