import 'dart:async';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:stpvelox/core/lcm/domain/providers.dart';
import 'package:stpvelox/core/lcm/models/lcm_decoded.dart';
import 'package:stpvelox/core/logging/has_logging.dart';
import 'package:stpvelox/lcm/types/scalar_i32_t.g.dart';

part 'motor_position_sensor.g.dart';

int? useMotorPosition(WidgetRef ref, int port) {
  return ref.watch(motorPositionSensorProvider(port));
}

@riverpod
class MotorPositionSensor extends _$MotorPositionSensor with HasLogger {
  StreamSubscription<LcmDecoded<ScalarI32T>>? _subscription;
  int? _currentValue;

  @override
  int? build(int port) {
    if (port < 0 || port >= 4) return null;

    ref.onDispose(_dispose);
    _startSubscription(port);
    return _currentValue;
  }

  void _startSubscription(int port) {
    final lcm = ref.read(lcmServiceProvider);
    _subscription = lcm
        .subscribeAs<ScalarI32T>(
            'libstp/motor/$port/position', ScalarI32T.decode)
        .listen(
      (decoded) {
        _currentValue = decoded.value.value;
        state = _currentValue;
      },
      onError: (error) {
        log.severe("Error in motor $port position subscription: $error");
      },
    );
  }

  void _dispose() {
    _subscription?.cancel();
    _subscription = null;
  }
}
