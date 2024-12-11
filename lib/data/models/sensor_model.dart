import 'package:stpvelox/domain/entities/sensor.dart';

class SensorModel extends Sensor {
  SensorModel({required String name, required String value})
      : super(name: name, value: value);

  factory SensorModel.fromJson(Map<String, dynamic> json) {
    return SensorModel(
      name: json['name'],
      value: json['value'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'value': value,
    };
  }
}
