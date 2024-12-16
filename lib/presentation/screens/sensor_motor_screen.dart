import 'package:flutter/material.dart';
import 'package:stpvelox/domain/entities/sensor.dart';

class SensorMotorScreen extends StatelessWidget {
  final int port;
  final Sensor sensor;

  const SensorMotorScreen({
    super.key,
    required this.port,
    required this.sensor,
  });

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
