import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stpvelox/application/inactivity/inactivity_notifier.dart';

class InactivityListener extends ConsumerWidget {
  const InactivityListener({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.watch(inactivityProvider.notifier);

    return Listener(
      behavior: HitTestBehavior.translucent, // captures even on empty space
      onPointerDown: (_) => notifier.userActivityDetected(),
      child: child,
    );
  }
}
