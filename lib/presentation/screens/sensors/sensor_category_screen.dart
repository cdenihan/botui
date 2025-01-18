import 'package:flutter/material.dart';
import 'package:stpvelox/core/utils/colors.dart';
import 'package:stpvelox/domain/entities/sensor.dart';
import 'package:stpvelox/domain/entities/sensor_category.dart';
import 'package:stpvelox/presentation/widgets/grid_tile.dart';
import 'package:stpvelox/presentation/widgets/responsive_grid.dart';
import 'package:stpvelox/presentation/widgets/top_bar.dart';

class SensorCategoryScreen extends StatelessWidget {
  final SensorCategory category;
  final List<Sensor> sensor;

  const SensorCategoryScreen({super.key, required this.category, required this.sensor});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: createTopBar(context, category.name),
      body: ResponsiveGrid(
        isScrollable: false,
        children: sensor
            .map((Sensor sensor) => _buildSensorTile(context, category, sensor))
            .toList(),
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
