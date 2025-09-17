import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stpvelox/features/settings/domain/usecases/manage_saved_networks.dart';
import 'package:stpvelox/features/settings/usecases/get_device_info.dart';
import 'package:stpvelox/features/wifi/application/wifi_provider.dart';
import 'package:stpvelox/features/wifi/domain/application/wifi_client_state.dart';
import 'package:stpvelox/features/wifi/domain/enities/saved_network.dart';
import 'package:stpvelox/features/wifi/domain/enities/wifi_credentials.dart';
import 'package:stpvelox/features/wifi/domain/enities/wifi_encryption_type.dart';
import 'package:stpvelox/features/wifi/domain/usecases/forget_wifi.dart';
import 'package:stpvelox/features/wifi/usecases/connect_to_wifi.dart';
import 'package:stpvelox/features/wifi/usecases/get_available_networks.dart';

class WifiClientNotifier extends StateNotifier<WifiClientState> {
  final GetAvailableNetworks getAvailableNetworks;
  final ConnectToWifi connectToWifi;
  final ForgetWifi forgetWifi;
  final GetDeviceInfo getDeviceInfo;
  final ManageSavedNetworks manageSavedNetworks;

  WifiClientNotifier({
    required this.getAvailableNetworks,
    required this.connectToWifi,
    required this.forgetWifi,
    required this.getDeviceInfo,
    required this.manageSavedNetworks,
  }) : super(WifiClientState());

  Future<void> loadNetworks() async {
    state.isLoading = true;
    try {
      final networks = await getAvailableNetworks();
      state = state.copyWith(isLoading: false, networks: networks);
    } catch (e) {
      state.errorMessage = e.toString();
    }
  }

  Future<void> connectToNetwork(String ssid, WifiEncryptionType encryptionType, WifiCredentials credentials) async {
    state.isLoading = true;
    try {
      await connectToWifi(ssid, encryptionType, credentials);

      final savedNetwork = SavedNetwork(
        ssid: ssid,
        encryptionType: encryptionType,
        credentials: credentials,
        lastConnected: DateTime.now(),
      );
      await manageSavedNetworks.saveNetwork(savedNetwork);

      state.connectedSsid = ssid;

      final networks = await getAvailableNetworks();
      state.networks = networks;
      state.isLoading = false;

      await loadDeviceInfo();
    } catch (e) {
      state.errorMessage = (e.toString());
    }
  }

  Future<void> forgetNetwork(String ssid) async {
    state.isLoading = true;
    try {
      await forgetWifi(ssid);
      state.forgottenSsid = ssid;

      final networks = await getAvailableNetworks();
      state.networks = networks;

      await loadDeviceInfo();
    } catch (e) {
      state.errorMessage = e.toString();
    }
  }

  Future<void> loadDeviceInfo() async {
    try {
      final deviceInfo = await getDeviceInfo();
      state.deviceInfo = deviceInfo;
    } catch (e) {
      state.errorMessage = e.toString();
    }
  }
}

final wifiClientProvider =
StateNotifierProvider<WifiClientNotifier, WifiClientState>((ref) {
  return WifiClientNotifier(
    getAvailableNetworks: ref.read(getAvailableNetworksProvider),
    connectToWifi: ref.read(connectToWifiProvider),
    forgetWifi: ref.read(forgetWifiProvider),
    getDeviceInfo: ref.read(getDeviceInfoProvider),
    manageSavedNetworks: ref.read(manageSavedNetworksProvider),
  );
});
