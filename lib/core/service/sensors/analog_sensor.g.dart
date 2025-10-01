// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'analog_sensor.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$analogSensorHash() => r'4db07976ae1e27ad28ee0776c839818c638a61a3';

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

abstract class _$AnalogSensor extends BuildlessAutoDisposeNotifier<int?> {
  late final int port;

  int? build(
    int port,
  );
}

/// See also [AnalogSensor].
@ProviderFor(AnalogSensor)
const analogSensorProvider = AnalogSensorFamily();

/// See also [AnalogSensor].
class AnalogSensorFamily extends Family<int?> {
  /// See also [AnalogSensor].
  const AnalogSensorFamily();

  /// See also [AnalogSensor].
  AnalogSensorProvider call(
    int port,
  ) {
    return AnalogSensorProvider(
      port,
    );
  }

  @override
  AnalogSensorProvider getProviderOverride(
    covariant AnalogSensorProvider provider,
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
  String? get name => r'analogSensorProvider';
}

/// See also [AnalogSensor].
class AnalogSensorProvider
    extends AutoDisposeNotifierProviderImpl<AnalogSensor, int?> {
  /// See also [AnalogSensor].
  AnalogSensorProvider(
    int port,
  ) : this._internal(
          () => AnalogSensor()..port = port,
          from: analogSensorProvider,
          name: r'analogSensorProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$analogSensorHash,
          dependencies: AnalogSensorFamily._dependencies,
          allTransitiveDependencies:
              AnalogSensorFamily._allTransitiveDependencies,
          port: port,
        );

  AnalogSensorProvider._internal(
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
    covariant AnalogSensor notifier,
  ) {
    return notifier.build(
      port,
    );
  }

  @override
  Override overrideWith(AnalogSensor Function() create) {
    return ProviderOverride(
      origin: this,
      override: AnalogSensorProvider._internal(
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
  AutoDisposeNotifierProviderElement<AnalogSensor, int?> createElement() {
    return _AnalogSensorProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is AnalogSensorProvider && other.port == port;
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
mixin AnalogSensorRef on AutoDisposeNotifierProviderRef<int?> {
  /// The parameter `port` of this provider.
  int get port;
}

class _AnalogSensorProviderElement
    extends AutoDisposeNotifierProviderElement<AnalogSensor, int?>
    with AnalogSensorRef {
  _AnalogSensorProviderElement(super.provider);

  @override
  int get port => (origin as AnalogSensorProvider).port;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
