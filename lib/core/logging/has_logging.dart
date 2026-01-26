import 'package:logging/logging.dart';
import 'package:stpvelox/core/logging/logging.dart';

mixin HasLogger {
  late final Logger log = getLogger(runtimeType.toString());
}