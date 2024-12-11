import 'arg.dart';

class NumberArg extends Arg {
  final double initial;
  final double min;
  final double max;
  final double step;

  NumberArg({
    required this.initial,
    required this.min,
    required this.max,
    required this.step,
  }) : super(type: 'number');


  factory NumberArg.fromJson(Map<String, dynamic> json) {
    return NumberArg(
      initial: (json['initial'] ?? 0).toDouble(),
      min: (json['min'] ?? 0).toDouble(),
      max: (json['max'] ?? 100).toDouble(),
      step: (json['step'] ?? 1).toDouble(),
    );
  }
}