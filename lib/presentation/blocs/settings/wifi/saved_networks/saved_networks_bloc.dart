import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stpvelox/domain/usecases/connect_to_wifi.dart';
import 'package:stpvelox/domain/usecases/manage_saved_networks.dart';
import 'package:stpvelox/presentation/blocs/settings/wifi/saved_networks/saved_networks_event.dart';
import 'package:stpvelox/presentation/blocs/settings/wifi/saved_networks/saved_networks_state.dart';

class SavedNetworksBloc extends Bloc<SavedNetworksEvent, SavedNetworksState> {
  final ManageSavedNetworks manageSavedNetworks;
  final ConnectToWifi connectToWifi;

  SavedNetworksBloc({
    required this.manageSavedNetworks,
    required this.connectToWifi,
  }) : super(SavedNetworksInitialState()) {
    on<LoadSavedNetworksEvent>(_onLoadSavedNetworks);
    on<RemoveSavedNetworkEvent>(_onRemoveSavedNetwork);
    on<ConnectToSavedNetworkEvent>(_onConnectToSavedNetwork);
  }

  Future<void> _onLoadSavedNetworks(
      LoadSavedNetworksEvent event, Emitter<SavedNetworksState> emit) async {
    emit(SavedNetworksLoadingState());
    try {
      final networks = await manageSavedNetworks.getSavedNetworks();
      emit(SavedNetworksLoadedState(networks));
    } catch (e) {
      emit(SavedNetworksErrorState(e.toString()));
    }
  }

  Future<void> _onRemoveSavedNetwork(
      RemoveSavedNetworkEvent event, Emitter<SavedNetworksState> emit) async {
    try {
      await manageSavedNetworks.removeSavedNetwork(event.ssid);
      add(LoadSavedNetworksEvent());
    } catch (e) {
      emit(SavedNetworksErrorState(e.toString()));
    }
  }

  Future<void> _onConnectToSavedNetwork(
      ConnectToSavedNetworkEvent event, Emitter<SavedNetworksState> emit) async {
    emit(SavedNetworksLoadingState());
    try {
      final savedNetwork = await manageSavedNetworks.getSavedNetwork(event.ssid);
      if (savedNetwork != null) {
        await connectToWifi(savedNetwork.ssid, savedNetwork.encryptionType, savedNetwork.credentials);
        final updatedNetwork = savedNetwork.copyWith(lastConnected: DateTime.now());
        await manageSavedNetworks.saveNetwork(updatedNetwork);
        add(LoadSavedNetworksEvent());
      } else {
        emit(SavedNetworksErrorState('Saved network not found'));
      }
    } catch (e) {
      emit(SavedNetworksErrorState(e.toString()));
    }
  }
}