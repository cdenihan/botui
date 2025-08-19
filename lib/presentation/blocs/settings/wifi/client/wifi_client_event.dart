import 'package:equatable/equatable.dart';
import 'package:stpvelox/domain/entities/wifi_credentials.dart';
import 'package:stpvelox/domain/entities/wifi_encryption_type.dart';

abstract class WifiClientEvent extends Equatable {
  const WifiClientEvent();
  @override
  List<Object?> get props => [];
}

class LoadNetworksEvent extends WifiClientEvent {}

class ConnectToNetworkEvent extends WifiClientEvent {
  final String ssid;
  final WifiEncryptionType encryptionType;
  final WifiCredentials credentials;

  const ConnectToNetworkEvent(this.ssid, this.encryptionType, this.credentials);

  @override
  List<Object?> get props => [ssid, encryptionType, credentials];
}

class ForgetNetworkEvent extends WifiClientEvent {
  final String ssid;
  const ForgetNetworkEvent(this.ssid);

  @override
  List<Object?> get props => [ssid];
}

class LoadDeviceInfoEvent extends WifiClientEvent {}
