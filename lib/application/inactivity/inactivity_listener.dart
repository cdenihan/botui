import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stpvelox/application/inactivity/inactivity_notifier.dart';
import 'package:stpvelox/core/logging/has_logging.dart';

class InactivityListener extends ConsumerWidget with HasLogger {
  InactivityListener({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.watch(inactivityProvider.notifier);

    void handleUserActivity(String source) {
      log.finer('User activity detected from: $source');
      notifier.userActivityDetected();
    }

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => handleUserActivity('GestureDetector.onTap'),
      onScaleStart: (_) => handleUserActivity('GestureDetector.onScaleStart'),
      child: Listener(
        behavior: HitTestBehavior.translucent,
        onPointerDown: (_) => handleUserActivity('Listener.onPointerDown'),
        onPointerMove: (_) => handleUserActivity('Listener.onPointerMove'),
        onPointerUp: (_) => handleUserActivity('Listener.onPointerUp'),
        onPointerSignal: (_) => handleUserActivity('Listener.onPointerSignal'),
        child: child,
      ),
    );
  }
}
