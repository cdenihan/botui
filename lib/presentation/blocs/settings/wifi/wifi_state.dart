import 'package:equatable/equatable.dart';
import 'package:stpvelox/domain/entities/device_info.dart';
import 'package:stpvelox/domain/entities/wifi_network.dart';

abstract class WifiState extends Equatable {
  const WifiState();

  @override
  List<Object?> get props => [];
}

class WifiInitialState extends WifiState {}

class WifiLoadingState extends WifiState {}

class WifiLoadedState extends WifiState {
  final List<WifiNetwork> networks;

  const WifiLoadedState(this.networks);

  @override
  List<Object?> get props => [networks];
}

class WifiErrorState extends WifiState {
  final String message;

  const WifiErrorState(this.message);

  @override
  List<Object?> get props => [message];
}

class WifiConnectingState extends WifiState {}

class WifiConnectedState extends WifiState {
  final String ssid;

  const WifiConnectedState(this.ssid);

  @override
  List<Object?> get props => [ssid];
}

class WifiForgettingState extends WifiState {}

class WifiForgottenState extends WifiState {
  final String ssid;

  const WifiForgottenState(this.ssid);

  @override
  List<Object?> get props => [ssid];
}

class DeviceInfoLoadedState extends WifiState {
  final DeviceInfo deviceInfo;

  const DeviceInfoLoadedState(this.deviceInfo);

  @override
  List<Object?> get props => [deviceInfo];
}
