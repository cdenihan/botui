import 'package:stpvelox/features/calibrate_sensors/domain/entities/calibrate_sensor.dart';
import 'package:stpvelox/features/calibrate_sensors/domain/entities/calibration_sensor_type.dart';
import 'package:stpvelox/features/calibrate_sensors/presentation/screens/calibration_sensors_black_white_screen.dart';
import 'package:stpvelox/features/calibrate_sensors/presentation/screens/calibration_sensors_wait_for_light_screen.dart';


abstract class CalibrationSensorsRemoteDataSource {
  Future<List<CalibrateSensor>> fetchCalibration();
}

class CalibrationSensorsRemoteDataSourceImpl
    extends CalibrationSensorsRemoteDataSource {
  CalibrateSensor getBlackWhite(int port) {
    return CalibrateSensor(
        name: 'Analog $port',
        sensorType: CalibrationSensorType.blackWhite,
        getWidgetScreen: (sensor) =>
            BlackWhiteCalibrateScreenUnified(port: port, sensor: sensor));
  }

  CalibrateSensor getWaitForLight(int port){
    return CalibrateSensor(
      name: 'Analog $port',
      sensorType: CalibrationSensorType.waitForLight,
      getWidgetScreen: (sensor) => CalibrationsSensorsWaitForLightScreen(port: port, sensor: sensor)
    );
  }

  @override
  Future<List<CalibrateSensor>> fetchCalibration() async {
    return [
      for (int port = 0; port < 6; port++)
        getBlackWhite(port)
    ];
  }
}
