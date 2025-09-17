import 'dart:math';
import 'dart:developer' as developer;

class KiprPlugin {
  static final Random _random = Random();

  // Mock servo states to simulate enable/disable behavior
  static final Set<int> _enabledServos = <int>{};

  // Mock motor positions that change over time
  static final Map<int, int> _motorPositions = <int, int>{};

  // Helper method to simulate realistic sensor noise
  static double _addNoise(double baseValue, double noiseRange) {
    return baseValue + (_random.nextDouble() - 0.5) * 2 * noiseRange;
  }

  // Orientation methods (returns values in degrees, typical range -180 to 180)
  static Future<double> getOrientationRoll() async {
    await Future.delayed(Duration(milliseconds: 1)); // Simulate async delay
    return _addNoise(0, 45); // ±45 degrees with noise
  }

  static Future<double> getOrientationPitch() async {
    await Future.delayed(Duration(milliseconds: 1));
    return _addNoise(0, 30); // ±30 degrees with noise
  }

  static Future<double> getOrientationYaw() async {
    await Future.delayed(Duration(milliseconds: 1));
    return _addNoise(0, 180); // Full rotation range with noise
  }

  // Gyroscope methods (returns angular velocity in degrees/second)
  static Future<double> getGyroX() async {
    await Future.delayed(Duration(milliseconds: 1));
    return _addNoise(0, 50); // ±50 deg/s with noise
  }

  static Future<double> getGyroY() async {
    await Future.delayed(Duration(milliseconds: 1));
    return _addNoise(0, 50);
  }

  static Future<double> getGyroZ() async {
    await Future.delayed(Duration(milliseconds: 1));
    return _addNoise(0, 50);
  }

  // Accelerometer methods (returns acceleration in m/s², Earth gravity ~9.8)
  static Future<double> getAccelX() async {
    await Future.delayed(Duration(milliseconds: 1));
    return _addNoise(0, 2); // ±2 m/s² with noise
  }

  static Future<double> getAccelY() async {
    await Future.delayed(Duration(milliseconds: 1));
    return _addNoise(0, 2);
  }

  static Future<double> getAccelZ() async {
    await Future.delayed(Duration(milliseconds: 1));
    return _addNoise(9.8, 1); // Gravity with some noise
  }

  // Magnetometer methods (returns magnetic field in microteslas)
  static Future<double> getMagX() async {
    await Future.delayed(Duration(milliseconds: 1));
    return _addNoise(20, 10); // Typical Earth magnetic field values
  }

  static Future<double> getMagY() async {
    await Future.delayed(Duration(milliseconds: 1));
    return _addNoise(-15, 10);
  }

  static Future<double> getMagZ() async {
    await Future.delayed(Duration(milliseconds: 1));
    return _addNoise(45, 10);
  }

  // Analog sensor methods (returns 0-4095 for 12-bit ADC)
  static Future<int> getAnalog(int port) async {
    await Future.delayed(Duration(milliseconds: 1));
    developer.log("Mock: Reading analog port $port");
    return _random.nextInt(4096); // 12-bit ADC range
  }

  // Digital sensor methods (returns 0 or 1)
  static Future<int> getDigital(int port) async {
    await Future.delayed(Duration(milliseconds: 1));
    developer.log("Mock: Reading digital port $port");
    return _random.nextBool() ? 1 : 0;
  }

  // Servo control methods
  static Future<void> enableServo(int port) async {
    await Future.delayed(Duration(milliseconds: 5));
    _enabledServos.add(port);
    developer.log("Mock: Servo enabled on port $port");
  }

  static Future<void> disableServo(int port) async {
    await Future.delayed(Duration(milliseconds: 5));
    _enabledServos.remove(port);
    developer.log("Mock: Servo disabled on port $port");
  }

  static Future<void> setServoPosition(int port, int position) async {
    await Future.delayed(Duration(milliseconds: 10));
    if (_enabledServos.contains(port)) {
      developer.log("Mock: Setting servo on port $port to position $position");
    } else {
      developer.log("Mock: Warning - Servo on port $port is not enabled");
    }
  }

  // Motor control methods
  static Future<void> stopMotor(int port) async {
    await Future.delayed(Duration(milliseconds: 5));
    developer.log("Mock: Motor stopped on port $port");
  }

  static Future<void> setMotorVelocity(int port, int velocity) async {
    await Future.delayed(Duration(milliseconds: 5));
    developer.log("Mock: Motor on port $port set to velocity $velocity");

    // Simulate position change based on velocity
    _motorPositions[port] = (_motorPositions[port] ?? 0) + velocity ~/ 10;
  }

  static Future<int> getMotorPosition(int port) async {
    await Future.delayed(Duration(milliseconds: 1));
    // Add some random drift to simulate real motor behavior
    int basePosition = _motorPositions[port] ?? 0;
    int drift = _random.nextInt(3) - 1; // -1, 0, or 1
    _motorPositions[port] = basePosition + drift;

    developer.log("Mock: Motor position on port $port: ${_motorPositions[port]}");
    return _motorPositions[port]!;
  }

  static Future<void> fullyDisableServos() async {
    await Future.delayed(Duration(milliseconds: 10));
    _enabledServos.clear();
    developer.log("Mock: All servos fully disabled");
  }

  // System status methods
  static Future<double> getImuTemperature() async {
    await Future.delayed(Duration(milliseconds: 1));
    return _addNoise(25.0, 5.0); // Room temperature ±5°C
  }

  static Future<double> getBatteryVoltage() async {
    await Future.delayed(Duration(milliseconds: 1));
    // Simulate battery discharge from 12V to 10V
    double baseVoltage = 11.0 + _random.nextDouble() * 1.5;
    return double.parse(baseVoltage.toStringAsFixed(2));
  }

  static Future<void> setSpiMode(bool mode) async {
    await Future.delayed(Duration(milliseconds: 5));
    developer.log("Mock: SPI mode set to $mode");
  }
}