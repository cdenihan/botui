import 'package:flutter/material.dart';
import 'package:stpvelox/core/utils/sudo_process.dart';
import 'package:stpvelox/domain/entities/setting.dart';
import 'package:stpvelox/domain/usecases/reboot.dart';
import 'package:stpvelox/presentation/screens/wifi/wifi_home_screen.dart';

abstract class SettingsRemoteDataSource {
  Future<List<Setting>> fetchSettings();
}

class SettingsRemoteDataSourceImpl implements SettingsRemoteDataSource {
  final RebootDevice reboot;

  SettingsRemoteDataSourceImpl({required this.reboot});

  @override
  Future<List<Setting>> fetchSettings() async {
    return [
      Setting(
        icon: Icons.wifi,
        label: "Wi-Fi",
        color: Colors.green,
        onTap: (context) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const WifiHomeScreen(),
            ),
          );
        },
      ),
      Setting(
        icon: Icons.power_settings_new,
        label: "Shutdown",
        color: Colors.red,
        onTap: (_) async {
          await _shutdownDevice();
        },
      ),
      Setting(
        icon: Icons.refresh,
        label: "Reboot",
        color: Colors.orange,
        onTap: (_) async {
          await reboot.call();
        },
      ),
      Setting(
        icon: Icons.remove_red_eye,
        label: "Hide UI",
        color: Colors.blue,
        onTap: (_) async {
          await SudoProcess.run('systemctl', ['stop', 'flutter-ui.service']);
        },
      )
    ];
  }

  Future<void> _shutdownDevice() async {
    await SudoProcess.run('shutdown', ['-h', 'now']);
  }
}
