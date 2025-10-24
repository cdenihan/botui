import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stpvelox/application/inactivity/inactivity_notifier.dart';
import 'package:stpvelox/core/logging/has_logging.dart';
import 'package:stpvelox/core/utils/colors/colors.dart';
import 'package:stpvelox/core/widgets/dashboard_tile.dart';
import 'package:stpvelox/features/program/presentation/screens/program_selection_screen.dart';
import 'package:stpvelox/features/sensors/presentation/screens/sensor_selection_screen.dart';
import 'package:stpvelox/features/settings/presentation/pages/settings_screen.dart';
import 'package:stpvelox/presentation/screens/robot_face_screen.dart';

import '../../../screen_renderer/application/screen_renderer_provider.dart';

class DashboardScreen extends ConsumerWidget with HasLogger{
  DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<bool>(inactivityProvider, (previous, next) {
      if (next == true) {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const RobotFaceScreen()),
        );
      }
    });


    ref.listen<Widget?>(screenRenderProviderProvider, (previous, next) {
      if (next == null) return;

      if (previous?.runtimeType == next.runtimeType) return;

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => next,
          settings: RouteSettings(name: next.runtimeType.toString()),
        ),
      );
    });





    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            children: [
              const Expanded(
                flex: 1,
                child: DashboardTile(
                  label: "Sensors & Actors",
                  icon: Icons.sensors,
                  destination: SensorSelectionScreen(),
                  color: AppColors.sensors,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                flex: 2,
                child: DashboardTile(
                  label: "Programs",
                  icon: Icons.code,
                  destination: ProgramSelectionScreen(),
                  color: AppColors.programs,
                  isMain: true,
                ),
              ),
              const SizedBox(height: 16),
              const Expanded(
                flex: 1,
                child: DashboardTile(
                  label: "Settings",
                  icon: Icons.settings,
                  destination: SettingsScreen(),
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
