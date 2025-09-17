import 'package:stpvelox/features/wifi/domain/enities/access_point_config.dart';

class AccessPointState {
  bool isStarted;
  late AccessPointConfig? config;
  late String? errorMessage;
  bool isLoading;

  AccessPointState({
    this.isStarted = false,
    this.config,
    this.errorMessage,
    this.isLoading = false,
  });

  AccessPointState copyWith({
    bool? isStarted,
    AccessPointConfig? config,
    String? errorMessage,
    bool? isLoading,
  }) {
    return AccessPointState(
      isStarted: isStarted ?? this.isStarted,
      config: config ?? this.config,
      errorMessage: errorMessage ?? this.errorMessage,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}