import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:stpvelox/features/sensors/presentation/utils/sensor_strategy_factory.dart';
import 'package:stpvelox/features/sensors/domain/entities/sensor_type.dart';

class SensorValueWidget extends StatelessWidget {
  final int port;
  final String sensorType;
  final WidgetRef ref;

  const SensorValueWidget({
    super.key,
    required this.port,
    this.sensorType = 'analog',
    required this.ref,
  });

  @override
  Widget build(BuildContext context) {
    final type = sensorType == 'digital' ? SensorType.digital : SensorType.analog;
    final strategy = SensorStrategyFactory.createStrategy(type);
    final reading = strategy.readValue(ref, port) ?? 0.0;

    return Text(
      reading.toStringAsFixed(0),
      style: TextStyle(
        fontSize: 48,
        fontWeight: FontWeight.bold,
        color: Colors.blue.shade300,
      ),
    );
  }
}
