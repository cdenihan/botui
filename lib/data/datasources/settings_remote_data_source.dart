import 'dart:io';

import 'package:flutter/material.dart';
import 'package:stpvelox/domain/entities/setting.dart';

abstract class SettingsRemoteDataSource {
  Future<List<Setting>> fetchSettings();
}

class SettingsRemoteDataSourceImpl implements SettingsRemoteDataSource {
  @override
  Future<List<Setting>> fetchSettings() async {
    return [
      Setting(
        icon: Icons.wifi,
        label: "Wi-Fi",
        color: Colors.green,
        onTap: () {
          print("Wi-Fi");
          // Implement Wi-Fi related functionality here
        },
      ),
      Setting(
        icon: Icons.power_settings_new,
        label: "Shutdown",
        color: Colors.red,
        onTap: () async {
          await _shutdownDevice();
        },
      ),
      Setting(
        icon: Icons.refresh,
        label: "Reboot",
        color: Colors.orange,
        onTap: () async {
          await _rebootDevice();
        },
      ),
    ];
  }

  Future<void> _shutdownDevice() async {
    await Process.run('shutdown', ['-h', 'now']);
  }

  Future<void> _rebootDevice() async {
    await Process.run('shutdown', ['-r', 'now']);
  }
}
