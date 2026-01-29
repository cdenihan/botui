import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stpvelox/application/inactivity/inactivity_notifier.dart';
import 'package:stpvelox/application/screensaver/screensaver_settings_provider.dart';
import 'package:stpvelox/core/logging/has_logging.dart';
import 'package:stpvelox/core/router/app_router.dart';

class InactivityListener extends ConsumerStatefulWidget {
  const InactivityListener({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  ConsumerState<InactivityListener> createState() => _InactivityListenerState();
}

class _InactivityListenerState extends ConsumerState<InactivityListener> with HasLogger {
  bool _screensaverShowing = false;

  void _handleUserActivity(String source) {
    log.finer('User activity detected from: $source');
    ref.read(inactivityProvider.notifier).userActivityDetected();
  }

  void _showScreensaver() {
    if (_screensaverShowing) return;

    final router = ref.read(appRouterProvider);
    final currentLocation = router.routerDelegate.currentConfiguration.fullPath;

    // Only show screensaver if we're on the dashboard
    if (!isDashboardRoute(currentLocation)) {
      log.fine('Screensaver blocked - not on dashboard (current: $currentLocation)');
      return;
    }

    final screensaverEnabled = ref.read(screensaverEnabledProvider);
    if (!screensaverEnabled) {
      log.fine('Screensaver disabled in settings');
      return;
    }

    if (!ScreensaverConfig.isWhitelisted('DashboardScreen')) {
      log.fine('DashboardScreen not whitelisted for screensaver');
      return;
    }

    log.info('Showing screensaver');
    _screensaverShowing = true;
    router.push(AppRoutes.robotFace);
  }

  void _hideScreensaver() {
    if (!_screensaverShowing) return;

    log.info('Hiding screensaver');
    _screensaverShowing = false;

    final router = ref.read(appRouterProvider);
    if (router.canPop()) {
      router.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<bool>(inactivityProvider, (previous, isInactive) {
      if (isInactive) {
        _showScreensaver();
      } else {
        _hideScreensaver();
      }
    });

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => _handleUserActivity('GestureDetector.onTap'),
      onScaleStart: (_) => _handleUserActivity('GestureDetector.onScaleStart'),
      child: Listener(
        behavior: HitTestBehavior.translucent,
        onPointerDown: (_) => _handleUserActivity('Listener.onPointerDown'),
        onPointerMove: (_) => _handleUserActivity('Listener.onPointerMove'),
        onPointerUp: (_) => _handleUserActivity('Listener.onPointerUp'),
        onPointerSignal: (_) => _handleUserActivity('Listener.onPointerSignal'),
        child: widget.child,
      ),
    );
  }
}
