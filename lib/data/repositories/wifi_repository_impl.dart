import 'package:stpvelox/data/datasources/linux_network_manager.dart';
import 'package:stpvelox/domain/entities/device_info.dart';
import 'package:stpvelox/domain/entities/wifi_credentials.dart';
import 'package:stpvelox/domain/entities/wifi_encryption_type.dart';
import 'package:stpvelox/domain/repositories/i_wifi_repository.dart';

import '../../domain/entities/wifi_network.dart';

class WifiRepositoryImpl implements IWifiRepository {
  final LinuxNetworkManager networkManager;

  WifiRepositoryImpl({required this.networkManager});

  @override
  Future<List<WifiNetwork>> getAvailableNetworks() async {
    return await networkManager.scanNetworks();
  }

  @override
  Future<void> connectToWifi(String ssid, WifiEncryptionType encryptionType, WifiCredentials credentials) {
    return networkManager.connect(ssid, encryptionType, credentials);
  }

  @override
  Future<void> forgetWifi(String ssid) {
    return networkManager.forget(ssid);
  }

  @override
  Future<DeviceInfo> getDeviceInfo() async {
    try {
      return await networkManager.getDeviceInfo();
    } catch (e) {
      throw Exception('Failed to get device info: $e');
    }
  }
}
