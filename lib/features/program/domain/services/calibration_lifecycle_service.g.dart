// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'calibration_lifecycle_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(CalibrationLifecycleService)
const calibrationLifecycleServiceProvider =
    CalibrationLifecycleServiceProvider._();

final class CalibrationLifecycleServiceProvider extends $NotifierProvider<
    CalibrationLifecycleService, CalibrationSession?> {
  const CalibrationLifecycleServiceProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'calibrationLifecycleServiceProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$calibrationLifecycleServiceHash();

  @$internal
  @override
  CalibrationLifecycleService create() => CalibrationLifecycleService();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CalibrationSession? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CalibrationSession?>(value),
    );
  }
}

String _$calibrationLifecycleServiceHash() =>
    r'38e08f4591f1a43749125d86dee6f7b57d0b4fe6';

abstract class _$CalibrationLifecycleService
    extends $Notifier<CalibrationSession?> {
  CalibrationSession? build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<CalibrationSession?, CalibrationSession?>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<CalibrationSession?, CalibrationSession?>,
        CalibrationSession?,
        Object?,
        Object?>;
    element.handleValue(ref, created);
  }
}
