import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stpvelox/application/inactivity/inactivity_notifier.dart';
import 'package:stpvelox/core/utils/colors/colors.dart';
import 'package:stpvelox/core/widgets/dashboard_tile.dart';
import 'package:stpvelox/features/program/presentation/screens/program_selection_screen.dart';
import 'package:stpvelox/features/sensors/presentation/screens/sensor_selection_screen.dart';
import 'package:stpvelox/features/settings/presentation/pages/settings_screen.dart';
import 'package:stpvelox/presentation/screens/robot_face_screen.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Listen for state changes
    ref.listen<bool>(inactivityProvider, (previous, next) {
      if (next == true) {
        // Navigate to the inactive screens
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const RobotFaceScreen()),
        );
      }
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
