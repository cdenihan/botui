// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(lcmService)
const lcmServiceProvider = LcmServiceProvider._();

final class LcmServiceProvider
    extends $FunctionalProvider<LcmService, LcmService, LcmService>
    with $Provider<LcmService> {
  const LcmServiceProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'lcmServiceProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$lcmServiceHash();

  @$internal
  @override
  $ProviderElement<LcmService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  LcmService create(Ref ref) {
    return lcmService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LcmService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LcmService>(value),
    );
  }
}

String _$lcmServiceHash() => r'1fbe88791bd8819cb6e8d8d7932e09828e587ae3';
