
import 'package:stpvelox/features/calibrate_sensors/data/datasource/calibration_remote_data_source.dart';
import 'package:stpvelox/features/calibrate_sensors/domain/repositories/calibration_repository.dart';

import '../../domain/entities/calibrate_sensor.dart';

class CalibrationSensorRepositoryImpl extends CalibrationRepository{
  final CalibrationSensorsRemoteDataSource remoteDataSource;

  CalibrationSensorRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<CalibrateSensor>> getCalibrationSensors() async {
    return await remoteDataSource.fetchCalibration();
  }
}