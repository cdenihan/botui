// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gyro_sensor.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(GyroSensor)
const gyroSensorProvider = GyroSensorProvider._();

final class GyroSensorProvider extends $NotifierProvider<GyroSensor, Gyro?> {
  const GyroSensorProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'gyroSensorProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$gyroSensorHash();

  @$internal
  @override
  GyroSensor create() => GyroSensor();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Gyro? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Gyro?>(value),
    );
  }
}

String _$gyroSensorHash() => r'dbfaf0c6410ab50cb6049011ebab0267ab846f6b';

abstract class _$GyroSensor extends $Notifier<Gyro?> {
  Gyro? build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<Gyro?, Gyro?>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<Gyro?, Gyro?>, Gyro?, Object?, Object?>;
    element.handleValue(ref, created);
  }
}
