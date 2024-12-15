import 'package:stpvelox/data/native/kipr_plugin.dart';
import 'package:stpvelox/domain/entities/sensor.dart';
import 'package:stpvelox/domain/entities/sensor_category.dart';
import 'package:stpvelox/presentation/screens/sensor_graph_screen.dart';

abstract class SensorsRemoteDataSource {
  Future<List<Sensor>> fetchSensors();
}

class SensorsRemoteDataSourceImpl implements SensorsRemoteDataSource {
  Sensor getAnalogSensor(int port) {
    return Sensor(
      category: SensorCategory.analog,
      name: 'Analog $port',
      getSensorScreen: (sensor) => SensorGraphScreen(sensor: sensor, getSensorValue: () => KiprPlugin.getAnalog(port))
    );
  }

  @override
  Future<List<Sensor>> fetchSensors() async {
    return [
      getAnalogSensor(0),
      getAnalogSensor(1),
      getAnalogSensor(2),
      getAnalogSensor(3),
      getAnalogSensor(4),
      getAnalogSensor(5),
      Sensor(
        category: SensorCategory.gyro,
        name: 'Gyro X',
        getSensorScreen: (sensor) => SensorGraphScreen(sensor: sensor, getSensorValue: () => KiprPlugin.getGyroX())
      ),
      Sensor(
        category: SensorCategory.gyro,
        name: 'Gyro Y',
        getSensorScreen: (sensor) => SensorGraphScreen(sensor: sensor, getSensorValue: () => KiprPlugin.getGyroY())
      ),
      Sensor(
        category: SensorCategory.gyro,
        name: 'Gyro Z',
        getSensorScreen: (sensor) => SensorGraphScreen(sensor: sensor, getSensorValue: () => KiprPlugin.getGyroZ())
      ),
    ];
  }
}