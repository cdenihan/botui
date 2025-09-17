import 'package:stpvelox/features/sensors/domain/entities/sensor.dart';

abstract class SensorRepository {
  Future<List<Sensor>> getSensors();
}