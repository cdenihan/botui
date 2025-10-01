// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'servo_sensor.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$servoModeSensorHash() => r'02d9920d6493e6420880d4669258d66ca260cd27';

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

abstract class _$ServoModeSensor
    extends BuildlessAutoDisposeNotifier<ServoMode?> {
  late final int port;

  ServoMode? build(
    int port,
  );
}

/// See also [ServoModeSensor].
@ProviderFor(ServoModeSensor)
const servoModeSensorProvider = ServoModeSensorFamily();

/// See also [ServoModeSensor].
class ServoModeSensorFamily extends Family<ServoMode?> {
  /// See also [ServoModeSensor].
  const ServoModeSensorFamily();

  /// See also [ServoModeSensor].
  ServoModeSensorProvider call(
    int port,
  ) {
    return ServoModeSensorProvider(
      port,
    );
  }

  @override
  ServoModeSensorProvider getProviderOverride(
    covariant ServoModeSensorProvider provider,
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
  String? get name => r'servoModeSensorProvider';
}

/// See also [ServoModeSensor].
class ServoModeSensorProvider
    extends AutoDisposeNotifierProviderImpl<ServoModeSensor, ServoMode?> {
  /// See also [ServoModeSensor].
  ServoModeSensorProvider(
    int port,
  ) : this._internal(
          () => ServoModeSensor()..port = port,
          from: servoModeSensorProvider,
          name: r'servoModeSensorProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$servoModeSensorHash,
          dependencies: ServoModeSensorFamily._dependencies,
          allTransitiveDependencies:
              ServoModeSensorFamily._allTransitiveDependencies,
          port: port,
        );

  ServoModeSensorProvider._internal(
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
  ServoMode? runNotifierBuild(
    covariant ServoModeSensor notifier,
  ) {
    return notifier.build(
      port,
    );
  }

  @override
  Override overrideWith(ServoModeSensor Function() create) {
    return ProviderOverride(
      origin: this,
      override: ServoModeSensorProvider._internal(
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
  AutoDisposeNotifierProviderElement<ServoModeSensor, ServoMode?>
      createElement() {
    return _ServoModeSensorProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ServoModeSensorProvider && other.port == port;
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
mixin ServoModeSensorRef on AutoDisposeNotifierProviderRef<ServoMode?> {
  /// The parameter `port` of this provider.
  int get port;
}

class _ServoModeSensorProviderElement
    extends AutoDisposeNotifierProviderElement<ServoModeSensor, ServoMode?>
    with ServoModeSensorRef {
  _ServoModeSensorProviderElement(super.provider);

  @override
  int get port => (origin as ServoModeSensorProvider).port;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
