// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'program_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ProgramSelection)
const programSelectionProvider = ProgramSelectionProvider._();

final class ProgramSelectionProvider
    extends $AsyncNotifierProvider<ProgramSelection, List<Program>> {
  const ProgramSelectionProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'programSelectionProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$programSelectionHash();

  @$internal
  @override
  ProgramSelection create() => ProgramSelection();
}

String _$programSelectionHash() => r'5dc9cf066ade51caddef3e14deeeed383cfd8a2c';

abstract class _$ProgramSelection extends $AsyncNotifier<List<Program>> {
  FutureOr<List<Program>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<AsyncValue<List<Program>>, List<Program>>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<List<Program>>, List<Program>>,
        AsyncValue<List<Program>>,
        Object?,
        Object?>;
    element.handleValue(ref, created);
  }
}
