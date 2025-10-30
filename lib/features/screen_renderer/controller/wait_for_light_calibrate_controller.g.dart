// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wait_for_light_calibrate_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(WaitForLightCalibrateController)
const waitForLightCalibrateControllerProvider =
    WaitForLightCalibrateControllerProvider._();

final class WaitForLightCalibrateControllerProvider extends $NotifierProvider<
    WaitForLightCalibrateController, WaitForLightCalibrateState> {
  const WaitForLightCalibrateControllerProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'waitForLightCalibrateControllerProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$waitForLightCalibrateControllerHash();

  @$internal
  @override
  WaitForLightCalibrateController create() => WaitForLightCalibrateController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(WaitForLightCalibrateState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<WaitForLightCalibrateState>(value),
    );
  }
}

String _$waitForLightCalibrateControllerHash() =>
    r'c77bf8c5a5b30fb80c554fd2261db7755955736b';

abstract class _$WaitForLightCalibrateController
    extends $Notifier<WaitForLightCalibrateState> {
  WaitForLightCalibrateState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref
        as $Ref<WaitForLightCalibrateState, WaitForLightCalibrateState>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<WaitForLightCalibrateState, WaitForLightCalibrateState>,
        WaitForLightCalibrateState,
        Object?,
        Object?>;
    element.handleValue(ref, created);
  }
}
