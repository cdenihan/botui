
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

abstract class ScreenReadingStrategy {
  Widget? readValue(Ref ref);
}