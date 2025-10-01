import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:stpvelox/core/service/sensors/temperature_sensor.dart';

class ImuTemperatureDisplay extends HookConsumerWidget {
  const ImuTemperatureDisplay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final temperature = useTemperature(ref);
    if (temperature == null) {
      return const SizedBox.shrink();
    }

    final color = temperature < 20
        ? Colors.blue
        : (temperature < 30 ? Colors.green : Colors.red);

    return Row(
      children: [
        Icon(
          Icons.thermostat,
          color: color,
          size: 40,
        ),
        const SizedBox(width: 8),
        Text('${temperature.toStringAsFixed(1)}°C'),
      ],
    );
  }
}
