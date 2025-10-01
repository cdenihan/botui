import 'dart:async';
import 'dart:typed_data';

import 'package:stpvelox/core/lcm/domain/repositories/lcm_repo.dart';
import 'package:stpvelox/core/lcm/models/lcm_decoded.dart';
import 'package:stpvelox/core/lcm/models/lcm_message.dart';
import 'package:stpvelox/core/logging/has_logging.dart';

class LcmService with HasLogger {
  final Map<String, StreamController<LcmMessage>> _streamControllers = {};
  final Map<String, int> _subscriptionIds = {};
  final Map<String, List<LcmMessage>> _messageQueues = {};
  bool _isPolling = false;
  Timer? _pollTimer;
  LcmRepo repo;

  LcmService({required this.repo});

  Stream<LcmMessage> subscribe(String topic) {
    if (topic.isEmpty) throw ArgumentError('empty topic');

    if (!_streamControllers.containsKey(topic)) {
      _streamControllers[topic] = StreamController<LcmMessage>.broadcast();
      _messageQueues[topic] = [];
      repo.subscribe(topic).then((id) {
        if (id != null) {
          _subscriptionIds[topic] = id;
        }
      });
    }

    return _streamControllers[topic]!.stream;
  }

  Future<void> unsubscribe(String topic) async {
    final subscriptionId = _subscriptionIds[topic];
    if (subscriptionId == null) return;

    try {
      await repo.unsubscribe(subscriptionId);

      _subscriptionIds.remove(topic);
      _messageQueues.remove(topic);

      final controller = _streamControllers.remove(topic);
      controller?.close();

      log.info('Unsubscribed from "$topic" with ID $subscriptionId');
    } catch (e, st) {
      log.severe('LCM unsubscribe error: $e', st);
      rethrow;
    }
  }

  Future<void> publish(String topic, List<int> bytes) async {
    if (topic.isEmpty) throw ArgumentError('empty topic');

    final data = Uint8List.fromList(bytes);
    repo.publish(topic, data);
  }

  Future<void> poll({int timeoutMs = 0, int maxMessages = 64}) async {
    final messages =
        await repo.poll(timeoutMs: timeoutMs, maxMessages: maxMessages);
    for (final message in messages) {
      _deliverMessage(message);
      _messageQueues[message.topic]?.add(message);
    }
  }

  Future<void> startPolling({int pollIntervalMs = 20}) async {
    if (_isPolling) return;
    _isPolling = true;

    final duration = Duration(milliseconds: pollIntervalMs);
    _pollTimer = Timer.periodic(duration, (_) async {
      if (!_isPolling) return;
      try {
        await poll(timeoutMs: 0, maxMessages: 64);
      } catch (e, st) {
        log.severe('LCM poll error: $e', st);
      }
    });
  }

  Future<void> stopPolling() async {
    if (!_isPolling) return;

    _isPolling = false;
    _pollTimer?.cancel();
    _pollTimer = null;
  }

  void dispose() {
    stopPolling();
    for (final controller in _streamControllers.values) {
      controller.close();
    }
    _streamControllers.clear();
    _subscriptionIds.clear();
    _messageQueues.clear();
  }

  Stream<LcmDecoded<T>> subscribeAs<T>(String topic, LcmDecoder<T> decode) {
    final base = subscribe(topic);
    return base.map((m) {
      log.fine('LCM message on $topic: ${m.data.length} bytes');
      log.finer('Raw data: ${m.data.toList()}');
      return LcmDecoded<T>(
        topic: m.topic,
        utime: m.utime,
        raw: m.data,
        value: decode(m.data),
      );
    });
  }

  void _deliverMessage(LcmMessage message) {
    final controller = _streamControllers[message.topic];
    log.fine('LCM message on ${message.topic}: ${message.data.length} bytes');
    log.fine('Raw data: ${message.data.toList()}');
    log.fine('Controller: $controller');
    log.fine(_streamControllers.keys.toList());
    if (controller != null && !controller.isClosed) {
      log.fine(
          'Delivering message on ${message.topic}: ${message.data.length} bytes');
      controller.add(message);
    }
  }
}
