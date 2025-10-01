// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reboot.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(rebootDevice)
const rebootDeviceProvider = RebootDeviceProvider._();

final class RebootDeviceProvider
    extends $FunctionalProvider<RebootDevice, RebootDevice, RebootDevice>
    with $Provider<RebootDevice> {
  const RebootDeviceProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'rebootDeviceProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$rebootDeviceHash();

  @$internal
  @override
  $ProviderElement<RebootDevice> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  RebootDevice create(Ref ref) {
    return rebootDevice(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(RebootDevice value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<RebootDevice>(value),
    );
  }
}

String _$rebootDeviceHash() => r'd31a4205a63a1b82ee5d9494c97ef2175d73d37d';
