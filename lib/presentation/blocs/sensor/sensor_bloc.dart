import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:stpvelox/domain/entities/sensor.dart';
import 'package:stpvelox/domain/usecases/get_sensors.dart';

part 'sensor_event.dart';
part 'sensor_state.dart';

class SensorBloc extends Bloc<SensorEvent, SensorState> {
  final GetSensors getSensors;

  SensorBloc({required this.getSensors}) : super(SensorInitial()) {
    on<LoadSensorsEvent>((event, emit) async {
      emit(SensorLoading());
      try {
        final sensors = await getSensors.execute();
        final categories = sensors.map((sensor) => sensor.category).toSet().toList();
        final expanded = List<bool>.filled(categories.length, false);
        emit(SensorLoaded(sensors: sensors, expandedSensors: expanded));
      } catch (e) {
        emit(SensorError(message: e.toString()));
      }
    });

    on<ExpandSensorEvent>((event, emit) {
      final state = this.state as SensorLoaded;
      final categories = state.sensors.map((sensor) => sensor.category).toSet().toList();
      final expanded = List<bool>.filled(categories.length, false);
      expanded[event.index] = true;
      emit(SensorLoaded(sensors: state.sensors, expandedSensors: expanded));
    });
  }
}
