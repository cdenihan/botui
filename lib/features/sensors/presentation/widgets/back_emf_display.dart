import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:stpvelox/core/service/sensors/back_emf_sensor.dart';

class BackEmfDisplay extends HookConsumerWidget {
  final int port;

  const BackEmfDisplay({
    super.key,
    required this.port,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final backEmfValue = useBackEmfValue(ref, port);

    return Column(
      children: [
        Text(
          (backEmfValue ?? 0.0).toStringAsFixed(2),
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Back-EMF',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
}
