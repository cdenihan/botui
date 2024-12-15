part of 'sensor_bloc.dart';

abstract class SensorEvent extends Equatable {
  const SensorEvent();

  @override
  List<Object> get props => [];
}

class LoadSensorsEvent extends SensorEvent {}

class ExpandSensorEvent extends SensorEvent {
  final int index;

  const ExpandSensorEvent({required this.index});

  @override
  List<Object> get props => [index];
}