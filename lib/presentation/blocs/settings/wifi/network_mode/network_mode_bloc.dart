import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stpvelox/domain/usecases/get_network_mode.dart';
import 'package:stpvelox/domain/usecases/set_network_mode.dart';
import 'package:stpvelox/presentation/blocs/settings/wifi/network_mode/network_mode_event.dart';
import 'package:stpvelox/presentation/blocs/settings/wifi/network_mode/network_mode_state.dart';

class NetworkModeBloc extends Bloc<NetworkModeEvent, NetworkModeState> {
  final GetNetworkMode getNetworkMode;
  final SetNetworkMode setNetworkMode;

  NetworkModeBloc({
    required this.getNetworkMode,
    required this.setNetworkMode,
  }) : super(NetworkModeInitialState()) {
    on<LoadNetworkModeEvent>(_onLoadNetworkMode);
    on<SetNetworkModeEvent>(_onSetNetworkMode);
  }

  Future<void> _onLoadNetworkMode(
      LoadNetworkModeEvent event, Emitter<NetworkModeState> emit) async {
    emit(NetworkModeLoadingState());
    try {
      final mode = await getNetworkMode();
      emit(NetworkModeLoadedState(mode));
    } catch (e) {
      emit(NetworkModeErrorState(e.toString()));
    }
  }

  Future<void> _onSetNetworkMode(
      SetNetworkModeEvent event, Emitter<NetworkModeState> emit) async {
    emit(NetworkModeLoadingState());
    try {
      await setNetworkMode(event.mode);
      emit(NetworkModeLoadedState(event.mode));
    } catch (e) {
      emit(NetworkModeErrorState(e.toString()));
    }
  }
}
