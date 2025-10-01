import 'dart:typed_data';

import 'package:stpvelox/core/lcm/models/lcm_message.dart';

abstract class LcmRepo {
  Future<int?> subscribe(String topic);

  Future<void> unsubscribe(int subscriptionId);

  Future<void> publish(String topic, Uint8List data);

  Future<List<LcmMessage>> poll({int timeoutMs = 0, int maxMessages = 64});

  void dispose();
}
