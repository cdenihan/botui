import 'package:stpvelox/domain/entities/args/bool_arg.dart';
import 'package:stpvelox/domain/entities/args/enum_arg.dart';
import 'package:stpvelox/domain/entities/args/number_arg.dart';

abstract class Arg {
  final String type;

  Arg({required this.type});

  factory Arg.fromJson(Map<String, dynamic> json) {
    switch (json['type']) {
      case 'number':
        return NumberArg.fromJson(json);
      case 'bool':
        return BoolArg.fromJson(json);
      case 'enum':
        return EnumArg.fromJson(json);
      default:
        throw UnsupportedError('Unsupported argument type: ${json['type']}');
    }
  }
}
