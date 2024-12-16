import 'dart:io';

import 'package:stpvelox/domain/entities/device_info.dart';
import 'package:stpvelox/domain/entities/wifi_credentials.dart';
import 'package:stpvelox/domain/entities/wifi_network.dart';

import '../../domain/entities/wifi_encryption_type.dart';

class LinuxNetworkManager {
  Future<List<WifiNetwork>> scanNetworks() async {
    // Example: nmcli -f SSID,SECURITY,IN-USE dev wifi
    final result = await Process.run(
        'nmcli', ['-f', 'SSID,SECURITY,IN-USE', 'dev', 'wifi']);
    if (result.exitCode != 0) {
      throw Exception('Failed to scan WiFi networks: ${result.stderr}');
    }

    // Parse the output
    // Example line: "MyHomeWifi  WPA2     *"
    // This is a simplification; real parsing might differ.
    final lines = (result.stdout as String).split('\n').skip(1);
    final networks = <WifiNetwork>[];
    for (var line in lines) {
      if (line.trim().isEmpty) continue;
      final parts =
          line.split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
      if (parts.isEmpty) continue;
      final ssid = parts[0];
      final security = parts.length > 1 ? parts[1] : '';
      final inUse = line.contains('*');

      WifiEncryptionType encType = WifiEncryptionType.open;
      if (security.contains('WPA3')) {
        encType = security.contains('EAP')
            ? WifiEncryptionType.wpa3Enterprise
            : WifiEncryptionType.wpa3Personal;
      } else if (security.contains('WPA2')) {
        encType = security.contains('EAP')
            ? WifiEncryptionType.wpa2Enterprise
            : WifiEncryptionType.wpa2Personal;
      }

      networks.add(WifiNetwork(
        ssid: ssid,
        encryptionType: encType,
        isConnected: inUse,
      ));
    }
    return networks;
  }

  Future<void> connect(String ssid, WifiEncryptionType encType,
      WifiCredentials credentials) async {
    List<String> cmd = ['device', 'wifi', 'connect', ssid];
    // For enterprise networks, nmcli might require a connection add or modify command.
    // This is a simplified assumption.
    switch (encType) {
      case WifiEncryptionType.open:
        // Just try to connect no password
        break;
      case WifiEncryptionType.wpa2Personal:
      case WifiEncryptionType.wpa3Personal:
        final passCred = credentials as PersonalCredentials;
        cmd.addAll(['password', passCred.password]);
        break;
      case WifiEncryptionType.wpa2Enterprise:
      case WifiEncryptionType.wpa3Enterprise:
        final entCred = credentials as EnterpriseCredentials;
        // Enterprise networks often require nmcli con add ... with 802-1x settings.
        // For simplicity:
        // nmcli connection add type wifi con-name "$SSID" ifname wlan0 ssid "$SSID" -- wifi-sec.key-mgmt wpa-eap 802-1x.eap peap 802-1x.identity user 802-1x.password pass
        // This is a one-liner example. Adjust as needed. In reality, you'd create a connection profile.
        await Process.run('nmcli', [
          'connection',
          'add',
          'type',
          'wifi',
          'con-name',
          ssid,
          'ifname',
          'wlan0',
          'ssid',
          ssid,
          'wifi-sec.key-mgmt',
          'wpa-eap',
          '802-1x.eap',
          'peap',
          '802-1x.identity',
          entCred.username,
          '802-1x.password',
          entCred.password,
          if (entCred.caCertificatePath != null) '802-1x.ca-cert' else '',
          if (entCred.caCertificatePath != null) entCred.caCertificatePath!,
        ]);
        // After adding, try to bring it up
        await Process.run('nmcli', ['connection', 'up', ssid]);
        return;
    }

    final result = await Process.run('nmcli', cmd);
    if (result.exitCode != 0) {
      throw Exception('Failed to connect: ${result.stderr}');
    }
  }

  Future<void> forget(String ssid) async {
    final result = await Process.run('nmcli', ['connection', 'delete', ssid]);
    if (result.exitCode != 0) {
      throw Exception('Failed to forget network: ${result.stderr}');
    }
  }

  Future<DeviceInfo> getDeviceInfo() async {
    try {
      // Get IP Address
      final ipResult = await Process.run('hostname', ['-I']);
      if (ipResult.exitCode != 0) {
        throw Exception('Failed to retrieve IP address: ${ipResult.stderr}');
      }
      final ipAddress = (ipResult.stdout as String).trim().split(' ').first;

      // Get Currently Connected Network
      final connResult = await Process.run(
          'nmcli', ['-t', '-f', 'SSID,SECURITY,IN-USE', 'dev', 'wifi']);
      if (connResult.exitCode != 0) {
        throw Exception(
            'Failed to retrieve connected network: ${connResult.stderr}');
      }

      final lines = (connResult.stdout as String).split('\n');
      WifiNetwork? connectedNetwork;
      for (var line in lines) {
        if (line.contains('*')) {
          // '*' indicates current connection
          final parts = line.split(':');
          if (parts.isNotEmpty) {
            final ssid = parts[0];
            final security = parts.length > 1 ? parts[1] : '';
            WifiEncryptionType encType = WifiEncryptionType.open;
            if (security.contains('WPA3')) {
              encType = security.contains('EAP')
                  ? WifiEncryptionType.wpa3Enterprise
                  : WifiEncryptionType.wpa3Personal;
            } else if (security.contains('WPA2')) {
              encType = security.contains('EAP')
                  ? WifiEncryptionType.wpa2Enterprise
                  : WifiEncryptionType.wpa2Personal;
            }

            connectedNetwork = WifiNetwork(
              ssid: ssid,
              encryptionType: encType,
              isConnected: true,
              isKnown: true, // Assuming connected network is known
            );
            break;
          }
        }
      }

      return DeviceInfo(
          ipAddress: ipAddress, connectedNetwork: connectedNetwork);
    } catch (e) {
      throw Exception('Error retrieving device info: $e');
    }
  }
}
