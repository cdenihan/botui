// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'button10_monitor.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Monitors button 10 for long presses:
/// - 3 seconds: Opens Dev Menu

@ProviderFor(Button10Monitor)
const button10MonitorProvider = Button10MonitorProvider._();

/// Monitors button 10 for long presses:
/// - 3 seconds: Opens Dev Menu
final class Button10MonitorProvider
    extends $NotifierProvider<Button10Monitor, void> {
  /// Monitors button 10 for long presses:
  /// - 3 seconds: Opens Dev Menu
  const Button10MonitorProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'button10MonitorProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$button10MonitorHash();

  @$internal
  @override
  Button10Monitor create() => Button10Monitor();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$button10MonitorHash() => r'a9ec39d3750f90b4037335b442c5c5f135f7bcfa';

/// Monitors button 10 for long presses:
/// - 3 seconds: Opens Dev Menu

abstract class _$Button10Monitor extends $Notifier<void> {
  void build();
  @$mustCallSuper
  @override
  void runBuild() {
    build();
    final ref = this.ref as $Ref<void, void>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<void, void>, void, Object?, Object?>;
    element.handleValue(ref, null);
  }
}
