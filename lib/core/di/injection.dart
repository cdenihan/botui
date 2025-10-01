import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
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
Future<List<Override>> initializeProviders() async {
  // Initialize SharedPreferences
  final sharedPreferences = await SharedPreferences.getInstance();
  // Initialize TouchCalibrator
  final touchCalibrator = TouchCalibrator();
  await touchCalibrator.loadCalibration();

  return [
    sharedPreferencesProvider.overrideWithValue(sharedPreferences),
    touchCalibratorProvider.overrideWithValue(touchCalibrator),
  ];
}

Future<String?> _getMacAddress() async {
  try {
    return await getMacAddressLinux("wlan0"); // or eth0
  } on PlatformException {
    return 'Failed to get mac address.';
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
