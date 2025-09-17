import 'package:stpvelox/features/wifi/domain/repositories/i_wifi_repository.dart';
import 'package:stpvelox/shared/domain/entities/device_info.dart';

class GetDeviceInfo {
  final IWifiRepository repository;

  GetDeviceInfo({required this.repository});

  Future<DeviceInfo> call() {
    return repository.getDeviceInfo();
  }
}
