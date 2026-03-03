// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'system_health_sensor.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(SystemHealthSensor)
const systemHealthSensorProvider = SystemHealthSensorProvider._();

final class SystemHealthSensorProvider
    extends $NotifierProvider<SystemHealthSensor, SystemHealth> {
  const SystemHealthSensorProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'systemHealthSensorProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$systemHealthSensorHash();

  @$internal
  @override
  SystemHealthSensor create() => SystemHealthSensor();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SystemHealth value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SystemHealth>(value),
    );
  }
}

String _$systemHealthSensorHash() =>
    r'e5f32ecbe807a2fc8947ac153e4e3bf56ac4c972';

abstract class _$SystemHealthSensor extends $Notifier<SystemHealth> {
  SystemHealth build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<SystemHealth, SystemHealth>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<SystemHealth, SystemHealth>,
        SystemHealth,
        Object?,
        Object?>;
    element.handleValue(ref, created);
  }
}
