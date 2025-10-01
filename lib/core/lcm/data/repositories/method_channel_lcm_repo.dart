import 'package:flutter/services.dart';
import 'package:stpvelox/core/lcm/domain/repositories/lcm_repo.dart';
import 'package:stpvelox/core/lcm/models/lcm_message.dart';
import 'package:stpvelox/core/logging/has_logging.dart';

class MethodChannelLcmRepo with HasLogger implements LcmRepo {
  static const MethodChannel _chan = MethodChannel('flutter/lcm');
  final Map<String, int> _subscriptionIds = {};
  bool _isInitialized = false;

  Future<void> _ensureInitialized() async {
    if (_isInitialized) return;

    try {
      await _chan.invokeMethod<void>('init');
      _isInitialized = true;
      log.info('LCM initialized successfully');
    } catch (e, st) {
      if (e is PlatformException && e.code == 'LCM_ALREADY_INITIALIZED') {
        log.fine('LCM was already initialized, continuing...');
        _isInitialized = true;
        return;
      }

      log.severe('LCM init error: $e', st);
      rethrow;
    }
  }

  @override
  Future<List<LcmMessage>> poll({int timeoutMs = 0, int maxMessages = 64}) async {
    if (timeoutMs < 0) timeoutMs = 0;
    if (maxMessages <= 0) maxMessages = 1;

    try {
      await _ensureInitialized();

      final result = await _chan.invokeMethod<List<dynamic>>('poll', {
        'timeoutMs': timeoutMs,
        'maxMessages': maxMessages,
      });

      final messages = (result ?? [])
          .map((e) => LcmMessage.fromMap(e as Map<dynamic, dynamic>))
          .toList();

      return messages;
    } catch (e, st) {
      log.severe('LCM poll error: $e', st);
      return [];
    }
  }

  @override
  Future<void> publish(String topic,Uint8List data) async {
    if (topic.isEmpty) throw ArgumentError('empty topic');

    try {
      await _ensureInitialized();

      await _chan.invokeMethod<void>('publish', {
        'channel': topic,
        'data': data,
      });
    } catch (e, st) {
      log.severe('LCM publish error: $e', st);
      rethrow;
    }
  }

  @override
  Future<int?> subscribe(String topic) async {
    try {
      await _ensureInitialized();

      final int? subscriptionId = await _chan.invokeMethod<int>('subscribe', {
        'channel': topic,
      });

      if (subscriptionId == null) {
        throw Exception('Failed to get subscription ID for topic "$topic"');
      }

      log.info('Subscribed to "$topic" with ID $subscriptionId');
      return subscriptionId;
    } catch (e, st) {
      log.severe('LCM subscribe error: $e', st);
      rethrow;
    }
  }

  @override
  Future<void> unsubscribe(int subscriptionId) async {
    await _chan.invokeMethod<void>('unsubscribe', {
      'subscriptionId': subscriptionId,
    });
  }

  Future<void> cleanup() async {
    for (final subscriptionId in _subscriptionIds.values) {
      await unsubscribe(subscriptionId);
    }

    _isInitialized = false;
  }

  @override
  void dispose() {
    cleanup();
    _subscriptionIds.clear();
  }
}
