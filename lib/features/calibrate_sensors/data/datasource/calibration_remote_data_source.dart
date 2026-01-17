import 'package:stpvelox/features/calibrate_sensors/domain/entities/calibrate_sensor.dart';
import 'package:stpvelox/features/calibrate_sensors/domain/entities/calibration_sensor_type.dart';
import 'package:stpvelox/features/calibrate_sensors/presentation/screens/calibration_sensors_black_white_screen.dart';
import 'package:stpvelox/features/calibrate_sensors/presentation/screens/calibration_sensors_wait_for_light_screen.dart';
import 'package:stpvelox/features/calibrate_sensors/presentation/screens/calibration_distance_screen.dart';


abstract class CalibrationSensorsRemoteDataSource {
  Future<List<CalibrateSensor>> fetchCalibration();
}

class CalibrationSensorsRemoteDataSourceImpl
    extends CalibrationSensorsRemoteDataSource {
  CalibrateSensor getBlackWhite() {
    return CalibrateSensor(
        name: 'Analog',
        sensorType: CalibrationSensorType.blackWhite,
        getWidgetScreen: (sensor) =>
            BlackWhiteCalibrateScreenUnified(sensor: sensor));
  }

  CalibrateSensor getWaitForLight(int port){
    return CalibrateSensor(
      name: 'Analog $port',
      sensorType: CalibrationSensorType.waitForLight,
      getWidgetScreen: (sensor) => CalibrationsSensorsWaitForLightScreen(port: port, sensor: sensor)
    );
  }

  CalibrateSensor getDistanceCalibration() {
    return CalibrateSensor(
      name: 'Distance',
      sensorType: CalibrationSensorType.distanceCalibration,
      getWidgetScreen: (sensor) => CalibrationDistanceScreen(),
    );
  }

  @override
  Future<List<CalibrateSensor>> fetchCalibration() async {
    return [
        getBlackWhite()
    ];
  }
}
