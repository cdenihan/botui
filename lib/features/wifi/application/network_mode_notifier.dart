import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stpvelox/features/settings/domain/usecases/set_network_mode.dart';
import 'package:stpvelox/features/wifi/application/wifi_provider.dart';
import 'package:stpvelox/features/wifi/domain/application/network_mode_state.dart';
import 'package:stpvelox/features/wifi/domain/enities/network_mode.dart';
import 'package:stpvelox/features/wifi/usecases/get_network_mode.dart';

class NetworkModeNotifier extends StateNotifier<NetworkModeState> {
  final GetNetworkMode getNetworkMode;
  final SetNetworkMode setNetworkMode;

  NetworkModeNotifier({
    required this.getNetworkMode,
    required this.setNetworkMode,
  }) : super(NetworkModeState());

  Future<void> loadNetworkMode() async {
    state.isLoading = true;
    try {
      final mode = await getNetworkMode();
      state.mode = mode;
      state.isLoading = false;
    } catch (e) {
      state.errorMessage = e.toString();
    }
  }

  Future<void> updateNetworkMode(NetworkMode mode) async {
    state.isLoading = true;
    try {
      await setNetworkMode(mode);
      state.mode = mode;
      state.isLoading = false;
    } catch (e) {
      state.errorMessage = e.toString();
    }
  }
}

final networkModeProvider =
StateNotifierProvider<NetworkModeNotifier, NetworkModeState>((ref) {
  return NetworkModeNotifier(
    getNetworkMode: ref.read(getNetworkModeProvider),
    setNetworkMode: ref.read(setNetworkModeProvider),
  );
});
