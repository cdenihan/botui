import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stpvelox/core/logging/has_logging.dart';
import 'package:stpvelox/features/settings/domain/usecases/set_network_mode.dart';
import 'package:stpvelox/features/wifi/application/wifi_provider.dart';
import 'package:stpvelox/features/wifi/domain/application/network_mode_state.dart';
import 'package:stpvelox/features/wifi/domain/enities/network_mode.dart';
import 'package:stpvelox/features/wifi/usecases/get_network_mode.dart';

class NetworkModeNotifier extends Notifier<NetworkModeState> with HasLogger {
  late final GetNetworkMode _getNetworkMode;
  late final SetNetworkMode _setNetworkMode;

  @override
  NetworkModeState build() {
    _getNetworkMode = ref.read(getNetworkModeProvider);
    _setNetworkMode = ref.read(setNetworkModeProvider);
    return NetworkModeState();
  }

  Future<void> loadNetworkMode() async {
    state = state.copyWith(isLoading: true);
    try {
      final mode = await _getNetworkMode();
      state = state.copyWith(mode: mode, isLoading: false);
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString(), isLoading: false);
    }
  }

  Future<void> updateNetworkMode(NetworkMode mode) async {
    state = state.copyWith(isLoading: true);
    try {
      await _setNetworkMode(mode);
      state = state.copyWith(mode: mode, isLoading: false);
      log.info("Network mode updated to ${state.mode}");
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString(), isLoading: false);
      log.severe("Failed to update network mode: $e");
    }
  }
}

final networkModeProvider =
    NotifierProvider<NetworkModeNotifier, NetworkModeState>(
  NetworkModeNotifier.new,
);
