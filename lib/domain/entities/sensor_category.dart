enum SensorCategory {
  analog('Analog'),
  digital('Digital'),
  motor('Motor'),
  servo('Servo'),
  gyro('Gyro'),
  accel('Accelerometer'),
  mag('Magnetometer'),
  orientation('Orientation'),
  ;

  final String name;

  const SensorCategory(this.name);
}