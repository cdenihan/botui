import 'package:stpvelox/domain/entities/args/arg.dart';

class Program {
  final String name;

  Program({required this.name, required String runScript, required List<Arg> args});
}