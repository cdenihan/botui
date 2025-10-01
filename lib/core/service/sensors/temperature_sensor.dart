import 'dart:async';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:stpvelox/core/lcm/domain/providers.dart';
import 'package:stpvelox/core/lcm/models/lcm_decoded.dart';
import 'package:stpvelox/core/logging/has_logging.dart';
import 'package:stpvelox/core/service/sensors/sensor_reading_strategy.dart';
import 'package:stpvelox/lcm/types/scalar_f_t.lcm.g.dart';

part 'temperature_sensor.g.dart';

double? useTemperature(WidgetRef ref) {
  return ref.watch(temperatureSensorProvider);
}

@riverpod
class TemperatureSensor extends _$TemperatureSensor with HasLogger {
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
    _subscription =
        lcm.subscribeAs<ScalarFT>('libstp/temp/value', ScalarFT.decode).listen(
              (decoded) {
            _currentValue = decoded.value.value;
            state = _currentValue;
          },
          onError: (error) {
            log.severe('Error in temperature subscription: $error');
          },
        );
  }

  void _dispose() {
    _subscription?.cancel();
    _subscription = null;
  }
}

/// Strategy for reading temperature sensor values
class TemperatureSensorReadingStrategy extends SensorReadingStrategy {
  @override
  double? readValue(WidgetRef ref, int? port) {
    return useTemperature(ref);
  }
}
