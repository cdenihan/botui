import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stpvelox/features/calibrate_sensors/data/datasource/calibration_remote_data_source.dart';
import 'package:stpvelox/features/calibrate_sensors/data/repository/calibrate_sensor_repository_impl.dart';
import 'package:stpvelox/features/calibrate_sensors/domain/entities/calibrate_sensor.dart';
import 'package:stpvelox/features/calibrate_sensors/domain/usecases/get_calibration_sensors.dart';

final calibrationSensorRemoteDataSource =
    Provider<CalibrationSensorsRemoteDataSource>(
        (ref) => CalibrationSensorsRemoteDataSourceImpl());

final calibrationSensorRepository = Provider<CalibrationSensorRepositoryImpl>(
    (ref) => CalibrationSensorRepositoryImpl(
        remoteDataSource: ref.watch(calibrationSensorRemoteDataSource)));

final getUseCaseCalibrationSensorProvider = Provider<GetCalibrationSensors>(
    (ref) => GetCalibrationSensors(
        calibrationRepository: ref.watch(calibrationSensorRepository)));


final calibrationSensorProvider = FutureProvider<List<CalibrateSensor>>( (ref) async {
  final getSensor = ref.watch(getUseCaseCalibrationSensorProvider);
  return getSensor.execute();
});