import 'package:logging/logging.dart';

mixin HasLogger {
  late final Logger log = Logger(runtimeType.toString());
}