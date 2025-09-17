import 'package:stpvelox/features/sensors/data/datasource/sensors_remote_data_source.dart';
import 'package:stpvelox/features/sensors/domain/entities/sensor.dart';
import 'package:stpvelox/features/sensors/domain/repositories/sensor_repository.dart';

class SensorRepositoryImpl implements SensorRepository {
  final SensorsRemoteDataSource remoteDataSource;

  SensorRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<Sensor>> getSensors() async {
    return await remoteDataSource.fetchSensors();
  }
}