import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stpvelox/features/settings/domain/usecases/manage_saved_networks.dart';
import 'package:stpvelox/features/wifi/application/wifi_provider.dart';
import 'package:stpvelox/features/wifi/domain/application/saved_networks_state.dart';
import 'package:stpvelox/features/wifi/usecases/connect_to_wifi.dart';

class SavedNetworksNotifier extends StateNotifier<SavedNetworksState> {
  final ManageSavedNetworks manageSavedNetworks;
  final ConnectToWifi connectToWifi;

  SavedNetworksNotifier({
    required this.manageSavedNetworks,
    required this.connectToWifi,
  }) : super(SavedNetworksState());

  Future<void> loadSavedNetworks() async {
    state.isLoading = true;
    try {
      final networks = await manageSavedNetworks.getSavedNetworks();
      state = state.copyWith(isLoading: false, networks: networks);
    } catch (e) {
      state.errorMessage = e.toString();
    }
  }

  Future<void> removeSavedNetwork(String ssid) async {
    try {
      await manageSavedNetworks.removeSavedNetwork(ssid);
      await loadSavedNetworks();
    } catch (e) {
      state.errorMessage = e.toString();
    }
  }

  Future<void> connectToSavedNetwork(String ssid) async {
    state.isLoading = true;
    try {
      final savedNetwork = await manageSavedNetworks.getSavedNetwork(ssid);
      if (savedNetwork != null) {
        await connectToWifi(savedNetwork.ssid, savedNetwork.encryptionType, savedNetwork.credentials);
        final updatedNetwork = savedNetwork.copyWith(lastConnected: DateTime.now());
        await manageSavedNetworks.saveNetwork(updatedNetwork);
        await loadSavedNetworks();
      } else {
        state.errorMessage = 'Network not found';
      }
    } catch (e) {
      state.errorMessage = e.toString();
    }
  }
}

final savedNetworksProvider =
StateNotifierProvider<SavedNetworksNotifier, SavedNetworksState>((ref) {
  return SavedNetworksNotifier(
    manageSavedNetworks: ref.read(manageSavedNetworksProvider),
    connectToWifi: ref.read(connectToWifiProvider),
  );
});
