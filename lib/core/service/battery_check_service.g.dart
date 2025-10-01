// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'battery_check_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(BatteryCheckService)
const batteryCheckServiceProvider = BatteryCheckServiceProvider._();

final class BatteryCheckServiceProvider
    extends $NotifierProvider<BatteryCheckService, double?> {
  const BatteryCheckServiceProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'batteryCheckServiceProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$batteryCheckServiceHash();

  @$internal
  @override
  BatteryCheckService create() => BatteryCheckService();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(double? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<double?>(value),
    );
  }
}

String _$batteryCheckServiceHash() =>
    r'13cc226fb9b1e5cac318680bf6d1a797d3f5de8d';

abstract class _$BatteryCheckService extends $Notifier<double?> {
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
