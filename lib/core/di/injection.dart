import 'dart:async';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stpvelox/core/utils/touch_calibrator.dart';

// SharedPreferences Provider
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError(
      'SharedPreferences must be overridden with actual instance');
});

// MAC Address Provider
final macAddressProvider = FutureProvider<String?>((ref) async {
  return await _getMacAddress();
});

// Touch Calibrator Provider
final touchCalibratorProvider = Provider<TouchCalibrator>((ref) {
  final calibrator = TouchCalibrator();
  // Note: loadCalibration will be called in initialization
  return calibrator;
});

// Initialize and override providers with actual instances
Future<(SharedPreferences, TouchCalibrator)> initializeProviders() async {
  // Initialize SharedPreferences
  final sharedPreferences = await SharedPreferences.getInstance();
  // Initialize TouchCalibrator
  final touchCalibrator = TouchCalibrator();
  await touchCalibrator.loadCalibration();

  return (sharedPreferences, touchCalibrator);
}

Future<String?> _getMacAddress() async {
  try {
    // Try to get WiFi interface first (works for Raspberry Pi with various WiFi adapters)
    final wifiInterface = await _getWifiInterface();
    if (wifiInterface != null) {
      final macAddr = await getMacAddressWithIp(wifiInterface);
      if (macAddr != null) return macAddr;
    }

    // Fallback to common ethernet interface names on Raspberry Pi
    // Try eth0 first (older Raspberry Pi models)
    final ethMac = await getMacAddressWithIp("eth0");
    if (ethMac != null) return ethMac;

    // Try enp* (newer naming scheme)
    final enpMac = await getMacAddressWithIp("enp4s0");
    if (enpMac != null) return enpMac;

    // Try wlan0 as last resort
    return await getMacAddressWithIp("wlan0");
  } catch (e) {
    return null;
  }
}

Future<String?> _getWifiInterface() async {
  try {
    final result = await Process.run('nmcli', ['-t', '-f', 'DEVICE,TYPE', 'device', 'status']);
    if (result.exitCode != 0) return null;

    final lines = (result.stdout as String).split('\n');
    for (var line in lines) {
      final parts = line.split(':');
      if (parts.length >= 2 && parts[1] == 'wifi') {
        final device = parts[0];
        // Skip p2p-dev interfaces
        if (device.startsWith('p2p-dev-')) continue;
        return device;
      }
    }
    return null;
  } catch (e) {
    return null;
  }
}

Future<String?> getMacAddressWithIp(String interface) async {
  try {
    final result = await Process.run('ip', ['address', 'show', interface]);

    if (result.exitCode == 0) {
      final output = result.stdout.toString();
      // Look for the MAC address in the output
      // Format: "link/ether XX:XX:XX:XX:XX:XX brd ..."
      final macRegex = RegExp(r'link/ether\s+([0-9a-f:]{17})', caseSensitive: false);
      final match = macRegex.firstMatch(output);

      if (match != null && match.groupCount >= 1) {
        return match.group(1)?.toUpperCase();
      }
    }
    return null;
  } catch (e) {
    return null;
  }
}

Future<String?> getMacAddressLinux([String interface = "eth0"]) async {
  final result =
      await Process.run("cat", ["/sys/class/net/$interface/address"]);
  if (result.exitCode == 0) {
    return result.stdout.toString().trim();
  }
  return null;
}
