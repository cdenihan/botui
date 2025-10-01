// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(lcmRepo)
const lcmRepoProvider = LcmRepoProvider._();

final class LcmRepoProvider
    extends $FunctionalProvider<LcmRepo, LcmRepo, LcmRepo>
    with $Provider<LcmRepo> {
  const LcmRepoProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'lcmRepoProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$lcmRepoHash();

  @$internal
  @override
  $ProviderElement<LcmRepo> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  LcmRepo create(Ref ref) {
    return lcmRepo(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LcmRepo value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LcmRepo>(value),
    );
  }
}

String _$lcmRepoHash() => r'8ef0372ad3550d227ed33b20dc06d814b780ce9e';

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

String _$lcmServiceHash() => r'15132580fd79e2f39b0c6a55d6d1313a2621d40a';
