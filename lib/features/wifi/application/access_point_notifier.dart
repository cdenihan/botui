import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stpvelox/features/wifi/application/wifi_provider.dart';
import 'package:stpvelox/features/wifi/domain/application/access_point_state.dart';
import 'package:stpvelox/features/wifi/domain/enities/access_point_config.dart';
import 'package:stpvelox/features/wifi/domain/usecases/manage_access_point.dart';

class AccessPointNotifier extends StateNotifier<AccessPointState> {
  final ManageAccessPoint manageAccessPoint;

  AccessPointNotifier(this.manageAccessPoint) : super(AccessPointState());

  Future<bool> isStarted() async {
    try {
      return await manageAccessPoint.isAccessPointActive();
    } catch (e) {
      state.errorMessage = e.toString();
      return false;
    }
  }

  Future<void> startAccessPoint(AccessPointConfig config) async {
    state.isLoading = true;
    try {
      await manageAccessPoint.startAccessPoint(config);
      state.config = config;
      state.isLoading = false;
    } catch (e) {
      state.errorMessage = e.toString();
    }
  }

  Future<void> stopAccessPoint() async {
    state.isLoading = true;
    try {
      await manageAccessPoint.stopAccessPoint();
      state.isStarted = false;
    } catch (e) {
      state.errorMessage = e.toString();
    }
  }

  Future<void> loadAccessPointConfig() async {
    state.isLoading = true;
    try {
      final config = await manageAccessPoint.getAccessPointConfig();
      state.config = config;
      state.isLoading = false;
    } catch (e) {
      state.errorMessage = e.toString();
    }
  }

  Future<void> startAccessPointWithLastConfig() async {
    state.isLoading = true;
    try {
      final config = await manageAccessPoint.getAccessPointConfig();
      if (config != null) {
        await manageAccessPoint.startAccessPoint(config);
        state.config = config;
        state.isLoading = false;
      } else {
        final defaultBand = await manageAccessPoint.findBestWifiBand();
        final defaultConfig = AccessPointConfig(
          ssid: 'STP-Velox-Robot',
          password: 'Robot123!',
          band: defaultBand,
        );
        await manageAccessPoint.startAccessPoint(defaultConfig);
        state.isStarted = true;
        state.config = defaultConfig;
      }
    } catch (e) {
      state.errorMessage = e.toString();
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

// Provider
final accessPointProvider =
StateNotifierProvider<AccessPointNotifier, AccessPointState>(
      (ref) => AccessPointNotifier(ref.read(manageAccessPointProvider)),
);
