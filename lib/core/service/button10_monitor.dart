import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:stpvelox/core/logging/has_logging.dart';
import 'package:stpvelox/core/router/app_router.dart';
import 'package:stpvelox/core/service/sensors/digital_sensor.dart';

part 'button10_monitor.g.dart';

/// Monitors button 10 for long presses:
/// - 3 seconds: Opens Dev Menu
@riverpod
class Button10Monitor extends _$Button10Monitor with HasLogger {
  static const _devMenuDuration = Duration(seconds: 3);

  DateTime? _holdStart;
  bool _menuOpened = false;

  @override
  void build() {
    // Watch digital sensor 10
    ref.listen(digitalSensorProvider(10), (previous, next) {
      _onSensorChanged(next);
    });
  }

  void _onSensorChanged(bool? isPressed) {
    if (isPressed == true) {
      // Button pressed - start tracking
      _holdStart ??= DateTime.now();
      _menuOpened = false;
    } else {
      // Button released - reset
      _holdStart = null;
      _menuOpened = false;
    }
  }

  /// Call this periodically to check hold duration and trigger actions
  void checkHoldDuration() {
    if (_holdStart == null) return;

    final elapsed = DateTime.now().difference(_holdStart!);

    if (elapsed >= _devMenuDuration && !_menuOpened) {
      _menuOpened = true;
      _openDevMenu();
    }
  }

  void _openDevMenu() {
    log.info('Button 10 held for 3 seconds - opening Dev Menu!');

    final router = ref.read(appRouterProvider);
    final currentRoute = router.routerDelegate.currentConfiguration.fullPath;

    // Don't open if already on dev menu or any easter egg screen
    if (currentRoute != AppRoutes.devMenu &&
        currentRoute != AppRoutes.flappyWombat) {
      router.push(AppRoutes.devMenu);
    }
  }
}
