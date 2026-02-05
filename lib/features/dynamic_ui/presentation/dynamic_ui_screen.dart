import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:stpvelox/core/lcm/domain/providers.dart';
import 'package:stpvelox/features/screen_renderer/application/screen_renderer_provider.dart';
import 'package:stpvelox/lcm/types/screen_render_answer_t.g.dart';

import 'widget_decoder.dart';

final _log = Logger('DynamicUIScreen');

/// Dynamic UI screen that renders widgets from JSON definitions.
///
/// Watches the [ScreenRenderProvider] directly so that only a single instance
/// ever exists. When new data arrives the widget simply re-renders in place
/// instead of being pushed/popped on the navigation stack.
class DynamicUIScreen extends HookConsumerWidget {
  const DynamicUIScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenData = ref.watch(screenRenderProviderProvider);

    if (screenData == null) {
      // Provider cleared while we're still mounted — show nothing.
      return const SizedBox.shrink();
    }

    final buildTimestamp = DateTime.now().toIso8601String();
    final title = screenData['title'] as String? ?? 'Screen';
    final body = screenData['body'] as Map<String, dynamic>?;

    _log.info('[BUILD @ $buildTimestamp] DynamicUIScreen building with title="$title"');
    _log.fine('[BUILD] screenData keys: ${screenData.keys.toList()}');
    _log.fine('[BUILD] body widget type: ${body?['widget'] ?? 'null'}');

    // Track current input values
    final values = useState<Map<String, dynamic>>({});

    // Re-extract initial values whenever screenData changes
    useEffect(() {
      _log.info('[EFFECT] useEffect triggered for screenData change, title="$title"');
      final newValues = <String, dynamic>{};
      _extractInitialValues(screenData, newValues);
      values.value = newValues;
      _log.fine('[EFFECT] Initial values extracted: ${values.value}');
      return null;
    }, [screenData]);

    void sendEvent(String action, {Map<String, dynamic>? extra}) {
      final timestamp = DateTime.now().toIso8601String();
      final lcm = ref.read(lcmServiceProvider);

      final payload = {
        '_action': action,
        'values': values.value,
        ...?extra,
      };

      final response = ScreenRenderAnswerT(
        screen_name: 'dynamic_ui',
        value: action,
        reason: jsonEncode(payload),
      );

      _log.info('[LCM TX @ $timestamp] screen_answer -> action=$action');
      _log.fine('[LCM TX] extra=$extra');
      _log.fine('[LCM TX] current values=${values.value}');
      _log.fine('[LCM TX] full payload=${jsonEncode(payload)}');
      lcm.publish('libstp/screen_render/answer', response);
      _log.info('[LCM TX] Message published successfully');
    }

    void onValueChanged(String widgetId, dynamic value) {
      values.value = {...values.value, widgetId: value};

      // Send change event
      sendEvent('change', extra: {
        'widget_id': widgetId,
        'value': value,
      });
    }

    void onButtonClicked(String buttonId) {
      sendEvent('click', extra: {
        'button_id': buttonId,
      });
    }

    void onKeypadInput(String key) {
      sendEvent('keypad', extra: {
        'key': key,
      });
    }

    final decoder = WidgetDecoder(
      onValueChanged: onValueChanged,
      onButtonClicked: onButtonClicked,
      onKeypadInput: onKeypadInput,
      ref: ref,
    );

    _log.info('[BUILD] Creating widget tree for title="$title"');

    Widget bodyWidget;
    if (body != null) {
      _log.info('[BUILD] Decoding body widget...');
      bodyWidget = decoder.decode(body);
      _log.info('[BUILD] Body widget decoded successfully');
    } else {
      _log.warning('[BUILD] No body content, showing placeholder');
      bodyWidget = const Center(
        child: Text('No content', style: TextStyle(color: Colors.grey)),
      );
    }

    _log.info('[BUILD] Returning Scaffold for title="$title"');

    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.grey[900],
          automaticallyImplyLeading: false,
          title: Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          toolbarHeight: 80,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: bodyWidget,
        ),
      ),
    );
  }
}

void _extractInitialValues(Map<String, dynamic> data, Map<String, dynamic> values) {
  // Recursively extract initial values from widgets
  void extract(dynamic item) {
    if (item is Map<String, dynamic>) {
      final id = item['id'] as String?;
      final value = item['value'];
      if (id != null && value != null) {
        values[id] = value;
      }

      final children = item['children'];
      if (children is List) {
        for (final child in children) {
          extract(child);
        }
      }

      final left = item['left'];
      if (left is List) {
        for (final child in left) {
          extract(child);
        }
      }
      final right = item['right'];
      if (right is List) {
        for (final child in right) {
          extract(child);
        }
      }

      final body = item['body'];
      if (body is Map<String, dynamic>) {
        extract(body);
      }
    }
  }

  extract(data);
}
