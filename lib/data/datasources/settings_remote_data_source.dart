import 'package:flutter/material.dart';
import 'package:stpvelox/domain/entities/setting.dart';

abstract class SettingsRemoteDataSource {
  Future<List<Setting>> fetchSettings();

  Future<void> updateSettingRemote(String label);
}

class SettingsRemoteDataSourceImpl implements SettingsRemoteDataSource {
  @override
  Future<List<Setting>> fetchSettings() async {
    return [
      Setting(icon: Icons.wifi, label: "Wi-Fi", color: Colors.green),
      Setting(
        icon: Icons.power_settings_new,
        label: "Shutdown",
        color: Colors.red,
      ),
      Setting(icon: Icons.refresh, label: "Reboot", color: Colors.orange),
    ];
  }

  @override
  Future<void> updateSettingRemote(String label) async {
    if (label == "Shutdown" || label == "Reboot") {
      throw Exception("Failed to execute '$label' command.");
    }
  }
}
