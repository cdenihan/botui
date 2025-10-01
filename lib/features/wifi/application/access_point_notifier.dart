import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stpvelox/features/wifi/application/wifi_provider.dart';
import 'package:stpvelox/features/wifi/domain/application/access_point_state.dart';
import 'package:stpvelox/features/wifi/domain/enities/access_point_config.dart';
import 'package:stpvelox/features/wifi/domain/usecases/manage_access_point.dart';

class AccessPointNotifier extends Notifier<AccessPointState> {
  late final ManageAccessPoint manageAccessPoint;

  @override
  AccessPointState build() {
    manageAccessPoint = ref.read(manageAccessPointProvider);
    return AccessPointState();
  }

  Future<bool> isStarted() async {
    try {
      return await manageAccessPoint.isAccessPointActive();
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
      return false;
    }
  }

  Future<void> startAccessPoint(AccessPointConfig config) async {
    state = state.copyWith(isLoading: true);
    try {
      await manageAccessPoint.startAccessPoint(config);
      state = state.copyWith(config: config, isLoading: false, isStarted: true);
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString(), isLoading: false);
    }
  }

  Future<void> stopAccessPoint() async {
    state = state.copyWith(isLoading: true);
    try {
      await manageAccessPoint.stopAccessPoint();
      state = state.copyWith(isStarted: false, isLoading: false);
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString(), isLoading: false);
    }
  }

  Future<void> loadAccessPointConfig() async {
    state = state.copyWith(isLoading: true);
    try {
      final config = await manageAccessPoint.getAccessPointConfig();
      state = state.copyWith(config: config, isLoading: false);
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString(), isLoading: false);
    }
  }

  Future<void> startAccessPointWithLastConfig() async {
    state = state.copyWith(isLoading: true);
    try {
      final config = await manageAccessPoint.getAccessPointConfig();
      if (config != null) {
        await manageAccessPoint.startAccessPoint(config);
        state = state.copyWith(config: config, isStarted: true, isLoading: false);
      } else {
        final defaultBand = await manageAccessPoint.findBestWifiBand();
        final defaultConfig = AccessPointConfig(
          ssid: 'STP-Velox-Robot',
          password: 'Robot123!',
          band: defaultBand,
        );
        await manageAccessPoint.startAccessPoint(defaultConfig);
        state = state.copyWith(
          isStarted: true,
          config: defaultConfig,
          isLoading: false,
        );
      }
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString(), isLoading: false);
    }
  }

  // Alias methods for UI compatibility
  Future<void> startHotspot(AccessPointConfig config) async {
    await startAccessPoint(config);
  }

  Future<void> stopHotspot() async {
    await stopAccessPoint();
  }
}
