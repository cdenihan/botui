import 'package:stpvelox/features/wifi/domain/enities/network_mode.dart';

class NetworkModeState {
  bool isLoading;
  late String? errorMessage;
  NetworkMode mode;

  NetworkModeState({
    this.isLoading = false,
    this.errorMessage,
    this.mode = NetworkMode.client,
  });

  NetworkModeState copyWith({
    bool? isLoading,
    String? errorMessage,
    NetworkMode? mode,
  }) {
    return NetworkModeState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      mode: mode ?? this.mode,
    );
  }
}