enum SensorCategory {
  analog('Analog'),
  digital('Digital'),
  motor('Motor'),
  servo('Servo'),
  gyro('Gyro'),
  accel('Accelerometer'),
  mag('Magnetometer'),
  ;

  final String name;

  const SensorCategory(this.name);
}