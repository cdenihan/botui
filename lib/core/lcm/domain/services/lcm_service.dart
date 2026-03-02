import 'dart:async';
import 'dart:typed_data';

import 'package:raccoon_transport/raccoon_transport.dart';
import 'package:stpvelox/core/lcm/models/lcm_decoded.dart';
import 'package:stpvelox/core/logging/has_logging.dart';

/// LCM Service - uses RaccoonTransport for retain + reliable delivery
class LcmService with HasLogger {
  RaccoonTransport? _transport;
  Completer<void>? _initCompleter;
  final Map<String, StreamController<LcmDecodedRaw>> _controllers = {};
  final Map<String, LcmSubscription> _subscriptions = {};
  final Map<String, SubscribeOptions> _subscribeOptions = {};

  /// Check if initialized
  bool get isInitialized => _transport != null;

  /// Future that completes when initialized
  Future<void> get ready => _initCompleter?.future ?? Future.value();

  /// Initialize transport connection
  Future<void> init({String? provider}) async {
    if (_transport != null) {
      log.warning('Transport already initialized');
      return;
    }

    if (_initCompleter != null) {
      // Already initializing, wait for it
      return _initCompleter!.future;
    }

    _initCompleter = Completer<void>();

    try {
      _transport = await RaccoonTransport.create(provider);
      log.info('Transport initialized: ${provider ?? "default"}');
      _initCompleter!.complete();
    } catch (e, st) {
      log.severe('Transport init failed: $e', st);
      _initCompleter!.completeError(e, st);
      _initCompleter = null;
      rethrow;
    }
  }

  /// Ensure transport is ready before use
  Future<void> _ensureReady() async {
    if (_transport != null) return;
    if (_initCompleter != null) {
      await _initCompleter!.future;
    } else {
      throw StateError('Transport not initialized. Call init() first.');
    }
  }

  /// Subscribe to raw messages on a channel
  Stream<LcmDecodedRaw> subscribe(String channel,
      {SubscribeOptions options = const SubscribeOptions()}) {
    // Return existing stream if already subscribed
    if (_controllers.containsKey(channel)) {
      return _controllers[channel]!.stream;
    }

    _subscribeOptions[channel] = options;

    final controller = StreamController<LcmDecodedRaw>.broadcast(
      onListen: () => _setupSubscription(channel),
    );
    _controllers[channel] = controller;

    // If already initialized, set up immediately
    if (_transport != null) {
      _setupSubscription(channel);
    }

    return controller.stream;
  }

  void _setupSubscription(String channel) {
    if (_subscriptions.containsKey(channel)) return;
    if (_transport == null) {
      // Wait for init and retry
      _initCompleter?.future.then((_) => _setupSubscription(channel));
      return;
    }

    final controller = _controllers[channel];
    if (controller == null) return;

    final options =
        _subscribeOptions[channel] ?? const SubscribeOptions();

    final sub = _transport!.subscribe(channel, (ch, data) {
      if (!controller.isClosed) {
        controller.add(LcmDecodedRaw(
          topic: ch,
          utime: DateTime.now().microsecondsSinceEpoch,
          data: data,
        ));
      }
    }, options: options);
    _subscriptions[channel] = sub;
    log.fine('Subscribed to: $channel (retain=${options.requestRetained})');
  }

  /// Subscribe and decode messages to a specific type
  Stream<LcmDecoded<T>> subscribeAs<T>(String channel, LcmDecoder<T> decode,
      {SubscribeOptions options = const SubscribeOptions()}) {
    return subscribe(channel, options: options).map((raw) {
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
      _transport?.unsubscribe(sub);
    }

    final controller = _controllers.remove(channel);
    controller?.close();
    _subscribeOptions.remove(channel);

    log.fine('Unsubscribed from: $channel');
  }

  /// Publish a typed message
  Future<void> publish(String channel, LcmMessage message,
      {PublishOptions options = const PublishOptions()}) async {
    await _ensureReady();
    _transport!.publishMessage(channel, message, options: options);
  }

  /// Publish raw data
  Future<void> publishRaw(String channel, Uint8List data,
      {PublishOptions options = const PublishOptions()}) async {
    await _ensureReady();
    _transport!.publish(channel, data, options: options);
  }

  /// Dispose
  void dispose() {
    for (final controller in _controllers.values) {
      controller.close();
    }
    _controllers.clear();
    _subscriptions.clear();
    _subscribeOptions.clear();
    _transport?.dispose();
    _transport = null;
    log.info('Transport disposed');
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
