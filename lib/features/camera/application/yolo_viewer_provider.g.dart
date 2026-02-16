// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'yolo_viewer_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider that streams YOLO detection frames from LCM

@ProviderFor(YoloFrameStream)
const yoloFrameStreamProvider = YoloFrameStreamProvider._();

/// Provider that streams YOLO detection frames from LCM
final class YoloFrameStreamProvider
    extends $NotifierProvider<YoloFrameStream, YoloFrame?> {
  /// Provider that streams YOLO detection frames from LCM
  const YoloFrameStreamProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'yoloFrameStreamProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$yoloFrameStreamHash();

  @$internal
  @override
  YoloFrameStream create() => YoloFrameStream();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(YoloFrame? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<YoloFrame?>(value),
    );
  }
}

String _$yoloFrameStreamHash() => r'f54954d5d18e9fbcd94402f796357a646b2cb2b7';

/// Provider that streams YOLO detection frames from LCM

abstract class _$YoloFrameStream extends $Notifier<YoloFrame?> {
  YoloFrame? build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<YoloFrame?, YoloFrame?>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<YoloFrame?, YoloFrame?>, YoloFrame?, Object?, Object?>;
    element.handleValue(ref, created);
  }
}
