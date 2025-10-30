import 'package:stpvelox/features/wifi/domain/enities/network_mode.dart';

class NetworkModeState {
  bool isLoading;
  String? errorMessage;
  NetworkMode mode;

  NetworkModeState({
    this.isLoading = false,
    this.errorMessage,
    this.mode = NetworkMode.client,
  });

  NetworkModeState copyWith({
    bool? isLoading,
    String? Function()? errorMessage,
    NetworkMode? mode,
  }) {
    return NetworkModeState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
      mode: mode ?? this.mode,
    );
  }
}