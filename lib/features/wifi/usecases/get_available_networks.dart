import 'package:stpvelox/features/wifi/domain/enities/wifi_network.dart';
import 'package:stpvelox/features/wifi/domain/repositories/i_wifi_repository.dart';

class GetAvailableNetworks {
  final IWifiRepository repository;

  GetAvailableNetworks({required this.repository});

  Future<List<WifiNetwork>> call() {
    return repository.getAvailableNetworks();
  }
}
