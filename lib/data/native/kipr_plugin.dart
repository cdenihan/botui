import 'package:flutter/services.dart';
import 'dart:developer' as developer;

class KiprPlugin {
  static const MethodChannel _channel = MethodChannel('stpvelox.kipr');

  static Future<int> getGyroX() async {
    try {
      final int gyroXValue = await _channel.invokeMethod<int>('gyroX') ?? 0;
      return gyroXValue;
    } on PlatformException catch (e) {
      developer.log("Failed to get gyroX: '${e.message}'.");
      return 0;
    }
  }

  static Future<int> getGyroY() async {
    try {
      final int gyroYValue = await _channel.invokeMethod<int>('gyroY') ?? 0;
      return gyroYValue;
    } on PlatformException catch (e) {
      developer.log("Failed to get gyroY: '${e.message}'.");
      return 0;
    }
  }

  static Future<int> getGyroZ() async {
    try {
      final int gyroZValue = await _channel.invokeMethod<int>('gyroZ') ?? 0;
      return gyroZValue;
    } on PlatformException catch (e) {
      developer.log("Failed to get gyroZ: '${e.message}'.");
      return 0;
    }
  }

  static Future<int> getAnalog(int port) async {
    try {
      // Pass the port as part of a map
      final int analogValue = await _channel.invokeMethod<int>(
        'analog',
        {'port': port},
      ) ?? 0;
      return analogValue;
    } on PlatformException catch (e) {
      // Handle exceptions from the native side
      print("Failed to get analog value: '${e.message}'.");
      return 0;
    }
  }
}
