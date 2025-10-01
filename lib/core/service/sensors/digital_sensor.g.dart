// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'digital_sensor.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$digitalSensorHash() => r'617f03eb89e00af4375ac37a4bd9d5183da26263';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

abstract class _$DigitalSensor extends BuildlessAutoDisposeNotifier<bool?> {
  late final int bit;

  bool? build(
    int bit,
  );
}

/// See also [DigitalSensor].
@ProviderFor(DigitalSensor)
const digitalSensorProvider = DigitalSensorFamily();

/// See also [DigitalSensor].
class DigitalSensorFamily extends Family<bool?> {
  /// See also [DigitalSensor].
  const DigitalSensorFamily();

  /// See also [DigitalSensor].
  DigitalSensorProvider call(
    int bit,
  ) {
    return DigitalSensorProvider(
      bit,
    );
  }

  @override
  DigitalSensorProvider getProviderOverride(
    covariant DigitalSensorProvider provider,
  ) {
    return call(
      provider.bit,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'digitalSensorProvider';
}

/// See also [DigitalSensor].
class DigitalSensorProvider
    extends AutoDisposeNotifierProviderImpl<DigitalSensor, bool?> {
  /// See also [DigitalSensor].
  DigitalSensorProvider(
    int bit,
  ) : this._internal(
          () => DigitalSensor()..bit = bit,
          from: digitalSensorProvider,
          name: r'digitalSensorProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$digitalSensorHash,
          dependencies: DigitalSensorFamily._dependencies,
          allTransitiveDependencies:
              DigitalSensorFamily._allTransitiveDependencies,
          bit: bit,
        );

  DigitalSensorProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.bit,
  }) : super.internal();

  final int bit;

  @override
  bool? runNotifierBuild(
    covariant DigitalSensor notifier,
  ) {
    return notifier.build(
      bit,
    );
  }

  @override
  Override overrideWith(DigitalSensor Function() create) {
    return ProviderOverride(
      origin: this,
      override: DigitalSensorProvider._internal(
        () => create()..bit = bit,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        bit: bit,
      ),
    );
  }

  @override
  AutoDisposeNotifierProviderElement<DigitalSensor, bool?> createElement() {
    return _DigitalSensorProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is DigitalSensorProvider && other.bit == bit;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, bit.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin DigitalSensorRef on AutoDisposeNotifierProviderRef<bool?> {
  /// The parameter `bit` of this provider.
  int get bit;
}

class _DigitalSensorProviderElement
    extends AutoDisposeNotifierProviderElement<DigitalSensor, bool?>
    with DigitalSensorRef {
  _DigitalSensorProviderElement(super.provider);

  @override
  int get bit => (origin as DigitalSensorProvider).bit;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
