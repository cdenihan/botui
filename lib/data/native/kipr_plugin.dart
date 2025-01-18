import 'package:flutter/services.dart';
import 'dart:developer' as developer;

class KiprPlugin {
  static const MethodChannel _channel = MethodChannel('stpvelox.kipr');

  // Existing Gyro Methods
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

  static Future<int> getAccelX() async {
    try {
      final int accelXValue = await _channel.invokeMethod<int>('accelX') ?? 0;
      return accelXValue;
    } on PlatformException catch (e) {
      developer.log("Failed to get accelX: '${e.message}'.");
      return 0;
    }
  }

  static Future<int> getAccelY() async {
    try {
      final int accelYValue = await _channel.invokeMethod<int>('accelY') ?? 0;
      return accelYValue;
    } on PlatformException catch (e) {
      developer.log("Failed to get accelY: '${e.message}'.");
      return 0;
    }
  }

  static Future<int> getAccelZ() async {
    try {
      final int accelZValue = await _channel.invokeMethod<int>('accelZ') ?? 0;
      return accelZValue;
    } on PlatformException catch (e) {
      developer.log("Failed to get accelZ: '${e.message}'.");
      return 0;
    }
  }

  static Future<int> getMagX() async {
    try {
      final int magXValue = await _channel.invokeMethod<int>('magX') ?? 0;
      return magXValue;
    } on PlatformException catch (e) {
      developer.log("Failed to get magX: '${e.message}'.");
      return 0;
    }
  }

  static Future<int> getMagY() async {
    try {
      final int magYValue = await _channel.invokeMethod<int>('magY') ?? 0;
      return magYValue;
    } on PlatformException catch (e) {
      developer.log("Failed to get magY: '${e.message}'.");
      return 0;
    }
  }

  static Future<int> getMagZ() async {
    try {
      final int magZValue = await _channel.invokeMethod<int>('magZ') ?? 0;
      return magZValue;
    } on PlatformException catch (e) {
      developer.log("Failed to get magZ: '${e.message}'.");
      return 0;
    }
  }

  // Existing Analog Method
  static Future<int> getAnalog(int port) async {
    try {
      final int analogValue = await _channel.invokeMethod<int>(
        'analog',
        {'port': port},
      ) ?? 0;
      return analogValue;
    } on PlatformException catch (e) {
      developer.log("Failed to get analog value: '${e.message}'.");
      return 0;
    }
  }

  static Future<int> getDigital(int port) async {
    try {
      final int digitalValue = await _channel.invokeMethod<int>(
        'digital',
        {'port': port},
      ) ?? 0;
      return digitalValue;
    } on PlatformException catch (e) {
      developer.log("Failed to get digital value: '${e.message}'.");
      return 0;
    }
  }

  static Future<void> enableServo(int port) async {
    try {
      await _channel.invokeMethod(
        'servoEnable',
        {'port': port},
      );
    } on PlatformException catch (e) {
      developer.log("Failed to enable servo on port $port: '${e.message}'.");
    }
  }

  static Future<void> disableServo(int port) async {
    try {
      await _channel.invokeMethod(
        'servoDisable',
        {'port': port},
      );
    } on PlatformException catch (e) {
      developer.log("Failed to disable servo on port $port: '${e.message}'.");
    }
  }

  static Future<void> setServoPosition(int port, int position) async {
    try {
      await _channel.invokeMethod(
        'servoSetPosition',
        {
          'port': port,
          'position': position,
        },
      );
    } on PlatformException catch (e) {
      developer.log("Failed to set servo position on port $port: '${e.message}'.");
    }
  }

  static Future<void> stopMotor(int port) async {
    try {
      await _channel.invokeMethod(
        'motorStop',
        {'port': port},
      );
    } on PlatformException catch (e) {
      developer.log("Failed to stop motor on port $port: '${e.message}'.");
    }
  }

  static Future<void> setMotorVelocity(int port, int velocity) async {
    try {
      await _channel.invokeMethod(
        'motorVelocity',
        {
          'port': port,
          'velocity': velocity,
        },
      );
    } on PlatformException catch (e) {
      developer.log("Failed to set motor velocity on port $port: '${e.message}'.");
    }
  }

  static Future<int> getMotorPosition(int port) async {
    try {
      final int position = await _channel.invokeMethod<int>(
        'motorGetPosition',
        {'port': port},
      ) ?? 0;
      return position;
    } on PlatformException catch (e) {
      developer.log("Failed to get motor position on port $port: '${e.message}'.");
      return 0;
    }
  }
}