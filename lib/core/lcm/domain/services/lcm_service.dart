import 'dart:async';
import 'dart:typed_data';

import 'package:raccoon_transport/raccoon_transport.dart';
import 'package:stpvelox/core/lcm/models/lcm_decoded.dart';
import 'package:stpvelox/core/logging/has_logging.dart';

/// LCM Service - uses lcm-dart directly (no MethodChannel, no polling!)
class LcmService with HasLogger {
  Lcm? _lcm;
  Completer<void>? _initCompleter;
  final Map<String, StreamController<LcmDecodedRaw>> _controllers = {};
  final Map<String, LcmSubscription> _subscriptions = {};
  bool _debugEnabled = false;

  /// Enable debug logging
  set debugEnabled(bool value) {
    _debugEnabled = value;
    _lcm?.debugEnabled = value;
  }

  bool get debugEnabled => _debugEnabled;

  /// Get LCM statistics
  LcmStats? get stats => _lcm?.stats;

  /// Check if initialized
  bool get isInitialized => _lcm != null;

  /// Future that completes when initialized
  Future<void> get ready => _initCompleter?.future ?? Future.value();

  /// Initialize LCM connection
  Future<void> init({String? provider}) async {
    if (_lcm != null) {
      log.warning('LCM already initialized');
      return;
    }

    if (_initCompleter != null) {
      // Already initializing, wait for it
      return _initCompleter!.future;
    }

    _initCompleter = Completer<void>();

    try {
      _lcm = await Lcm.create(provider);
      _lcm!.debugEnabled = _debugEnabled;
      log.info('LCM initialized: ${provider ?? "default"}');
      _initCompleter!.complete();
    } catch (e, st) {
      log.severe('LCM init failed: $e', st);
      _initCompleter!.completeError(e, st);
      _initCompleter = null;
      rethrow;
    }
  }

  /// Ensure LCM is ready before use
  Future<void> _ensureReady() async {
    if (_lcm != null) return;
    if (_initCompleter != null) {
      await _initCompleter!.future;
    } else {
      throw StateError('LCM not initialized. Call init() first.');
    }
  }

  /// Subscribe to raw messages on a channel
  Stream<LcmDecodedRaw> subscribe(String channel) {
    // Return existing stream if already subscribed
    if (_controllers.containsKey(channel)) {
      return _controllers[channel]!.stream;
    }

    final controller = StreamController<LcmDecodedRaw>.broadcast(
      onListen: () => _setupSubscription(channel),
    );
    _controllers[channel] = controller;

    // If already initialized, set up immediately
    if (_lcm != null) {
      _setupSubscription(channel);
    }

    return controller.stream;
  }

  void _setupSubscription(String channel) {
    if (_subscriptions.containsKey(channel)) return;
    if (_lcm == null) {
      // Wait for init and retry
      _initCompleter?.future.then((_) => _setupSubscription(channel));
      return;
    }

    final controller = _controllers[channel];
    if (controller == null) return;

    final sub = _lcm!.subscribe(channel, (ch, data) {
      if (!controller.isClosed) {
        controller.add(LcmDecodedRaw(
          topic: ch,
          utime: DateTime.now().microsecondsSinceEpoch,
          data: data,
        ));
      }
    });
    _subscriptions[channel] = sub;
    log.fine('Subscribed to: $channel');
  }

  /// Subscribe and decode messages to a specific type
  Stream<LcmDecoded<T>> subscribeAs<T>(String channel, LcmDecoder<T> decode) {
    return subscribe(channel).map((raw) {
      final buffer = LcmBuffer.fromUint8List(raw.data);
      return LcmDecoded<T>(
        topic: raw.topic,
        utime: raw.utime,
        raw: raw.data,
        value: decode(buffer),
      );
    });
  }

  /// Unsubscribe from a channel
  void unsubscribe(String channel) {
    final sub = _subscriptions.remove(channel);
    if (sub != null) {
      _lcm?.unsubscribe(sub);
    }

    final controller = _controllers.remove(channel);
    controller?.close();

    log.fine('Unsubscribed from: $channel');
  }

  /// Publish a typed message
  Future<void> publish(String channel, LcmMessage message) async {
    await _ensureReady();

    final buffer = LcmBuffer(65536);
    message.encode(buffer);
    final data = Uint8List.sublistView(buffer.uint8List, 0, buffer.position);
    _lcm!.publish(channel, data);
  }

  /// Publish raw data
  Future<void> publishRaw(String channel, Uint8List data) async {
    await _ensureReady();
    _lcm!.publish(channel, data);
  }

  /// Log current statistics
  void logStats() {
    _lcm?.logStats();
  }

  /// Dispose
  void dispose() {
    for (final controller in _controllers.values) {
      controller.close();
    }
    _controllers.clear();
    _subscriptions.clear();
    _lcm?.close();
    _lcm = null;
    log.info('LCM disposed');
  }
}

/// Raw message (before decoding)
class LcmDecodedRaw {
  final String topic;
  final int utime;
  final Uint8List data;

  LcmDecodedRaw({
    required this.topic,
    required this.utime,
    required this.data,
  });
}
