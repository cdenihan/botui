
import 'package:stpvelox/features/calibrate_sensors/domain/entities/calibrate_sensor.dart';

abstract class CalibrationRepository{
    Future<List<CalibrateSensor>> getCalibrationSensors();
}