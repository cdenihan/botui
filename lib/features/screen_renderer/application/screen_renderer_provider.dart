import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:stpvelox/core/lcm/domain/providers.dart';
import 'package:stpvelox/core/logging/has_logging.dart';
import 'package:stpvelox/core/service/sensors/ScreenReadingStrategy.dart';
import 'package:stpvelox/features/dynamic_ui/presentation/dynamic_ui_screen.dart';
import 'package:stpvelox/lcm/types/screen_render_t.g.dart';

part 'screen_renderer_provider.g.dart';

Widget? useScreenRenderValue(Ref ref) {
  return ref.watch(screenRenderProviderProvider);
}

@Riverpod(keepAlive: true)
class ScreenRenderProvider extends _$ScreenRenderProvider with HasLogger {
  int _messageCounter = 0;

  @override
  Widget? build() {
    log.info('[ScreenRenderProvider] build() called, initializing...');
    ref.onDispose(_dispose);
    _startSubscription();
    return null;
  }

  StreamSubscription? _subscription;

  void clear() {
    log.info('[ScreenRenderProvider] clear() called, setting state to null');
    state = null;
  }

  void _startSubscription() {
    final lcm = ref.read(lcmServiceProvider);
    log.info('[ScreenRenderProvider] Starting LCM subscription on libstp/screen_render');

    _subscription = lcm
        .subscribeAs<ScreenRenderT>(
      'libstp/screen_render',
      ScreenRenderT.decode,
    )
        .listen((decoded) async {
      _messageCounter++;
      final msgId = _messageCounter;
      final rawEntries = decoded.value.entries;
      final screenName = decoded.value.screen_name;
      final timestamp = DateTime.now().toIso8601String();

      log.info('[LCM RX #$msgId @ $timestamp] screen_render <- name=$screenName');
      log.fine('[LCM RX #$msgId] raw entries (${rawEntries.length} chars): ${rawEntries.substring(0, rawEntries.length > 200 ? 200 : rawEntries.length)}...');

      try {
        Map<String, dynamic> parsed = jsonDecode(rawEntries) as Map<String, dynamic>;
        log.fine('[LCM RX #$msgId] JSON parsed successfully, keys: ${parsed.keys.toList()}');

        if (screenName == 'dynamic_ui') {
          final oldState = state;
          log.info('[LCM RX #$msgId] Processing dynamic_ui message, current state: ${oldState?.runtimeType}');

          // Handle dynamic UI screens from Python
          if (parsed['screen'] == 'close') {
            // Close the dynamic UI screen
            log.info('[LCM RX #$msgId] Closing dynamic UI screen');
            clear();
          } else {
            final title = parsed['title'] ?? '<no title>';
            final bodyType = parsed['body']?['widget'] ?? '<no body widget>';
            log.info('[LCM RX #$msgId] Showing dynamic UI screen: title="$title", body widget="$bodyType"');

            final newScreen = DynamicUIScreen(
              key: ValueKey('dynamic_ui_$msgId'),
              screenData: parsed,
            );
            state = newScreen;
            log.info('[LCM RX #$msgId] State updated with new DynamicUIScreen (key: dynamic_ui_$msgId)');
          }
        } else {
          log.warning('[LCM RX #$msgId] Unknown screen_name: $screenName, ignoring');
        }
      } catch (e, stackTrace) {
        log.severe('[LCM RX #$msgId] Error processing screen_render message: $e');
        log.severe('[LCM RX #$msgId] Stack trace: $stackTrace');
      }
    }, onError: (error, stackTrace) {
      log.severe('[ScreenRenderProvider] LCM subscription error: $error');
      log.severe('[ScreenRenderProvider] Stack trace: $stackTrace');
    });

    log.info('[ScreenRenderProvider] LCM subscription started');
  }

  void _dispose() {
    log.info('[ScreenRenderProvider] _dispose() called, cancelling subscription');
    _subscription?.cancel();
    _subscription = null;
    log.info('[ScreenRenderProvider] Subscription cancelled');
  }
}

class ScreenRenderProviderStrategy extends ScreenReadingStrategy {
  @override
  Widget? readValue(Ref ref) {
    return useScreenRenderValue(ref);
  }
}
