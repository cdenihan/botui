import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stpvelox/domain/entities/access_point_config.dart';
import 'package:stpvelox/domain/usecases/manage_access_point.dart';
import 'package:stpvelox/presentation/blocs/settings/wifi/access_point/access_point_event.dart';
import 'package:stpvelox/presentation/blocs/settings/wifi/access_point/access_point_state.dart';

class AccessPointBloc extends Bloc<AccessPointEvent, AccessPointState> {
  final ManageAccessPoint manageAccessPoint;

  AccessPointBloc({
    required this.manageAccessPoint,
  }) : super(AccessPointInitialState()) {
    on<StartAccessPointEvent>(_onStartAccessPoint);
    on<StopAccessPointEvent>(_onStopAccessPoint);
    on<LoadAccessPointConfigEvent>(_onLoadAccessPointConfig);
    on<StartAccessPointWithLastConfigEvent>(_onStartAccessPointWithLastConfig);
  }

  Future<void> _onStartAccessPoint(
      StartAccessPointEvent event, Emitter<AccessPointState> emit) async {
    emit(AccessPointLoadingState());
    try {
      await manageAccessPoint.startAccessPoint(event.config);
      emit(AccessPointStartedState(event.config));
    } catch (e) {
      emit(AccessPointErrorState(e.toString()));
    }
  }

  Future<void> _onStopAccessPoint(
      StopAccessPointEvent event, Emitter<AccessPointState> emit) async {
    emit(AccessPointLoadingState());
    try {
      await manageAccessPoint.stopAccessPoint();
      emit(AccessPointStoppedState());
    } catch (e) {
      emit(AccessPointErrorState(e.toString()));
    }
  }

  Future<void> _onLoadAccessPointConfig(
      LoadAccessPointConfigEvent event, Emitter<AccessPointState> emit) async {
    emit(AccessPointLoadingState());
    try {
      final config = await manageAccessPoint.getAccessPointConfig();
      emit(AccessPointLoadedState(config));
    } catch (e) {
      emit(AccessPointErrorState(e.toString()));
    }
  }

  Future<void> _onStartAccessPointWithLastConfig(
      StartAccessPointWithLastConfigEvent event,
      Emitter<AccessPointState> emit) async {
    emit(AccessPointLoadingState());
    try {
      final config = await manageAccessPoint.getAccessPointConfig();
      if (config != null) {
        await manageAccessPoint.startAccessPoint(config);
        emit(AccessPointStartedState(config));
      } else {
        final defaultBand = await manageAccessPoint.findBestWifiBand();
        final defaultConfig = AccessPointConfig(
          ssid: 'STP-Velox-Robot',
          password: 'Robot123!',
          band: defaultBand,
        );
        await manageAccessPoint.startAccessPoint(defaultConfig);
        emit(AccessPointStartedState(defaultConfig));
      }
    } catch (e) {
      emit(AccessPointErrorState(e.toString()));
    }
  }
}
