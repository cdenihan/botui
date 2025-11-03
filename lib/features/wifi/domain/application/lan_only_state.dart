import 'package:freezed_annotation/freezed_annotation.dart';

part 'lan_only_state.freezed.dart';

@freezed
class LanOnlyState with _$LanOnlyState {
  const factory LanOnlyState({
    @Default(false) bool isActive,
    @Default(false) bool isLoading,
    @Default(false) bool isCableConnected,
    String? ipAddress,
    String? macAddress,
    String? errorMessage,
  }) = _LanOnlyState;
}

