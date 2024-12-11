import 'package:stpvelox/domain/entities/sensor.dart';

abstract class SensorsRemoteDataSource {
  Future<List<Sensor>> fetchSensors();
}

class SensorsRemoteDataSourceImpl implements SensorsRemoteDataSource {
  @override
  Future<List<Sensor>> fetchSensors() async {
    return [
      Sensor(name: "Temperature", value: "25°C"),
      Sensor(name: "Humidity", value: "60%"),
      Sensor(name: "Pressure", value: "1013 hPa"),
    ];
  }
}