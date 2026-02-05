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

    // Handle dynamic UI screen — push once when data appears, pop when cleared.
    // The DynamicUIScreen itself watches the provider for content updates,
    // so we never need to push/replace for content changes.
    ref.listen<Map<String, dynamic>?>(screenRenderProviderProvider, (previous, next) {
      final timestamp = DateTime.now().toIso8601String();
      final currentLocation = router.routerDelegate.currentConfiguration.fullPath;
      final isDashboard = isDashboardRoute(currentLocation);
      final isCalibrationRoute = currentLocation == AppRoutes.calibrationScreen;

      log.info('[LISTENER @ $timestamp] screenRenderProvider changed');
      log.info('[LISTENER] currentLocation="$currentLocation"');
      log.info('[LISTENER] had data=${previous != null}, has data=${next != null}');

      if (!isDashboard && !isCalibrationRoute) {
        log.info('[LISTENER] Not on dashboard or calibration route, ignoring');
        return;
      }

      final wasOpen = previous != null;
      final shouldBeOpen = next != null;

      if (!wasOpen && shouldBeOpen && isDashboard) {
        // First data arrived — push the screen once
        log.info('[LISTENER] Pushing DynamicUI screen');
        context.push(AppRoutes.calibrationScreen);
      } else if (wasOpen && !shouldBeOpen && isCalibrationRoute) {
        // Data cleared — pop the screen
        log.info('[LISTENER] Popping DynamicUI screen');
        if (context.canPop()) {
          context.pop();
        }
      }
      // Content changes (wasOpen && shouldBeOpen) are handled by
      // DynamicUIScreen watching the provider — no navigation needed.
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
