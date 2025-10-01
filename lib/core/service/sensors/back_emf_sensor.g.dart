// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'back_emf_sensor.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$backEmfSensorHash() => r'fa74261fcf8a1d26aad4c9f57ecb22cac6d30014';

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

abstract class _$BackEmfSensor extends BuildlessAutoDisposeNotifier<int?> {
  late final int port;

  int? build(
    int port,
  );
}

/// See also [BackEmfSensor].
@ProviderFor(BackEmfSensor)
const backEmfSensorProvider = BackEmfSensorFamily();

/// See also [BackEmfSensor].
class BackEmfSensorFamily extends Family<int?> {
  /// See also [BackEmfSensor].
  const BackEmfSensorFamily();

  /// See also [BackEmfSensor].
  BackEmfSensorProvider call(
    int port,
  ) {
    return BackEmfSensorProvider(
      port,
    );
  }

  @override
  BackEmfSensorProvider getProviderOverride(
    covariant BackEmfSensorProvider provider,
  ) {
    return call(
      provider.port,
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
  String? get name => r'backEmfSensorProvider';
}

/// See also [BackEmfSensor].
class BackEmfSensorProvider
    extends AutoDisposeNotifierProviderImpl<BackEmfSensor, int?> {
  /// See also [BackEmfSensor].
  BackEmfSensorProvider(
    int port,
  ) : this._internal(
          () => BackEmfSensor()..port = port,
          from: backEmfSensorProvider,
          name: r'backEmfSensorProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$backEmfSensorHash,
          dependencies: BackEmfSensorFamily._dependencies,
          allTransitiveDependencies:
              BackEmfSensorFamily._allTransitiveDependencies,
          port: port,
        );

  BackEmfSensorProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.port,
  }) : super.internal();

  final int port;

  @override
  int? runNotifierBuild(
    covariant BackEmfSensor notifier,
  ) {
    return notifier.build(
      port,
    );
  }

  @override
  Override overrideWith(BackEmfSensor Function() create) {
    return ProviderOverride(
      origin: this,
      override: BackEmfSensorProvider._internal(
        () => create()..port = port,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        port: port,
      ),
    );
  }

  @override
  AutoDisposeNotifierProviderElement<BackEmfSensor, int?> createElement() {
    return _BackEmfSensorProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is BackEmfSensorProvider && other.port == port;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, port.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin BackEmfSensorRef on AutoDisposeNotifierProviderRef<int?> {
  /// The parameter `port` of this provider.
  int get port;
}

class _BackEmfSensorProviderElement
    extends AutoDisposeNotifierProviderElement<BackEmfSensor, int?>
    with BackEmfSensorRef {
  _BackEmfSensorProviderElement(super.provider);

  @override
  int get port => (origin as BackEmfSensorProvider).port;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
