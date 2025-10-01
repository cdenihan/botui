import 'dart:async';
import 'dart:math';
import 'dart:typed_data';

import 'package:stpvelox/core/lcm/domain/repositories/lcm_repo.dart';
import 'package:stpvelox/core/lcm/models/lcm_message.dart';
import 'package:stpvelox/core/logging/has_logging.dart';

class MockLcmRepo with HasLogger implements LcmRepo {
  final List<LcmMessage> _inbox = [];
  final Set<String> _topics = {};
  final Map<int, String> _subscriptionIds = {};
  int _utimeCounter = 1;

  @override
  Future<List<LcmMessage>> poll({int timeoutMs = 0, int maxMessages = 64}) {
    final n = _inbox.length < maxMessages ? _inbox.length : maxMessages;
    final out = List<LcmMessage>.from(_inbox.take(n));
    _inbox.removeRange(0, n);
    return Future.value(out);
  }

  @override
  Future<void> publish(String topic, Uint8List data) async {
    if (_topics.contains(topic)) {
      final message = LcmMessage(
        topic: topic,
        utime: _utimeCounter++,
        data: data,
      );
      _inbox.add(message);
    }
  }

  @override
  Future<int?> subscribe(String topic) {
    final id = Random().nextInt(1 << 31);
    _topics.add(topic);
    _subscriptionIds[id] = topic;
    return Future.value(id);
  }

  @override
  Future<void> unsubscribe(int subscriptionId) {
    final topic = _subscriptionIds.remove(subscriptionId);
    if (topic != null) {
      _topics.remove(topic);
    }
    return Future.value();
  }

  @override
  void dispose() {
    _inbox.clear();
    _topics.clear();
    _subscriptionIds.clear();
  }
}
