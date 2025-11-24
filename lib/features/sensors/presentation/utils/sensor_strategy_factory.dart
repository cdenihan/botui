import 'package:stpvelox/core/service/sensors/accelerometer_sensor.dart';
import 'package:stpvelox/core/service/sensors/analog_sensor.dart';
import 'package:stpvelox/core/service/sensors/battery_voltage_sensor.dart';
import 'package:stpvelox/core/service/sensors/cpu_temperature_sensor.dart';
import 'package:stpvelox/core/service/sensors/digital_sensor.dart';
import 'package:stpvelox/core/service/sensors/gyro_sensor.dart';
import 'package:stpvelox/core/service/sensors/magnetometer_sensor.dart';
import 'package:stpvelox/core/service/sensors/sensor_reading_strategy.dart';
import 'package:stpvelox/core/service/sensors/temperature_sensor.dart';
import 'package:stpvelox/features/sensors/domain/entities/sensor_type.dart';

/// Factory for creating sensor reading strategies based on sensor type
class SensorStrategyFactory {
  /// Creates the appropriate sensor reading strategy for the given sensor type
  static SensorReadingStrategy createStrategy(SensorType type) {
    switch (type) {
      case SensorType.analog:
        return AnalogSensorReadingStrategy();
      case SensorType.digital:
        return DigitalSensorReadingStrategy();
      case SensorType.gyroX:
        return GyroXSensorReadingStrategy();
      case SensorType.gyroY:
        return GyroYSensorReadingStrategy();
      case SensorType.gyroZ:
        return GyroZSensorReadingStrategy();
      case SensorType.accelX:
        return AccelXSensorReadingStrategy();
      case SensorType.accelY:
        return AccelYSensorReadingStrategy();
      case SensorType.accelZ:
        return AccelZSensorReadingStrategy();
      case SensorType.magX:
        return MagXSensorReadingStrategy();
      case SensorType.magY:
        return MagYSensorReadingStrategy();
      case SensorType.magZ:
        return MagZSensorReadingStrategy();
      case SensorType.temperature:
        return TemperatureSensorReadingStrategy();
      case SensorType.cpuTemperature:
        return CpuTemperatureSensorReadingStrategy();
      case SensorType.batteryVoltage:
        return BatteryVoltageSensorReadingStrategy();
      default:
        return _NullSensorReadingStrategy();
    }
  }
}

/// Null object pattern for unsupported sensor types
class _NullSensorReadingStrategy extends SensorReadingStrategy {
  @override
  double? readValue(ref, port) => null;
}