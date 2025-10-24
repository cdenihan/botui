
import 'package:stpvelox/features/calibrate_sensors/domain/entities/calibrate_sensor.dart';
import 'package:stpvelox/features/calibrate_sensors/domain/repositories/calibration_repository.dart';

class GetCalibrationSensors{
  final CalibrationRepository calibrationRepository;

  GetCalibrationSensors({
    required this.calibrationRepository
  });

  Future<List<CalibrateSensor>> execute() async {
    return await calibrationRepository.getCalibrationSensors();
  }
}