// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'motor_power_sensor.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(MotorPowerSensor)
const motorPowerSensorProvider = MotorPowerSensorFamily._();

final class MotorPowerSensorProvider
    extends $NotifierProvider<MotorPowerSensor, int?> {
  const MotorPowerSensorProvider._(
      {required MotorPowerSensorFamily super.from, required int super.argument})
      : super(
          retry: null,
          name: r'motorPowerSensorProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$motorPowerSensorHash();

  @override
  String toString() {
    return r'motorPowerSensorProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  MotorPowerSensor create() => MotorPowerSensor();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int?>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is MotorPowerSensorProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$motorPowerSensorHash() => r'61986c9f6112b991df87310b39888b26ba81f579';

final class MotorPowerSensorFamily extends $Family
    with $ClassFamilyOverride<MotorPowerSensor, int?, int?, int?, int> {
  const MotorPowerSensorFamily._()
      : super(
          retry: null,
          name: r'motorPowerSensorProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  MotorPowerSensorProvider call(
    int port,
  ) =>
      MotorPowerSensorProvider._(argument: port, from: this);

  @override
  String toString() => r'motorPowerSensorProvider';
}

abstract class _$MotorPowerSensor extends $Notifier<int?> {
  late final _$args = ref.$arg as int;
  int get port => _$args;

  int? build(
    int port,
  );
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build(
      _$args,
    );
    final ref = this.ref as $Ref<int?, int?>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<int?, int?>, int?, Object?, Object?>;
    element.handleValue(ref, created);
  }
}
