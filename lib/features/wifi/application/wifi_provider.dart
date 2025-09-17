import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stpvelox/features/wifi/application/access_point_notifier.dart';
import 'package:stpvelox/features/wifi/data/datasource/linux_network_manager.dart';
import 'package:stpvelox/features/wifi/data/repositories/wifi_repository_impl.dart';
import 'package:stpvelox/features/wifi/domain/application/access_point_state.dart';
import 'package:stpvelox/features/wifi/domain/repositories/i_wifi_repository.dart';
import 'package:stpvelox/features/wifi/domain/usecases/forget_wifi.dart';
import 'package:stpvelox/features/wifi/domain/usecases/manage_access_point.dart';
import 'package:stpvelox/features/wifi/usecases/get_network_mode.dart';
import 'package:stpvelox/features/wifi/usecases/get_available_networks.dart';
import 'package:stpvelox/features/wifi/usecases/connect_to_wifi.dart';
import 'package:stpvelox/features/settings/usecases/get_device_info.dart';
import 'package:stpvelox/features/settings/domain/usecases/manage_saved_networks.dart';
import 'package:stpvelox/features/settings/domain/usecases/set_network_mode.dart';

final linuxNetworkManagerProvider =
    Provider<LinuxNetworkManager>((ref) => LinuxNetworkManager());

final wifiRepositoryProvider = Provider<IWifiRepository>((ref) =>
    WifiRepositoryImpl(networkManager: ref.watch(linuxNetworkManagerProvider)));

final forgetWifiProvider = Provider<ForgetWifi>(
    (ref) => ForgetWifi(repository: ref.watch(wifiRepositoryProvider)));

final accessPointProvider = StateNotifierProvider<AccessPointNotifier, AccessPointState>((ref) {
    return AccessPointNotifier(ref.watch(manageAccessPointProvider));
});

final manageAccessPointProvider = Provider<ManageAccessPoint>(
    (ref) => ManageAccessPoint(ref.watch(wifiRepositoryProvider)));

final getNetworkModeProvider = Provider<GetNetworkMode>(
    (ref) => GetNetworkMode(ref.watch(wifiRepositoryProvider)));

final getAvailableNetworksProvider = Provider<GetAvailableNetworks>(
    (ref) => GetAvailableNetworks(repository: ref.watch(wifiRepositoryProvider)));

final connectToWifiProvider = Provider<ConnectToWifi>(
    (ref) => ConnectToWifi(repository: ref.watch(wifiRepositoryProvider)));

final getDeviceInfoProvider = Provider<GetDeviceInfo>(
    (ref) => GetDeviceInfo(repository: ref.watch(wifiRepositoryProvider)));

final manageSavedNetworksProvider = Provider<ManageSavedNetworks>(
    (ref) => ManageSavedNetworks(ref.watch(wifiRepositoryProvider)));

final setNetworkModeProvider = Provider<SetNetworkMode>(
    (ref) => SetNetworkMode(ref.watch(wifiRepositoryProvider)));
