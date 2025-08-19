import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stpvelox/domain/entities/saved_network.dart';
import 'package:stpvelox/domain/usecases/connect_to_wifi.dart';
import 'package:stpvelox/domain/usecases/forget_wifi.dart';
import 'package:stpvelox/domain/usecases/get_available_networks.dart';
import 'package:stpvelox/domain/usecases/get_device_info.dart';
import 'package:stpvelox/domain/usecases/manage_saved_networks.dart';
import 'package:stpvelox/presentation/blocs/settings/wifi/client/wifi_client_event.dart';
import 'package:stpvelox/presentation/blocs/settings/wifi/client/wifi_client_state.dart';

class WifiClientBloc extends Bloc<WifiClientEvent, WifiClientState> {
  final GetAvailableNetworks getAvailableNetworks;
  final ConnectToWifi connectToWifi;
  final ForgetWifi forgetWifi;
  final GetDeviceInfo getDeviceInfo;
  final ManageSavedNetworks manageSavedNetworks;

  WifiClientBloc({
    required this.getAvailableNetworks,
    required this.connectToWifi,
    required this.forgetWifi,
    required this.getDeviceInfo,
    required this.manageSavedNetworks,
  }) : super(WifiClientInitialState()) {
    on<LoadNetworksEvent>(_onLoadNetworks);
    on<ConnectToNetworkEvent>(_onConnectToNetwork);
    on<ForgetNetworkEvent>(_onForgetNetwork);
    on<LoadDeviceInfoEvent>(_onLoadDeviceInfo);
  }

  Future<void> _onLoadNetworks(
      LoadNetworksEvent event, Emitter<WifiClientState> emit) async {
    emit(WifiClientLoadingState());
    try {
      final networks = await getAvailableNetworks();
      emit(WifiClientLoadedState(networks));
    } catch (e) {
      emit(WifiClientErrorState(e.toString()));
    }
  }

  Future<void> _onConnectToNetwork(
      ConnectToNetworkEvent event, Emitter<WifiClientState> emit) async {
    emit(WifiClientConnectingState());
    try {
      await connectToWifi(event.ssid, event.encryptionType, event.credentials);

      final savedNetwork = SavedNetwork(
        ssid: event.ssid,
        encryptionType: event.encryptionType,
        credentials: event.credentials,
        lastConnected: DateTime.now(),
      );
      await manageSavedNetworks.saveNetwork(savedNetwork);

      emit(WifiClientConnectedState(event.ssid));

      final networks = await getAvailableNetworks();
      emit(WifiClientLoadedState(networks));
      add(LoadDeviceInfoEvent());
    } catch (e) {
      emit(WifiClientErrorState(e.toString()));
    }
  }

  Future<void> _onForgetNetwork(
      ForgetNetworkEvent event, Emitter<WifiClientState> emit) async {
    emit(WifiClientForgettingState());
    try {
      await forgetWifi(event.ssid);
      emit(WifiClientForgottenState(event.ssid));

      final networks = await getAvailableNetworks();
      emit(WifiClientLoadedState(networks));
      add(LoadDeviceInfoEvent());
    } catch (e) {
      emit(WifiClientErrorState(e.toString()));
    }
  }

  Future<void> _onLoadDeviceInfo(
      LoadDeviceInfoEvent event, Emitter<WifiClientState> emit) async {
    try {
      final deviceInfo = await getDeviceInfo();
      emit(DeviceInfoLoadedState(deviceInfo));
    } catch (e) {
      emit(WifiClientErrorState(e.toString()));
    }
  }
}
