// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'distance_calibrate_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(DistanceCalibrateController)
const distanceCalibrateControllerProvider =
    DistanceCalibrateControllerProvider._();

final class DistanceCalibrateControllerProvider extends $NotifierProvider<
    DistanceCalibrateController, DistanceCalibrateState> {
  const DistanceCalibrateControllerProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'distanceCalibrateControllerProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$distanceCalibrateControllerHash();

  @$internal
  @override
  DistanceCalibrateController create() => DistanceCalibrateController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DistanceCalibrateState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DistanceCalibrateState>(value),
    );
  }
}

String _$distanceCalibrateControllerHash() =>
    r'ba0f661d2e2ccc890d3b2962eadb3fb812e6601a';

abstract class _$DistanceCalibrateController
    extends $Notifier<DistanceCalibrateState> {
  DistanceCalibrateState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref =
        this.ref as $Ref<DistanceCalibrateState, DistanceCalibrateState>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<DistanceCalibrateState, DistanceCalibrateState>,
        DistanceCalibrateState,
        Object?,
        Object?>;
    element.handleValue(ref, created);
  }
}
