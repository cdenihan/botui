import 'dart:async';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:stpvelox/core/lcm/domain/providers.dart';
import 'package:stpvelox/core/lcm/models/lcm_decoded.dart';
import 'package:stpvelox/core/logging/has_logging.dart';
import 'package:stpvelox/core/service/sensors/sensor_reading_strategy.dart';
import 'package:stpvelox/lcm/types/scalar_f_t.lcm.g.dart';

part 'battery_voltage_sensor.g.dart';

double? useBatteryVoltage(WidgetRef ref) {
  return ref.watch(batteryVoltageSensorProvider);
}

@riverpod
class BatteryVoltageSensor extends _$BatteryVoltageSensor with HasLogger {
  StreamSubscription<LcmDecoded<ScalarFT>>? _subscription;
  double? _currentValue;

  @override
  double? build() {
    ref.onDispose(_dispose);
    _startSubscription();
    return _currentValue;
  }

  void _startSubscription() {
    final lcm = ref.read(lcmServiceProvider);
    _subscription = lcm
        .subscribeAs<ScalarFT>('libstp/battery/voltage', ScalarFT.decode)
        .listen(
      (decoded) {
        _currentValue = decoded.value.value;
        state = _currentValue;
      },
      onError: (error) {
        log.severe('Error in battery voltage subscription: $error');
      },
    );
  }

  void _dispose() {
    _subscription?.cancel();
    _subscription = null;
  }
}

/// Strategy for reading battery voltage values
class BatteryVoltageSensorReadingStrategy extends SensorReadingStrategy {
  @override
  double? readValue(WidgetRef ref, int? port) {
    return useBatteryVoltage(ref);
  }
}
