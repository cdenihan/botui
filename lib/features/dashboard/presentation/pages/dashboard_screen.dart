import 'package:flutter/material.dart';
import 'package:stpvelox/core/utils/colors.dart';
import 'package:stpvelox/core/widgets/dashboard_tile.dart';
import 'package:stpvelox/features/program/application/program_selection_screen.dart';
import 'package:stpvelox/features/sensors/presentation/pages/sensor_selection_screen.dart';
import 'package:stpvelox/features/settings/presentation/pages/settings_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
