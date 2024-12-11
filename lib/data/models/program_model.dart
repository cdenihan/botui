import 'package:stpvelox/domain/entities/program.dart';

class ProgramModel extends Program {
  ProgramModel({required String name, required String status})
      : super(name: name, status: status);

  factory ProgramModel.fromJson(Map<String, dynamic> json) {
    return ProgramModel(
      name: json['name'],
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'status': status,
    };
  }
}
