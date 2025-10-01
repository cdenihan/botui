import 'package:hooks_riverpod/hooks_riverpod.dart';

/// Strategy pattern interface for reading sensor values
/// Each sensor type should implement this to provide a uniform reading interface
abstract class SensorReadingStrategy {
  /// Reads the current sensor value and returns it as a double
  /// Returns null if the sensor is not available or has no data
  double? readValue(WidgetRef ref, int? port);
}