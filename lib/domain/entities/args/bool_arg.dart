import 'arg.dart';

class BoolArg extends Arg {
  final bool initial;

  BoolArg({required this.initial}) : super(type: 'bool');

  factory BoolArg.fromJson(Map<String, dynamic> json) {
    return BoolArg(
      initial: json['initial'] ?? false,
    );
  }
}