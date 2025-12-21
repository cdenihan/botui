// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'black_white_calibrate_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(BlackWhiteCalibrateController)
const blackWhiteCalibrateControllerProvider =
    BlackWhiteCalibrateControllerProvider._();

final class BlackWhiteCalibrateControllerProvider extends $NotifierProvider<
    BlackWhiteCalibrateController, BlackWhiteCalibrateState> {
  const BlackWhiteCalibrateControllerProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'blackWhiteCalibrateControllerProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$blackWhiteCalibrateControllerHash();

  @$internal
  @override
  BlackWhiteCalibrateController create() => BlackWhiteCalibrateController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(BlackWhiteCalibrateState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<BlackWhiteCalibrateState>(value),
    );
  }
}

String _$blackWhiteCalibrateControllerHash() =>
    r'c9ffa664941baf066d51ac36ebdb678236a600a8';

abstract class _$BlackWhiteCalibrateController
    extends $Notifier<BlackWhiteCalibrateState> {
  BlackWhiteCalibrateState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref =
        this.ref as $Ref<BlackWhiteCalibrateState, BlackWhiteCalibrateState>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<BlackWhiteCalibrateState, BlackWhiteCalibrateState>,
        BlackWhiteCalibrateState,
        Object?,
        Object?>;
    element.handleValue(ref, created);
  }
}
