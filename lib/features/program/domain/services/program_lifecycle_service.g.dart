// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'program_lifecycle_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ProgramLifecycleService)
const programLifecycleServiceProvider = ProgramLifecycleServiceProvider._();

final class ProgramLifecycleServiceProvider
    extends $NotifierProvider<ProgramLifecycleService, ProgramSession?> {
  const ProgramLifecycleServiceProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'programLifecycleServiceProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$programLifecycleServiceHash();

  @$internal
  @override
  ProgramLifecycleService create() => ProgramLifecycleService();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ProgramSession? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ProgramSession?>(value),
    );
  }
}

String _$programLifecycleServiceHash() =>
    r'2946c2bf5e2a870970e822b9713cbc814870220c';

abstract class _$ProgramLifecycleService extends $Notifier<ProgramSession?> {
  ProgramSession? build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<ProgramSession?, ProgramSession?>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<ProgramSession?, ProgramSession?>,
        ProgramSession?,
        Object?,
        Object?>;
    element.handleValue(ref, created);
  }
}
