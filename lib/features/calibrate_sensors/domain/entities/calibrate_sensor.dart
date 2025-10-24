
import 'package:flutter/cupertino.dart';
import 'package:stpvelox/features/calibrate_sensors/domain/entities/calibration_sensor_type.dart';

class CalibrateSensor{
  final String name;
  final String state;
  final CalibrationSensorType sensorType;
  final Widget Function(CalibrateSensor) getWidgetScreen;

  CalibrateSensor({
    required this.name,
    required this.state,
    required this.sensorType,
    required this.getWidgetScreen
  });

  Widget get screen => getWidgetScreen(this);
}