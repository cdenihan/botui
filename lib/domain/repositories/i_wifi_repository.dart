import 'package:stpvelox/domain/entities/access_point_config.dart';
import 'package:stpvelox/domain/entities/device_info.dart';
import 'package:stpvelox/domain/entities/network_mode.dart';
import 'package:stpvelox/domain/entities/saved_network.dart';
import 'package:stpvelox/domain/entities/wifi_band.dart';
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

  // New methods for network modes and saved networks
  Future<NetworkMode> getCurrentNetworkMode();
  Future<void> setNetworkMode(NetworkMode mode);
  Future<void> initializeNetworkMode();
  
  // Access Point Mode
  Future<void> startAccessPoint(AccessPointConfig config);
  Future<void> stopAccessPoint();
  Future<bool> isAccessPointActive();
  Future<AccessPointConfig?> getAccessPointConfig();
  Future<WifiBand> findBestWifiBand();
  Future<int> findBestChannel(WifiBand band);
  
  // Saved Networks
  Future<List<SavedNetwork>> getSavedNetworks();
  Future<void> saveNetwork(SavedNetwork network);
  Future<void> removeSavedNetwork(String ssid);
  Future<SavedNetwork?> getSavedNetwork(String ssid);
  
  // LAN Only Mode
  Future<void> enableLanOnlyMode();
  Future<void> disableLanOnlyMode();
  Future<bool> isLanOnlyModeActive();
}
