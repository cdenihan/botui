import 'package:stpvelox/features/wifi/domain/enities/network_mode.dart';
import 'package:stpvelox/features/wifi/domain/repositories/i_wifi_repository.dart';

class SetNetworkMode {
  final IWifiRepository repository;

  SetNetworkMode(this.repository);

  Future<void> call(NetworkMode mode) async {
    await repository.setNetworkMode(mode);
  }
}