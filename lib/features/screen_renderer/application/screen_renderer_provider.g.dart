// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'screen_renderer_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ScreenRenderProvider)
const screenRenderProviderProvider = ScreenRenderProviderProvider._();

final class ScreenRenderProviderProvider
    extends $NotifierProvider<ScreenRenderProvider, Widget?> {
  const ScreenRenderProviderProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'screenRenderProviderProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$screenRenderProviderHash();

  @$internal
  @override
  ScreenRenderProvider create() => ScreenRenderProvider();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Widget? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Widget?>(value),
    );
  }
}

String _$screenRenderProviderHash() =>
    r'76f22b9c1367996cb838de1de55e7f14382b75ea';

abstract class _$ScreenRenderProvider extends $Notifier<Widget?> {
  Widget? build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<Widget?, Widget?>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<Widget?, Widget?>, Widget?, Object?, Object?>;
    element.handleValue(ref, created);
  }
}
