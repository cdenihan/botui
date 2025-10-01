import 'package:stpvelox/features/wifi/domain/enities/saved_network.dart';

class SavedNetworksState {
  bool isLoading;
  List<SavedNetwork> networks;
  late String? errorMessage;

  SavedNetworksState({
    this.isLoading = false,
    this.networks = const [],
    this.errorMessage,
  });

  SavedNetworksState copyWith({
    bool? isLoading,
    List<SavedNetwork>? networks,
    String? errorMessage,
  }) {
    return SavedNetworksState(
      isLoading: isLoading ?? this.isLoading,
      networks: networks ?? this.networks,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
