import 'package:stpvelox/features/wifi/domain/enities/network_mode.dart';
import 'package:stpvelox/features/wifi/domain/repositories/i_wifi_repository.dart';

class GetNetworkMode {
  final IWifiRepository repository;

  GetNetworkMode(this.repository);

  Future<NetworkMode> call() async {
    return await repository.getCurrentNetworkMode();
  }
}