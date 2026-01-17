enum CalibrationSensorType{
  blackWhite('Black and White'),
  waitForLight('Wait for Light'),
  distanceCalibration('Distance Calibration');

  final String name;

  const CalibrationSensorType(this.name);
}