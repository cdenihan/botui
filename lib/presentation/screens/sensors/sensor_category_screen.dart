import 'package:flutter/material.dart';
import 'package:stpvelox/core/utils/colors.dart';
import 'package:stpvelox/data/native/kipr_plugin.dart';
import 'package:stpvelox/domain/entities/sensor.dart';
import 'package:stpvelox/domain/entities/sensor_category.dart';
import 'package:stpvelox/presentation/widgets/grid_tile.dart';
import 'package:stpvelox/presentation/widgets/responsive_grid.dart';
import 'package:stpvelox/presentation/widgets/top_bar.dart';

class SensorCategoryScreen extends StatelessWidget {
  final SensorCategory category;
  final List<Sensor> sensor;

  const SensorCategoryScreen(
      {super.key, required this.category, required this.sensor});

  Future<void> _stopAllMotors() async {
    for (int i = 0; i < 4; i++) {
      await KiprPlugin.stopMotor(i);
    }
  }

  Future<void> _disableAllServos() async {
      await KiprPlugin.fullyDisableServos();
  }

  @override
  Widget build(BuildContext context) {
    final bool isMotorCategory = category.name == 'Motor';
    final bool isServoCategory = category.name == 'Servo';

    return Scaffold(
      appBar: createTopBar(context, category.name),
      body: Column(
        children: [
          Expanded(
            child: ResponsiveGrid(
              isScrollable: true,
              children: sensor
                  .map((Sensor sensor) =>
                      _buildSensorTile(context, category, sensor))
                  .toList(),
            ),
          ),
          if (isMotorCategory)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: double.infinity,
                height: 70,
                child: ElevatedButton(
                  onPressed: _stopAllMotors,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Stop All Motors',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          if (isServoCategory)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: double.infinity,
                height: 70,
                child: ElevatedButton(
                  onPressed: _disableAllServos,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Disable All Servos',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSensorTile(
      BuildContext context, SensorCategory category, Sensor sensor) {
    return ResponsiveGridTile(
      label: sensor.name,
      icon: Icons.auto_graph,
      onPressed: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => sensor.screen,
        ),
      ),
      color: AppColors.getTileColor(category.index),
    );
  }
}