import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stpvelox/features/settings/domain/usecases/manage_saved_networks.dart';
import 'package:stpvelox/features/wifi/application/wifi_provider.dart';
import 'package:stpvelox/features/wifi/domain/application/saved_networks_state.dart';
import 'package:stpvelox/features/wifi/usecases/connect_to_wifi.dart';

class SavedNetworksNotifier extends Notifier<SavedNetworksState> {
  late final ManageSavedNetworks _manageSavedNetworks;
  late final ConnectToWifi _connectToWifi;

  @override
  SavedNetworksState build() {
    _manageSavedNetworks = ref.read(manageSavedNetworksProvider);
    _connectToWifi = ref.read(connectToWifiProvider);
    return SavedNetworksState();
  }

  Future<void> loadSavedNetworks() async {
    state = state.copyWith(isLoading: true);
    try {
      final networks = await _manageSavedNetworks.getSavedNetworks();
      state = state.copyWith(isLoading: false, networks: networks);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> removeSavedNetwork(String ssid) async {
    try {
      await _manageSavedNetworks.removeSavedNetwork(ssid);
      await loadSavedNetworks();
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
    }
  }

  Future<void> connectToSavedNetwork(String ssid) async {
    state = state.copyWith(isLoading: true);
    try {
      final savedNetwork = await _manageSavedNetworks.getSavedNetwork(ssid);
      if (savedNetwork != null) {
        await _connectToWifi(
          savedNetwork.ssid,
          savedNetwork.encryptionType,
          savedNetwork.credentials,
        );
        final updatedNetwork =
            savedNetwork.copyWith(lastConnected: DateTime.now());
        await _manageSavedNetworks.saveNetwork(updatedNetwork);
        await loadSavedNetworks();
      } else {
        state = state.copyWith(errorMessage: 'Network not found');
      }
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
    }
  }
}

final savedNetworksProvider =
    NotifierProvider<SavedNetworksNotifier, SavedNetworksState>(
  SavedNetworksNotifier.new,
);
