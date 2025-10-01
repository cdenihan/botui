// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'motor_power_sensor.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$motorPowerSensorHash() => r'61986c9f6112b991df87310b39888b26ba81f579';

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

abstract class _$MotorPowerSensor extends BuildlessAutoDisposeNotifier<int?> {
  late final int port;

  int? build(
    int port,
  );
}

/// See also [MotorPowerSensor].
@ProviderFor(MotorPowerSensor)
const motorPowerSensorProvider = MotorPowerSensorFamily();

/// See also [MotorPowerSensor].
class MotorPowerSensorFamily extends Family<int?> {
  /// See also [MotorPowerSensor].
  const MotorPowerSensorFamily();

  /// See also [MotorPowerSensor].
  MotorPowerSensorProvider call(
    int port,
  ) {
    return MotorPowerSensorProvider(
      port,
    );
  }

  @override
  MotorPowerSensorProvider getProviderOverride(
    covariant MotorPowerSensorProvider provider,
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
  String? get name => r'motorPowerSensorProvider';
}

/// See also [MotorPowerSensor].
class MotorPowerSensorProvider
    extends AutoDisposeNotifierProviderImpl<MotorPowerSensor, int?> {
  /// See also [MotorPowerSensor].
  MotorPowerSensorProvider(
    int port,
  ) : this._internal(
          () => MotorPowerSensor()..port = port,
          from: motorPowerSensorProvider,
          name: r'motorPowerSensorProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$motorPowerSensorHash,
          dependencies: MotorPowerSensorFamily._dependencies,
          allTransitiveDependencies:
              MotorPowerSensorFamily._allTransitiveDependencies,
          port: port,
        );

  MotorPowerSensorProvider._internal(
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
    covariant MotorPowerSensor notifier,
  ) {
    return notifier.build(
      port,
    );
  }

  @override
  Override overrideWith(MotorPowerSensor Function() create) {
    return ProviderOverride(
      origin: this,
      override: MotorPowerSensorProvider._internal(
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
  AutoDisposeNotifierProviderElement<MotorPowerSensor, int?> createElement() {
    return _MotorPowerSensorProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is MotorPowerSensorProvider && other.port == port;
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
mixin MotorPowerSensorRef on AutoDisposeNotifierProviderRef<int?> {
  /// The parameter `port` of this provider.
  int get port;
}

class _MotorPowerSensorProviderElement
    extends AutoDisposeNotifierProviderElement<MotorPowerSensor, int?>
    with MotorPowerSensorRef {
  _MotorPowerSensorProviderElement(super.provider);

  @override
  int get port => (origin as MotorPowerSensorProvider).port;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
