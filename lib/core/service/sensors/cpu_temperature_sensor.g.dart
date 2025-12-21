// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cpu_temperature_sensor.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(CpuTemperatureSensor)
const cpuTemperatureSensorProvider = CpuTemperatureSensorProvider._();

final class CpuTemperatureSensorProvider
    extends $NotifierProvider<CpuTemperatureSensor, double?> {
  const CpuTemperatureSensorProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'cpuTemperatureSensorProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$cpuTemperatureSensorHash();

  @$internal
  @override
  CpuTemperatureSensor create() => CpuTemperatureSensor();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(double? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<double?>(value),
    );
  }
}

String _$cpuTemperatureSensorHash() =>
    r'5bc578b5acbd214ef2990cebdbeb3008c817930d';

abstract class _$CpuTemperatureSensor extends $Notifier<double?> {
  double? build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<double?, double?>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<double?, double?>, double?, Object?, Object?>;
    element.handleValue(ref, created);
  }
}
