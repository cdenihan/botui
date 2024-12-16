import 'package:flutter/material.dart';
import 'package:stpvelox/domain/entities/sensor.dart';

class SensorServoScreen extends StatelessWidget {
  final int port;
  final Sensor sensor;

  const SensorServoScreen({super.key, required this.port, required this.sensor});

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
