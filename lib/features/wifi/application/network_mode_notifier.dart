import 'dart:async';
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

    // Listen to LAN state changes for cable disconnection
    _startListeningToLanState();

    return NetworkModeState();
  }

  /// Start listening to LAN state changes to detect cable disconnection
  void _startListeningToLanState() {
    ref.listen(
      lanOnlyProvider,
      (previous, next) {
        // Check if cable was disconnected while in LAN only mode
        if (state.mode == NetworkMode.lanOnly &&
            next.errorMessage == 'LAN_CABLE_DISCONNECTED') {
          log.warning('LAN cable disconnected, automatically switching to client mode');
          _handleCableDisconnection();
        }
      },
    );
  }

  /// Handle cable disconnection by automatically switching to client mode
  Future<void> _handleCableDisconnection() async {
    try {
      // Disable LAN only mode
      await ref.read(lanOnlyProvider.notifier).disable();

      // Switch to client mode
      await _setNetworkMode(NetworkMode.client);

      state = state.copyWith(
        mode: NetworkMode.client,
        errorMessage: () => 'LAN cable disconnected. Automatically switched to client mode.',
      );

      log.info('Automatically switched to client mode due to cable disconnection');
    } catch (e) {
      log.severe('Failed to switch to client mode after cable disconnection: $e');
      state = state.copyWith(
        errorMessage: () => 'Failed to switch mode after cable disconnection: $e',
      );
    }
  }

  Future<void> loadNetworkMode() async {
    state = state.copyWith(isLoading: true, errorMessage: () => null);
    try {
      final mode = await _getNetworkMode();
      state = state.copyWith(mode: mode, isLoading: false, errorMessage: () => null);
    } catch (e) {
      state = state.copyWith(errorMessage: () => e.toString(), isLoading: false);
    }
  }

  Future<void> updateNetworkMode(NetworkMode mode) async {
    final previousMode = state.mode;
    state = state.copyWith(isLoading: true, errorMessage: () => null);
    try {
      // Handle mode-specific logic
      if (mode == NetworkMode.lanOnly) {
        // Enable LAN only mode through the LAN provider
        await ref.read(lanOnlyProvider.notifier).enable();

        // Check if enabling failed (e.g., no cable connected)
        final lanState = ref.read(lanOnlyProvider);
        if (lanState.errorMessage != null || !lanState.isActive) {
          final error = lanState.errorMessage ??
              'LAN only mode did not become active. Check ethernet and try again.';
          // Revert to previous mode if LAN mode failed
          state = state.copyWith(
            mode: previousMode,
            isLoading: false,
            errorMessage: () => error,
          );
          log.warning("Failed to enable LAN mode: $error");
          return;
        }
      } else if (state.mode == NetworkMode.lanOnly) {
        // Disable LAN only mode when switching away from it
        await ref.read(lanOnlyProvider.notifier).disable();
      }

      if (mode == NetworkMode.accessPoint) {
        // The access point will be started in the config screen
        // Just set the mode here
        await _setNetworkMode(mode);
      } else {
        await _setNetworkMode(mode);
      }

      state = state.copyWith(mode: mode, isLoading: false, errorMessage: () => null);
      log.info("Network mode updated to ${state.mode}");
    } catch (e) {
      state = state.copyWith(
        mode: previousMode,
        errorMessage: () => e.toString(),
        isLoading: false,
      );
      log.severe("Failed to update network mode: $e");
    }
  }
}

final networkModeProvider =
    NotifierProvider<NetworkModeNotifier, NetworkModeState>(
  NetworkModeNotifier.new,
);
