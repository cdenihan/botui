import 'dart:async';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:stpvelox/core/lcm/domain/providers.dart';
import 'package:stpvelox/core/lcm/models/lcm_decoded.dart';
import 'package:stpvelox/core/logging/has_logging.dart';
import 'package:stpvelox/core/service/sensors/sensor_reading_strategy.dart';
import 'package:stpvelox/lcm/types/vector3f_t.lcm.g.dart';

part 'accelerometer_sensor.g.dart';


Vector3fT? useAccelerometer(WidgetRef ref) {
  return ref.watch(accelerometerSensorProvider);
}

@riverpod
class AccelerometerSensor extends _$AccelerometerSensor with HasLogger {
  StreamSubscription<LcmDecoded<Vector3fT>>? _subscription;
  Vector3fT? _currentValue;

  @override
  Vector3fT? build() {
    ref.onDispose(_dispose);
    _startSubscription();
    return _currentValue;
  }

  void _startSubscription() {
    final lcm = ref.read(lcmServiceProvider);
    _subscription = lcm
        .subscribeAs<Vector3fT>('libstp/accel/value', Vector3fT.decode)
        .listen(
          (decoded) {
        _currentValue = decoded.value;
        state = _currentValue;
      },
      onError: (error) {
        log.severe('Error in accelerometer subscription: $error');
      },
    );
  }

  void _dispose() {
    _subscription?.cancel();
    _subscription = null;
  }
}

/// Strategy for reading accelerometer X-axis values
class AccelXSensorReadingStrategy extends SensorReadingStrategy {
  @override
  double? readValue(WidgetRef ref, int? port) {
    return useAccelerometer(ref)?.x;
  }
}

/// Strategy for reading accelerometer Y-axis values
class AccelYSensorReadingStrategy extends SensorReadingStrategy {
  @override
  double? readValue(WidgetRef ref, int? port) {
    return useAccelerometer(ref)?.y;
  }
}

/// Strategy for reading accelerometer Z-axis values
class AccelZSensorReadingStrategy extends SensorReadingStrategy {
  @override
  double? readValue(WidgetRef ref, int? port) {
    return useAccelerometer(ref)?.z;
  }
}
