import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stpvelox/core/utils/sudo_process.dart';
import 'package:stpvelox/features/settings/domain/entities/setting.dart';
import 'package:stpvelox/features/settings/domain/usecases/reboot.dart';
import 'package:stpvelox/features/settings/presentation/pages/service_status_screen.dart';
import 'package:stpvelox/features/settings/presentation/pages/touch_calibration_screen.dart';
import 'package:stpvelox/features/wifi/presentation/pages/wifi_home_screen.dart';
import 'package:stpvelox/shared/data/native/kipr_plugin.dart';

abstract class SettingsRemoteDataSource {
  Future<List<Setting>> fetchSettings();
}

class SettingsRemoteDataSourceImpl implements SettingsRemoteDataSource {
  final RebootDevice reboot;
  final SharedPreferences sharedPreferences;
  bool allowSpiCommands = false;

  SettingsRemoteDataSourceImpl(
      {required this.reboot, required this.sharedPreferences});

  @override
  Future<List<Setting>> fetchSettings() async {
    return [
      Setting(
        icon: Icons.wifi,
        label: "Wi-Fi",
        color: Colors.green,
        type: SettingType.button,
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
        type: SettingType.button,
        onTap: (_) async {
          await _shutdownDevice();
        },
      ),
      Setting(
        icon: Icons.refresh,
        label: "Reboot",
        color: Colors.orange,
        type: SettingType.button,
        onTap: (_) async {
          await reboot.call();
        },
      ),
      Setting(
        icon: Icons.display_settings,
        label: "Calibrate",
        color: Colors.purple,
        type: SettingType.button,
        onTap: (context) async {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => TouchCalibrationScreen(
                onFinished: () {
                  Navigator.of(context).pop();
                },
              ),
            ),
          );
        },
      ),
      Setting(
        icon: Icons.remove_red_eye,
        label: "Hide UI",
        color: Colors.blue,
        type: SettingType.button,
        onTap: (_) async {
          await SudoProcess.run('systemctl', ['stop', 'flutter-ui.service']);
        },
      ),
      Setting(
        icon: Icons.usb,
        label: "Allow SPI Commands",
        color: Colors.teal,
        type: SettingType.toggle,
        value: () => allowSpiCommands,
        onTap: (_) async {
          allowSpiCommands = !allowSpiCommands;
          await KiprPlugin.setSpiMode(allowSpiCommands);
        },
      ),
      Setting(
        icon: Icons.analytics_outlined,
        label: "Status",
        color: Colors.greenAccent,
        onTap: (context) async {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => ServiceStatusScreen()
            ),
          );
        },
      )
    ];
  }

  Future<void> _shutdownDevice() async {
    await SudoProcess.run('shutdown', ['-h', 'now']);
  }
}
