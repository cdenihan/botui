import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:stpvelox/core/service/sensors/imu_accuracy_sensor.dart';

enum AccuracyType { gyro, accel, mag, quaternion }

class ImuAccuracyDisplay extends HookConsumerWidget {
  final AccuracyType? type;

  const ImuAccuracyDisplay({super.key, this.type});

  static Color getAccuracyColor(int? accuracy) {
    if (accuracy == null) return Colors.grey;
    switch (accuracy) {
      case 0:
        return Colors.red;
      case 1:
        return Colors.orange;
      case 2:
        return Colors.yellow;
      case 3:
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  static String getAccuracyLabel(int? accuracy) {
    if (accuracy == null) return '?';
    return accuracy.toString();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accuracy = useImuAccuracy(ref);

    // If a specific type is requested, show only that one
    if (type != null) {
      final value = switch (type!) {
        AccuracyType.gyro => accuracy.gyro,
        AccuracyType.accel => accuracy.accel,
        AccuracyType.mag => accuracy.mag,
        AccuracyType.quaternion => accuracy.quaternion,
      };
      return _AccuracyIndicator(accuracy: value);
    }

    // Otherwise show all (for backwards compatibility)
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _AccuracyIndicatorWithLabel(
          label: 'G',
          accuracy: accuracy.gyro,
          tooltip: 'Gyroscope',
        ),
        const SizedBox(width: 4),
        _AccuracyIndicatorWithLabel(
          label: 'A',
          accuracy: accuracy.accel,
          tooltip: 'Accelerometer',
        ),
        const SizedBox(width: 4),
        _AccuracyIndicatorWithLabel(
          label: 'M',
          accuracy: accuracy.mag,
          tooltip: 'Magnetometer',
        ),
      ],
    );
  }
}

class _AccuracyIndicator extends StatelessWidget {
  final int? accuracy;

  const _AccuracyIndicator({required this.accuracy});

  @override
  Widget build(BuildContext context) {
    final color = ImuAccuracyDisplay.getAccuracyColor(accuracy);
    final text = ImuAccuracyDisplay.getAccuracyLabel(accuracy);

    return Tooltip(
      message: 'Accuracy: ${accuracy ?? "No data"}',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.2),
          border: Border.all(color: color, width: 2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.sensors, color: color, size: 20),
            const SizedBox(width: 6),
            Text(
              text,
              style: TextStyle(
                color: color,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AccuracyIndicatorWithLabel extends StatelessWidget {
  final String label;
  final int? accuracy;
  final String tooltip;

  const _AccuracyIndicatorWithLabel({
    required this.label,
    required this.accuracy,
    required this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final color = ImuAccuracyDisplay.getAccuracyColor(accuracy);
    final text = ImuAccuracyDisplay.getAccuracyLabel(accuracy);

    return Tooltip(
      message: '$tooltip: ${accuracy ?? "No data"}',
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: color.withOpacity(0.2),
          border: Border.all(color: color, width: 2),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Center(
          child: Text(
            '$label$text',
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
