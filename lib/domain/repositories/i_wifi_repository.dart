import 'package:stpvelox/domain/entities/device_info.dart';
import 'package:stpvelox/domain/entities/wifi_credentials.dart';
import 'package:stpvelox/domain/entities/wifi_encryption_type.dart';
import 'package:stpvelox/domain/entities/wifi_network.dart';

abstract class IWifiRepository {
  Future<List<WifiNetwork>> getAvailableNetworks();

  Future<void> connectToWifi(
    String ssid,
    WifiEncryptionType encryptionType,
    WifiCredentials credentials,
  );

  Future<void> forgetWifi(String ssid);

  Future<DeviceInfo> getDeviceInfo();
}
