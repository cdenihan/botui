import 'package:stpvelox/features/wifi/domain/enities/wifi_network.dart';
import 'package:stpvelox/shared/domain/entities/device_info.dart';

class WifiClientState {
  bool isLoading;
  List<WifiNetwork> networks;
  late String? errorMessage;
  late String? connectedSsid;
  late String? forgottenSsid;
  late DeviceInfo? deviceInfo;

  WifiClientState({
    this.isLoading = false,
    this.networks = const [],
    this.errorMessage,
    this.connectedSsid,
    this.forgottenSsid,
    this.deviceInfo,
  });

  WifiClientState copyWith({
    bool? isLoading,
    List<WifiNetwork>? networks,
    String? errorMessage,
    String? connectedSsid,
    String? forgottenSsid,
    bool? deviceInfo,
  }) {
    return WifiClientState(
      isLoading: isLoading ?? this.isLoading,
      networks: networks ?? this.networks,
      errorMessage: errorMessage ?? this.errorMessage,
      connectedSsid: connectedSsid ?? this.connectedSsid,
      forgottenSsid: forgottenSsid ?? this.forgottenSsid,
      deviceInfo: deviceInfo == null ? this.deviceInfo : null,
    );
  }
}