import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:stpvelox/core/logging/has_logging.dart';
import 'package:stpvelox/core/router/app_router.dart';
import 'package:stpvelox/core/utils/colors/colors.dart';

import '../../../screen_renderer/application/screen_renderer_provider.dart';

class DashboardScreen extends ConsumerWidget with HasLogger {
  DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    // Handle calibration screens pushed from LCM - only when on dashboard
    ref.listen<Widget?>(screenRenderProviderProvider, (previous, next) {
      final timestamp = DateTime.now().toIso8601String();
      final currentLocation = router.routerDelegate.currentConfiguration.fullPath;
      final isDashboard = isDashboardRoute(currentLocation);
      final isCalibrationRoute = currentLocation == AppRoutes.calibrationScreen;

      log.info('[LISTENER @ $timestamp] screenRenderProvider changed');
      log.info('[LISTENER] currentLocation="$currentLocation"');
      log.info('[LISTENER] previous: ${previous?.runtimeType} (key=${previous?.key})');
      log.info('[LISTENER] next: ${next?.runtimeType} (key=${next?.key})');

      if (!isDashboard && !isCalibrationRoute) {
        log.info('[LISTENER] Not on dashboard or calibration route, ignoring screen update');
        return; // Only react when on dashboard (push) or calibration (replace)
      }

      if (next == null) {
        log.info('[LISTENER] next is null, attempting to pop');
        if (context.canPop()) {
          log.info('[LISTENER] Popping current screen');
          context.pop();
        } else {
          log.info('[LISTENER] Cannot pop, no screen to pop');
        }
        return;
      }

      // IMPORTANT: Compare by key instead of just runtimeType to detect content changes
      final previousKey = previous?.key;
      final nextKey = next.key;

      if (previous == next) {
        log.info('[LISTENER] previous == next (same object), skipping');
        return;
      }

      if (isCalibrationRoute) {
        log.info('[LISTENER] Replacing existing calibration screen with updated content');
        router.replace(AppRoutes.calibrationScreen, extra: next);
        log.info('[LISTENER] Screen replaced successfully');
      } else {
        log.info('[LISTENER] Pushing new screen to calibrationScreen route');
        context.push(AppRoutes.calibrationScreen, extra: next);
        log.info('[LISTENER] Screen pushed successfully');
      }
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            children: [
              Expanded(
                flex: 1,
                child: _DashboardTile(
                  label: "Sensors & Actors",
                  icon: Icons.sensors,
                  route: AppRoutes.sensors,
                  color: AppColors.sensors,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                flex: 2,
                child: _DashboardTile(
                  label: "Programs",
                  icon: Icons.code,
                  route: AppRoutes.programs,
                  color: AppColors.programs,
                  isMain: true,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                flex: 1,
                child: _DashboardTile(
                  label: "Settings",
                  icon: Icons.settings,
                  route: AppRoutes.settings,
                  color: AppColors.settings,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Dashboard tile that navigates using go_router
class _DashboardTile extends StatelessWidget {
  final String label;
  final IconData icon;
  final String route;
  final Color color;
  final bool isMain;

  const _DashboardTile({
    required this.label,
    required this.icon,
    required this.route,
    required this.color,
    this.isMain = false,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: label,
      button: true,
      child: GestureDetector(
        onTap: () => context.push(route),
        child: Container(
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [
              BoxShadow(
                color: Colors.black45,
                offset: Offset(0, 4),
                blurRadius: 6,
              ),
            ],
          ),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  size: isMain ? 60 : 50,
                  color: Colors.white,
                ),
                SizedBox(height: isMain ? 12 : 8),
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isMain ? 26 : 22,
                    fontWeight: isMain ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
