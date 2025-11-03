// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'lan_only_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\n'
    'Please remove the constructor from your class.');

/// @nodoc
mixin _$LanOnlyState {
  bool get isActive => throw _privateConstructorUsedError;
  bool get isLoading => throw _privateConstructorUsedError;
  bool get isCableConnected => throw _privateConstructorUsedError;
  String? get ipAddress => throw _privateConstructorUsedError;
  String? get macAddress => throw _privateConstructorUsedError;
  String? get errorMessage => throw _privateConstructorUsedError;

  /// Create a copy of LanOnlyState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $LanOnlyStateCopyWith<LanOnlyState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LanOnlyStateCopyWith<$Res> {
  factory $LanOnlyStateCopyWith(
          LanOnlyState value, $Res Function(LanOnlyState) then) =
      _$LanOnlyStateCopyWithImpl<$Res, LanOnlyState>;
  @useResult
  $Res call(
      {bool isActive,
      bool isLoading,
      bool isCableConnected,
      String? ipAddress,
      String? macAddress,
      String? errorMessage});
}

/// @nodoc
class _$LanOnlyStateCopyWithImpl<$Res, $Val extends LanOnlyState>
    implements $LanOnlyStateCopyWith<$Res> {
  _$LanOnlyStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of LanOnlyState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isActive = null,
    Object? isLoading = null,
    Object? isCableConnected = null,
    Object? ipAddress = freezed,
    Object? macAddress = freezed,
    Object? errorMessage = freezed,
  }) {
    return _then(_value.copyWith(
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      isCableConnected: null == isCableConnected
          ? _value.isCableConnected
          : isCableConnected // ignore: cast_nullable_to_non_nullable
              as bool,
      ipAddress: freezed == ipAddress
          ? _value.ipAddress
          : ipAddress // ignore: cast_nullable_to_non_nullable
              as String?,
      macAddress: freezed == macAddress
          ? _value.macAddress
          : macAddress // ignore: cast_nullable_to_non_nullable
              as String?,
      errorMessage: freezed == errorMessage
          ? _value.errorMessage
          : errorMessage // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$LanOnlyStateImplCopyWith<$Res>
    implements $LanOnlyStateCopyWith<$Res> {
  factory _$$LanOnlyStateImplCopyWith(
          _$LanOnlyStateImpl value, $Res Function(_$LanOnlyStateImpl) then) =
      __$$LanOnlyStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {bool isActive,
      bool isLoading,
      bool isCableConnected,
      String? ipAddress,
      String? macAddress,
      String? errorMessage});
}

/// @nodoc
class __$$LanOnlyStateImplCopyWithImpl<$Res>
    extends _$LanOnlyStateCopyWithImpl<$Res, _$LanOnlyStateImpl>
    implements _$$LanOnlyStateImplCopyWith<$Res> {
  __$$LanOnlyStateImplCopyWithImpl(
      _$LanOnlyStateImpl _value, $Res Function(_$LanOnlyStateImpl) _then)
      : super(_value, _then);

  /// Create a copy of LanOnlyState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isActive = null,
    Object? isLoading = null,
    Object? isCableConnected = null,
    Object? ipAddress = freezed,
    Object? macAddress = freezed,
    Object? errorMessage = freezed,
  }) {
    return _then(_$LanOnlyStateImpl(
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      isCableConnected: null == isCableConnected
          ? _value.isCableConnected
          : isCableConnected // ignore: cast_nullable_to_non_nullable
              as bool,
      ipAddress: freezed == ipAddress
          ? _value.ipAddress
          : ipAddress // ignore: cast_nullable_to_non_nullable
              as String?,
      macAddress: freezed == macAddress
          ? _value.macAddress
          : macAddress // ignore: cast_nullable_to_non_nullable
              as String?,
      errorMessage: freezed == errorMessage
          ? _value.errorMessage
          : errorMessage // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

class _$LanOnlyStateImpl implements _LanOnlyState {
  const _$LanOnlyStateImpl(
      {this.isActive = false,
      this.isLoading = false,
      this.isCableConnected = false,
      this.ipAddress,
      this.macAddress,
      this.errorMessage});

  @override
  @JsonKey()
  final bool isActive;
  @override
  @JsonKey()
  final bool isLoading;
  @override
  @JsonKey()
  final bool isCableConnected;
  @override
  final String? ipAddress;
  @override
  final String? macAddress;
  @override
  final String? errorMessage;

  @override
  String toString() {
    return 'LanOnlyState(isActive: $isActive, isLoading: $isLoading, isCableConnected: $isCableConnected, ipAddress: $ipAddress, macAddress: $macAddress, errorMessage: $errorMessage)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LanOnlyStateImpl &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive) &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.isCableConnected, isCableConnected) ||
                other.isCableConnected == isCableConnected) &&
            (identical(other.ipAddress, ipAddress) ||
                other.ipAddress == ipAddress) &&
            (identical(other.macAddress, macAddress) ||
                other.macAddress == macAddress) &&
            (identical(other.errorMessage, errorMessage) ||
                other.errorMessage == errorMessage));
  }

  @override
  int get hashCode => Object.hash(runtimeType, isActive, isLoading,
      isCableConnected, ipAddress, macAddress, errorMessage);

  /// Create a copy of LanOnlyState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LanOnlyStateImplCopyWith<_$LanOnlyStateImpl> get copyWith =>
      __$$LanOnlyStateImplCopyWithImpl<_$LanOnlyStateImpl>(this, _$identity);
}

abstract class _LanOnlyState implements LanOnlyState {
  const factory _LanOnlyState(
      {final bool isActive,
      final bool isLoading,
      final bool isCableConnected,
      final String? ipAddress,
      final String? macAddress,
      final String? errorMessage}) = _$LanOnlyStateImpl;

  @override
  bool get isActive;
  @override
  bool get isLoading;
  @override
  bool get isCableConnected;
  @override
  String? get ipAddress;
  @override
  String? get macAddress;
  @override
  String? get errorMessage;

  /// Create a copy of LanOnlyState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LanOnlyStateImplCopyWith<_$LanOnlyStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

