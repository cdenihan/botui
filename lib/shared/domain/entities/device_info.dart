import 'package:stpvelox/features/wifi/domain/enities/wifi_network.dart';

class DeviceInfo {
  final String ipAddress;
  final WifiNetwork? connectedNetwork;

  DeviceInfo({required this.ipAddress, this.connectedNetwork});
}
