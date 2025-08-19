import 'package:equatable/equatable.dart';
import 'package:stpvelox/domain/entities/device_info.dart';
import 'package:stpvelox/domain/entities/wifi_network.dart';

abstract class WifiClientState extends Equatable {
  const WifiClientState();

  @override
  List<Object?> get props => [];
}

class WifiClientInitialState extends WifiClientState {}

class WifiClientLoadingState extends WifiClientState {} // For loading networks or device info

class WifiClientLoadedState extends WifiClientState {
  final List<WifiNetwork> networks;

  const WifiClientLoadedState(this.networks);

  @override
  List<Object?> get props => [networks];
}

class WifiClientErrorState extends WifiClientState {
  final String message;

  const WifiClientErrorState(this.message);

  @override
  List<Object?> get props => [message];
}

class WifiClientConnectingState extends WifiClientState {}

class WifiClientConnectedState extends WifiClientState {
  final String ssid;

  const WifiClientConnectedState(this.ssid);

  @override
  List<Object?> get props => [ssid];
}

class WifiClientForgettingState extends WifiClientState {}

class WifiClientForgottenState extends WifiClientState {
  final String ssid;

  const WifiClientForgottenState(this.ssid);

  @override
  List<Object?> get props => [ssid];
}

class DeviceInfoLoadedState extends WifiClientState {
  final DeviceInfo deviceInfo;

  const DeviceInfoLoadedState(this.deviceInfo);

  @override
  List<Object?> get props => [deviceInfo];
}
