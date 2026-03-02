import 'dart:async';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:stpvelox/core/lcm/domain/providers.dart';
import 'package:stpvelox/core/lcm/models/lcm_decoded.dart';
import 'package:stpvelox/core/logging/has_logging.dart';
import 'package:raccoon_transport/messages/types/scalar_i8_t.g.dart';
import 'package:raccoon_transport/raccoon_transport.dart';

part 'imu_accuracy_sensor.g.dart';

class ImuAccuracy {
  /// Accuracy values: 0 = unreliable, 1 = low, 2 = medium, 3 = high
  /// null means no data received yet
  final int? gyro;
  final int? accel;
  final int? mag;
  final int? quaternion;

  const ImuAccuracy({
    this.gyro,
    this.accel,
    this.mag,
    this.quaternion,
  });

  ImuAccuracy copyWith({
    int? gyro,
    int? accel,
    int? mag,
    int? quaternion,
  }) {
    return ImuAccuracy(
      gyro: gyro ?? this.gyro,
      accel: accel ?? this.accel,
      mag: mag ?? this.mag,
      quaternion: quaternion ?? this.quaternion,
    );
  }
}

ImuAccuracy useImuAccuracy(WidgetRef ref) {
  return ref.watch(imuAccuracySensorProvider);
}

@Riverpod(keepAlive: true)
class ImuAccuracySensor extends _$ImuAccuracySensor with HasLogger {
  StreamSubscription<LcmDecoded<ScalarI8T>>? _gyroSub;
  StreamSubscription<LcmDecoded<ScalarI8T>>? _accelSub;
  StreamSubscription<LcmDecoded<ScalarI8T>>? _magSub;
  StreamSubscription<LcmDecoded<ScalarI8T>>? _quatSub;

  ImuAccuracy _currentValue = const ImuAccuracy();

  @override
  ImuAccuracy build() {
    ref.onDispose(_dispose);
    _startSubscriptions();
    return _currentValue;
  }

  void _startSubscriptions() {
    final lcm = ref.read(lcmServiceProvider);
    log.info('Starting IMU accuracy subscriptions');

    _gyroSub = lcm
        .subscribeAs<ScalarI8T>(Channels.gyroAccuracy, ScalarI8T.decode,
            options: const SubscribeOptions(requestRetained: true))
        .listen(
      (decoded) {
        log.info('Gyro accuracy received: ${decoded.value.dir}');
        _currentValue = _currentValue.copyWith(gyro: decoded.value.dir);
        state = _currentValue;
      },
      onError: (error) {
        log.severe('Error in gyro accuracy subscription: $error');
      },
    );

    _accelSub = lcm
        .subscribeAs<ScalarI8T>(Channels.accelAccuracy, ScalarI8T.decode,
            options: const SubscribeOptions(requestRetained: true))
        .listen(
      (decoded) {
        log.info('Accel accuracy received: ${decoded.value.dir}');
        _currentValue = _currentValue.copyWith(accel: decoded.value.dir);
        state = _currentValue;
      },
      onError: (error) {
        log.severe('Error in accel accuracy subscription: $error');
      },
    );

    _magSub = lcm
        .subscribeAs<ScalarI8T>(Channels.compassAccuracy, ScalarI8T.decode,
            options: const SubscribeOptions(requestRetained: true))
        .listen(
      (decoded) {
        log.info('Mag accuracy received: ${decoded.value.dir}');
        _currentValue = _currentValue.copyWith(mag: decoded.value.dir);
        state = _currentValue;
      },
      onError: (error) {
        log.severe('Error in mag accuracy subscription: $error');
      },
    );

    _quatSub = lcm
        .subscribeAs<ScalarI8T>(
            Channels.quaternionAccuracy, ScalarI8T.decode,
            options: const SubscribeOptions(requestRetained: true))
        .listen(
      (decoded) {
        log.info('Quaternion accuracy received: ${decoded.value.dir}');
        _currentValue = _currentValue.copyWith(quaternion: decoded.value.dir);
        state = _currentValue;
      },
      onError: (error) {
        log.severe('Error in quaternion accuracy subscription: $error');
      },
    );
  }

  void _dispose() {
    _gyroSub?.cancel();
    _accelSub?.cancel();
    _magSub?.cancel();
    _quatSub?.cancel();
    _gyroSub = null;
    _accelSub = null;
    _magSub = null;
    _quatSub = null;
  }
}
