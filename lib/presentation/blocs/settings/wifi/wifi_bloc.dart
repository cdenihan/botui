import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stpvelox/domain/usecases/connect_to_wifi.dart';
import 'package:stpvelox/domain/usecases/forget_wifi.dart';
import 'package:stpvelox/domain/usecases/get_available_networks.dart';
import 'package:stpvelox/domain/usecases/get_device_info.dart';
import 'package:stpvelox/presentation/blocs/settings/wifi/wifi_event.dart';
import 'package:stpvelox/presentation/blocs/settings/wifi/wifi_state.dart';

class WifiBloc extends Bloc<WifiEvent, WifiState> {
  final GetAvailableNetworks getAvailableNetworks;
  final ConnectToWifi connectToWifi;
  final ForgetWifi forgetWifi;
  final GetDeviceInfo getDeviceInfo;

  WifiBloc({
    required this.getAvailableNetworks,
    required this.connectToWifi,
    required this.forgetWifi,
    required this.getDeviceInfo,
  }) : super(WifiInitialState()) {
    on<LoadNetworksEvent>(_onLoadNetworks);
    on<ConnectToNetworkEvent>(_onConnectToNetwork);
    on<ForgetNetworkEvent>(_onForgetNetwork);
    on<LoadDeviceInfoEvent>(_onLoadDeviceInfo);
  }

  Future<void> _onLoadNetworks(LoadNetworksEvent event, Emitter<WifiState> emit) async {
    emit(WifiLoadingState());
    try {
      final networks = await getAvailableNetworks();
      emit(WifiLoadedState(networks));
    } catch (e) {
      emit(WifiErrorState(e.toString()));
    }
  }

  Future<void> _onConnectToNetwork(ConnectToNetworkEvent event, Emitter<WifiState> emit) async {
    emit(WifiConnectingState());
    try {
      await connectToWifi(event.ssid, event.encryptionType, event.credentials);
      emit(WifiConnectedState(event.ssid));
      // Reload networks and device info after connection
      final networks = await getAvailableNetworks();
      emit(WifiLoadedState(networks));
      add(LoadDeviceInfoEvent());
    } catch (e) {
      emit(WifiErrorState(e.toString()));
    }
  }

  Future<void> _onForgetNetwork(ForgetNetworkEvent event, Emitter<WifiState> emit) async {
    emit(WifiForgettingState());
    try {
      await forgetWifi(event.ssid);
      emit(WifiForgottenState(event.ssid));
      // Reload networks and device info after forgetting
      final networks = await getAvailableNetworks();
      emit(WifiLoadedState(networks));
      add(LoadDeviceInfoEvent());
    } catch (e) {
      emit(WifiErrorState(e.toString()));
    }
  }

  Future<void> _onLoadDeviceInfo(LoadDeviceInfoEvent event, Emitter<WifiState> emit) async {
    try {
      final deviceInfo = await getDeviceInfo();
      emit(DeviceInfoLoadedState(deviceInfo));
    } catch (e) {
      emit(WifiErrorState(e.toString()));
    }
  }
}