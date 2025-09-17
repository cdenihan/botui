import 'package:stpvelox/features/wifi/domain/enities/wifi_credentials.dart';
import 'package:stpvelox/features/wifi/domain/enities/wifi_encryption_type.dart';
import 'package:stpvelox/features/wifi/domain/repositories/i_wifi_repository.dart';

class ConnectToWifi {
  final IWifiRepository repository;

  ConnectToWifi({required this.repository});

  Future<void> call(
    String ssid,
    WifiEncryptionType encryptionType,
    WifiCredentials credentials,
  ) {
    return repository.connectToWifi(ssid, encryptionType, credentials);
  }
}
