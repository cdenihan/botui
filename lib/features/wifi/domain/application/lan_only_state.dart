class LanOnlyState {
  bool isActive;
  bool isLoading;
  bool isCableConnected;
  String? ipAddress;
  String? macAddress;
  String? errorMessage;

  LanOnlyState({
    this.isActive = false,
    this.isLoading = false,
    this.isCableConnected = false,
    this.ipAddress,
    this.macAddress,
    this.errorMessage,
  });

  LanOnlyState copyWith({
    bool? isActive,
    bool? isLoading,
    bool? isCableConnected,
    String? ipAddress,
    String? macAddress,
    String? errorMessage,
  }) {
    return LanOnlyState(
      isActive: isActive ?? this.isActive,
      isLoading: isLoading ?? this.isLoading,
      isCableConnected: isCableConnected ?? this.isCableConnected,
      ipAddress: ipAddress ?? this.ipAddress,
      macAddress: macAddress ?? this.macAddress,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

