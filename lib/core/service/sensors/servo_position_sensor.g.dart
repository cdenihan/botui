// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'servo_position_sensor.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ServoPositionSensor)
const servoPositionSensorProvider = ServoPositionSensorFamily._();

final class ServoPositionSensorProvider
    extends $NotifierProvider<ServoPositionSensor, int?> {
  const ServoPositionSensorProvider._(
      {required ServoPositionSensorFamily super.from,
      required int super.argument})
      : super(
          retry: null,
          name: r'servoPositionSensorProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$servoPositionSensorHash();

  @override
  String toString() {
    return r'servoPositionSensorProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  ServoPositionSensor create() => ServoPositionSensor();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int?>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is ServoPositionSensorProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$servoPositionSensorHash() =>
    r'997be2ee47856c58d89cb173141b1b67705bf2c8';

final class ServoPositionSensorFamily extends $Family
    with $ClassFamilyOverride<ServoPositionSensor, int?, int?, int?, int> {
  const ServoPositionSensorFamily._()
      : super(
          retry: null,
          name: r'servoPositionSensorProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  ServoPositionSensorProvider call(
    int port,
  ) =>
      ServoPositionSensorProvider._(argument: port, from: this);

  @override
  String toString() => r'servoPositionSensorProvider';
}

abstract class _$ServoPositionSensor extends $Notifier<int?> {
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
