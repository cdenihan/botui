enum SensorCategory {
  analog('Analog'),
  digital('Digital'),
  motor('Motor'),
  servo('Servo'),
  gyro('Gyro'),
  accel('Accel'),
  mag('Magneto'),
  orientation('Orientation'),
  heading('Heading'),
  temperature('Temperature'),
  battery('Battery'),
  ;

  final String name;

  const SensorCategory(this.name);
}